#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

#include "Wrapper.h"


using namespace llvm;

extern "C" ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION, "Team7 Optimizations", "v0.1",
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](StringRef Name, ModulePassManager &PM,
           ArrayRef<PassBuilder::PipelineElement>) {
          outs() << "pass name = " << Name << "\n";
          if (Name == "pack-regs-arg") {
            PM.addPass(PackRegisters());
            return true;
          }
          if (Name == "weird-arith") {
            PM.addPass(WeirdArithmetic());
            return true;
          }
          return false;
        }
      );
    }
  };
}
