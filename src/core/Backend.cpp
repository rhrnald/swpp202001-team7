#include "Backend.h"
#include "RegisterAllocator.cpp"
#include "llvm/Analysis/TargetFolder.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/raw_os_ostream.h"
#include <string>
#include <sstream>
#include <memory>
#include <queue>

#define DEBUG false
#define DEBUG_OUT() if (DEBUG) outs()

using namespace llvm;
using namespace std;

map<BasicBlock *, set<Instruction *>> FinalUses;

// Return sizeof(T) in bytes.
unsigned getAccessSize(Type *T) {
  if (isa<PointerType>(T))
    return 8;
  else if (isa<IntegerType>(T)) {
    return T->getIntegerBitWidth() == 1 ? 1 : (T->getIntegerBitWidth() / 8);
  } else if (isa<ArrayType>(T)) {
    return getAccessSize(T->getArrayElementType()) * T->getArrayNumElements();
  }
  assert(false && "Unsupported access size type!");
}

// Converts IR::Function into another IR::Function that has registers
// transformed to stack.
class DepromoteRegisters : public InstVisitor<DepromoteRegisters> {
private:
  LLVMContext *Context;
  IntegerType *I64Ty;
  IntegerType *I1Ty;
  PointerType *I8PtrTy;

  unique_ptr<Module> ModuleToEmit;
  Function *FuncToEmit = nullptr;
  BasicBlock *BBToEmit = nullptr;
  unique_ptr<IRBuilder<TargetFolder>> Builder;
  Function *MallocFn = nullptr;

  map<Function *, Function *> FuncMap;
  map<GlobalVariable *, Constant *> GVMap; // Global var to 'inttoptr i'
  vector<pair<uint64_t, uint64_t>> GVLocs; // (Global var addr, size) info
  map<Argument *, Argument *> ArgMap;
  map<BasicBlock *, BasicBlock *> BBMap;
  map<Instruction *, AllocaInst *> RegToAllocaMap;
  map<PHINode *, AllocaInst *> PhiToTempAllocaMap;

  bool RefSet;      // indicates whether the reference sp is set
  bool RefSpilled;  // indicates whether the reference sp is spilled 

  // Register Allocation
  RegisterAllocator *RA;
  map<Instruction *, queue<unsigned>> AdventMap;  // holds next advent timesteps
  map<Instruction *, Value *> SourceToEmitMap;

  void raiseError(Instruction &I) {
    errs() << "DepromoteRegisters: Unsupported Instruction: " << I << "\n";
    abort();
  }

  Type *SrcToTgtType(Type *SrcTy) {
    if (SrcTy->isIntegerTy())
      // All integer registers are zero-extended to 64 bit registers.
      return I64Ty;
    assert(isa<PointerType>(SrcTy));
    // Pointers are also 64 bit registers, but let's keep type.
    // Assembler will take care of it.
    return SrcTy;
  }

  void checkSrcType(Type *T) {
    if (T->isIntegerTy()) {
      unsigned bw = T->getIntegerBitWidth();
      assert(bw == 1 || bw == 8 || bw == 16 || bw == 32 || bw == 64);
    } else if (T->isArrayTy()) {
      return checkSrcType(T->getArrayElementType());
    } else {
      assert(isa<PointerType>(T) || isa<ArrayType>(T));
    }
  }

  void checkTgtType(Type *T) {
    if (T->isIntegerTy()) {
      // Only 64-bit values or registers are available after depromotion.
      assert(T->getIntegerBitWidth() == 64);
    } else {
      assert(isa<PointerType>(T));
    }
  }


  string assemblyRegisterName(unsigned registerId) {
    // accept zero for Constant
    assert(0 <= registerId && registerId <= 16);
    return "__r" + to_string(registerId) + "__";
  }
  Value *emitLoadFromSrcRegister(Instruction *I, unsigned targetRegisterId) {
    assert(RegToAllocaMap.count(I));
    assert(1 <= targetRegisterId && targetRegisterId <= 16 &&
           "r1 ~ r16 are available only!");
    string RegName = assemblyRegisterName(targetRegisterId);
    auto *TgtVal = Builder->CreateLoad(RegToAllocaMap[I], RegName);
    checkTgtType(TgtVal->getType());
    return TgtVal;
  }
  void emitStoreToSrcRegister(Value *V, Instruction *I) {
    assert(RegToAllocaMap.count(I));
    checkTgtType(V->getType());
    if (auto *I = dyn_cast<Instruction>(V))
      if (I->hasName())
        assert(I->getName().startswith("__r"));
    Builder->CreateStore(V, RegToAllocaMap[I]);
  }

