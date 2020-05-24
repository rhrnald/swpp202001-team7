#ifndef LOOP_UNROLL_HELPER
#define LOOP_UNROLL_HELPER

#include "llvm/IR/PassManager.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;

class LoopUnrollPreHelper : public PassInfoMixin<LoopUnrollPreHelper> {
private:
  map<Function *, bool> CompatibleWithUnroll;
  Type *i64Ty, *i8PtrTy, *i64PtrTy;
  Value *One;
  bool getCompatibleWithUnroll(Function *F);
  void GeneratePad(AllocaInst *Dummy, Value *A, vector<Instruction*> &ToInsert, string prefix);  
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};

class LoopUnrollPostHelper : public PassInfoMixin<LoopUnrollPostHelper> {
private:
  map<string, Function *> FunctionMap;
  map<string, Instruction *> InstMap;
  Type *i64Ty, *i64PtrTy;

public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};
#endif