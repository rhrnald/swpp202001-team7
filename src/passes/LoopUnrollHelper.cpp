#include "LoopUnrollHelper.h"

using namespace llvm;
using namespace std;

const string PREFIX_OF_DUMMY = "$dummy$", PREFIX_OF_START = "$fnstart$";
const string PREFIX_OF_RETURN = "$fnreturn$", PREFIX_OF_END = "$fnend$";
const string PREFIX_OF_ARG = "$fnarg$", SUFFIX = "$dot$";
const string SYSWRAP = "$sysfnwrap$", OPERAND = "$operand$", RETURN = "$return$", DUMMY = "$dummy$";

PreservedAnalyses LoopUnrollPreHelper::run(Module &M, ModuleAnalysisManager &MAM) {
  LLVMContext &Context = M.getContext();
  i64Ty = Type::getInt64Ty(Context);
  i8PtrTy = Type::getInt8PtrTy(Context), i64PtrTy = Type::getInt64PtrTy(Context);
  int cnt = 0;

  vector<Instruction*> ToErased;
  for (auto &F : M) {
    if (!isa<Function>(F) || F.isDeclaration()) continue;
    for (auto &BB : F) {
      auto &IL = BB.getInstList();
      for (auto &I : BB) { 
        if (CallInst *CI = dyn_cast<CallInst>(&I)) {
          Function *CF = CI->getCalledFunction();
          string FnName = CF->getName().str();
          vector<Instruction *> ToInsert;

          string OpName = SYSWRAP + to_string(cnt) + "$" + FnName + OPERAND;
          string RetName = SYSWRAP + to_string(cnt) + "$" + FnName + RETURN;
          AllocaInst *Dummy = new AllocaInst(i64Ty, 0, SYSWRAP + to_string(cnt) + "$" + FnName + DUMMY);
          F.getEntryBlock().getInstList().push_front(Dummy);

          if (FnName == "write") {
            ToInsert.push_back(BinaryOperator::CreateAdd(CI->getArgOperand(0), ConstantInt::get(i64Ty, 1), OpName));
            ToInsert.push_back(new StoreInst(ToInsert.back(), Dummy));
          } else if (FnName == "read") {
            ToInsert.push_back(new PtrToIntInst(Dummy, i64Ty, RetName));
            CI->replaceAllUsesWith(ToInsert.back());
          } else if (FnName == "free") {
            ToInsert.push_back(new PtrToIntInst(CI->getArgOperand(0), i64Ty, OpName));
            ToInsert.push_back(new StoreInst(ToInsert.back(), Dummy));
          } else if (FnName == "malloc") {
            ToInsert.push_back(new PtrToIntInst(Dummy, i64Ty, "meaningless"));
            ToInsert.push_back(BinaryOperator::CreateAdd(CI->getArgOperand(0), ToInsert.back(), OpName));
            ToInsert.push_back(new IntToPtrInst(ToInsert.back(), i8PtrTy, RetName));
            CI->replaceAllUsesWith(ToInsert.back());
          } else {
              continue;
          }
          cnt++;
          Instruction *Last = CI;
          for (auto &NewInst : ToInsert) IL.insertAfter(Last->getIterator(), NewInst), Last = NewInst;
          ToErased.push_back(CI);
        }
      }
    }
  }
  for (auto &E : ToErased) E->eraseFromParent();
  return PreservedAnalyses::all();
}

static tuple<string,string,string,int> Parse(string target) {
  if (target.find(SYSWRAP) == string::npos || 
       (target.find(OPERAND) == string::npos && target.find(RETURN) == string::npos && target.find(DUMMY) == string::npos))
    return {"", "", "", -1};
  vector<int> pos;
  for (int i = 0; i < (int) target.size(); i++)
    if (target[i] == '$') pos.push_back(i);
  return {target.substr(0, pos[3]) + target.substr(pos[4]), target.substr(pos[2]+1, pos[3]-pos[2]-1),
          target.substr(pos[3], pos[4]-pos[3]+1), atoi(target.substr(pos[1]+1, pos[2]-pos[1]- 1).c_str())};
}

static string GetVariant(string identifier, string vartype) {
  return identifier.substr(0, identifier.size()-1) + vartype;
}

PreservedAnalyses LoopUnrollPostHelper::run(Module &M, ModuleAnalysisManager &MAM) {
  LLVMContext &Context = M.getContext();
  for (auto &F : M) {
    if (isa<Function>(F)) {
      FunctionMap[F.getName()] = &F;
      if (F.isDeclaration()) continue;
      for (auto &BB : F) for (auto &I : BB) {
        if (I.getName() != "") InstMap[I.getName()] = &I;
      }
    }
  }

  map<Function*, Instruction*> DummyMap;
  bool SkipOne = false, Ended = false;
  Function *Callee = NULL;
  vector<Instruction *> ParsedConsecutives, ToErased;
  CallInst *NewCaller = NULL;
  Instruction *PrevCaller = NULL;
  vector<tuple<vector<Instruction *>, Instruction*, Instruction*>> Replacements;
  vector<Value *> Args;
  unsigned ArgNum = 0;

  vector<Instruction*> Dummies;
  
  for (auto &F : M) {
    if ((!isa<Function>(F)) || F.isDeclaration()) continue;
    for (auto &BB : F) for (auto &I : BB) {
      string InstName = I.getName().str();
      auto [Identifier, FnName, Variant, Cnt] = Parse(InstName);
      if (Cnt == -1) continue;

      Callee = FunctionMap[FnName];

      if (Variant == DUMMY) {
        Dummies.push_back(&I);
      } else if (Variant == RETURN) {
        if (FnName == "read") {
          NewCaller = CallInst::Create(Callee->getFunctionType(), Callee, Args, "newread", &I);
          I.replaceAllUsesWith(NewCaller);
          ToErased.push_back(&I);
        } else if (FnName == "malloc") {
          Instruction *OperandInst = InstMap[GetVariant(Identifier, OPERAND)];
          Args.push_back(OperandInst->getOperand(0));
          NewCaller = CallInst::Create(Callee->getFunctionType(), Callee, Args, "newmalloc", &I);
          I.replaceAllUsesWith(NewCaller);
          ToErased.push_back(OperandInst);
          ToErased.push_back(&I);
        }
      } else if (Variant == OPERAND) {
        if (FnName == "write") {
          Args.push_back(I.getOperand(0));
          NewCaller = CallInst::Create(Callee->getFunctionType(), Callee, Args, "", &I);
          I.replaceAllUsesWith(UndefValue::get(I.getType()));
          ToErased.push_back(&I);
        } else if (FnName == "free") {
          Args.push_back(I.getOperand(0));
          NewCaller = CallInst::Create(Callee->getFunctionType(), Callee, Args, "", &I);
          I.replaceAllUsesWith(UndefValue::get(I.getType()));
          ToErased.push_back(&I);
        }
      }
      Args.clear();
    }
  }
  std::reverse(ToErased.begin(), ToErased.end());
  for (auto &I : ToErased) I->eraseFromParent();
  for (auto &D : Dummies) {
    for (auto &U : D->uses())
      if (Instruction *UsrI = dyn_cast<Instruction>(U.getUser())) UsrI->eraseFromParent();
  }
  for (auto &D : Dummies) D->eraseFromParent();
  return PreservedAnalyses::all();
}