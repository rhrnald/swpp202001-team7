#include "MemUseOptimization.h"

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
    AllocaBytesTy = FunctionType::get(I8PtrTy, {I64Ty, I64Ty}, false);
    AllocaBytesFn = Function::Create(AllocaBytesTy, Function::ExternalLinkage,
                                    AllocaBytesName, M);
  }
  if (GetSPFn == NULL) {
    GetSPTy = FunctionType::get(I64Ty, {}, false);
    GetSPFn = Function::Create(GetSPTy, Function::ExternalLinkage, GetSPName, M);
  }

  // GetSPFn should not be inlined
  if (!GetSPFn->hasFnAttribute(Attribute::NoInline))
    GetSPFn->addFnAttr(Attribute::NoInline);

  // Fetch malloc and free instruction in main, that are not on any loops
  vector<CallInst*> MallocInsts;
  vector<CallInst*> FreeInsts;

  FunctionAnalysisManager &FAM
    = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  LoopInfo LI(FAM.getResult<DominatorTreeAnalysis>(*MainFn));

  for (auto &BB : *MainFn) {
    if (LI.getLoopFor(&BB)) continue; // Ignore loop blocks
    for (auto &I : BB) {
      if (CallInst *CI = dyn_cast<CallInst>(&I)) {
        if (CI->getCalledFunction() == MallocFn)
          MallocInsts.push_back(CI);
        if (CI->getCalledFunction() == FreeFn)
          FreeInsts.push_back(CI);
      }
    }
  }

  // No need to optimize if there is no candidate malloc
  if (MallocInsts.empty()) {
    return PreservedAnalyses::all();
  }

  /* Convert all candidate malloc(size) to:
   * if (__get_stack_pointer__() - size >= STACK_DANGEROUS_REGION)
   *   return alloca_bytes(size);
   * else
   *   return malloc(size); */
  for (auto &CI : MallocInsts) {
    BasicBlock *BB = CI->getParent();
    BasicBlock *SplitBB = BB->splitBasicBlock(CI, "div." + BB->getName());
    BasicBlock *AllocaBB = BasicBlock::Create(Context, "alloca." + BB->getName(), MainFn);
    BasicBlock *MallocBB = BasicBlock::Create(Context, "malloc." + BB->getName(), MainFn);

    Value *AllocSize = CI->getOperand(0);

    // Basic Block Conditional Branch Update
    auto *CurrentSP = CallInst::Create(GetSPTy, GetSPFn, {}, "cur.sp");
    auto *SubSP = llvm::BinaryOperator::CreateSub(CurrentSP, AllocSize, "lookahead.sp");
    auto *CmpSP = new ICmpInst(ICmpInst::ICMP_SGE, SubSP,
                        ConstantInt::get(I64Ty, STACK_DANGEROUS_REGION), "is.safe.sp");
    auto *BrSP = BranchInst::Create(AllocaBB, MallocBB, CmpSP);

    BB->getInstList().pop_back();           // Remove BranchInst BB->SplitBB
    BB->getInstList().push_back(CurrentSP); // __get_stack_pointer()__
    BB->getInstList().push_back(SubSP);     // __get_stack_pointer()__ - size
    BB->getInstList().push_back(CmpSP);     // (..) >= STACK_DANGEROUS_REGION
    BB->getInstList().push_back(BrSP);      // True: AllocaBB, False: MallocBB

    // Alloca Basic Block
    auto *AllocaBytes = CallInst::Create(AllocaBytesTy, AllocaBytesFn,
                          {AllocSize, ConstantInt::get(I64Ty, 0)}, "by.alloca_bytes");
    auto *BackFromAllocaBytes = BranchInst::Create(SplitBB);

    AllocaBB->getInstList().push_back(AllocaBytes); // __alloca_bytes__(size, free_in_block=0)
    AllocaBB->getInstList().push_back(BackFromAllocaBytes);

    // Malloc Basic Block
    auto *Malloc = CallInst::Create(MallocTy, MallocFn, {AllocSize}, "by.malloc");
    auto *BackFromMalloc = BranchInst::Create(SplitBB);

    MallocBB->getInstList().push_back(Malloc); // malloc(size)
    MallocBB->getInstList().push_back(BackFromMalloc);

    // Splited Basic Block; Absolb allocation using a PHI node
    auto *Phi = PHINode::Create(CI->getType(), 2, "allocation." + CI->getName());
    Phi->addIncoming(AllocaBytes, AllocaBB);
    Phi->addIncoming(Malloc, MallocBB);
    SplitBB->getInstList().push_front(Phi);

    CI->replaceAllUsesWith(Phi);
    CI->eraseFromParent();
  }

  /* Convert all candidate free(ptr) to: (since they can be either STACK or HEAP alloc)
   * if ((int) ptr >= STACK_BOUNDARY)
   *   free(ptr)
   * else
   *   ; // do nothing */
  for (auto &CI : FreeInsts) {
    BasicBlock *BB = CI->getParent();
    BasicBlock *SplitBB = BB->splitBasicBlock(CI, "div." + BB->getName());
    BasicBlock *FreeBB = BasicBlock::Create(Context, "free." + BB->getName(), MainFn);

    Value *AllocPtr = CI->getOperand(0);

    // Basic Block Conditional Branch Update
    auto *AllocPos = new PtrToIntInst(AllocPtr, I64Ty, "sp.as.int");
    auto *CmpSP = new ICmpInst(ICmpInst::ICMP_SGE, AllocPos,
                        ConstantInt::get(I64Ty, STACK_BOUNDARY), "cmp.sp");
    auto *BrSP = BranchInst::Create(FreeBB, SplitBB, CmpSP);

    BB->getInstList().pop_back();          // Remove BranchInst BB->SplitBB
    BB->getInstList().push_back(AllocPos); // (int) ptr
    BB->getInstList().push_back(CmpSP);    // (int) ptr >= STACK_BOUNDARY
    BB->getInstList().push_back(BrSP);     // True: FreeBB, False: SplitBB

    // FreeBB for actual free in HEAP area
    auto *Free = CallInst::Create(FreeTy, FreeFn, {AllocPtr});
    auto *Back = BranchInst::Create(SplitBB);

    FreeBB->getInstList().push_back(Free);
    FreeBB->getInstList().push_back(Back);

    CI->eraseFromParent();
  }

  return PreservedAnalyses::all();
}