#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace llvm::PatternMatch;
using namespace std;

namespace {
class WeirdArithmetic : public PassInfoMixin<WeirdArithmetic> {
    
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {

    vector< pair<Instruction *, Instruction *> > Worklist;
    for (auto &F : M) for (auto &BB : F) for (auto &I : BB) {
      Value *X;
      ConstantInt *C;
      // add x, x => mul x, 2
      if (match(&I, m_Add(m_Value(X), m_Deferred(X)))) {
        auto NewI = BinaryOperator::CreateMul(
                        X, ConstantInt::get(I.getType(), 2));
        Worklist.push_back(make_pair(&I, NewI));
      }
      // sub 0, x => mul x, -1
      else if (match(&I, m_Sub(m_ZeroInt(), m_Value(X)))) {
        auto NewI = BinaryOperator::CreateMul(
                        X, ConstantInt::getSigned(I.getType(), -1));
        Worklist.push_back(make_pair(&I, NewI));
      }
      // c_and x, 2^n-1 => urem x, 2^n
      else if (match(&I, m_c_And(m_Value(X), m_ConstantInt(C)))) {
        uint64_t N = C->getZExtValue();
        // if (N+1) is a power of 2
        // - (N+1) is never zero, since instcombine pass removes
        //   [and x, -1] since it is redundant.
        if ((N & (N+1)) == 0) {
          auto NewI = BinaryOperator::CreateURem(
                        X, ConstantInt::get(I.getType(), N+1));
          Worklist.push_back(make_pair(&I, NewI));
        }
      }
    }

    for (auto RP : Worklist)
      ReplaceInstWithInst(RP.first, RP.second);
    
    return PreservedAnalyses::all();
  }
};
}