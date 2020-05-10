#include "PackRegisters.h"

#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;

PreservedAnalyses PackRegisters::run(Module &M, ModuleAnalysisManager &MAM) {
    FunctionAnalysisManager &FAM = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
    
    // This below debug codes should be deleted.
    outs() << "(PackRegisters) Module Name: " << M.getName() << "\n";

    for (Function &F : M) {
      outs() << F.getName() << "\n";
      if (F.isDeclaration()) {
        outs() << "  (declaration)\n";
      }
      for (BasicBlock &BB : F) {
        outs() << "  " << BB.getName() << "\n";
      }
    }

    return PreservedAnalyses::all();
}