  // RA actions.
  void reportUse(Instruction *Source, Instruction *UserInst, bool pop=true) {
    unsigned NextAdvent = RegisterAllocator::NO_MORE_ADVENT;
    DEBUG_OUT() << "reportUse: " << Source->getName();
    if (UserInst) DEBUG_OUT() << " used by " << UserInst->getName();
    DEBUG_OUT() << ", pop = " << pop << " from " << AdventMap[Source].size() << "\n";
    if (pop) AdventMap[Source].pop();
    if (!AdventMap[Source].empty()) NextAdvent = AdventMap[Source].front();
    RA->update(Source, UserInst, NextAdvent);
  }

  void evict(RegisterAllocator::Allocation *Alloc) {
    Instruction *Victim = Alloc->Source;
    Instruction *LastUser = Alloc->LastUser;
    if (!AdventMap[Victim].empty() ||
        !LastUser || FinalUses[LastUser->getParent()].count(Victim) == 0) {
      // must spill
      emitStoreToSrcRegister(SourceToEmitMap[Victim], Victim);
    }
  }

  unsigned requestRegister(Instruction *I) {
    auto RegId = RA->request(I);
    if (RegId == 0) {
      evict(RA->evict());
      RegId = RA->request(I);
      assert(RegId && "request after an eviction should work!");
    }
    reportUse(I, nullptr, false);
    return RegId;
  }

  unsigned getRegister(Instruction *I) {
    auto RegId = RA->get(I);
    if (RegId == 0) {
      RegId = requestRegister(I);
      // fill
      SourceToEmitMap[I] = emitLoadFromSrcRegister(I, RegId);
    }
    return RegId;
  }

  void clearRA() {
    RegisterAllocator::Allocation *Alloc;
    while ((Alloc = RA->evict())) {
      evict(Alloc);
    }
  }

  // Encode the value of V.
  // If V is an argument, return the corresponding argN argument.
  // If V is a constant, just return it.
  // If V is an instruction, it emits load from the temporary alloca.
  Value *translateSrcOperandToTgt(Value *V, Instruction *U, unsigned *AllocId) {
    return translateSrcOperandToTgt(V, U, 0, AllocId);
  }
  Value *translateSrcOperandToTgt(Value *V, Instruction *U, unsigned OperandId,
                                  unsigned *AllocatedId=nullptr) {
    checkSrcType(V->getType());

    if (auto *A = dyn_cast<Argument>(V)) {
      // Nothing to emit.
      // Returns one of "arg1", "arg2", ...
      assert(ArgMap.count(A));
      return ArgMap[A];

    } else if (auto *CI = dyn_cast<ConstantInt>(V)) {
      return ConstantInt::get(I64Ty, CI->getZExtValue());

    } else if (isa<ConstantPointerNull>(V)) {
      return V;

    } else if (isa<UndefValue>(V)) {
      return UndefValue::get(I64Ty);

    } else if (auto *GV = dyn_cast<GlobalVariable>(V)) {
      assert(GVMap.count(GV));
      return GVMap[GV];

    } else if (auto *I = dyn_cast<Instruction>(V)) {
      if (AllocatedId) {
        *AllocatedId = getRegister(I);
        reportUse(I, U);
        return SourceToEmitMap[I];
      }
      else {
        if (RA->get(I)) {
          reportUse(I, U);
          emitStoreToSrcRegister(SourceToEmitMap[I], I);
        }
        if (OperandId > 3) {
          // handling function calls
          if (RA->requestTempRegister(OperandId)) {
            RA->giveUpTempRegister(OperandId);
          }
          else {
            evict(RA->evict(OperandId));
          }
        }
        return emitLoadFromSrcRegister(I, OperandId);
      }

    } else {
      assert(false && "Unknown instruction type!");
    }
  }

public:
  Module *getDepromotedModule() const
  { return ModuleToEmit.get(); }

