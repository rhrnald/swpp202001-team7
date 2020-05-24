#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/SourceMgr.h"
#include "gtest/gtest.h"

#include "../passes/ReorderMemAccess.h"

using namespace llvm;
using namespace std;

TEST(PassCheck, ReorderMemAccessTest) {
  // Create an IR Module.
  LLVMContext Context;
  unique_ptr<Module> M(new Module("MyTestModule", Context));
  auto *TestFTy = FunctionType::get(Type::getVoidTy(Context), {}, false);
  auto *MallocFTy = FunctionType::get(Type::getInt8PtrTy(Context),
                                      { Type::getInt64Ty(Context) }, false);
  Function *TestF = Function::Create(TestFTy, Function::ExternalLinkage,
                                     "test", *M);
  Function *MallocF = Function::Create(MallocFTy, Function::ExternalLinkage,
                                       "malloc", *M);

  //////////////////////////////Create Function//////////////////////////////
  BasicBlock *Entry = BasicBlock::Create(Context, "entry", TestF);
  IRBuilder<> EntryBuilder(Entry);

  //Allocate
  auto *m1 = EntryBuilder.CreateCall(MallocF, ConstantInt::get(Type::getInt64Ty(Context), 8), "p1");
  auto *s1 = EntryBuilder.CreateAlloca(Type::getInt8PtrTy(Context), nullptr, "q1");
  auto *m2 = EntryBuilder.CreateCall(MallocF, ConstantInt::get(Type::getInt64Ty(Context), 8), "p2");
  auto *s2 = EntryBuilder.CreateAlloca(Type::getInt8PtrTy(Context), nullptr, "q2");

  //Load/Store
  auto *ms1 = EntryBuilder.CreateStore(m1, ConstantInt::get(Type::getInt8Ty(Context), 1));
  auto *ss1 = EntryBuilder.CreateStore(s1, ConstantInt::get(Type::getInt8Ty(Context), 1));
  auto *ms2 = EntryBuilder.CreateStore(m2, ConstantInt::get(Type::getInt8Ty(Context), 1));
  auto *ss2 = EntryBuilder.CreateStore(s2, ConstantInt::get(Type::getInt8Ty(Context), 1));

  //Exit Block
  BasicBlock *Exit = BasicBlock::Create(Context, "exit", TestF);
  EntryBuilder.CreateBr(Exit);
  IRBuilder<>(Exit).CreateRetVoid();
  ///////////////////////////////Apply Pass//////////////////////////////////
  LoopAnalysisManager LAM;
  FunctionAnalysisManager FAM;
  CGSCCAnalysisManager CGAM;
  ModuleAnalysisManager MAM;
  PassBuilder PB;
  PB.registerModuleAnalyses(MAM);
  PB.registerCGSCCAnalyses(CGAM);
  PB.registerFunctionAnalyses(FAM);
  PB.registerLoopAnalyses(LAM);
  PB.crossRegisterProxies(LAM, FAM, CGAM, MAM);

  ModulePassManager MPM;
  MPM.addPass(ReorderMemAccess());

  //////////////////////////////////Test/////////////////////////////////////
  vector<Instruction*> bef, aft;
  for (auto &F : *M) for (auto &BB : F) {
    if(BB.getName()=="entry") {
      for(auto &inst : BB.getInstList()) {
        bef.push_back(&inst);
      }
    }
  }

  MPM.run(*M, MAM);

  for (auto &F : *M) for (auto &BB : F) {
    if(BB.getName()=="entry") {
      for(auto &inst : BB.getInstList()) {
        aft.push_back(&inst);
      }
    }
  }

  EXPECT_EQ(aft[0],bef[1]);
  EXPECT_EQ(aft[1],bef[3]);
  EXPECT_EQ(aft[2],bef[5]);
  EXPECT_EQ(aft[3],bef[7]);
  EXPECT_EQ(aft[4],bef[0]);
  EXPECT_EQ(aft[5],bef[2]);
  EXPECT_EQ(aft[6],bef[4]);
  EXPECT_EQ(aft[7],bef[6]);
}
