#include "ResetPointer.h"

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/InstVisitor.h"
#include <string>

using namespace llvm::PatternMatch;
using namespace std;
using namespace llvm;

AllocType getOpType(const Value *V) {
  if (auto *CI = dyn_cast<CallInst>(V)) {
    if (isMallocCall(CI))
      return HEAP;
    if (isAllocaByteCall(CI)) 
      return STACK;
    return UNKNOWN;
  } else if (auto *AI = dyn_cast<AllocaInst>(V)) {
    return STACK;
  } else if (auto *BI = dyn_cast<BitCastInst>(V)) {
    return getOpType(BI->getOperand(0));
  } else if (auto *GI = dyn_cast<GetElementPtrInst>(V)) {
    return getOpType(GI->getPointerOperand());
  } else if (auto *BCO = dyn_cast<BitCastOperator>(V)) {
    return getOpType(BCO->getOperand(0));
  } else if (auto *BO = dyn_cast<BinaryOperator>(V)) {
    AllocType op1 = getOpType(BO->getOperand(0));
    if(op1!=UNKNOWN) return op1;
    return getOpType(BO->getOperand(1));
  }
  return UNKNOWN;
}
AllocType getAccessType(const Value *V) {
  if (auto *CI = dyn_cast<CallInst>(V)) {
    if (isMallocCall(CI))
      return NOEFFECT;
    if (isFreeCall(CI))
      return NOEFFECT;
    if (isAllocaByteCall(CI)) 
      return NOEFFECT;
    return CALL;
  } else if (auto *LI = dyn_cast<LoadInst>(V)) {
    return getOpType(LI->getPointerOperand());
  } else if (auto *SI = dyn_cast<StoreInst>(V)) {
    return getOpType(SI->getPointerOperand());
  }
  return NOEFFECT;
}

void ResetPointer(Module *M) {
  LLVMContext &context = M->getContext();
  auto *VoidFTy = FunctionType::get(Type::getVoidTy(context), {}, false);
  Function *reset_stack = Function::Create(VoidFTy, Function::ExternalLinkage, ResetStackName, M);
  Function *reset_heap = Function::Create(VoidFTy, Function::ExternalLinkage, ResetHeapName, M);

  for (auto &F : *M) for (auto &BB : F) {
    vector<Instruction*> s,h;

    int state=UNKNOWN;
    for(auto &itr : BB) {
        int cur = getAccessType(&itr);
        if(cur==NOEFFECT) {
          continue;
        }
        if(cur==CALL || cur==UNKNOWN) {
          state=UNKNOWN;
          continue;
        }

        if(cur==STACK) {
          if(state==HEAP) s.push_back(&itr);
          state=STACK;
        }

        if(cur==HEAP) {
          if(state==STACK) h.push_back(&itr);
          state=HEAP;
        }
    }
    if(s.empty() && h.empty()) continue;
    for(auto &iptr : s) {
      CallInst *I = CallInst::Create(reset_stack);//->getFunctionType(), reset_stack, {}, "");
      I->insertBefore(iptr);
    }
    for(auto &iptr : h) {
      CallInst *I = CallInst::Create(reset_heap);//->getFunctionType(), reset_heap, {}, "");
      I->insertBefore(iptr);
    }
  }
}
