#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;


class ArgumentPackingInfo {
public:
  vector<Type*> ArgTy;
  map<unsigned, Argument*> NotPack;
  map<unsigned, vector<Argument*>> WillPack;
  unsigned PackedArgCount;
  LLVMContext *Context;

  ArgumentPackingInfo(Function &F);
  void clear();
};

class PackRegisters : public PassInfoMixin<PackRegisters> {
private:
  map<Function*, ArgumentPackingInfo*> PackInfo;
  Function* PackRegistersFromCallee(Function *F);
  pair<Instruction*, CallInst*> PackRegistersFromCaller(CallInst *CI, Function *NewF);
  
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};
