#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;


/* ArgumentPackingInfo - A class for every Function in LLVM,
 *   that contains register packing information. The indices for ArgTy,
 *   NotPack, WillPack are for the newly converted(argument packed)
 *   function. 
 * */
class ArgumentPackingInfo {
public:
  /* ArgTy - Argument types of the new function */
  vector<Type*> ArgTy;
  /* NotPack - ArgNo to Argument* map.
   *   For those arguments that will not be packed */
  map<unsigned, Argument*> NotPack;
  /* WillPack - ArgNo to vector<Argument*> map.
   *   For those arguments that should be packed, encoded with std::vector */
  map<unsigned, vector<Argument*>> WillPack;
  /* PackedArgCount - The number of the new function's arguments */
  unsigned PackedArgCount;
  /* Context - The context of the function */
  LLVMContext *Context;

  /* ArgumentPackingInfo - A constructor of the class.
   *   It makes the above data-structures for register packing. */
  ArgumentPackingInfo(Function &F);

  /* clear - Memory cleaner function */
  void clear();
};


/* PackRegisters - An LLVM optimization class by packing the argument
 *   of the function. It is divided into callee part(PackRegistersFromCalle)
 *   and caller part(PackRegistersFromCaller).
 * */
class PackRegisters : public PassInfoMixin<PackRegisters> {
private:
  /* PackInfo - A map from Function*(old function ptr) to
   *   ArgumentPackingInfo* */
  map<Function*, ArgumentPackingInfo*> PackInfo;
  /* PackRegistersFromCallee - Callee update. Returns the newly created
   *   function. */
  Function* PackRegistersFromCallee(Function *F);
  /* PackRegistersFromCaller - Caller update. Returns a std::pair of
   *   insertion ptr of the new CallInst(Instruction ptr) and the
   *   corresponding new CallInst. */
  pair<Instruction*, CallInst*> PackRegistersFromCaller(CallInst *CI, Function *NewF);
  
public:
  /* run - Runs the main optimization! */
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};
