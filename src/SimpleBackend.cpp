#include "SimpleBackend.h"
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

using namespace llvm;
using namespace std;


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
  unique_ptr<IRBuilder<>> Builder;

  map<Function *, Function *> FuncMap;
  map<GlobalVariable *, GlobalVariable *> GVMap;
  map<Argument *, Argument *> ArgMap;
  map<BasicBlock *, BasicBlock *> BBMap;
  map<Instruction *, AllocaInst *> RegToAllocaMap;

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
    assert(1 <= registerId && registerId <= 16);
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

  // Encode the value of V.
  // If V is an argument, return the corresponding argN argument.
  // If V is a constant, just return it.
  // If V is an instruction, it emits load from the temporary alloca.
  Value *translateSrcOperandToTgt(Value *V, unsigned OperandId) {
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

    } else if (auto *GV = dyn_cast<GlobalVariable>(V)) {
      assert(GVMap.count(GV));
      return GVMap[GV];

    } else if (auto *I = dyn_cast<Instruction>(V)) {
      return emitLoadFromSrcRegister(I, OperandId);

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

      } else {
        GlobalVariable *GVSrc = dyn_cast<GlobalVariable>(&G);
        assert(GVSrc);
        // Clone the global variable into tgt.
        auto *GVTgt = new GlobalVariable(GVSrc->getValueType(),
            GVSrc->isConstant(), GVSrc->getLinkage(), GVSrc->getInitializer(),
            GVSrc->getName());
        ModuleToEmit->getGlobalList().push_back(GVTgt);
        GVMap[GVSrc] = GVTgt;
      }
    }
  }

  void visitFunction(Function &F) {
    assert(FuncMap.count(&F));
    FuncToEmit = FuncMap[&F];

    // Fill source argument -> target argument map.
    for (unsigned i = 0, e = F.arg_size(); i < e; ++i) {
      auto *Arg = FuncToEmit->getArg(i);
      Arg->setName("__arg" + to_string(i + 1) + "__");
      checkTgtType(Arg->getType());
      ArgMap[F.getArg(i)] = Arg;
    }

    // Fill source BB -> target BB map.
    for (auto &BB : F) {
      BBMap[&BB] = BasicBlock::Create(*Context, BB.getName(), FuncToEmit);
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
        }
      }
    }

    Builder = make_unique<IRBuilder<>>(BBToEmit);
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
    auto *TgtPtrOp = translateSrcOperandToTgt(LI.getPointerOperand(), 1);
    auto *LoadedTy = TgtPtrOp->getType()->getPointerElementType();
    Value *LoadedVal = nullptr;

    if (LoadedTy->isIntegerTy() && LoadedTy->getIntegerBitWidth() < 64) {
      // Need to zext.
      // before_zext__ will be recognized by the assembler & merged with 64-bit
      // load to a smaller load.
      string Reg = assemblyRegisterName(1);
      string RegBeforeZext = Reg + "before_zext__";
      LoadedVal = Builder->CreateLoad(TgtPtrOp, RegBeforeZext);
      LoadedVal = Builder->CreateZExt(LoadedVal, I64Ty, Reg);
    } else {
      LoadedVal = Builder->CreateLoad(TgtPtrOp, assemblyRegisterName(1));
    }
    checkTgtType(LoadedVal->getType());
    emitStoreToSrcRegister(LoadedVal, &LI);
  }
  void visitStoreInst(StoreInst &SI) {
    auto *Ty = SI.getValueOperand()->getType();
    checkSrcType(Ty);

    auto *TgtValOp = translateSrcOperandToTgt(SI.getValueOperand(), 1);
    checkTgtType(TgtValOp->getType());
    if (TgtValOp->getType() != Ty) {
      // 64bit -> Ty bit trunc is needed.
      // after_trunc__ will be recognized by the assembler & merged with 64-bit
      // store into a smaller store.
      string R0Trunc = assemblyRegisterName(1) + "after_trunc__";
      assert(Ty->isIntegerTy() && TgtValOp->getType()->isIntegerTy());
      TgtValOp = Builder->CreateTrunc(TgtValOp, Ty, R0Trunc);
    }

    auto *TgtPtrOp = translateSrcOperandToTgt(SI.getPointerOperand(), 2);
    Builder->CreateStore(TgtValOp, TgtPtrOp);
  }

  // ---- Arithmetic operations ----
  void visitBinaryOperator(BinaryOperator &BO) {
    auto *Ty = BO.getType();
    checkSrcType(Ty);

    switch(BO.getOpcode()) {
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

    auto *Op1 = translateSrcOperandToTgt(BO.getOperand(0), 1);
    auto *Op2 = translateSrcOperandToTgt(BO.getOperand(1), 2);
    auto *Op1Trunc = Builder->CreateTruncOrBitCast(Op1, Ty,
        assemblyRegisterName(1) + "after_trunc__");
    auto *Op2Trunc = Builder->CreateTruncOrBitCast(Op2, Ty,
        assemblyRegisterName(2) + "after_trunc__");

    Value *Res = nullptr;
    if (BO.getType() != I64Ty) {
      Res = Builder->CreateBinOp(BO.getOpcode(), Op1Trunc, Op2Trunc,
                                 assemblyRegisterName(1) + "before_zext__");
      Res = Builder->CreateZExt(Res, I64Ty, assemblyRegisterName(1));
    } else {
      Res = Builder->CreateBinOp(BO.getOpcode(), Op1Trunc, Op2Trunc,
                                 assemblyRegisterName(1));
    }
    emitStoreToSrcRegister(Res, &BO);
  }
  void visitICmpInst(ICmpInst &II) {
    auto *OpTy = II.getOperand(0)->getType();
    checkSrcType(II.getType());
    checkSrcType(OpTy);

    auto *Op1 = translateSrcOperandToTgt(II.getOperand(0), 1);
    auto *Op2 = translateSrcOperandToTgt(II.getOperand(1), 2);
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
    auto *OpCond = translateSrcOperandToTgt(SI.getOperand(0), 1);
    assert(OpCond->getType() == I64Ty);
    // i64 -> i1 trunc
    string R1Trunc = assemblyRegisterName(1) + "after_trunc__";
    OpCond = Builder->CreateTrunc(OpCond, I1Ty, R1Trunc);

    auto *OpLeft = translateSrcOperandToTgt(SI.getOperand(1), 2);
    auto *OpRight = translateSrcOperandToTgt(SI.getOperand(2), 3);
    emitStoreToSrcRegister(
      Builder->CreateSelect(OpCond, OpLeft, OpRight, assemblyRegisterName(1)),
      &SI);
  }
  void visitGetElementPtrInst(GetElementPtrInst &GEPI) {
    // Make it look like 'gep i8* ptr, i'
    auto *PtrOp = translateSrcOperandToTgt(GEPI.getPointerOperand(), 1);
    auto *PtrI8Op = Builder->CreateBitCast(PtrOp, I8PtrTy,
                                           assemblyRegisterName(1));
    unsigned Idx = 1;
    Type *CurrentPtrTy = GEPI.getPointerOperandType();

    while (Idx <= GEPI.getNumIndices()) {
      assert(GEPI.getOperand(Idx)->getType() == I64Ty &&
             "We only accept getelementptr with indices of 64 bits.");
      auto *IdxValue = translateSrcOperandToTgt(GEPI.getOperand(Idx), 2);

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
    auto *Op = translateSrcOperandToTgt(BCI.getOperand(0), 1);
    auto *CastedOp = Builder->CreateBitCast(Op, BCI.getType(),
        assemblyRegisterName(1));
    emitStoreToSrcRegister(CastedOp, &BCI);
  }
  void visitSExtInst(SExtInst &SI) {
    // Get the sign bit.
    uint64_t bw = SI.getOperand(0)->getType()->getIntegerBitWidth();
    auto *Op = translateSrcOperandToTgt(SI.getOperand(0), 1);
    auto *AndVal =
      Builder->CreateAnd(Op, (1llu << (bw - 1)), assemblyRegisterName(1));
    auto *NegVal =
      Builder->CreateSub(ConstantInt::get(I64Ty, 0), AndVal,
                         assemblyRegisterName(1));
    auto *ResVal =
      Builder->CreateOr(NegVal, Op, assemblyRegisterName(1));
    emitStoreToSrcRegister(ResVal, &SI);
  }
  void visitZExtInst(ZExtInst &ZI) {
    // Everything is zero-extended by default.
    auto *Op = translateSrcOperandToTgt(ZI.getOperand(0), 1);
    emitStoreToSrcRegister(Op, &ZI);
  }
  void visitTruncInst(TruncInst &TI) {
    auto *Op = translateSrcOperandToTgt(TI.getOperand(0), 1);
    uint64_t Mask = (1llu << (TI.getDestTy()->getIntegerBitWidth())) - 1;
    emitStoreToSrcRegister(
      Builder->CreateAnd(Op, Mask, assemblyRegisterName(1)),
      &TI);
  }
  void visitPtrToIntInst(PtrToIntInst &PI) {
    auto *Op = translateSrcOperandToTgt(PI.getOperand(0), 1);
    emitStoreToSrcRegister(
      Builder->CreatePtrToInt(Op, I64Ty, assemblyRegisterName(1)),
      &PI);
  }
  void visitIntToPtrInst(IntToPtrInst &II) {
    auto *Op = translateSrcOperandToTgt(II.getOperand(0), 1);
    emitStoreToSrcRegister(
      Builder->CreateIntToPtr(Op, II.getType(), assemblyRegisterName(1)),
      &II);
  }

  // ---- Call ----
  void visitCallInst(CallInst &CI) {
    auto *CalledF = CI.getCalledFunction();
    assert(FuncMap.count(CalledF));
    auto *CalledFInTgt = FuncMap[CalledF];

    SmallVector<Value *, 16> Args;
    unsigned Idx = 1;
    for (auto I = CI.arg_begin(), E = CI.arg_end(); I != E; ++I) {
      Args.emplace_back(translateSrcOperandToTgt(*I, Idx));
      ++Idx;
    }
    if (CI.hasName()) {
      Value *Res = Builder->CreateCall(CalledFInTgt, Args,
                                       assemblyRegisterName(1));
      emitStoreToSrcRegister(Res, &CI);
    } else {
      Builder->CreateCall(CalledFInTgt, Args);
    }
  }

  // ---- Terminators ----
  void visitReturnInst(ReturnInst &RI) {
    if (auto *RetVal = RI.getReturnValue())
      Builder->CreateRet(translateSrcOperandToTgt(RetVal, 1));
    else
      // To `ret i64 0`
      Builder->CreateRet(
        ConstantInt::get(IntegerType::getInt64Ty(*Context), 0));
  }
  void visitBranchInst(BranchInst &BI) {
    for (auto *Succ : BI.successors())
      processPHIsInSuccessor(Succ, BI.getParent());

    if (BI.isUnconditional()) {
      Builder->CreateBr(BBMap[BI.getSuccessor(0)]);
    } else {
      auto *CondOp = translateSrcOperandToTgt(BI.getCondition(), 1);
      // to_i1__ is recognized by assembler.
      string regname = assemblyRegisterName(1) + "to_i1__";
      auto *Condi1 = Builder->CreateICmpNE(CondOp, ConstantInt::get(I64Ty, 0),
                                           regname);
      Builder->CreateCondBr(Condi1, BBMap[BI.getSuccessor(0)],
                                    BBMap[BI.getSuccessor(1)]);
    }
  }
  void visitSwitchInst(SwitchInst &SI) {
    // Emit phi's values first!
    for (unsigned i = 0, e = SI.getNumSuccessors(); i != e; ++i)
      processPHIsInSuccessor(SI.getSuccessor(i), SI.getParent());

    auto *TgtCond = translateSrcOperandToTgt(SI.getCondition(), 1);
    vector<pair<ConstantInt *, BasicBlock *>> TgtCases;
    for (SwitchInst::CaseIt I = SI.case_begin(), E = SI.case_end();
         I != E; ++I) {
      auto *C = ConstantInt::get(I64Ty, I->getCaseValue()->getZExtValue());
      TgtCases.emplace_back(C, BBMap[I->getCaseSuccessor()]);
    }
    auto *TgtSI = Builder->CreateSwitch(TgtCond, BBMap[SI.getDefaultDest()],
                                        SI.getNumCases());
    for (auto [CaseVal, CaseDest] : TgtCases)
      TgtSI->addCase(CaseVal, CaseDest);
  }

  void processPHIsInSuccessor(BasicBlock *Succ, BasicBlock *BBFrom) {
    for (auto &PHI : Succ->phis())
      emitStoreToSrcRegister(
        translateSrcOperandToTgt(PHI.getIncomingValueForBlock(BBFrom), 1),
        &PHI);
  }


  // ---- Phi ----
  void visitPHINode(PHINode &PN) {
    // Do nothing! already processed by processPHIsInSuccessors().
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




PreservedAnalyses SimpleBackend::run(Module &M, ModuleAnalysisManager &FAM) {
  if (verifyModule(M, &errs(), nullptr))
    exit(1);

  // First, name all instructions / arguments / etc.
  InstNamer Namer;
  Namer.visit(M);

  // Second, depromote registers to alloca & canonicalize iN types into i64.
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