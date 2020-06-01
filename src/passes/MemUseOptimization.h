#ifndef MEM_USE_OPTIMIZATION
#define MEM_USE_OPTIMIZATION

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;


class MemUseOptimization : public PassInfoMixin<MemUseOptimization> {
    
public:
  Function *MainFn, *MallocFn, *AllocaBytesFn;
  FunctionType *MainTy, *MallocTy, *AllocaBytesTy;
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};

#endif
