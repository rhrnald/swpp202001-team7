#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;


namespace {
class WeirdArithmetic : public PassInfoMixin<WeirdArithmetic> {
    
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
    FunctionAnalysisManager &FAM = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();

    // This below debug codes should be deleted.
    outs() << "(WeirdArithmetic) Module Name: " << M.getName() << "\n";

    return PreservedAnalyses::all();
  }
};
}