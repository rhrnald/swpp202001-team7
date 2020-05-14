#include "CheckConstExpr.h"

#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;

PreservedAnalyses CheckConstExpr::run(Module &M, ModuleAnalysisManager &MAM) {
  for (auto &G : M.globals()) {
    if (auto *F = dyn_cast<Function>(&G)) {
      for (auto I = inst_begin(F), E = inst_end(F); I != E; ++I) {
        Instruction *II = &*I;
        for (auto &V : I->operands()) {
          if (isa<ConstantExpr>(V)) {
            errs() << "ERROR: Constant expressions should not exist!\n";
            errs() << "\t" << *I << "\n";
            exit(1);
          }
        }
      }
    } else if (auto *GV = dyn_cast<GlobalVariable>(&G)) {
      if (GV->hasInitializer()) {
        errs() << "ERROR: Global variables should not have initializers!\n";
        errs() << "\t" << *GV << "\n";
        exit(1);
      }
    }
  }
  return PreservedAnalyses::all();
}