  void visitModule(Module &M) {
    Context = &M.getContext();
    ModuleToEmit = unique_ptr<Module>(new Module("DepromotedModule", *Context));
    I64Ty = IntegerType::getInt64Ty(*Context);
    I1Ty = IntegerType::getInt1Ty(*Context);
    I8PtrTy = PointerType::getInt8PtrTy(*Context);
    ModuleToEmit->setDataLayout(M.getDataLayout());

    uint64_t GVOffset = 20480;
    FunctionType *MallocTy = nullptr;
    for (auto &G : M.global_objects()) {
      if (auto *F = dyn_cast<Function>(&G)) {
        SmallVector<Type *, 16> FuncArgTys;

        // Map arguments to arg1, arg2, .. registers.
        for (auto I = F->arg_begin(), E = F->arg_end(); I != E; ++I) {
          Argument *A = &*I;
          checkSrcType(A->getType());
          FuncArgTys.push_back(SrcToTgtType(A->getType()));
        }

        // A function returns either i64 or a pointer.
        auto *RetTy = F->getReturnType()->isVoidTy() ? I64Ty :
                        SrcToTgtType(F->getReturnType());
        FunctionType *FTy = FunctionType::get(RetTy, FuncArgTys, false);
        FuncMap[F] = Function::Create(FTy, Function::ExternalLinkage,
                                      F->getName(), *ModuleToEmit);

        if (F->getName() == "malloc") {
          assert(FuncArgTys.size() == 1 && FuncArgTys[0] == I64Ty &&
                 "malloc has one argument");
          assert(RetTy->isPointerTy() && "malloc should return pointer");
          MallocTy = dyn_cast<FunctionType>(F->getValueType());
          MallocFn = FuncMap[F];
        }

      } else {
        GlobalVariable *GVSrc = dyn_cast<GlobalVariable>(&G);
        assert(GVSrc &&
               "A global object is neither function nor global variable");

        unsigned sz = (getAccessSize(GVSrc->getValueType()) + 7) / 8 * 8;
        auto *CI = ConstantInt::get(I64Ty, GVOffset);
        GVMap[GVSrc] = ConstantExpr::getIntToPtr(CI, GVSrc->getType());
        GVLocs.emplace_back(GVOffset, sz);

        GVOffset += sz;
      }
    }

    if (!MallocFn) {
      MallocTy = FunctionType::get(I8PtrTy, {I64Ty}, false);
      MallocFn = Function::Create(MallocTy, Function::ExternalLinkage,
                                  "malloc", *ModuleToEmit);
    }
  }

  void visitFunction(Function &F) {
    assert(FuncMap.count(&F));
    FuncToEmit = FuncMap[&F];

    RefSet = false;
    RefSpilled = false;
    RA = new RegisterAllocator();

    // Fill source argument -> target argument map.
    for (unsigned i = 0, e = F.arg_size(); i < e; ++i) {
      auto *Arg = FuncToEmit->getArg(i);
      Arg->setName("__arg" + to_string(i + 1) + "__");
      checkTgtType(Arg->getType());
      ArgMap[F.getArg(i)] = Arg;
    }

    // Fill source BB -> target BB map.
    for (auto &BB : F) {
      BBMap[&BB] = BasicBlock::Create(*Context, "." + BB.getName(), FuncToEmit);
    }
  }

  void visitBasicBlock(BasicBlock &BB) {
    assert(BBMap.count(&BB));
    BBToEmit = BBMap[&BB];

    Function *SourceFunc = BB.getParent();
    if (&BB == &SourceFunc->getEntryBlock()) {
      // Let's create an alloca for each register..!
      IRBuilder<> IB(BBToEmit);
      for (inst_iterator I = inst_begin(*SourceFunc), E = inst_end(*SourceFunc);
           I != E; ++I) {
        if (I->hasName()) {
          auto *Ty = I->getType();
          checkSrcType(Ty);
          RegToAllocaMap[&*I] =
            IB.CreateAlloca(SrcToTgtType(Ty), nullptr, I->getName() + "_slot");
          if (auto *PN = dyn_cast<PHINode>(&*I)) {
            PhiToTempAllocaMap[PN] =
              IB.CreateAlloca(SrcToTgtType(Ty), nullptr,
                              I->getName() + "_phi_tmp_slot");
          }
        }
      }
      if (FuncToEmit->getName() == "main") {
        // Let's create a malloc for each global var.
        // This is dummy register.
        string Reg1 = assemblyRegisterName(1);
        for (auto &[_, Size] : GVLocs) {
          auto *ArgTy =
            dyn_cast<IntegerType>(MallocFn->getFunctionType()->getParamType(0));
          assert(ArgTy);
          IB.CreateCall(MallocFn, {ConstantInt::get(ArgTy, Size)}, Reg1);
        }
      }
    }
    DEBUG_OUT() << BB.getName() << ":\n";

    AdventMap.clear();
    SourceToEmitMap.clear();
    unsigned timestep = 0;
    for (auto &I : BB) {
      if (!isa<PHINode>(&I)) {
        for (unsigned i = 0, e = I.getNumOperands(); i < e; ++i) {
          Instruction *Op = dyn_cast<Instruction>(I.getOperand(i));
          if (Op) {
            AdventMap[Op].push(timestep);
          }
        }
      }
      if (I.isTerminator() && !isa<ReturnInst>(&I)) {
        for (unsigned i = 0, e = I.getNumSuccessors(); i < e; ++i) {
          for (auto &Phi : I.getSuccessor(i)->phis()) {
            auto *InPhi = dyn_cast<Instruction>(Phi.getIncomingValueForBlock(&BB));
            if (InPhi) {
              AdventMap[InPhi].push(timestep);
            }
          }
        }
      }
      DEBUG_OUT() << timestep << ": " << I << "\n";
      timestep += 1;
    }
    if (DEBUG) {
      outs() << "AdventMap:\n";
      for (auto &[I, _Q] : AdventMap) {
        queue<unsigned> Q = _Q;
        outs() << I->getName() << ":";
        while (!Q.empty()) {
          outs() << " " << Q.front();
          Q.pop();
        }
        outs() << "\n";
      }
      outs() << "FinalUses:\n";
      for (auto I : FinalUses[&BB]) {
        outs() << " - " << I->getName() << "\n";
      }
      outs() << "\n";
    }

    Builder = make_unique<IRBuilder<TargetFolder>>(BBToEmit,
        TargetFolder(ModuleToEmit->getDataLayout()));
    
    DEBUG_OUT() << "BB visit done\n";
  }

