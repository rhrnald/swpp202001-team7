#include "PackRegisters.h"

#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/PassAnalysisSupport.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"

using namespace llvm;
using namespace std;


static const unsigned PACK_MAX_SIZE = 64;   // Max int bit count
static const unsigned PACK_VALID_COUNT = 3; // Min pack arguments requirement


ArgumentPackingInfo::ArgumentPackingInfo(Function &F) {
  Context = &(F.getContext());
  if (F.arg_size() == 0) {
    PackedArgCount = 0;
    return;
  }

  unique_ptr<DataLayout> DL(new DataLayout(F.getParent())); // getTypeSizeInBits
  vector<pair<unsigned, Argument*>> Args; // vector of (BitSize, Argument*)

  for (auto &A : F.args()) {
    Args.emplace_back(DL->getTypeSizeInBits(A.getType()), &A);
  }
  std::sort(Args.begin(), Args.end());
  // This reverse direction could be more optimal. I left it.
  // std::reverse(Args.begin(), Args.end());

  unsigned ArgCount = F.arg_size();
  unsigned PackedCount = 0, PackedSize = Args[0].first,
           PackedFrom = 0, PackedNow = 0;
  
  while (PackedFrom < ArgCount) {
    // Pack as much Arguments as possible
    while (PackedNow + 1 < Args.size() &&
            PackedSize + Args[PackedNow + 1].first <= PACK_MAX_SIZE) {
      PackedSize += Args[++PackedNow].first;
    }
    if (PackedNow + 1 - PackedFrom >= PACK_VALID_COUNT) {
      // If # packed arguments >= PACK_VALID_COUNT
      for (unsigned i = PackedFrom; i <= PackedNow; i++) {
        WillPack[PackedCount].push_back(Args[i].second);
      }
      ArgTy.push_back(Type::getInt64Ty(*Context));
      PackedCount++;
      PackedFrom = PackedNow + 1;
      PackedSize = 0;
    } else {
      // No profit for packing
      ArgTy.push_back(Args[PackedFrom].second->getType());
      PackedSize -= Args[PackedFrom].first;
      NotPack[PackedCount++] = Args[PackedFrom++].second;
    }
  }

  // New function's info
  PackedArgCount = PackedCount;

  // Memory cleaner
  Args.clear();
}

void ArgumentPackingInfo::clear() {
  ArgTy.clear();
  NotPack.clear();
  for (auto &[_, V] : WillPack) V.clear();
  WillPack.clear();
}


