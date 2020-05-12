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


static const unsigned PACK_MAX_SIZE = 64;
static const unsigned PACK_VALID_COUNT = 3;


ArgumentPackingInfo::ArgumentPackingInfo(Function &F) {
  Context = &(F.getContext());
  if (F.arg_size() == 0) {
    PackedArgCount = 0;
    return;
  }

  unique_ptr<DataLayout> DL(new DataLayout(F.getParent()));
  vector<pair<unsigned, Argument*>> Args;

  for (auto &A : F.args()) {
    Args.emplace_back(DL->getTypeSizeInBits(A.getType()), &A);
  }
  std::sort(Args.begin(), Args.end());
  // std::reverse(Args.begin(), Args.end());

  unsigned ArgCount = F.arg_size();
  unsigned PackedCount = 0, PackedSize = Args[0].first,
           PackedFrom = 0, PackedNow = 0;
  
  while (PackedFrom < ArgCount) {
    while (PackedNow + 1 < Args.size() &&
            PackedSize + Args[PackedNow + 1].first <= PACK_MAX_SIZE) {
      PackedSize += Args[++PackedNow].first;
    }
    if (PackedNow + 1 - PackedFrom >= PACK_VALID_COUNT) {
      for (unsigned i = PackedFrom; i <= PackedNow; i++) {
        WillPack[PackedCount].push_back(Args[i].second);
      }
      ArgTy.push_back(Type::getInt64Ty(*Context));
      PackedCount++;
      PackedFrom = PackedNow + 1;
      PackedSize = 0;
    } else {
      ArgTy.push_back(Args[PackedFrom].second->getType());
      PackedSize -= Args[PackedFrom].first;
      NotPack[PackedCount++] = Args[PackedFrom++].second;
    }
  }

  PackedArgCount = PackedCount;

  Args.clear();
}

void ArgumentPackingInfo::clear() {
  ArgTy.clear();
  NotPack.clear();
  for (auto &[_, V] : WillPack) V.clear();
  WillPack.clear();
}


Function* PackRegisters::PackRegistersFromCallee(Function *F) {
  ArgumentPackingInfo *API = PackInfo[F];
  vector<Type*> &ArgTy = API->ArgTy;
  Module *M = F->getParent();
  LLVMContext *Context = API->Context;
  unique_ptr<DataLayout> DL(new DataLayout(M));
  ValueToValueMapTy VMap;

  FunctionType *NewFTy = FunctionType::get(F->getFunctionType()->getReturnType(), ArgTy, false);
  Function *NewF = Function::Create(NewFTy, Function::ExternalLinkage, "", *M);

  for (auto &[i, A] : API->NotPack) {
    A->replaceAllUsesWith(NewF->getArg(i));
    NewF->getArg(i)->setName(A->getName());
  }

  if (!API->WillPack.empty()) {
    BasicBlock *PrevEntry = &(F->getEntryBlock());
    BasicBlock *NewEntry = BasicBlock::Create(*Context);
    auto &NewEntryInstList = NewEntry->getInstList();

    if (PrevEntry->getName() == "") PrevEntry->setName("prev_entry");
    NewEntry->setName("split_reg");

    F->getBasicBlockList().push_front(NewEntry);

    map<Value*, Value*> ToBeTrunc;

    for (auto &[i, Pack] : API->WillPack) {
      bool Init = 1;
      Value *NewA = NewF->getArg(i);
      Value *BeforeDivisor;
      Value *BeforeRem;
      unsigned BeforeASize;
      Twine MergedName = "merged";

      for (auto &A : Pack) {
        if (!Init) {
          Instruction *UDiv = BinaryOperator::CreateUDiv(BeforeRem, BeforeDivisor, "merge");
          NewEntryInstList.push_back(UDiv);
          BeforeRem = UDiv;
        } else {
          BeforeRem = NewA;
          Init = 0;
        }
        unsigned long long ASize = 1ULL << DL->getTypeSizeInBits(A->getType());
        Value *Divisor = ConstantInt::get(Type::getInt64Ty(*Context), ASize);
        Instruction *URem = BinaryOperator::CreateURem(BeforeRem, Divisor, "zext." + A->getName());
        NewEntryInstList.push_back(URem);
        ToBeTrunc[A] = URem;

        BeforeDivisor = Divisor;
        BeforeASize = ASize;
        MergedName.concat("." + A->getName());
      }

      NewF->getArg(i)->setName(MergedName);
    }

    for (auto &[A, ZExtA] : ToBeTrunc) {
      Instruction *Trunc = new TruncInst(ZExtA, A->getType(), "trunc." + A->getName());
      NewEntryInstList.push_back(Trunc);
      A->replaceAllUsesWith(Trunc);
    }

    BranchInst *Br = BranchInst::Create(PrevEntry, NewEntry);
    ToBeTrunc.clear();
  }

  for (auto &BB : *F) {
    BasicBlock *NewBB = CloneBasicBlock(&BB, VMap, "", NewF);
    VMap[&BB] = NewBB;
  }
  NewF->copyAttributesFrom(F);
  NewF->setName(F->getName());

  return NewF;
}

