#include "MemUseOptimization.h"

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/InstVisitor.h"

using namespace llvm;
using namespace llvm::PatternMatch;
using namespace std;

PreservedAnalyses MemUseOptimization::run(Module &M, ModuleAnalysisManager &MAM) {
  MallocFn = AllocaBytesFn = MainFn = NULL;
  for (auto &F : M) {
    if (F.getName() == "malloc") {
      MallocFn = &F;
      MallocTy = dyn_cast<FunctionType>(F.getValueType());
    }
    if (F.getName() == "__alloca_bytes__") {
      AllocaBytesFn = &F;
      AllocaBytesTy = dyn_cast<FunctionType>(F.getValueType());
    }
    if (F.getName() == "main") {
      MainFn = &F;
      MainTy = dyn_cast<FunctionType>(F.getValueType());
    }
  }
  assert(MainFn != NULL);
  if (MallocFn == NULL) {
    MallocTy = FunctionType::get(I8PtrTy, {I64Ty}, false);
    MallocFn = Function::Create(MallocTy, Function::ExternalLinkage,
                                  "malloc", M);
  }
  if (AllocaBytesFn == NULL) {
    AllocaBytesTy = FunctionType::get(I8PtrTy, {I64Ty}, false);
    AllocaBytesFn = Function::Create(AllocaBytesTy, Function::ExternalLinkage,
                                  "__alloca_bytes__", M);
  }

  set<BasicBlock*> BlockInLoop;
  LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

  for (auto &BB : *MainFn) {
    for (auto &I : BB) {

    }
  }
  return PreservedAnalyses::all();
}
