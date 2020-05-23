#include "LoopUnrollPreHelper.h"

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
  if (FnName == "read" || FnName == "write" || FnName == "malloc" || FnName == "free")
    return ret = true;
  return false;
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
            //GenerateAdhoc2(Dummy, CI, ToInsert);
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
