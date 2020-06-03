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

#ifdef MEM_USE_OPTIMIZATION

TEST(PassCheck, MemUseOptimizationTest) {
  // Create an IR Module.
  LLVMContext Context;
  unique_ptr<Module> M(new Module("MyTestModule", Context));
  auto *TestFTy = FunctionType::get(Type::getInt32Ty(Context), {}, false);
  auto *MallocFTy = FunctionType::get(Type::getInt8PtrTy(Context),
                                      { Type::getInt64Ty(Context) }, false);
  auto *FreeFTy = FunctionType::get(Type::getVoidTy(Context),
                                      { Type::getInt8PtrTy(Context) }, false);
  Function *MainF = Function::Create(TestFTy, Function::ExternalLinkage,
                                     "main", *M);
  Function *MallocF = Function::Create(MallocFTy, Function::ExternalLinkage,
                                       "malloc", *M);
  Function *FreeF = Function::Create(FreeFTy, Function::ExternalLinkage,
                                       "free", *M);

  //////////////////////////////Create Function//////////////////////////////
  BasicBlock *Entry = BasicBlock::Create(Context, "entry", MainF);
  IRBuilder<> EntryBuilder(Entry);

  //Allocate
  auto *m = EntryBuilder.CreateCall(MallocF, ConstantInt::get(Type::getInt64Ty(Context), 8), "mem");

  //Store
  auto *s = EntryBuilder.CreateStore(ConstantInt::get(Type::getInt8Ty(Context), 1), m);

  //Free
  auto *f = EntryBuilder.CreateCall(FreeF, m);

  //Ret
  auto *r = EntryBuilder.CreateRet(ConstantInt::get(Type::getInt32Ty(Context), 0));

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
  MPM.addPass(MemUseOptimization());

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

  map<string, Function*> FunctionMap;
  map<string, BasicBlock*> BasicBlockMap;
  map<string, vector<Instruction*>> InstructionMap;

  for (auto &F : *M) {
    FunctionMap[F.getName()] = &F;
    if (F.isDeclaration()) continue;
    for (auto &BB : F) {
      BasicBlockMap[BB.getName()] = &BB;
      for (auto &I : BB) {
        InstructionMap[BB.getName()].push_back(&I);
      }
    }
  }

  EXPECT_TRUE(FunctionMap.count("__get_stack_pointer__") > 0);
  EXPECT_TRUE(FunctionMap.count("__alloca_bytes__") > 0);

  EXPECT_TRUE(FunctionMap.count("main") > 0);
  EXPECT_TRUE(BasicBlockMap.count("entry") > 0);
  EXPECT_TRUE(BasicBlockMap.count("div.entry") > 0);
  EXPECT_TRUE(BasicBlockMap.count("alloca.entry") > 0);
  EXPECT_TRUE(BasicBlockMap.count("malloc.entry") > 0);
  EXPECT_TRUE(BasicBlockMap.count("div.div.entry") > 0);

  string conv_entry;
  string stack_dangerous_region_str = to_string(STACK_DANGEROUS_REGION);
  string expt_entry = "\n"
    "entry:\n"
    "  %cur.sp = call i64 @__get_stack_pointer__()\n"
    "  %lookahead.sp = sub i64 %cur.sp, 8\n"
    "  %is.safe.sp = icmp sge i64 %lookahead.sp, " + stack_dangerous_region_str + "\n"
    "  br i1 %is.safe.sp, label %alloca.entry, label %malloc.entry\n";
  llvm::raw_string_ostream rso_entry(conv_entry);

  auto &entry = InstructionMap["entry"];
  BasicBlockMap["entry"]->print(rso_entry);
  EXPECT_EQ(entry.size(), 4);
  EXPECT_EQ(conv_entry, expt_entry);


  string conv_div_entry;
  string expt_div_entry = "\n"
    "div.entry:                                        ; preds = %malloc.entry, %alloca.entry\n"
    "  %allocation.mem = phi i8* [ %by.alloca_bytes, %alloca.entry ], [ %by.malloc, %malloc.entry ]\n"
    "  store i8 1, i8* %allocation.mem\n"
    "  %sp.as.int = ptrtoint i8* %allocation.mem to i64\n"
    "  %cmp.sp = icmp sge i64 %sp.as.int, 10240\n"
    "  br i1 %cmp.sp, label %free.div.entry, label %div.div.entry\n";
  llvm::raw_string_ostream rso_div_entry(conv_div_entry);

  auto &div_entry = InstructionMap["div.entry"];
  BasicBlockMap["div.entry"]->print(rso_div_entry);
  EXPECT_EQ(div_entry.size(), 5);
  EXPECT_EQ(conv_div_entry, expt_div_entry);


  string conv_div_div_entry;
  string expt_div_div_entry = "\n"
    "div.div.entry:                                    ; preds = %free.div.entry, %div.entry\n"
    "  ret i32 0\n";
  llvm::raw_string_ostream rso_div_div_entry(conv_div_div_entry);

  auto &div_div_entry = InstructionMap["div.div.entry"];
  BasicBlockMap["div.div.entry"]->print(rso_div_div_entry);
  EXPECT_EQ(div_div_entry.size(), 1);
  EXPECT_EQ(conv_div_div_entry, expt_div_div_entry);


  string conv_alloca_entry;
  string expt_alloca_entry = "\n"
    "alloca.entry:                                     ; preds = %entry\n"
    "  %by.alloca_bytes = call i8* @__alloca_bytes__(i64 8, i64 0)\n"
    "  br label %div.entry\n";
  llvm::raw_string_ostream rso_alloca_entry(conv_alloca_entry);

  auto &alloca_entry = InstructionMap["alloca.entry"];
  BasicBlockMap["alloca.entry"]->print(rso_alloca_entry);
  EXPECT_EQ(alloca_entry.size(), 2);
  EXPECT_EQ(conv_alloca_entry, expt_alloca_entry);


  string conv_malloc_entry;
  string expt_malloc_entry = "\n"
    "malloc.entry:                                     ; preds = %entry\n"
    "  %by.malloc = call i8* @malloc(i64 8)\n"
    "  br label %div.entry\n";
  llvm::raw_string_ostream rso_malloc_entry(conv_malloc_entry);

  auto &malloc_entry = InstructionMap["malloc.entry"];
  BasicBlockMap["malloc.entry"]->print(rso_malloc_entry);
  EXPECT_EQ(malloc_entry.size(), 2);
  EXPECT_EQ(conv_malloc_entry, expt_malloc_entry);


  string conv_free_div_entry;
  string expt_free_div_entry = "\n"
    "free.div.entry:                                   ; preds = %div.entry\n"
    "  call void @free(i8* %allocation.mem)\n"
    "  br label %div.div.entry\n";
  llvm::raw_string_ostream rso_free_div_entry(conv_free_div_entry);

  auto &free_div_entry = InstructionMap["free.div.entry"];
  BasicBlockMap["free.div.entry"]->print(rso_free_div_entry);
  EXPECT_EQ(free_div_entry.size(), 2);
  EXPECT_EQ(conv_free_div_entry, expt_free_div_entry);
}

#endif
