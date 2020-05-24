#ifndef REORDER_MEM_ACCESS
#define REORDER_MEM_ACCESS

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;


class ReorderMemAccess : public PassInfoMixin<ReorderMemAccess> {
    
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};

#endif
