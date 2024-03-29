#include "WeirdArithmetic.h"

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace llvm::PatternMatch;
using namespace std;

PreservedAnalyses WeirdArithmetic::run(Module &M, ModuleAnalysisManager &MAM) {
  vector< pair<Instruction *, Instruction *> > Worklist;
  for (auto &F : M) for (auto &BB : F) for (auto &I : BB) {
    Value *X;
    ConstantInt *C;
    Instruction *NewI = nullptr;
    // sub 0, x => mul x, -1
    if (match(&I, m_Sub(m_ZeroInt(), m_Value(X)))) {
      NewI = BinaryOperator::CreateMul(
          X, ConstantInt::getSigned(I.getType(), -1));
    }
    // c_and x, N => urem x, N'
    else if (match(&I, m_c_And(m_Value(X), m_ConstantInt(C)))) {
      Instruction *InstX;
      uint64_t N = C->getZExtValue();
      // if x matches [shl ?, M], then fill the M LSBs of N with ones.
      if ((InstX = dyn_cast<Instruction>(X))
          && InstX->getOpcode() == BinaryOperator::Shl
          && match(InstX->getOperand(1), m_ConstantInt(C))) {
        N |= ((1ULL << C->getZExtValue()) - 1ULL);
      }
      // if (N+1) is a power of 2
      // - (N+1) is never zero, since instcombine pass removes
      //   [and x, -1] since it is redundant.
      if ((N & (N+1)) == 0) {
        NewI = BinaryOperator::CreateURem(
            X, ConstantInt::get(I.getType(), N+1));
      }
    }
    // shift x, N => mul/div x, 2^N
    else if (I.isShift() && (C = dyn_cast<ConstantInt>(I.getOperand(1)))) {
      uint64_t N = C->getZExtValue();
      X = I.getOperand(0);
      switch (I.getOpcode()) {
      // srl x, N => mul x, 2^N
      case BinaryOperator::Shl:
        NewI = BinaryOperator::CreateMul(
            X, ConstantInt::get(I.getType(), 1ULL<<N));
        break;
      // lshr x, N => udiv x, 2^N
      case BinaryOperator::LShr:
        NewI = BinaryOperator::CreateUDiv(
            X, ConstantInt::get(I.getType(), 1ULL<<N));
        break;
      }
    }
    // and i1 x, y => mul i1 x, y
    else if (I.getOpcode() == BinaryOperator::And
            && I.getType() == Type::getInt1Ty(M.getContext())) {
      NewI = BinaryOperator::CreateMul(I.getOperand(0), I.getOperand(1));
    }

    if (NewI) Worklist.push_back(make_pair(&I, NewI));
  }

  for (auto RP : Worklist)
    ReplaceInstWithInst(RP.first, RP.second);

  return PreservedAnalyses::all();
}