  // Unsupported instruction goes here.
  void visitInstruction(Instruction &I) {
    raiseError(I);
  }

  // ---- Memory operations ----
  void visitAllocaInst(AllocaInst &I) {
    // NOTE: It is assumed that allocas are only in the entry block!
    assert(I.getParent() == &I.getFunction()->getEntryBlock() &&
           "Alloca is not in the entry block; this algorithm wouldn't work");

    checkSrcType(I.getAllocatedType());
    // This will be lowered to 'r1 = add sp, <offset>'
    auto *NewAllc = Builder->CreateAlloca(I.getAllocatedType(),
                                          I.getArraySize(), assemblyRegisterName(1));
    emitStoreToSrcRegister(NewAllc, &I);
  }
  void visitLoadInst(LoadInst &LI) {
    checkSrcType(LI.getType());
    unsigned RegId = 0;
    auto *TgtPtrOp = translateSrcOperandToTgt(LI.getPointerOperand(), &LI, &RegId);
    auto *LoadedTy = TgtPtrOp->getType()->getPointerElementType();
    Value *LoadedVal = nullptr;

    RegId = requestRegister(&LI);
    string Reg = assemblyRegisterName(RegId);
    if (LoadedTy->isIntegerTy() && LoadedTy->getIntegerBitWidth() < 64) {
      // Need to zext.
      // before_zext__ will be recognized by the assembler & merged with 64-bit
      // load to a smaller load.
      string RegBeforeZext = Reg + "before_zext__";
      LoadedVal = Builder->CreateLoad(TgtPtrOp, RegBeforeZext);
      LoadedVal = Builder->CreateZExt(LoadedVal, I64Ty, Reg);
    } else {
      LoadedVal = Builder->CreateLoad(TgtPtrOp, Reg);
    }
    checkTgtType(LoadedVal->getType());
    SourceToEmitMap[&LI] = LoadedVal;
  }
  void visitStoreInst(StoreInst &SI) {
    auto *Ty = SI.getValueOperand()->getType();
    checkSrcType(Ty);

    auto *TgtValOp = translateSrcOperandToTgt(SI.getValueOperand(), &SI, 1);
    checkTgtType(TgtValOp->getType());
    if (TgtValOp->getType() != Ty) {
      // 64bit -> Ty bit trunc is needed.
      // after_trunc__ will be recognized by the assembler & merged with 64-bit
      // store into a smaller store.
      string R0Trunc = assemblyRegisterName(1) + "after_trunc__";
      assert(Ty->isIntegerTy() && TgtValOp->getType()->isIntegerTy());
      TgtValOp = Builder->CreateTrunc(TgtValOp, Ty, R0Trunc);
    }

    auto *TgtPtrOp = translateSrcOperandToTgt(SI.getPointerOperand(), &SI, 2);
    Builder->CreateStore(TgtValOp, TgtPtrOp);
  }

