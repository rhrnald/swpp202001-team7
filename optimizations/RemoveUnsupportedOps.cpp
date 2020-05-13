#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace std;
using namespace llvm;

namespace {
class RemoveUnsupportedOps : public llvm::PassInfoMixin<RemoveUnsupportedOps> {
  Constant *getZero(Type *T) {
    return T->isPointerTy() ?
        ConstantPointerNull::get(dyn_cast<PointerType>(T)) :
        ConstantInt::get(T, 0);
  }

public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    vector<Instruction *> V;
    for (auto I = inst_begin(F), E = inst_end(F); I != E; ++I) {
      Instruction *II = &*I;
      bool Deleted = false;
      if (auto *Intr = dyn_cast<IntrinsicInst>(II)) {
        if (Intr->getIntrinsicID() == Intrinsic::lifetime_start ||
            Intr->getIntrinsicID() == Intrinsic::lifetime_end) {
          V.push_back(Intr);
          Deleted = true;
        }
      } else if (auto *UI = dyn_cast<UnreachableInst>(II)) {
        LLVMContext &Cxt = F.getParent()->getContext();
        auto *RE = F.getReturnType()->isVoidTy() ? ReturnInst::Create(Cxt) :
            ReturnInst::Create(Cxt, getZero(F.getReturnType()));
        RE->insertBefore(UI);
        V.push_back(UI);
        Deleted = true;
      }

      if (!Deleted) {
        for (unsigned i = 0; i < II->getNumOperands(); ++i) {
          Value *V = II->getOperand(i);
          if (isa<UndefValue>(V)) {
            auto *T = V->getType();
            II->setOperand(i, getZero(T));
          }
        }
      }
    }

    for (auto *I : V)
      I->eraseFromParent();
    return PreservedAnalyses::all();
  }
};
}
