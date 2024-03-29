#ifndef MEM_USE_OPTIMIZATION
#define MEM_USE_OPTIMIZATION

#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Analysis/LoopInfo.h"

using namespace llvm;

const std::string AllocaBytesFnName = "__alloca_bytes__";
const std::string GetSPFnName = "__get_stack_pointer__";

const int STACK_DANGEROUS_REGION = 5120;
const int STACK_BOUNDARY = 10240;

class MemUseOptimization : public PassInfoMixin<MemUseOptimization> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};
#endif
