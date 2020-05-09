#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/PassAnalysisSupport.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"

using namespace llvm;
using namespace std;


namespace {
class PackRegisters : public PassInfoMixin<PackRegisters> {

private:
    
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
    unique_ptr<DataLayout> DL(new DataLayout(&M));
    FunctionAnalysisManager &FAM = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
    
    // This below debug codes should be deleted.
    outs() << "(PackRegisters) Module Name: " << M.getName() << "\n";

    for (Function &F : M) {
      if (F.getName() == "main") {
        BasicBlock &BB = F.getEntryBlock();
        LLVMContext &Context = F.getContext();
        for (auto &I : BB) {
          Value *Lef = ConstantInt::get(Type::getInt32Ty(Context), 4);
          Value *Rig = ConstantInt::get(Type::getInt32Ty(Context), 5);
          Instruction *II = BinaryOperator::CreateAdd(Lef, Rig);

          BB.getInstList().insertAfter(I.getIterator(), II);

          break;
        }
      }
    }

    Function *pF, *nF;
    for (Function &F : M) {
      pF = &F;
      break;
    }

    ValueToValueMapTy VMap;

    vector<Type*> ArgTy;
    FunctionType *FTy = FunctionType::get(pF->getFunctionType()->getReturnType(), ArgTy, false);
    nF = Function::Create(FTy, Function::ExternalLinkage, "test", M);

    LLVMContext &Context = pF->getContext();

    BasicBlock *pBPE = &(pF->getEntryBlock());
    BasicBlock *pBE = BasicBlock::Create(Context, "");

    pF->getBasicBlockList().push_front(pBE);
    Value *Lef = ConstantInt::get(Type::getInt32Ty(Context), 4);
    Value *Rig = ConstantInt::get(Type::getInt32Ty(Context), 5);
    Instruction *II = BinaryOperator::CreateAdd(Lef, Rig, "newa");
    pBE->getInstList().push_back(II);
    BranchInst *Br = BranchInst::Create(pBPE, pBE);
    Value *AA = pF->arg_begin();
    AA->replaceAllUsesWith(II);

    for (auto &pBB : *pF) {
      BasicBlock *nBB = CloneBasicBlock(&pBB, VMap, "", nF);
      VMap[&pBB] = nBB;
    }

/*
    vector<Type*> ArgTy;
    FunctionType *FTy = FunctionType::get(pF->getFunctionType()->getReturnType(), ArgTy, false);
    nF = Function::Create(FTy, Function::ExternalLinkage, "test", M);

    LLVMContext &Context = nF->getContext();

    BasicBlock *nBE = BasicBlock::Create(Context, "", nF);
    Value *Lef = ConstantInt::get(Type::getInt32Ty(Context), 4);
    Value *Rig = ConstantInt::get(Type::getInt32Ty(Context), 5);
    Instruction *II = BinaryOperator::CreateAdd(Lef, Rig, "newa");
    nBE->getInstList().push_back(II);
    Value *AA = pF->arg_begin();

    BasicBlock *nSB = NULL;
    outs() << AA->getName() << "\n";
    outs() << II->getName() << "\n";

    for (auto &pBB : *pF) {
      BasicBlock *nBB = CloneBasicBlock(&pBB, VMap, "", nF);
      if (!nSB) nSB = nBB;
      VMap[&pBB] = nBB;
    }

    BranchInst *Br = BranchInst::Create(nSB, nBE);
*/
/*

    ValueToValueMapTy VMap;


    //for (auto &A : sF->args()) { ArgTy.push_back(A.getType()); }

    FunctionType *FTy = FunctionType::get(sF->getFunctionType()->getReturnType(), ArgTy, false);
    // FunctionType *FTy = sF->getFunctionType();
    nF = Function::Create(FTy, Function::ExternalLinkage, "test", M);

    Function::arg_iterator It = nF->arg_begin();
    for (auto &A : sF->args()) {
      It->setName(A.getName());
      VMap[&A] = &*It++;
    }

    auto Name = sF->getName();
    SmallVector<ReturnInst*, 8> Returns;

    CloneFunctionInto(nF, sF, VMap, sF->getSubprogram() != NULL, Returns, "");
*/
    // sF->removeFromParent();
    // newF->setName(Name);

/*
    auto *TestFTy = sF->getFunctionType();
    LLVMContext &Context = M.getContext();
    Function *TestF = Function::Create(TestFTy, Function::ExternalLinkage,
                                     "test", M);  
    // BasicBlock *Entry = BasicBlock::Create(Context, "entry", TestF);
    // ReturnInst *Ret = ReturnInst::Create(Context, Entry);

    for (auto &BB : *sF) {
      BasicBlock *newB = BasicBlock::Create(Context, BB.getName(), TestF);
      for (auto &I : BB) {
        auto *newI = Instruction::clone(I);
      }
    }
    */

    return PreservedAnalyses::all();
  }
};
}