  // ---- Arithmetic operations ----
  void visitBinaryOperator(BinaryOperator &BO) {
    auto *Ty = BO.getType();
    checkSrcType(Ty);

    auto Opcode = BO.getOpcode();
    switch(Opcode) {
    case Instruction::UDiv:
    case Instruction::URem:
    case Instruction::Mul:
    case Instruction::Shl:
    case Instruction::LShr:
    case Instruction::And:
    case Instruction::Or:
    case Instruction::Xor:
    case Instruction::Add:
    case Instruction::Sub:
    case Instruction::SDiv:
    case Instruction::SRem:
    case Instruction::AShr:
      break;
    default: raiseError(BO); break;
    }

    auto *Op1 = translateSrcOperandToTgt(BO.getOperand(0), &BO, 1);
    auto *Op2 = translateSrcOperandToTgt(BO.getOperand(1), &BO, 2);
    auto *Op1Trunc = Builder->CreateTruncOrBitCast(Op1, Ty,
        assemblyRegisterName(1) + "after_trunc__");
    auto *Op2Trunc = Builder->CreateTruncOrBitCast(Op2, Ty,
        assemblyRegisterName(2) + "after_trunc__");

    Value *Res = nullptr;
    if (Ty != I64Ty) {
      Res = Builder->CreateBinOp(Opcode, Op1Trunc, Op2Trunc,
                                 assemblyRegisterName(1) + "before_zext__");
      Res = Builder->CreateZExt(Res, I64Ty, assemblyRegisterName(1));
    } else {
      Res = Builder->CreateBinOp(Opcode, Op1Trunc, Op2Trunc,
                                 assemblyRegisterName(1));
    }
    emitStoreToSrcRegister(Res, &BO);
  }
  void visitICmpInst(ICmpInst &II) {
    auto *OpTy = II.getOperand(0)->getType();
    checkSrcType(II.getType());
    checkSrcType(OpTy);

    auto *Op1 = translateSrcOperandToTgt(II.getOperand(0), &II, 1);
    auto *Op2 = translateSrcOperandToTgt(II.getOperand(1), &II, 2);
    auto *Op1Trunc = Builder->CreateTruncOrBitCast(Op1, OpTy,
        assemblyRegisterName(1) + "after_trunc__");
    auto *Op2Trunc = Builder->CreateTruncOrBitCast(Op2, OpTy,
        assemblyRegisterName(2) + "after_trunc__");

    // i1 -> i64 zext
    string Reg = assemblyRegisterName(1);
    string Reg_before_zext = Reg + "before_zext__";
    emitStoreToSrcRegister(
      Builder->CreateZExt(
        Builder->CreateICmp(II.getPredicate(), Op1Trunc, Op2Trunc,
        Reg_before_zext), I64Ty, Reg),
      &II);
  }
  void visitSelectInst(SelectInst &SI) {
    auto *Ty = SI.getType();
    auto *OpCond = translateSrcOperandToTgt(SI.getOperand(0), &SI, 1);
    assert(OpCond->getType() == I64Ty);
    // i64 -> i1 trunc
    string R1Trunc = assemblyRegisterName(1) + "after_trunc__";
    OpCond = Builder->CreateTrunc(OpCond, I1Ty, R1Trunc);

    auto *OpLeft = translateSrcOperandToTgt(SI.getOperand(1), &SI, 2);
    auto *OpRight = translateSrcOperandToTgt(SI.getOperand(2), &SI, 3);
    emitStoreToSrcRegister(
      Builder->CreateSelect(OpCond, OpLeft, OpRight, assemblyRegisterName(1)),
      &SI);
  }
  void visitGetElementPtrInst(GetElementPtrInst &GEPI) {
    // Make it look like 'gep i8* ptr, i'
    auto *PtrOp = translateSrcOperandToTgt(GEPI.getPointerOperand(), &GEPI, 1);
    auto *PtrI8Op = Builder->CreateBitCast(PtrOp, I8PtrTy,
                                           assemblyRegisterName(1));
    unsigned Idx = 1;
    Type *CurrentPtrTy = GEPI.getPointerOperandType();

    while (Idx <= GEPI.getNumIndices()) {
      assert(GEPI.getOperand(Idx)->getType() == I64Ty &&
             "We only accept getelementptr with indices of 64 bits.");
      auto *IdxValue = translateSrcOperandToTgt(GEPI.getOperand(Idx), &GEPI, 2);

      auto *ElemTy = CurrentPtrTy->getPointerElementType();
      unsigned sz = getAccessSize(ElemTy);
      if (sz != 1) {
        assert(sz != 0);
        IdxValue = Builder->CreateMul(IdxValue, ConstantInt::get(I64Ty, sz),
                                      assemblyRegisterName(2));
      }

      bool isZero = false;
      if (auto *CI = dyn_cast<ConstantInt>(IdxValue))
        isZero = CI->getZExtValue() == 0;

      if (!isZero)
        PtrI8Op = Builder->CreateGEP(PtrI8Op, IdxValue, assemblyRegisterName(1));

      if (!ElemTy->isArrayTy()) {
        CurrentPtrTy = nullptr;
        assert(Idx == GEPI.getNumIndices());
      } else
        CurrentPtrTy = PointerType::get(ElemTy->getArrayElementType(), 0);
      ++Idx;
    }

    PtrOp = Builder->CreateBitCast(PtrI8Op, GEPI.getType(),
                                   assemblyRegisterName(1));
    emitStoreToSrcRegister(PtrOp, &GEPI);
  }

