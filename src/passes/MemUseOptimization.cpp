#include "MemUseOptimization.h"

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"

using namespace llvm;
using namespace std;

PreservedAnalyses MemUseOptimization::run(Module &M, ModuleAnalysisManager &MAM) {
  LLVMContext &Context = M.getContext();
  Type *I64Ty = Type::getInt64Ty(Context);
  Type *I1Ty = Type::getInt1Ty(Context);
  Type *I8PtrTy = Type::getInt8PtrTy(Context);

  Function *MainFn, *MallocFn, *AllocaBytesFn, *GetSPFn, *FreeFn;
  FunctionType *MainTy, *MallocTy, *AllocaBytesTy, *GetSPTy, *FreeTy;

  MallocFn = AllocaBytesFn = MainFn = GetSPFn = NULL;
  // Fetch the corresponding functions from the module
  for (auto &F : M) {
    if (F.getName() == "malloc") {
      MallocFn = &F, MallocTy = dyn_cast<FunctionType>(F.getValueType());
    } else if (F.getName() == "free") {
      FreeFn = &F, FreeTy = dyn_cast<FunctionType>(F.getValueType());
    } else if (F.getName() == AllocaBytesName) {
      AllocaBytesFn = &F, AllocaBytesTy = dyn_cast<FunctionType>(F.getValueType());
    } else if (F.getName() == GetSPName) {
      GetSPFn = &F, GetSPTy = dyn_cast<FunctionType>(F.getValueType());
    } else if (F.getName() == "main") {
      MainFn = &F, MainTy = dyn_cast<FunctionType>(F.getValueType());
    }
  }

  // Main function must exist
  assert(MainFn != NULL && "No main function in the IR module!");

  // Create AllocaBytes and GetSP if they don't exist
  if (AllocaBytesFn == NULL) {
    AllocaBytesTy = FunctionType::get(Type::getInt8PtrTy(Context),
                              { I64Ty, I64Ty }, false);
    AllocaBytesFn = Function::Create(AllocaBytesTy, Function::ExternalLinkage,
                                    AllocaBytesName, M);
  }
  if (GetSPFn == NULL) {
    GetSPTy = FunctionType::get(I64Ty, {}, false);
    GetSPFn = Function::Create(GetSPTy, Function::ExternalLinkage, GetSPName, M);
  }

  if (!GetSPFn->hasFnAttribute(Attribute::NoInline))
    GetSPFn->addFnAttr(Attribute::NoInline);

  vector<CallInst*> MallocInsts;
  vector<CallInst*> FreeInsts;

  FunctionAnalysisManager &FAM
    = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  LoopInfo LI(FAM.getResult<DominatorTreeAnalysis>(*MainFn));

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
    BasicBlock *SplitBB = BB->splitBasicBlock(CI, "div." + BB->getName());
    BasicBlock *AllocaBB = BasicBlock::Create(Context, "alloca." + BB->getName(), MainFn);
    BasicBlock *MallocBB = BasicBlock::Create(Context, "malloc." + BB->getName(), MainFn);

    Value *AllocSize = CI->getOperand(0);

    auto *CurrentSP = CallInst::Create(GetSPTy, GetSPFn, {}, "cur.sp");
    auto *SubSP = llvm::BinaryOperator::CreateSub(CurrentSP, AllocSize, "lookahead.sp");
    auto *CmpSP = new ICmpInst(ICmpInst::ICMP_SGE, SubSP,
                        ConstantInt::get(I64Ty, STACK_DANGEROUS_REGION), "cmp.sp");
    auto *BrSP = BranchInst::Create(AllocaBB, MallocBB, CmpSP);

    BB->getInstList().pop_back();
    BB->getInstList().push_back(CurrentSP);
    BB->getInstList().push_back(SubSP);
    BB->getInstList().push_back(CmpSP);
    BB->getInstList().push_back(BrSP);

    auto *AllocaBytes = CallInst::Create(AllocaBytesTy, AllocaBytesFn,
                          {AllocSize, ConstantInt::get(I64Ty, 0)}, "by.alloca_bytes");
    auto *BackFromAllocaBytes = BranchInst::Create(SplitBB);

    AllocaBB->getInstList().push_back(AllocaBytes);
    AllocaBB->getInstList().push_back(BackFromAllocaBytes);

    auto *Malloc = CallInst::Create(MallocTy, MallocFn, {AllocSize}, "by.malloc");
    auto *BackFromMalloc = BranchInst::Create(SplitBB);

    MallocBB->getInstList().push_back(Malloc);
    MallocBB->getInstList().push_back(BackFromMalloc);

    auto *Phi = PHINode::Create(CI->getType(), 2, "allocation." + CI->getName());
    Phi->addIncoming(AllocaBytes, AllocaBB);
    Phi->addIncoming(Malloc, MallocBB);
    SplitBB->getInstList().push_front(Phi);

    CI->replaceAllUsesWith(Phi);
    CI->eraseFromParent();
  }

  for (auto &CI : FreeInsts) {
    BasicBlock *BB = CI->getParent();
    BasicBlock *SplitBB = BB->splitBasicBlock(CI, "div." + BB->getName());
    BasicBlock *MallocBB = BasicBlock::Create(Context, "free." + BB->getName(), MainFn);

    Value *AllocPtr = CI->getOperand(0);

    auto *AllocPos = new PtrToIntInst(AllocPtr, I64Ty, "sp.as.int");
    auto *CmpSP = new ICmpInst(ICmpInst::ICMP_SGE, AllocPos,
                        ConstantInt::get(I64Ty, STACK_BOUNDARY), "cmp.sp");
    auto *BrSP = BranchInst::Create(MallocBB, SplitBB, CmpSP);

    BB->getInstList().pop_back();
    BB->getInstList().push_back(AllocPos);
    BB->getInstList().push_back(CmpSP);
    BB->getInstList().push_back(BrSP);

    auto *Free = CallInst::Create(FreeTy, FreeFn, {AllocPtr});
    auto *Back = BranchInst::Create(SplitBB);

    MallocBB->getInstList().push_back(Free);
    MallocBB->getInstList().push_back(Back);

    CI->eraseFromParent();
  }

  return PreservedAnalyses::all();
}