Function* PackRegisters::PackRegistersFromCallee(Function *F) {
  ArgumentPackingInfo *API = PackInfo[F]; // Packing Information about F
  vector<Type*> &ArgTy = API->ArgTy;
  Module *M = F->getParent();
  LLVMContext *Context = API->Context;
  unique_ptr<DataLayout> DL(new DataLayout(M));
  ValueToValueMapTy VMap;

  // I will clone a new function from F.
  // There is no simpler way to change arguments of a function..
  FunctionType *NewFTy = FunctionType::get(F->getFunctionType()->getReturnType(), ArgTy, false);
  Function *NewF = Function::Create(NewFTy, Function::ExternalLinkage, "", M);

  // Process for API->NotPack. Just replaceAllUseWith.
  for (auto &[i, A] : API->NotPack) {
    A->replaceAllUsesWith(NewF->getArg(i));
    NewF->getArg(i)->setName(A->getName());
  }

  // Process for API->WillPack. Create a new block on entry that
  //   unpack the merged arguments. Uses UDiv->URem->Trunc.
  if (!API->WillPack.empty()) {
    BasicBlock *PrevEntry = &(F->getEntryBlock());
    BasicBlock *NewEntry = BasicBlock::Create(*Context);
    auto &NewEntryInstList = NewEntry->getInstList(); // For inserting new instructions.

    if (PrevEntry->getName() == "") PrevEntry->setName("prev_entry");
    NewEntry->setName("split_reg");

    F->getBasicBlockList().push_front(NewEntry);

    map<Value*, Value*> ToBeTrunc; // ZExted arguments; should be truncated.

    for (auto &[i, Pack] : API->WillPack) {
      bool Init = 1;
      Value *NewA = NewF->getArg(i);
      Value *BeforeDivisor;
      Value *BeforeRem;
      unsigned BeforeASize;

      for (auto &A : Pack) {
        // Sequentially read the packed argument
        if (!Init) {
          // E.x., %merge = udiv i64 %merged, 256
          Instruction *UDiv = BinaryOperator::CreateUDiv(BeforeRem, BeforeDivisor, "merge");
          NewEntryInstList.push_back(UDiv);
          BeforeRem = UDiv;
        } else {
          BeforeRem = NewA;
          Init = 0;
        }
        // E.x., %zext.a = urem i64 %merged, 256
        unsigned long long ASize = 1ULL << DL->getTypeSizeInBits(A->getType());
        Value *Divisor = ConstantInt::get(Type::getInt64Ty(*Context), ASize);
        Instruction *URem = BinaryOperator::CreateURem(BeforeRem, Divisor, "zext." + A->getName());
        NewEntryInstList.push_back(URem);
        ToBeTrunc[A] = URem;

        BeforeDivisor = Divisor;
        BeforeASize = ASize;
      }

      NewF->getArg(i)->setName("merged");
    }

    for (auto &[A, ZExtA] : ToBeTrunc) {
      // E.x., %trunc.a = trunc i64 %zext.a to i8
      Instruction *Trunc = new TruncInst(ZExtA, A->getType(), "trunc." + A->getName());
      NewEntryInstList.push_back(Trunc);
      // Then %trunc.a replaces every %a
      A->replaceAllUsesWith(Trunc);
    }

    // E.x., br label %prev_entry
    BranchInst *Br = BranchInst::Create(PrevEntry, NewEntry);
    ToBeTrunc.clear();
  }

  // Clone everything(except arguments) from the original function
  for (auto &BB : *F) {
    BasicBlock *NewBB = CloneBasicBlock(&BB, VMap, "", NewF);
    VMap[&BB] = NewBB;
  }
  NewF->copyAttributesFrom(F);
  NewF->setName(F->getName());

  return NewF;
}

pair<Instruction*, CallInst*> PackRegisters::PackRegistersFromCaller(CallInst *CI, Function *NewF) {
  Function *F = CI->getCalledFunction(); // The old callee Function ptr (!= NewF)
  ArgumentPackingInfo *API = PackInfo[F];
  Module *M = NewF->getParent();
  LLVMContext *Context = API->Context;
  BasicBlock *BB = CI->getParent();
  unique_ptr<DataLayout> DL(new DataLayout(M));
  auto &BBInstList = BB->getInstList(); // For inserting new instructions

  vector<Value*> Args(API->PackedArgCount, NULL); // Arguments for NewF
  map<Argument*, Value*> ArgToParam; // Argument to Parameters map

  for (unsigned i = 0; i < F->arg_size(); i++) {
    Argument *A = F->getArg(i);
    Value *V = CI->getOperand(i);
    ArgToParam[A] = V;
  }
  
  // Process NotPack. Just take it
  for (auto &[i, A] : API->NotPack) {
    Args[i] = ArgToParam[A];
  }

  Instruction *LastInstruction = CI; // The last Instruction's ptr

  // Process WillPack. Merge registers before the function call
  for (auto &[i, Pack] : API->WillPack) {
    vector<Instruction*> ZExts; // ZExts of every original argument

    for (auto &A : Pack) {
      // E.x., %zext.a = zext i8 %a to i64
      Value *V = ArgToParam[A];
      Instruction *ZExt = new ZExtInst(V, Type::getInt64Ty(*Context), "zext." + V->getName());
      BBInstList.insertAfter(LastInstruction->getIterator(), ZExt);
      LastInstruction = ZExt;

      ZExts.push_back(ZExt);
    }

    Instruction *LastMerge = LastInstruction; // Lastly merged Instruction ptr

    for (int j = Pack.size()-1; j >= 0; j--) {
      // Reverse order packing
      if (j + 1 < Pack.size()) {
        // E.x., %merge.1 = xor i64 %merge, %zext.a
        Instruction *Xor = BinaryOperator::CreateXor(LastMerge, ZExts[j], "merge");
        LastMerge = Xor;
        BBInstList.insertAfter(LastInstruction->getIterator(), Xor);
        LastInstruction = Xor;
      }
      if (j > 0) {
        // E.x., %merge.1 = mul i64 %merge, 256
        unsigned long long NextSize = 1ULL << DL->getTypeSizeInBits(Pack[j-1]->getType());
        Value *Multiplier = ConstantInt::get(Type::getInt64Ty(*Context), NextSize);
        Instruction *Mul = BinaryOperator::CreateMul(LastMerge, Multiplier, "merge");
        BBInstList.insertAfter(LastInstruction->getIterator(), Mul);
        LastMerge = Mul;
        LastInstruction = Mul;
      }
    }

    // NewF's ith argument is LastMerge
    Args[i] = LastMerge;
    ZExts.clear();
  }

  // Create a new function call and copy every information from the original
  CallInst *NewCI = CallInst::Create(NewF->getFunctionType(), NewF, Args, "");
  NewCI->setAttributes(CI->getAttributes());
  NewCI->setCallingConv(CI->getCallingConv());
  NewCI->setTailCall(CI->getTailCallKind());
  NewCI->setDebugLoc(CI->getDebugLoc());

  // Set CallInst's target
  if (F->getReturnType() != Type::getVoidTy(*Context)) {
    NewCI->setName(CI->getName());
  }

  Args.clear();
  ArgToParam.clear();

  // Returns (Insertion position, Newly created caller)
  return make_pair(LastInstruction, NewCI);
}