  // ---- Casts ----
  void visitBitCastInst(BitCastInst &BCI) {
    auto *Op = translateSrcOperandToTgt(BCI.getOperand(0), &BCI, 1);
    auto *CastedOp = Builder->CreateBitCast(Op, BCI.getType(),
        assemblyRegisterName(1));
    emitStoreToSrcRegister(CastedOp, &BCI);
  }
  void visitSExtInst(SExtInst &SI) {
    // Get the sign bit.
    uint64_t bw = SI.getOperand(0)->getType()->getIntegerBitWidth();
    auto *Op = translateSrcOperandToTgt(SI.getOperand(0), &SI, 1);
    if (bw < 64) {
      Op =
        Builder->CreateMul(Op, ConstantInt::get(I64Ty, (1llu << (64 - bw))),
                          assemblyRegisterName(1));
      Op =
        Builder->CreateAShr(Op, 64 - bw, assemblyRegisterName(1));
    }
    emitStoreToSrcRegister(Op, &SI);
  }
  void visitZExtInst(ZExtInst &ZI) {
    // Everything is zero-extended by default.
    auto *Op = translateSrcOperandToTgt(ZI.getOperand(0), &ZI, 1);
    emitStoreToSrcRegister(Op, &ZI);
  }
  void visitTruncInst(TruncInst &TI) {
    auto *Op = translateSrcOperandToTgt(TI.getOperand(0), &TI, 1);
    uint64_t Divisor = (1llu << (TI.getDestTy()->getIntegerBitWidth()));
    emitStoreToSrcRegister(
      Builder->CreateURem(Op, ConstantInt::get(I64Ty, Divisor), 
                            assemblyRegisterName(1)),
      &TI);
  }
  void visitPtrToIntInst(PtrToIntInst &PI) {
    auto *Op = translateSrcOperandToTgt(PI.getOperand(0), &PI, 1);
    emitStoreToSrcRegister(
      Builder->CreatePtrToInt(Op, I64Ty, assemblyRegisterName(1)),
      &PI);
  }
  void visitIntToPtrInst(IntToPtrInst &II) {
    auto *Op = translateSrcOperandToTgt(II.getOperand(0), &II, 1);
    emitStoreToSrcRegister(
      Builder->CreateIntToPtr(Op, II.getType(), assemblyRegisterName(1)),
      &II);
  }

  // ---- Call ----
  void visitCallInst(CallInst &CI) {
    auto *CalledF = CI.getCalledFunction();
    assert(FuncMap.count(CalledF));
    auto *CalledFInTgt = FuncMap[CalledF];

    if (!RefSet && CalledF->getName() == SetRefName) {
      RefSet = true;
      // Now the reference sp is set. Prepare for it!
      unsigned GotId = RA->requestTempRegister(RefSPId);
      if (GotId == 0) {
        evict(RA->evict(RefSPId));
        GotId = RA->requestTempRegister(RefSPId);
      }
    }
    else if (RefSet && CalledF->getName() == SpillRefName) {
      // The reference sp is spilled for the moment. Enjoy!
      // However, don't forget that RefSet is still true!
      RefSpilled = true;
    }
    else if (RefSpilled) {
      RA->giveUpTempRegister(RefSPId);
    }

    SmallVector<Value *, 16> Args;
    unsigned Idx = 1;
    for (auto I = CI.arg_begin(), E = CI.arg_end(); I != E; ++I) {
      Args.emplace_back(translateSrcOperandToTgt(*I, &CI, Idx));
      if(!isa<Constant>(&*I)) ++Idx;  // constants don't need registers
    }
    if (CI.hasName()) {
      Value *Res = Builder->CreateCall(CalledFInTgt, Args,
                                       assemblyRegisterName(1));
      emitStoreToSrcRegister(Res, &CI);
    } else {
      Builder->CreateCall(CalledFInTgt, Args);
    }

    if (RefSpilled && CalledF->getName() != SpillRefName) {
      if (RA->requestTempRegister(RefSPId) == 0) {
        evict(RA->evict(RefSPId));
        RA->requestTempRegister(RefSPId);
      }
      RefSpilled = false;
    }
  }

