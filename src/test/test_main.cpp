#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/SourceMgr.h"
#include "gtest/gtest.h"
#include "SimpleBackend.h"

using namespace llvm;
using namespace std;

TEST(TestDemo, CheckMain) {
  // Show that the assembler correctly emits 'start main 0' as well as 'end main'
  LLVMContext Context;
  unique_ptr<Module> M(new Module("MyTestModule", Context));
  auto *I64Ty = Type::getInt64Ty(Context);
  auto *TestFTy = FunctionType::get(I64Ty, {}, false);
  Function *TestF = Function::Create(TestFTy, Function::ExternalLinkage,
                                     "main", *M);

  BasicBlock *Entry = BasicBlock::Create(Context, "entry", TestF);
  IRBuilder<> EntryBuilder(Entry);
  EntryBuilder.CreateRet(ConstantInt::get(I64Ty, 0));

  string str;
  raw_string_ostream os(str);
  AssemblyEmitter(&os).run(M.get());

  str = os.str();
  // These strings should exist in the assembly!
  EXPECT_NE(str.find("start main 0:"), string::npos);
  EXPECT_NE(str.find("end main"), string::npos);
}


int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}