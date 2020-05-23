#include "LoopUnrollPostHelper.h"

#include "llvm/IR/PassManager.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;

const string PREFIX_OF_DUMMY = "$dummy$", PREFIX_OF_START = "$fnstart$";
const string PREFIX_OF_RETURN = "$fnreturn$", PREFIX_OF_END = "$fnend$";
const string PREFIX_OF_ARG = "$fnarg$", SUFFIX = "$dot$";

string getParse(string target, string prefix, string postfix) {
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
  string FnName;
  Function *FnParse = NULL;
  vector<pair<vector<Instruction *>, Instruction*>> Replacements;
  vector<Instruction *> Consecutives;
  CallInst *NewCall = NULL;
  Value *X, *Y;
  vector<Value *> Args;
  unsigned ArgNum = 0;
  for (auto &F : M) for (auto &BB : F) for (auto &I : BB) {
    if (FnParse) Consecutives.push_back(&I);
    if (SkipOne) {
      if (Ended) {
        Ended = false, FnParse = NULL;
      }
      SkipOne = false; continue;
    }
    if (!FnParse) {
      if ((FnName = getParse(I.getName(), PREFIX_OF_START, SUFFIX)) != "") {
        FnParse = FunctionMap[FnName];
        SkipOne = true, ArgNum = 0;
      }
    } else {
      if (ArgNum < FnParse->arg_size()) {
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
          NewCall = CallInst::Create(FnParse->getFunctionType(), FnParse, Args, FnName);
          if (FnParse->getReturnType() != Type::getVoidTy(Context)) {
            I.replaceAllUsesWith(NewCall);
          }
          vector<Value *> Empty; std::swap(Args, Empty);
          Ended = true;
        } else {
          if ((FnName = getParse(I.getName(), PREFIX_OF_START, SUFFIX)) != "") {
            SkipOne = true;
          }
        }
      }
    }
  }
  return PreservedAnalyses::all();
}
