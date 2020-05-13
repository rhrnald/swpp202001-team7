#ifndef WEIRD_ARITHMETIC
#define WEIRD_ARITHMETIC

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;


class WeirdArithmetic : public PassInfoMixin<WeirdArithmetic> {
    
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};

#endif