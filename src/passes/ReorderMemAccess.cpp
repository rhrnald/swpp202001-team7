#include "ReorderMemAccess.h"

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/InstVisitor.h"

using namespace llvm;
using namespace llvm::PatternMatch;
using namespace std;


enum AllocType {
  STACK, HEAP, UNKNOWN
};

static bool isMallocCall(const CallInst *CI) {
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
static bool isAllocaByteCall(const CallInst *CI) {
  return CI->getCalledFunction()->getName() == "__alloca_bytes__";
}

// A very simple getBlockType().
// Sees which memory area V is pointing to.
AllocType getBlockType(const Value *V) {
  if (auto *CI = dyn_cast<CallInst>(V)) {
    if (isMallocCall(CI))
      return HEAP;
    if (isAllocaByteCall(CI)) 
      return STACK;
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

//check if instruction I must be infront of instruction J
bool checkDom(Instruction* I, Instruction* J) {
  int Itype=getBlockType(I);
  int Jtype=getBlockType(J);
  if(Itype==Jtype && (Itype!=UNKNOWN)) return true;

  /*for(auto ptr : J->getOperandList()) {
    if(ptr==I) return true;
  }
  return false;*/
  
  int num=J->getNumOperands();
  for(int i=0; i<num; i++)
    if(J->getOperand(i) == I) return true;
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
