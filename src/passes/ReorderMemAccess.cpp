#include "ReorderMemAccess.h"

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/InstVisitor.h"

using namespace llvm;
using namespace llvm::PatternMatch;
using namespace std;


enum AllocType {
  STACK, HEAP, UNKNOWN, CALL, NOEFFECT
};

bool isMallocCall(const CallInst *CI) {
  // Assume that it is undefined behavior for a program to define a
  // 'malloc' function.
  // Actually this is what C standard says. :) "malloc" is categorized as a
  // 'reserved keyword', so defining a "malloc" function is undefined behavior,
  // even if compiler may not complain about it at all.
  //
  // https://www.gnu.org/software/libc/manual/html_node/Reserved-Names.html
  //
  // C17 standard 7.1.3.2:
  //   If the program declares or defines an identifier in a context in which
  //   it is reserved (other than as allowed by 7.1.4), or defines a reserved
  //   identifier as a macro name, the behavior is undefined.
  return CI->getCalledFunction()->getName() == "malloc";
}
bool isAllocaByteCall(const CallInst *CI) {
  return CI->getCalledFunction()->getName() == "__alloca_bytes__";
}
bool isFreeCall(const CallInst *CI) {
  return CI->getCalledFunction()->getName() == "free";
}

AllocType getBlockType(const Value *V) {
  if (auto *CI = dyn_cast<CallInst>(V)) {
    if (isMallocCall(CI))
      return HEAP;
    if (isFreeCall(CI))
      return HEAP;
    if (isAllocaByteCall(CI)) 
      return STACK;
    return CALL;
  } else if (auto *AI = dyn_cast<AllocaInst>(V)) {
    return STACK;
  } else if (auto *BI = dyn_cast<BitCastInst>(V)) {
    return getBlockType(BI->getOperand(0));
  } else if (auto *GI = dyn_cast<GetElementPtrInst>(V)) {
    return getBlockType(GI->getPointerOperand());
  } else if (auto *LI = dyn_cast<LoadInst>(V)) {
    return getBlockType(LI->getPointerOperand());
  } else if (auto *SI = dyn_cast<StoreInst>(V)) {
    return getBlockType(SI->getPointerOperand());
  } else if (auto *GV = dyn_cast<GlobalVariable>(V)) {
    return HEAP;
  } else if (auto *BCO = dyn_cast<BitCastOperator>(V)) {
    return getBlockType(BCO->getOperand(0));
  }
  return UNKNOWN;
}
AllocType getOpTypeReorder(const Value *V) {
  if (auto *CI = dyn_cast<CallInst>(V)) {
    if (isMallocCall(CI))
      return HEAP;
    if (isFreeCall(CI))
      return HEAP;
    if (isAllocaByteCall(CI)) 
      return STACK;
    return UNKNOWN;
  } else if (auto *AI = dyn_cast<AllocaInst>(V)) {
    return STACK;
  } else if (auto *BI = dyn_cast<BitCastInst>(V)) {
    return getOpTypeReorder(BI->getOperand(0));
  } else if (auto *GI = dyn_cast<GetElementPtrInst>(V)) {
    return getOpTypeReorder(GI->getPointerOperand());
  } else if (auto *BCO = dyn_cast<BitCastOperator>(V)) {
    return getOpTypeReorder(BCO->getOperand(0));
  } else if (auto *GV = dyn_cast<GlobalVariable>(V)) {
    return HEAP;
  } else if (auto *BO = dyn_cast<BinaryOperator>(V)) {
    AllocType op1 = getOpTypeReorder(BO->getOperand(0));
    if(op1!=UNKNOWN) return op1;
    return getOpTypeReorder(BO->getOperand(1));
  }
  return UNKNOWN;
}
AllocType getAccessTypeReorder(const Value *V) {
  if (auto *CI = dyn_cast<CallInst>(V)) {
    if (isMallocCall(CI))
      return NOEFFECT;
    if (isFreeCall(CI))
      return NOEFFECT;
    if (isAllocaByteCall(CI)) 
      return NOEFFECT;
    return CALL;
  } else if (auto *LI = dyn_cast<LoadInst>(V)) {
    return getOpTypeReorder(LI->getPointerOperand());
  } else if (auto *SI = dyn_cast<StoreInst>(V)) {
    return getOpTypeReorder(SI->getPointerOperand());
  }
  return NOEFFECT;
}

//check if instruction I must be infront of instruction J
bool checkDom(Instruction* I, Instruction* J) {
  int num=J->getNumOperands();
  for(int i=0; i<num; i++)
    if(J->getOperand(i) == I) return true;

  int Itype=getAccessTypeReorder(I);
  int Jtype=getAccessTypeReorder(J);
  if(Itype==NOEFFECT || Jtype==NOEFFECT) return false;
  if(Itype==CALL || Jtype==CALL) return true;
  if(Itype!=NOEFFECT && Itype==Jtype && (Itype!=UNKNOWN)) return true;
  if(Itype!=NOEFFECT && Jtype==UNKNOWN) return true;
  
  return false;
}

PreservedAnalyses ReorderMemAccess::run(Module &M, ModuleAnalysisManager &MAM) {
  for (auto &F : M) for (auto &BB : F) {

    //Initialize
    vector<Instruction *> Insts, newInsts;
    for (auto &I : BB) {
      Insts.push_back(&I);
    }
    Instruction *BranchInst=Insts.back(); Insts.pop_back();

    int n = Insts.size();
    vector<vector<int>> dom;
    vector<int> type, cnt, used;
    dom.resize(n), type.resize(n), cnt.resize(n), used.resize(n);

    for(int i=0; i<n; i++) {
      type[i]=getBlockType(Insts[i]);
      used[i]=0;
    }
    
    //Check Dominance
    for(int i=0; i<n; i++) for(int j=i+1; j<n; j++) {
      if(checkDom(Insts[i], Insts[j])) {
        dom[i].push_back(j);
        cnt[j]++;
      }
    }

    //Reorder Instructions
    int lft=n;
    int block=HEAP;

    // Will block Heap and Stack in alternatively.
    // And push unblocked instruction which can be(not violating dominance).
    while(lft) { //While there are left Inst.

      bool flag=true;
      while(flag) { //While no more Inst pushed.
        flag=false;

        for(int i=0; i<n; i++) {
          if(used[i] || type[i]==block) continue; //If instruction is already used/ If instruction is blocked.

          if(!cnt[i]) { //No dominancy=No more instruction needed ahead of current instruction.
            flag=true;
            for(int nxt : dom[i]) cnt[nxt]--;
            used[i]=true;
            lft--;
            newInsts.push_back(Insts[i]);
          }
        }
      }

      //Change blocking.
      block=STACK+HEAP-block;
      /*
      if (block==HEAP) block=STACK;
      else if (block==STACK) block=UNKNOWN;
      else block=HEAP;
      */
    }

    //clear Block
    for (auto &Iptr : Insts) {
      Iptr->removeFromParent();
    }
    BranchInst->removeFromParent();

    //restruct Block
    for (auto &Iptr : newInsts) {
      BB.getInstList().push_back(Iptr);
    }
    BB.getInstList().push_back(BranchInst);
  }
  return PreservedAnalyses::all();
}
