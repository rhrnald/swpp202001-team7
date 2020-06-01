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

  Function *MainFn, *MallocFn, *AllocaBytesFn, *GetSPFn;
  FunctionType *MainTy, *MallocTy, *AllocaBytesTy, *GetSPTy;

  MallocFn = AllocaBytesFn = MainFn = NULL;
  for (auto &F : M) {
    if (F.getName() == "malloc") {
      MallocFn = &F;
      MallocTy = dyn_cast<FunctionType>(F.getValueType());
    }
    if (F.getName() == "__alloca_bytes__") {
      AllocaBytesFn = &F;
    }
    if (F.getName() == "main") {
      MainFn = &F;
      MainTy = dyn_cast<FunctionType>(F.getValueType());
    }
  }
  assert(MainFn != NULL);

  if (MallocFn == NULL) {
    MallocTy = FunctionType::get(Type::getInt8PtrTy(Context),
                              { Type::getInt64Ty(Context) }, false);
    MallocFn = Function::Create(MallocTy, Function::ExternalLinkage,
                                  "malloc", M);
  }
  if (AllocaBytesFn == NULL) {
    AllocaBytesTy = FunctionType::get(Type::getInt8PtrTy(Context),
                              { Type::getInt64Ty(Context), Type::getInt64Ty(Context) }, false);
    AllocaBytesFn = Function::Create(AllocaBytesTy, Function::ExternalLinkage,
                                  "__alloca_bytes__", M);
  }

  GetSPTy = FunctionType::get(Type::getInt64Ty(Context), { }, false);
  GetSPFn = Function::Create(GetSPTy, Function::ExternalLinkage,
                                  "__get_stack_pointer__", M);

  BasicBlock *Entry = BasicBlock::Create(Context, "entry", GetSPFn);
  IRBuilder<> EntryBuilder(Entry);
  EntryBuilder.CreateRet(ConstantInt::get(Type::getInt64Ty(Context), 10240));

  set<BasicBlock*> BlockInLoop;

  FunctionAnalysisManager &FAM
    = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(*MainFn);
  LoopInfo LI(DT);

  vector<CallInst*> Candidates;
  CallInst *CI;
  Instruction *CurrentSP;
  //vector<Value*> EmptyArg;
  //CurrentSP = CallInst::Create(GetSPTy, GetSPFn, EmptyArg);

  for (auto &BB : *MainFn) {
    if (LI.getLoopFor(&BB)) {
      outs() << BB.getName() << " is in the loop\n";
      continue;
    }
    for (auto &I : BB) {
      if ((CI = dyn_cast<CallInst>(&I)) &&
             CI->getCalledFunction() == MallocFn)
        Candidates.push_back(CI);
    }
  }

  if (Candidates.empty()) {
    AllocaBytesFn->eraseFromParent();
    GetSPFn->eraseFromParent();
    return PreservedAnalyses::all();
  }

  for (auto &CI : Candidates) {
    BasicBlock *BB = CI->getParent();
    BasicBlock *SplitBB = BB->splitBasicBlock(CI, "divided." + BB->getName());
    BasicBlock *AllocaBB = BasicBlock::Create(Context, "alloca." + BB->getName(), MainFn);
    BasicBlock *MallocBB = BasicBlock::Create(Context, "malloc." + BB->getName(), MainFn);

    Value *AllocSize = CI->getOperand(0);

    CallInst *CurrentSP = CallInst::Create(GetSPTy, GetSPFn, {}, "cur.sp");
    //Instruction *CurrentSP = llvm::BinaryOperator::CreateMul(AllocSize, AllocSize, "sss");
    Instruction *SubSP = llvm::BinaryOperator::CreateSub(CurrentSP, AllocSize, "lookahead.sp");
    ICmpInst *CmpSP = new ICmpInst(ICmpInst::ICMP_SGE, SubSP, ConstantInt::get(Type::getInt64Ty(Context), 10240), "cmp.sp");
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

  //outs() << M;

  return PreservedAnalyses::all();
}
