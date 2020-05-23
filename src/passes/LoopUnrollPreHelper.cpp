#include "LoopUnrollPreHelper.h"

#include "llvm/IR/PassManager.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;

const string PREFIX_OF_DUMMY = "$dummy$", PREFIX_OF_START = "$fnstart$";
const string PREFIX_OF_RETURN = "$fnreturn$", PREFIX_OF_END = "$fnend$";
const string PREFIX_OF_ARG = "$fnarg$", SUFFIX = "$dot$";

bool LoopUnrollPreHelper::getCompatibleWithUnroll(Function *F) {
}

void LoopUnrollPreHelper::GeneratePad(AllocaInst *Dummy, Value *V, vector<Instruction*> &ToInsert, string prefix) {
}

PreservedAnalyses LoopUnrollPreHelper::run(Module &M, ModuleAnalysisManager &MAM) {
  return PreservedAnalyses::all();
}
