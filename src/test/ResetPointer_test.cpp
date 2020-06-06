#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/SourceMgr.h"
#include "gtest/gtest.h"

#include "../passes/Wrapper.h"

using namespace llvm;
using namespace std;

#ifdef REORDER_MEM_ACCESS

void ResetPointer(Module *M);

TEST(PassCheck, ResetPointerTest) {
  // Create an IR Module.
  LLVMContext Context;
  Module *M=new Module("MyTestModule", Context);
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
  auto *s1 = EntryBuilder.CreateAlloca(Type::getInt8Ty(Context));
  auto *m2 = EntryBuilder.CreateCall(MallocF, ConstantInt::get(Type::getInt64Ty(Context), 8), "p2");
  auto *s2 = EntryBuilder.CreateAlloca(Type::getInt8Ty(Context));

  //Load/Store
  auto *ms1 = EntryBuilder.CreateStore(ConstantInt::get(Type::getInt8Ty(Context), 1), m1);
  auto *ss1 = EntryBuilder.CreateStore(ConstantInt::get(Type::getInt8Ty(Context), 1), s1);
  auto *ms2 = EntryBuilder.CreateStore(ConstantInt::get(Type::getInt8Ty(Context), 1), m2);
  auto *ss2 = EntryBuilder.CreateStore(ConstantInt::get(Type::getInt8Ty(Context), 1), s2);

  //Exit Block
  BasicBlock *Exit = BasicBlock::Create(Context, "exit", TestF);
  EntryBuilder.CreateBr(Exit);
  IRBuilder<>(Exit).CreateRetVoid();
  ///////////////////////////////Apply Pass//////////////////////////////////
  ResetPointer(M);
  //////////////////////////////////Test/////////////////////////////////////
  bool exist_reset_heap=false;
  bool exist_reset_stack=false;

  for (auto &F : *M) for (auto &BB : F) {
    if(BB.getName()=="entry") {
      for(auto &inst : BB.getInstList()) {
        if (auto *CI = dyn_cast<CallInst>(&inst)) {
          if(CI->getCalledFunction()->getName() == "__reset_heap__") exist_reset_heap=true;
          if(CI->getCalledFunction()->getName() == "__reset_stack__") exist_reset_stack=true;
        }
      }
    }
  }

  EXPECT_EQ(exist_reset_heap, true);
  EXPECT_EQ(exist_reset_stack, true);
}

#endif
