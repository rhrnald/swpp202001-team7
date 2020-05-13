#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;


class CheckConstExpr : public llvm::PassInfoMixin<CheckConstExpr> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};