pair<Instruction*, CallInst*> PackRegisters::PackRegistersFromCaller(CallInst *CI, Function *NewF) {
  Function *F = CI->getCalledFunction();
  ArgumentPackingInfo *API = PackInfo[F];
  Module *M = NewF->getParent();
  LLVMContext *Context = API->Context;
  BasicBlock *BB = CI->getParent();
  unique_ptr<DataLayout> DL(new DataLayout(M));
  auto &BBInstList = BB->getInstList();

  vector<Value*> Args(API->PackedArgCount, NULL);
  map<Argument*, Value*> ArgToParam;

  for (unsigned i = 0; i < F->arg_size(); i++) {
    Argument *A = F->getArg(i);
    Value *V = CI->getOperand(i);
    ArgToParam[A] = V;
  }
  
  for (auto &[i, A] : API->NotPack) {
    Args[i] = ArgToParam[A];
  }

  Instruction *LastInstruction = CI;

  for (auto &[i, Pack] : API->WillPack) {
    vector<Instruction*> ZExts;

    for (auto &A : Pack) {
      Value *V = ArgToParam[A];
      Instruction *ZExt = new ZExtInst(V, Type::getInt64Ty(*Context), "zext." + A->getName());
      BBInstList.insertAfter(LastInstruction->getIterator(), ZExt);
      LastInstruction = ZExt;

      ZExts.push_back(ZExt);
    }

    Instruction *LastMerge = LastInstruction;

    for (int j = Pack.size()-1; j >= 0; j--) {
      if (j + 1 < Pack.size()) {
        Instruction *Xor = BinaryOperator::CreateXor(LastMerge, ZExts[j], "merge");
        LastMerge = Xor;
        BBInstList.insertAfter(LastInstruction->getIterator(), Xor);
        LastInstruction = Xor;
      }
      if (j > 0) {
        unsigned long long NextSize = 1ULL << DL->getTypeSizeInBits(Pack[j-1]->getType());
        Value *Multiplier = ConstantInt::get(Type::getInt64Ty(*Context), NextSize);
        Instruction *Mul = BinaryOperator::CreateMul(LastMerge, Multiplier, "merge");
        BBInstList.insertAfter(LastInstruction->getIterator(), Mul);
        LastMerge = Mul;
        LastInstruction = Mul;
      }
    }

    Args[i] = LastMerge;
    ZExts.clear();
  }

  CallInst *NewCI = CallInst::Create(NewF->getFunctionType(), NewF, Args, "");
  NewCI->setAttributes(CI->getAttributes());
  NewCI->setCallingConv(CI->getCallingConv());
  NewCI->setTailCall(CI->getTailCallKind());
  NewCI->setDebugLoc(CI->getDebugLoc());

  if (F->getReturnType() != Type::getVoidTy(*Context)) {
    NewCI->setName(CI->getName());
  }

  Args.clear();
  ArgToParam.clear();

  return make_pair(LastInstruction, NewCI);
}

PreservedAnalyses PackRegisters::run(Module &M, ModuleAnalysisManager &MAM) {
  FunctionAnalysisManager &FAM = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  
  vector<Function*> OrigFunctions;
  map<Function*, Function*> FunctionMap;
  map<CallInst*, pair<Instruction*, CallInst*>> CallerMap;
  vector<CallInst*> ToRemove;

  for (Function &F : M) {
    if (!F.isDeclaration()) {
      PackInfo[&F] = new ArgumentPackingInfo(F);
      OrigFunctions.push_back(&F);
    }
  }

  for (Function *F : OrigFunctions) {
    Function *NewF = PackRegistersFromCallee(F);
    FunctionMap[F] = NewF;
  }

  for (Function &F : M) {
    for (auto &BB : F) {
      for (auto &I : BB) {
        CallInst *CI = dyn_cast<CallInst>(&I);
        if (!CI) continue;

        Function *Called = CI->getCalledFunction();
        if (!Called->isDeclaration()) {
          CallerMap[CI] = PackRegistersFromCaller(CI, FunctionMap[Called]);
          ToRemove.push_back(CI);
        }
      }
    }
  }

  for (auto &CI : ToRemove) {
    BasicBlock *BB = CI->getParent();
    auto &[InsertionPoint, NewCI] = CallerMap[CI];

    BB->getInstList().insertAfter(InsertionPoint->getIterator(), NewCI);
    CI->replaceAllUsesWith(NewCI);
    CI->removeFromParent();
  }

  for (Function *F : OrigFunctions) {
    Function *NewF = FunctionMap[F];
    F->removeFromParent();
    NewF->setName(F->getName());
  }

  OrigFunctions.clear();
  FunctionMap.clear();
  CallerMap.clear();
  ToRemove.clear();
  for (auto &[F, PI] : PackInfo) {
    PI->clear();
  }
  PackInfo.clear();

  return PreservedAnalyses::all();
}
