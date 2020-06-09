#ifndef RESET_POINTER
#define RESET_POINTER

#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace std;
using namespace llvm;
const std::string ResetStackName = "__reset_stack__";
const std::string ResetHeapName = "__reset_heap__";

enum AllocType {STACK, HEAP, UNKNOWN, CALL};

bool isMallocCall(const CallInst *CI);
bool isAllocaByteCall(const CallInst *CI);
bool isFreeCall(const CallInst *CI);
AllocType getBlockType(const Value *V);

AllocType getOpType(const Value *V);
AllocType getAccessType(const Value *V);
void ResetPointer(Module *M);


#endif
