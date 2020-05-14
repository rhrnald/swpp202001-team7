#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace std;
using namespace llvm;

class RemoveUnsupportedOps : public llvm::PassInfoMixin<RemoveUnsupportedOps> {
  Constant *getZero(Type *T) {
    return T->isPointerTy() ?
        ConstantPointerNull::get(dyn_cast<PointerType>(T)) :
        ConstantInt::get(T, 0);
  }

public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};
