#ifndef LOOP_UNROLL_POST_HELPER
#define LOOP_UNROLL_POST_HELPER

#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;

class LoopUnrollPostHelper : public PassInfoMixin<LoopUnrollPostHelper> {
private:
  map<string, Function *> FunctionMap;
  Type *i64Ty, *i64PtrTy;
  
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};
#endif