  // ---- Terminators ----
  void visitReturnInst(ReturnInst &RI) {
    if (auto *RetVal = RI.getReturnValue())
      Builder->CreateRet(translateSrcOperandToTgt(RetVal, &RI, 1));
    else
      // To `ret i64 0`
      Builder->CreateRet(
        ConstantInt::get(IntegerType::getInt64Ty(*Context), 0));
  }
  void visitBranchInst(BranchInst &BI) {
    for (auto *Succ : BI.successors())
      processPHIsInSuccessor(Succ, BI.getParent(), &BI);

    if (BI.isUnconditional()) {
      clearRA();
      Builder->CreateBr(BBMap[BI.getSuccessor(0)]);
    } else {
      auto *CondOp = translateSrcOperandToTgt(BI.getCondition(), &BI, 1);
      // to_i1__ is recognized by assembler.
      string regname = assemblyRegisterName(1) + "to_i1__";
      auto *Condi1 = Builder->CreateICmpNE(CondOp, ConstantInt::get(I64Ty, 0),
                                           regname);
      clearRA();
      Builder->CreateCondBr(Condi1, BBMap[BI.getSuccessor(0)],
                                    BBMap[BI.getSuccessor(1)]);
    }
  }
  void visitSwitchInst(SwitchInst &SI) {
    // Emit phi's values first!
    for (unsigned i = 0, e = SI.getNumSuccessors(); i != e; ++i)
      processPHIsInSuccessor(SI.getSuccessor(i), SI.getParent(), &SI);

    auto *TgtCond = translateSrcOperandToTgt(SI.getCondition(), &SI, 1);
    vector<pair<ConstantInt *, BasicBlock *>> TgtCases;
    for (auto I = SI.case_begin(), E = SI.case_end(); I != E; ++I) {
      auto *C = ConstantInt::get(I64Ty, I->getCaseValue()->getZExtValue());
      TgtCases.emplace_back(C, BBMap[I->getCaseSuccessor()]);
    }

    clearRA();
    
    auto *TgtSI = Builder->CreateSwitch(TgtCond, BBMap[SI.getDefaultDest()],
                                        SI.getNumCases());
    for (auto [CaseVal, CaseDest] : TgtCases)
      TgtSI->addCase(CaseVal, CaseDest);
  }

  void processPHIsInSuccessor(BasicBlock *Succ, BasicBlock *BBFrom, Instruction *U) {
    // PHIs can use each other:
    // ex)
    // loop:
    //   x = phi [0, entry] [y, loop] // y from the prev. iteration
    //   y = phi [1, entry] [x, loop] // x from the prev. iteration
    //   ...
    //   br label %loop
    //
    // This should be lowered into:
    // loop:
    //   (value x is 'load x_phi_tmp_slot')  -->  processed by visitPHINode
    //   (value y is 'load y_phi_tmp_slot')  
    //   ...
    //   store y, x_phi_tmp_slot   -->  processed by processPHIsInSuccessor
    //   store x, y_phi_tmp_slot
    for (auto &PHI : Succ->phis()) {
      auto *V =
        translateSrcOperandToTgt(PHI.getIncomingValueForBlock(BBFrom), U, 1);
      checkTgtType(V->getType());
      assert(!isa<Instruction>(V) || !V->hasName() ||
             V->getName().startswith("__r"));
      assert(PhiToTempAllocaMap.count(&PHI));
      Builder->CreateStore(V, PhiToTempAllocaMap[&PHI]);
    }
  }

  // ---- Phi ----
  void visitPHINode(PHINode &PN) {
    // PHI: Absorbing the tmp_slot
    assert(RegToAllocaMap.count(&PN));
    assert(PhiToTempAllocaMap.count(&PN));
    Builder->CreateStore(
      Builder->CreateLoad(PhiToTempAllocaMap[&PN], assemblyRegisterName(1)),
      RegToAllocaMap[&PN]);
  }

  // ---- For Debugging -----
  void dumpToStdOut() {
    outs() << *ModuleToEmit;
  }
};


// A simple namer. :)
class InstNamer : public InstVisitor<InstNamer> {
public:
  void visitFunction(Function &F) {
    for (auto &Arg : F.args())
      if (!Arg.hasName())
        Arg.setName("arg");

    for (BasicBlock &BB : F) {
      if (!BB.hasName())
        BB.setName(&F.getEntryBlock() == &BB ? "entry" : "bb");

      for (Instruction &I : BB)
        if (!I.hasName() && !I.getType()->isVoidTy())
          I.setName("tmp");
    }
  }
};

class ConstExprToInsts : public InstVisitor<ConstExprToInsts> {
  Instruction *ConvertCEToInst(ConstantExpr *CE, Instruction *InsertBefore) {
    auto *NewI = CE->getAsInstruction();
    NewI->insertBefore(InsertBefore);
    NewI->setName("from_constexpr");
    visitInstruction(*NewI);
    return NewI;
  }
public:
  void visitInstruction(Instruction &I) {
    for (unsigned Idx = 0; Idx < I.getNumOperands(); ++Idx) {
      if (auto *CE = dyn_cast<ConstantExpr>(I.getOperand(Idx))) {
        I.setOperand(Idx, ConvertCEToInst(CE, &I));
      }
    }
  }
};

class AllocaBytesHandler : public InstVisitor<AllocaBytesHandler> {
private:
  Function *SetRefFn, *SpillRefFn, *FreeBytesFn;
public:
  AllocaBytesHandler(Module &M) {
    auto RefFTy = FunctionType::get(Type::getVoidTy(M.getContext()), false);
    SetRefFn = Function::Create(RefFTy, Function::ExternalLinkage, SetRefName, M);
    SpillRefFn = Function::Create(RefFTy, Function::ExternalLinkage, SpillRefName, M);
    FreeBytesFn = Function::Create(FunctionType::get(Type::getVoidTy(M.getContext()),
                                    {Type::getInt64Ty(M.getContext())}, false), 
                                    Function::ExternalLinkage, FreeBytesName, M);
  }

