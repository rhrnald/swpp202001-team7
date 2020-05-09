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


static const unsigned PACK_MAX_SIZE = 64;
static const unsigned PACK_VALID_COUNT = 3;


namespace {
class ArgumentPackingInfo {
private:

public:
  map<unsigned, Value*> NotPack;
  map<unsigned, vector<Value*>> WillPack;
  LLVMContext *Context;
  unsigned PackedArgCount;

  ArgumentPackingInfo(Function &F) {
    Context = &(F.getContext());
    if (F.arg_size() == 0) {
      PackedArgCount = 0;
      return;
    }

    DataLayout *DL = new DataLayout(F.getParent());
    vector<pair<unsigned, Value*>> Args;

    for (auto &A : F.args()) {
      Args.emplace_back(DL->getTypeSizeInBits(A.getType()), &A);
    }
    std::sort(Args.begin(), Args.end());
    // std::reverse(Args.begin(), Args.end());

    unsigned ArgCount = F.arg_size();
    unsigned PackedCount = 0, PackedSize = 0, PackedFrom = 0, PackedNow = 0;
    
    while (PackedFrom < ArgCount) {
      while (PackedNow + 1 < Args.size() &&
             PackedSize + Args[PackedNow + 1].first <= PACK_MAX_SIZE) {
        PackedSize += Args[++PackedNow].first;
      }
      if (PackedNow + 1 - PackedFrom >= PACK_VALID_COUNT) {
        for (unsigned i = PackedFrom; i <= PackedNow; i++) {
          WillPack[PackedCount].push_back(Args[i].second);
        }
        PackedCount++;
        PackedFrom = PackedNow + 1;
        PackedSize = 0;
      } else {
        PackedSize -= Args[PackedFrom].first;
        NotPack[PackedCount++] = Args[PackedFrom++].second;
      }
    }

    PackedArgCount = PackedCount;
    Args.clear();
  }

  vector<Type*>& getArgTy() {
    vector<Type*> *PArgTy = new vector<Type*>(), &ArgTy = *PArgTy;
    for (unsigned i = 0; i < PackedArgCount; i++) {
      if (NotPack.find(i) != NotPack.end()) {
        ArgTy.push_back(NotPack[i]->getType());
      } else {
        ArgTy.push_back(Type::getInt64Ty(*Context));
      }
    }
    return ArgTy;
  }

  void clear() {
    NotPack.clear();
    for (auto &[_, V] : WillPack) V.clear();
    WillPack.clear();
  }
};


class PackRegisters : public PassInfoMixin<PackRegisters> {

private:
  map<Function*, ArgumentPackingInfo*> PackInfo;

  void PackRegistersFromCallee(Function &F) {
    ArgumentPackingInfo *API = PackInfo[&F];
    vector<Type*> &ArgTy = API->getArgTy();
    Module *M = F.getParent();
    StringRef OrigName = F.getName();
    LLVMContext *Context = API->Context;
    DataLayout *DL = new DataLayout(F.getParent());

    FunctionType *NewFTy = FunctionType::get(F.getFunctionType()->getReturnType(), ArgTy, false);
    Function *NewF = Function::Create(NewFTy, Function::ExternalLinkage, "", *M);
    ValueToValueMapTy VMap;

    if (!API->WillPack.empty()) {
      BasicBlock *PrevEntry = &(F.getEntryBlock());
      BasicBlock *NewEntry = BasicBlock::Create(*Context);

      if (PrevEntry->getName() == "") PrevEntry->setName("prev_entry");
      NewEntry->setName("split_reg");

      F.getBasicBlockList().push_front(NewEntry);

      map<Value*, Value*> ToBeTrunc;

      for (auto &[i, P] : API->WillPack) {
        bool Init = 1;
        Value *NewA = NewF->getArg(i);
        Value *BeforeDiv;
        Value *BeforeA;
        Value *BeforeRem;
        unsigned BeforeASize;

        for (auto &A : P) {
          if (!Init) {
            Instruction *Rem = BinaryOperator::CreateUDiv(BeforeRem, BeforeDiv, "merge");
            NewEntry->getInstList().push_back(Rem);
            BeforeRem = Rem;
          } else {
            BeforeRem = NewA;
            Init = 0;
          }
          unsigned long long ASize = 1ULL << DL->getTypeSizeInBits(A->getType());
          Value *Div = ConstantInt::get(Type::getInt64Ty(*Context), ASize);
          Instruction *Rem = BinaryOperator::CreateURem(BeforeRem, Div, "zext");
          NewEntry->getInstList().push_back(Rem);
          ToBeTrunc[A] = Rem;

          BeforeDiv = Div;
          BeforeASize = ASize;
        }
      }

      for (auto &[A, ZA] : ToBeTrunc) {
        Instruction *Trunc = new TruncInst(ZA, A->getType(), "trunc");
        NewEntry->getInstList().push_back(Trunc);
        A->replaceAllUsesWith(Trunc);
      }

      BranchInst *Br = BranchInst::Create(PrevEntry, NewEntry);
    }

    for (auto &BB : F) {
      BasicBlock *NewBB = CloneBasicBlock(&BB, VMap, "", NewF);
      VMap[&BB] = NewBB;
    }

    for (auto &[i, A] : API->NotPack) {
      A->replaceAllUsesWith(NewF->getArg(i));
      NewF->getArg(i)->setName(A->getName());
    }

    for (auto &A : NewF->args()) {
      if (A.getName() == "") {
        A.setName("merged");
      }
    }

    F.removeFromParent();
    NewF->setName(OrigName);

    ArgTy.clear();
    VMap.clear();
  }

  void PackRegistersFromCaller(CallInst &CI) {

  }
    
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
    FunctionAnalysisManager &FAM = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
    
    vector<Function*> OrigFunctions;

    for (Function &F : M) {
      if (F.isDeclaration()) {
        continue;
      }
      PackInfo[&F] = new ArgumentPackingInfo(F);
      OrigFunctions.push_back(&F);
    }

    for (Function *F : OrigFunctions) {
      PackRegistersFromCallee(*F);
    }

    return PreservedAnalyses::all();
  }
};
}