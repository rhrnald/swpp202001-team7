#include "MemUseOptimization.h"

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Pass.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/IRBuilder.h"

using namespace llvm;
//using namespace llvm::PatternMatch;
using namespace std;

PreservedAnalyses MemUseOptimization::run(Module &M, ModuleAnalysisManager &MAM) {

  LLVMContext &Context = M.getContext();
  Type *I64Ty = Type::getInt64Ty(Context);
  Type *I1Ty = Type::getInt1Ty(Context);
  Type *I8PtrTy = Type::getInt8PtrTy(Context);

  Function *MainFn, *MallocFn, *AllocaBytesFn, *GetSPFn, *FreeFn;
  FunctionType *MainTy, *MallocTy, *AllocaBytesTy, *GetSPTy, *FreeTy;

  MallocFn = AllocaBytesFn = MainFn = GetSPFn = NULL;
  for (auto &F : M) {
    if (F.getName() == "malloc") {
      MallocFn = &F, MallocTy = dyn_cast<FunctionType>(F.getValueType());
    } else if (F.getName() == "__alloca_bytes__") {
      AllocaBytesFn = &F, AllocaBytesTy = dyn_cast<FunctionType>(F.getValueType());
    } else if (F.getName() == "__get_stack_pointer__") {
      GetSPFn = &F, GetSPTy = dyn_cast<FunctionType>(F.getValueType());
    } else if (F.getName() == "free") {
      FreeFn = &F, FreeTy = dyn_cast<FunctionType>(F.getValueType());
    } else if (F.getName() == "main") {
      MainFn = &F, MainTy = dyn_cast<FunctionType>(F.getValueType());
    }
  }

  assert(MainFn != NULL);

  if (AllocaBytesFn == NULL) {
    AllocaBytesTy = FunctionType::get(Type::getInt8PtrTy(Context),
                              { Type::getInt64Ty(Context), Type::getInt64Ty(Context) }, false);
    AllocaBytesFn = Function::Create(AllocaBytesTy, Function::ExternalLinkage,
                                  "__alloca_bytes__", M);
  }
  if (GetSPFn == NULL) {
    GetSPTy = FunctionType::get(Type::getInt64Ty(Context), { }, false);
    GetSPFn = Function::Create(GetSPTy, Function::ExternalLinkage,
                                    "__get_stack_pointer__", M);
  }

  BasicBlock *Entry = BasicBlock::Create(Context, "entry", GetSPFn);
  IRBuilder<> EntryBuilder(Entry);
  EntryBuilder.CreateRet(ConstantInt::get(Type::getInt64Ty(Context), 10240));

  set<BasicBlock*> BlockInLoop;

  FunctionAnalysisManager &FAM
    = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  //DominatorTree &DT = ;
  LoopInfo LI(FAM.getResult<DominatorTreeAnalysis>(*MainFn));

  vector<CallInst*> MallocInsts;
  vector<CallInst*> FreeInsts;

  for (auto &BB : *MainFn) {
    if (LI.getLoopFor(&BB)) continue;
    for (auto &I : BB) {
      if (CallInst *CI = dyn_cast<CallInst>(&I)) {
        if (CI->getCalledFunction() == MallocFn)
          MallocInsts.push_back(CI);
        if (CI->getCalledFunction() == FreeFn)
          FreeInsts.push_back(CI);
      }
    }
  }

  if (MallocInsts.empty()) {
    return PreservedAnalyses::all();
  }

  for (auto &CI : MallocInsts) {
    BasicBlock *BB = CI->getParent();
    BasicBlock *SplitBB = BB->splitBasicBlock(CI, "divided." + BB->getName());
    BasicBlock *AllocaBB = BasicBlock::Create(Context, "alloca." + BB->getName(), MainFn);
    BasicBlock *MallocBB = BasicBlock::Create(Context, "malloc." + BB->getName(), MainFn);

    Value *AllocSize = CI->getOperand(0);

    CallInst *CurrentSP = CallInst::Create(GetSPTy, GetSPFn, {}, "cur.sp");
    Instruction *SubSP = llvm::BinaryOperator::CreateSub(CurrentSP, AllocSize, "lookahead.sp");
    ICmpInst *CmpSP = new ICmpInst(ICmpInst::ICMP_SGE, SubSP, ConstantInt::get(Type::getInt64Ty(Context), 5120), "cmp.sp");
    BranchInst *BrSP = BranchInst::Create(AllocaBB, MallocBB, CmpSP);

    BB->getInstList().pop_back();
    BB->getInstList().push_back(CurrentSP);
    BB->getInstList().push_back(SubSP);
    BB->getInstList().push_back(CmpSP);
    BB->getInstList().push_back(BrSP);

    CallInst *AllocaBytes = CallInst::Create(AllocaBytesTy, AllocaBytesFn, {AllocSize, ConstantInt::get(Type::getInt64Ty(Context), 0)}, "by.alloca_bytes");
    BranchInst *Back1 = BranchInst::Create(SplitBB);

    AllocaBB->getInstList().push_back(AllocaBytes);
    AllocaBB->getInstList().push_back(Back1);

    CallInst *Malloc = CallInst::Create(MallocTy, MallocFn, {AllocSize}, "by.malloc");
    BranchInst *Back2 = BranchInst::Create(SplitBB);

    MallocBB->getInstList().push_back(Malloc);
    MallocBB->getInstList().push_back(Back2);

    PHINode *Phi = PHINode::Create(CI->getType(), 2, "allocation");
    Phi->addIncoming(AllocaBytes, AllocaBB);
    Phi->addIncoming(Malloc, MallocBB);
    SplitBB->getInstList().push_front(Phi);

    CI->replaceAllUsesWith(Phi);
    CI->eraseFromParent();
  }

  for (auto &CI : FreeInsts) {
    BasicBlock *BB = CI->getParent();
    BasicBlock *SplitBB = BB->splitBasicBlock(CI, "divided." + BB->getName());
    BasicBlock *MallocBB = BasicBlock::Create(Context, "malloc." + BB->getName(), MainFn);

    Value *AllocPtr = CI->getOperand(0);

    PtrToIntInst *AllocPos = new PtrToIntInst(AllocPtr, Type::getInt64Ty(Context), "stack.pos");
    ICmpInst *CmpSP = new ICmpInst(ICmpInst::ICMP_SGE, AllocPos, ConstantInt::get(Type::getInt64Ty(Context), 10240), "cmp.sp");
    BranchInst *BrSP = BranchInst::Create(MallocBB, SplitBB, CmpSP);

    BB->getInstList().pop_back();
    BB->getInstList().push_back(AllocPos);
    BB->getInstList().push_back(CmpSP);
    BB->getInstList().push_back(BrSP);

    CallInst *Free = CallInst::Create(FreeTy, FreeFn, {AllocPtr});
    BranchInst *Back = BranchInst::Create(SplitBB);

    MallocBB->getInstList().push_back(Free);
    MallocBB->getInstList().push_back(Back);

    CI->eraseFromParent();
  }

  return PreservedAnalyses::all();
}