  void visitFunction(Function &F) {
    bool ABFound = false;
    for (auto &BB : F) {
      bool FreeInThisBlock = true;
      stack<Value *> SizeVector;
      for (auto &I : BB) {
        if (auto CI = dyn_cast<CallInst>(&I)) {
          Function *CalledFn = CI->getCalledFunction();
          if (CalledFn->getName() == AllocaBytesName) {
            if (!ABFound) {
              CallInst::Create(SetRefFn)->insertBefore(CI);
              ABFound = true;
            }
            if (FreeInThisBlock) {
              ConstantInt *FITB;
              assert((FITB = dyn_cast<ConstantInt>(CI->getArgOperand(1))) &&
                     "free_in_this_block should be constant!");
              if (FITB->isZero()) FreeInThisBlock = false;
              else {
                SizeVector.push(CI->getArgOperand(0));
              }
            }
          }
          else if (ABFound && CI->arg_size() == 16) {
            bool NoConstant = true;
            for (auto i = CI->arg_begin(), e = CI->arg_end(); i != e; ++i) {
              if (isa<Constant>(&*i)) {
                NoConstant = false;
                break;
              }
            }
            if (NoConstant) {
              CallInst::Create(SpillRefFn)->insertBefore(CI);
            }
          }
        }
      }
      if (FreeInThisBlock && !SizeVector.empty()) {
        Value *Size = SizeVector.top();
        SizeVector.pop();
        while (!SizeVector.empty()) {
          Size = BinaryOperator::CreateNUWAdd(Size, SizeVector.top(), "free_size");
          SizeVector.pop();
        }
        CallInst::Create(FreeBytesFn, {Size})->insertBefore(&*BB.rbegin());
      }
    }
  }
};

// Following are the cases of FinalUses so far.
// 1. an Instruction is declared and used only in one BasicBlock.
// 2. an Instruction is used in a ReturnBlock.
class RAHelper {
public:
  void visit(Function &F) {
    map<Instruction *, set<BasicBlock *>> AdventBlocks;
    for (auto &BB : F) {
      bool ReturnBlock = isa<ReturnInst>(BB.getTerminator());
      for (auto &I : BB) {
        if (I.hasName()) AdventBlocks[&I].insert(&BB);
        PHINode *Phi = dyn_cast<PHINode>(&I);
        for (unsigned i = 0, e = I.getNumOperands(); i < e; ++i) {
          auto *Op = dyn_cast<Instruction>(I.getOperand(i));
          if (Op) {
            if (Phi) {
              AdventBlocks[Op].insert(Phi->getIncomingBlock(i));
            }
            else {
              AdventBlocks[Op].insert(&BB);
              if (ReturnBlock) FinalUses[&BB].insert(Op);
            }
          }
        }
      }
    }
    for (auto &[I, S] : AdventBlocks) {
      if(S.size() == 1) {
        FinalUses[*S.begin()].insert(I);
      }
    }
  }
};

PreservedAnalyses Backend::run(Module &M, ModuleAnalysisManager &MAM) {
  if (verifyModule(M, &errs(), nullptr))
    exit(1);

  // First, name all instructions / arguments / etc.
  InstNamer Namer;
  Namer.visit(M);

  // Second, convert known constant expressions to instructions.
  ConstExprToInsts CEI;
  CEI.visit(M);

  // Second and half, handle AllocaBytes
  AllocaBytesHandler ABH(M);
  ABH.visit(M);

  // Second and three quaters, check FinalUser
  RAHelper RAH;
  for (auto &F : M) RAH.visit(F);

  // Third, depromote registers to alloca & canonicalize iN types into i64.
  DepromoteRegisters Deprom;
  Deprom.visit(M);

  if (verifyModule(M, &errs(), nullptr)) {
    errs() << "BUG: DepromoteRegisters created an ill-formed module!\n";
    errs() << M;
    exit(1);
  }

  // For debugging, this will print the depromoted module.
  if (printDepromotedModule)
    Deprom.dumpToStdOut();

  // Now, let's emit assembly!
  error_code EC;
  raw_ostream *os =
    outputFile == "-" ? &outs() : new raw_fd_ostream(outputFile, EC);

  if (EC) {
    errs() << "Cannot open file: " << outputFile << "\n";
    exit(1);
  }

  AssemblyEmitter Emitter(os);
  Emitter.run(Deprom.getDepromotedModule());

  if (os != &outs()) delete os;

  return PreservedAnalyses::all();
}
