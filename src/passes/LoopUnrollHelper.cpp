#include "LoopUnrollHelper.h"

#include "llvm/IR/PassManager.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;

const string PREFIX_OF_DUMMY = "$dummy$", PREFIX_OF_START = "$fnstart$";
const string PREFIX_OF_RETURN = "$fnreturn$", PREFIX_OF_END = "$fnend$";
const string PREFIX_OF_ARG = "$fnarg$", SUFFIX = "$dot$";

bool LoopUnrollPreHelper::getCompatibleWithUnroll(Function *F) {
  if (CompatibleWithUnroll.count(F)) return CompatibleWithUnroll[F];
  bool &ret = CompatibleWithUnroll[F] = false;
  StringRef FnName = F->getName();
  ret |= (FnName == "read" || FnName == "write" || FnName == "malloc" || FnName == "free");
  return ret;
}

void LoopUnrollPreHelper::GeneratePad(AllocaInst *Dummy, Value *V, vector<Instruction*> &ToInsert, string prefix) {
  if (V->getType()->isPointerTy()) {
    ToInsert.push_back(new PtrToIntInst(V, i64Ty, prefix));
    ToInsert.push_back(new StoreInst(ToInsert.back(), Dummy));
  } else {
    if (V->getType() != i64Ty) {
      ToInsert.push_back(new ZExtInst(V, i64Ty, prefix));
      ToInsert.push_back(new StoreInst(ToInsert.back(), Dummy));
    } else {
      ToInsert.push_back(new StoreInst(V, Dummy));
    }
  }
}

PreservedAnalyses LoopUnrollPreHelper::run(Module &M, ModuleAnalysisManager &MAM) {
  LLVMContext &Context = M.getContext();
  i64Ty = Type::getInt64Ty(Context), i64PtrTy = Type::getInt64PtrTy(Context);

  vector<Instruction*> ToErased;
  for (auto &F : M) {
    if (!isa<Function>(F) || F.isDeclaration()) continue;
    AllocaInst *Dummy = new AllocaInst(i64Ty, 0, PREFIX_OF_DUMMY);
    F.getEntryBlock().getInstList().push_front(Dummy);
    for (auto &BB : F) {
      auto &IL = BB.getInstList();
      for (auto &I : BB) { 
        if (CallInst *CI = dyn_cast<CallInst>(&I)) {
          Function *CF = CI->getCalledFunction();
          if (!getCompatibleWithUnroll(CF)) continue;
          StringRef FnName = CF->getName();
          vector<Instruction *> ToInsert;

          ToInsert.push_back(new PtrToIntInst(Dummy, i64Ty, PREFIX_OF_START + FnName + SUFFIX));
          ToInsert.push_back(new StoreInst(ToInsert.back(), Dummy));
          for (auto &A : CI->args()) {
            GeneratePad(Dummy, A, ToInsert, PREFIX_OF_ARG);
          }
          if (CF->getReturnType() != Type::getVoidTy(Context)) {
            if (CI->getType()->isPointerTy())
              ToInsert.push_back(new IntToPtrInst(ConstantInt::get(i64Ty, 1ULL), CI->getType(), PREFIX_OF_RETURN + CI->getName() + SUFFIX));
            else
              ToInsert.push_back(new PtrToIntInst(Dummy, CI->getType(), PREFIX_OF_RETURN + CI->getName() + SUFFIX));
            CI->replaceAllUsesWith(ToInsert.back());
          }
          ToInsert.push_back(new PtrToIntInst(Dummy, i64Ty, PREFIX_OF_END + FnName + SUFFIX));
          ToInsert.push_back(new StoreInst(ToInsert.back(), Dummy));

          Instruction *Last = CI;
          for (auto &NewInst : ToInsert) {
            IL.insertAfter(Last->getIterator(), NewInst);
            Last = NewInst;
          }
          ToErased.push_back(CI);
        }
      }
    }
  }
  for (auto &E : ToErased) E->eraseFromParent();
  return PreservedAnalyses::all();
}

static string getParse(string target, string prefix, string postfix) {
  if (target.size() < prefix.size() + postfix.size()) return "";
  if (target.substr(0, prefix.size()) != prefix) return "";
  uint64_t i = target.find(postfix);
  return i == string::npos? "" : target.substr(prefix.size(), i - prefix.size());
}

PreservedAnalyses LoopUnrollPostHelper::run(Module &M, ModuleAnalysisManager &MAM) {
  LLVMContext &Context = M.getContext();
  for (auto &F : M) {
    if (!isa<Function>(F)) continue;
    FunctionMap[F.getName()] = &F;
  }
  bool SkipOne = false, Ended = false;
  string FnName = "";
  Function *FnParse = NULL;
  vector<tuple<vector<Instruction *>, Instruction*, Instruction*>> Replacements;
  vector<Instruction *> Consecutives, Deletes;
  CallInst *NewCall = NULL;
  Instruction *Caller = NULL;
  Value *X, *Y;
  vector<Value *> Args;
  map<Function*, Instruction*> DummyMap;
  unsigned ArgNum = 0;
  for (auto &F : M) {
    if ((!isa<Function>(F)) || F.isDeclaration()) continue;
    for (auto &BB : F) for (auto &I : BB) {
      if (I.getName().find(PREFIX_OF_DUMMY) != StringRef::npos) DummyMap[&F] = &I;
      if (FnParse) Consecutives.push_back(&I);
      if (SkipOne) {
        if (Ended) {
          Replacements.emplace_back(Consecutives, Caller, NewCall);
          Consecutives.clear();
          Ended = false, FnParse = NULL, FnName = "", ArgNum = 0, NewCall = NULL, Caller = NULL, X = Y = NULL;
        }
        SkipOne = false; continue;
      }
      if (!FnParse) {
        if ((FnName = getParse(I.getName(), PREFIX_OF_START, SUFFIX)) != "") {
          FnParse = FunctionMap[FnName];
          SkipOne = true, ArgNum = 0;
        }
      } else {
        if (ArgNum++ < FnParse->arg_size()) {
          if (StoreInst *S = dyn_cast<StoreInst>(&I)) {
            X = S->getOperand(0);
          } else if (ZExtInst *Z = dyn_cast<ZExtInst>(&I)) {
            X = Z->getOperand(0);
            SkipOne = true;
          } else if (PtrToIntInst *P = dyn_cast<PtrToIntInst>(&I)) {
            X = P->getOperand(0);
            SkipOne = true;
          }
          Args.push_back(X);
        } else {
          if (!Ended) {
            NewCall = CallInst::Create(FnParse->getFunctionType(), FnParse, Args, "", &I);
            if (NewCall->getType() != Type::getVoidTy(Context)) {
              NewCall->setName("newcall");
              Caller = &I;
            } else {
              SkipOne = true;
            }
            Args.clear();
            Ended = true;
          } else {
            SkipOne = true;
          }
        }
      }
    }
  }

  for (auto &[C, CR, NCI] : Replacements) {
    if (CR) CR->replaceAllUsesWith(NCI);
    for (auto &I : C) Deletes.push_back(I);
  }

  reverse(Deletes.begin(), Deletes.end());
  for (auto &I : Deletes) I->eraseFromParent();

  for (auto &[_, D] : DummyMap) {
    for (auto &U : D->uses()) {
      User *Usr = U.getUser();
      if (Instruction *UsrI = dyn_cast<Instruction>(Usr)) UsrI->eraseFromParent();
    }
    D->eraseFromParent();
  }
  return PreservedAnalyses::all();
}