PreservedAnalyses PackRegisters::run(Module &M, ModuleAnalysisManager &MAM) {
  FunctionAnalysisManager &FAM = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  
  vector<Function*> OrigFunctions;
  map<Function*, Function*> FunctionMap;
  vector<CallInst*> OrigFunctionCall;
  map<CallInst*, pair<Instruction*, CallInst*>> CallerMap;

  for (Function &F : M) {
    if (!F.isDeclaration()) { // Do not optimizes declaration(e.x., malloc)
      // Make every ArgumentPackingInfo, and push to the vector
      PackInfo[&F] = new ArgumentPackingInfo(F);
      OrigFunctions.push_back(&F);
    }
  }

  for (Function *F : OrigFunctions) {
    // Optimizes callees first.
    // The old function F is not deleted yet. (Or, this causes an error)
    // But the new function NewF is added to the module. (Or, this causes an error)
    Function *NewF = PackRegistersFromCallee(F);
    FunctionMap[F] = NewF;
  }

  for (Function &F : M) {
    for (auto &BB : F) {
      for (auto &I : BB) {
        CallInst *CI = dyn_cast<CallInst>(&I);
        if (!CI) continue;

        // Okay it's function call.
        Function *Called = CI->getCalledFunction();
        if (!Called->isDeclaration()) {
          // Optimizes caller part.
          // The old function call CI is not deleted yet.
          // Also, the new function call is not inserted yet.
          CallerMap[CI] = PackRegistersFromCaller(CI, FunctionMap[Called]);
          OrigFunctionCall.push_back(CI);
        }
      }
    }
  }

  for (auto &CI : OrigFunctionCall) {
    BasicBlock *BB = CI->getParent();
    auto &[InsertionPoint, NewCI] = CallerMap[CI];

    // Insert the new function call after the Instruction ptr.
    // And replaceAllUses, and finally delete the original one.
    BB->getInstList().insertAfter(InsertionPoint->getIterator(), NewCI);
    CI->replaceAllUsesWith(NewCI);
    CI->removeFromParent();
  }

  for (Function *F : OrigFunctions) {
    // Remove the original functions and rename the new ones.
    Function *NewF = FunctionMap[F];
    F->removeFromParent();
    NewF->setName(F->getName());
  }

  // Memory cleaner
  OrigFunctions.clear();
  FunctionMap.clear();
  CallerMap.clear();
  OrigFunctionCall.clear();

  return PreservedAnalyses::all();
}
