#include "SimpleBackend.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/InstVisitor.h"

#include <regex>
#include <set>
#include <sstream>
#include <string>

using namespace llvm;
using namespace std;

namespace {

string getAccessSizeInStr(Type *T) {
  return std::to_string(getAccessSize(T));
}

string to_string(const ConstantInt &CI) {
  return std::to_string(CI.getZExtValue());
}

bool ends_with(const string &a, const string &suffix) {
  if (a.length() < suffix.length())
    return false;
  return a.substr(a.length() - suffix.length(), a.length()) == suffix;
}

void raiseError(const string &msg, Value *V) {
  if (V == nullptr)
    errs() << "AssemblyEmitter: " << msg << "\n";
  else
    errs() << "AssemblyEmitter: " << msg << ": " << *V << "\n";
  abort();
}
void raiseError(Instruction &I) {
  raiseError("Unsupported Instruction", &I);
}
void raiseErrorIf(bool cond, const string &msg, Value *V) {
  if (cond)
    raiseError(msg, V);
}
void raiseErrorIf(bool cond, const string &msg) {
  if (cond)
    raiseError(msg, nullptr);
}

set<unsigned> ValidIntBitwidths = { 1, 8, 16, 32, 64 };

void checkRegisterType(Instruction *I) {
  raiseErrorIf(!I->hasName(), "the instruction does not have a name", I);
  auto *T = I->getType();

  raiseErrorIf(!isa<IntegerType>(T) && !isa<PointerType>(T),
                "unknown register type", I);

  string name = I->getName().str();
  unsigned bw = T->isIntegerTy() ? T->getIntegerBitWidth() : 64;

  if (ends_with(name, "after_trunc__") || ends_with(name, "before_zext__")) {
    raiseErrorIf(!ValidIntBitwidths.count(bw) || bw == 64,
                  "register should be non-64 bits", I);
  } else if (ends_with(name, "to_i1__")) {
    raiseErrorIf(bw != 1, "register is not i1", I);
  } else {
    raiseErrorIf(bw != 64, "register is not 64 bits", I);
  }
}

string getRegisterNameFromArgument(Argument *A) {
  const string msg = "incorrect argument name";
  raiseErrorIf(!A->hasName(), msg, A);

  regex re("__arg([0-9]+)__");
  cmatch m;
  string name = A->getName().str();
  regex_match(name.c_str(), m, re);
  raiseErrorIf(m.empty() || m[0].length() != name.length(), msg, A);

  int regid = stoi(m[1].str());
  raiseErrorIf(regid <= 0 || 16 < regid, msg, A);

  // Well, allow names like arg01...
  return "arg" + std::to_string(regid);
}

string stripTrailingDigits(string name) {
  // Strip trailing numbers
  // e.g. remove '3' from "__r1__3"
  unsigned lastidx = 0;
  for (; lastidx < name.length(); ++lastidx) {
    if (!isdigit(name[name.length() - 1 - lastidx]))
      break;
  }
  name = name.substr(0, name.length() - lastidx);
  return name;
}

string leaveAssemblyRegisterNameOnly(string name, bool stripCasts) {
  name = stripTrailingDigits(name);
  if (stripCasts) {
    vector<string> suffices = {"after_trunc__", "before_zext__", "to_i1__"};
    for (auto &s : suffices)
      if (ends_with(name, s)) {
        name = name.substr(0, name.length() - s.length());
        break;
      }
  }
  return name;
}

bool shouldBeMappedToAssemblyRegister(Instruction *I) {
  string name = leaveAssemblyRegisterNameOnly(I->getName().str(), true);
  regex re("__r([0-9]+)__");
  cmatch m;
  regex_match(name.c_str(), m, re);
  return !m.empty() && m[0].length() == name.length();
}

string getRegisterNameFromInstruction(Instruction *I, bool stripCasts) {
  const string msg = "incorrect instruction name";
  raiseErrorIf(!I->hasName(), msg, I);

  string name = leaveAssemblyRegisterNameOnly(I->getName().str(), stripCasts);
  regex re("__r([0-9]+)__");
  cmatch m;
  regex_match(name.c_str(), m, re);
  raiseErrorIf(m.empty() || m[0].length() != name.length(), msg, I);

  int regid = stoi(m[1].str());
  raiseErrorIf(regid <= 0 || 16 < regid, msg, I);

  // Well, allow names like arg01...
  return "r" + std::to_string(regid);
}



class StackFrame {
  map<AllocaInst *, unsigned> AllocaStackOffset;

public:
  unsigned UsedStackSize;

  StackFrame() : UsedStackSize(0) {}

  void addAlloca(AllocaInst *I) {
    assert(!AllocaStackOffset.count(I));
    AllocaStackOffset[I] = UsedStackSize;
    UsedStackSize += (getAccessSize(I->getAllocatedType()) + 7) / 8 * 8;
  }

  unsigned getStackOffset(AllocaInst *I) const {
    auto Itr = AllocaStackOffset.find(I);
    assert(Itr != AllocaStackOffset.end());
    return Itr->second;
  }
};

class AssemblyEmitterImpl : public InstVisitor<AssemblyEmitterImpl> {
public:
  vector<string> FnBody;
  StackFrame CurrentStackFrame;

private:
  // ----- Emit functions -----
  void _emitAssemblyBody(const string &Cmd, const vector<string> &Ops,
                         stringstream &ss) {
    ss << Cmd;
    for (auto &Op : Ops)
      ss << " " << Op;
  }

  void emitAssembly(const string &DestReg, const string &Cmd,
                    const vector<string> &Ops) {
    stringstream ss;
    ss << DestReg << " = ";
    _emitAssemblyBody(Cmd, Ops, ss);
    FnBody.push_back(ss.str());
  }

  void emitAssembly(const string &Cmd, const vector<string> &Ops) {
    stringstream ss;
    _emitAssemblyBody(Cmd, Ops, ss);
    FnBody.push_back(ss.str());
  }

  void emitCopy(const string &DestReg, const string &val) {
    if (DestReg != val)
      emitAssembly(DestReg, "mul", {val, "1", "64"});
  }

  void emitBasicBlockStart(const string &name) {
    FnBody.push_back(name + ":");
  }

  // If V is a register or constant, return its name.
  // If V is alloca, return its offset from stack.
  pair<string, int> getOperand(Value *V, bool shouldNotBeStackSlot = true) {
    if (auto *A = dyn_cast<Argument>(V)) {
      // Its name should be __argN__.
      // Extract & return the argN.
      auto *ATy = A->getType();
      raiseErrorIf(!((ATy->isIntegerTy() && ATy->getIntegerBitWidth() == 64) ||
                     ATy->isPointerTy()), "unknown argument type", A);
      return { getRegisterNameFromArgument(A), -1 };

    } else if (auto *CI = dyn_cast<ConstantInt>(V)) {
      return { to_string(*CI), -1 };

    } else if (isa<ConstantPointerNull>(V)) {
      return { "0", -1 };

    } else if (isa<UndefValue>(V)) {
      return { "r1", -1 };

    } else if (auto *CE = dyn_cast<ConstantExpr>(V)) {
      if (CE->getOpcode() == Instruction::IntToPtr) {
        auto *CI = dyn_cast<ConstantInt>(CE->getOperand(0));
        if (CI)
          return { to_string(*CI), -1 };
        else
          assert(false && "Unknown inttoptr form");
      }
      assert(false && "Unknown constantexpr");

    } else if (auto *I = dyn_cast<Instruction>(V)) {
      if (isa<TruncInst>(I)) {
        // Trunc is just a wrapper for passing type cheking of IR.
        return getOperand(I->getOperand(0), shouldNotBeStackSlot);
      } else if (shouldBeMappedToAssemblyRegister(I)) {
        // Note that alloca can also have a register name.
        //   __r1__ = alloca i32
        // This will be lowered to:
        //   r1 = add sp, <offset>
        checkRegisterType(I);
        return { getRegisterNameFromInstruction(I, true), -1 };
      } else if (auto *AI = dyn_cast<AllocaInst>(V)) {
        raiseErrorIf(shouldNotBeStackSlot, "alloca cannot come here", AI);

        // alloca's name should not start with __r..!
        raiseErrorIf(!AI->hasName(), "alloca does not have name!", AI);
        return { "" , CurrentStackFrame.getStackOffset(AI) };
      } else {
        assert(false && "Unknown instruction type!");
      }

    } else {
      assert(false && "Unknown value type!");
    }
  }


public:
  AssemblyEmitterImpl() {}

  void visitFunction(Function &F) {
    CurrentStackFrame = StackFrame();
    FnBody.clear();
  }

  void visitBasicBlock(BasicBlock &BB) {
    raiseErrorIf(!BB.hasName(), "This basic block does not have name: ", &BB);
    emitBasicBlockStart(BB.getName().str());
  }

  // Unsupported instruction goes here.
  void visitInstruction(Instruction &I) {
    // Instructions that are eliminated by SimpleBackend:
    // - phi
    // - sext
    raiseError(I);
  }

  // ---- Memory operations ----
  void visitAllocaInst(AllocaInst &I) {
    CurrentStackFrame.addAlloca(&I);

    if (shouldBeMappedToAssemblyRegister(&I)) {
      // I is: __r1__ = alloca i32
      // Will be lowered to:
      //   r1 = add sp ofs
      unsigned ofs = CurrentStackFrame.getStackOffset(&I);
      string DestReg = getRegisterNameFromInstruction(&I, false);
      emitAssembly(DestReg, "add", {"sp", std::to_string(ofs), "64"});
    }
  }
  void visitLoadInst(LoadInst &LI) {
    auto [PtrOp, StackOffset] = getOperand(LI.getPointerOperand(), false);
    string Dest = getRegisterNameFromInstruction(&LI, true);
    string sz = getAccessSizeInStr(LI.getType());

    if (StackOffset != -1)
      // load stack
      emitAssembly(Dest, "load", {sz, "sp", std::to_string(StackOffset)});
    else
      emitAssembly(Dest, "load", {sz, PtrOp, "0"});
  }
  void visitStoreInst(StoreInst &SI) {
    auto [ValOp, _] = getOperand(SI.getValueOperand(), true);
    auto [PtrOp, StackOffset] = getOperand(SI.getPointerOperand(), false);
    string sz = getAccessSizeInStr(SI.getValueOperand()->getType());

    if (StackOffset != -1)
      emitAssembly("store", {sz, ValOp, "sp", std::to_string(StackOffset)});
    else
      emitAssembly("store", {sz, ValOp, PtrOp, "0"});
  }

  // ---- Arithmetic operations ----
  void visitBinaryOperator(BinaryOperator &BO) {
    auto [Op1, unused_1] = getOperand(BO.getOperand(0));
    auto [Op2, unused_2] = getOperand(BO.getOperand(1));
    string DestReg = getRegisterNameFromInstruction(&BO, true); // iN -> i64
    string Cmd;
    string sz = std::to_string(BO.getType()->getIntegerBitWidth());

    switch(BO.getOpcode()) {
    case Instruction::UDiv: Cmd = "udiv"; break;
    case Instruction::SDiv: Cmd = "sdiv"; break;
    case Instruction::URem: Cmd = "urem"; break;
    case Instruction::SRem: Cmd = "srem"; break;
    case Instruction::Mul:  Cmd = "mul"; break;
    case Instruction::Shl:  Cmd = "shl"; break;
    case Instruction::AShr: Cmd = "ashr"; break;
    case Instruction::LShr: Cmd = "lshr"; break;
    case Instruction::And:  Cmd = "and"; break;
    case Instruction::Or:   Cmd = "or"; break;
    case Instruction::Xor:  Cmd = "xor"; break;
    case Instruction::Add:  Cmd = "add"; break;
    case Instruction::Sub:  Cmd = "sub"; break;
    default: raiseError(BO); break;
    }

    emitAssembly(DestReg, Cmd, {Op1, Op2, sz});
  }
  void visitICmpInst(ICmpInst &II) {
    if (ends_with(stripTrailingDigits(II.getName().str()), "to_i1__")) {
      // Should be used by branch.
      // Ignore this.
      return;
    }

    auto [Op1, unused_1] = getOperand(II.getOperand(0));
    auto [Op2, unused_2] = getOperand(II.getOperand(1));
    string DestReg = getRegisterNameFromInstruction(&II, true); // i1 -> i64
    string pred = ICmpInst::getPredicateName(II.getPredicate()).str();
    auto *OpTy = II.getOperand(0)->getType();
    string sz = std::to_string(
      OpTy->isPointerTy() ? 64 : OpTy->getIntegerBitWidth());

    emitAssembly(DestReg, "icmp", {pred, Op1, Op2, sz});
  }
  void visitSelectInst(SelectInst &SI) {
    auto [Op1, unused_1] = getOperand(SI.getOperand(0));
    auto [Op2, unused_2] = getOperand(SI.getOperand(1));
    auto [Op3, unused_3] = getOperand(SI.getOperand(2));
    string DestReg = getRegisterNameFromInstruction(&SI, false);
    emitAssembly(DestReg, "select", {Op1, Op2, Op3});
  }
  void visitGetElementPtrInst(GetElementPtrInst &GEPI) {
    // Allow 'gep i8* ptr, i' only.
    raiseErrorIf(GEPI.getNumIndices() != 1, "Too many indices", &GEPI);

    Type *PtrTy = GEPI.getPointerOperandType();
    raiseErrorIf(!PtrTy->getPointerElementType()->isIntegerTy(),
                 "Unsupported pointer type", &GEPI);
    raiseErrorIf(PtrTy->getPointerElementType()->getIntegerBitWidth() != 8,
                 "Unsupported pointer type", &GEPI);

    auto [Op1, unused_1] = getOperand(GEPI.getOperand(0));
    auto [Op2, unused_2] = getOperand(GEPI.getOperand(1));
    string DestReg = getRegisterNameFromInstruction(&GEPI, false);
    emitAssembly(DestReg, "add", {Op1, Op2, "64"});
  }

  // Casts
  void visitZExtInst(ZExtInst &ZI) {
    // This test should pass.
    (void)getRegisterNameFromInstruction(&ZI, false);
  }
  void visitTruncInst(TruncInst &TI) {
    // This test should pass.
    if (auto *I = dyn_cast<Instruction>(TI.getOperand(0)))
      (void)getRegisterNameFromInstruction(I, false);
  }
  void visitBitCastInst(BitCastInst &BCI) {
    auto [Op1, _] = getOperand(BCI.getOperand(0));
    string DestReg = getRegisterNameFromInstruction(&BCI, false);
    emitCopy(DestReg, Op1);
  }
  void visitPtrToIntInst(PtrToIntInst &PI) {
    auto [Op1, _] = getOperand(PI.getOperand(0));
    string DestReg = getRegisterNameFromInstruction(&PI, false);
    emitCopy(DestReg, Op1);
  }
  void visitIntToPtrInst(IntToPtrInst &II) {
    auto [Op1, _] = getOperand(II.getOperand(0));
    string DestReg = getRegisterNameFromInstruction(&II, false);
    emitCopy(DestReg, Op1);
  }

  // ---- Call ----
  void visitCallInst(CallInst &CI) {
    string FnName = (string)CI.getCalledFunction()->getName();
    vector<string> Args;
    bool MallocOrFree = true;
    if (FnName != "malloc" && FnName != "free") {
      MallocOrFree = false;
      Args.emplace_back(FnName);
    }

    unsigned Idx = 0;
    for (auto I = CI.arg_begin(), E = CI.arg_end(); I != E; ++I) {
      Args.emplace_back(getOperand(*I).first);
      ++Idx;
    }
    if (CI.hasName()) {
      string DestReg = getRegisterNameFromInstruction(&CI, false);
      emitAssembly(DestReg, MallocOrFree ? FnName : "call", Args);
    } else {
      emitAssembly(MallocOrFree ? FnName : "call", Args);
    }
  }

  // ---- Terminators ----
  void visitReturnInst(ReturnInst &RI) {
    raiseErrorIf(RI.getReturnValue() == nullptr, "ret should have value", &RI);
    emitAssembly("ret", { getOperand(RI.getReturnValue()).first });
  }
  void visitBranchInst(BranchInst &BI) {
    if (BI.isUnconditional()) {
      emitAssembly("br", {(string)BI.getSuccessor(0)->getName()});
    } else {
      string Cond;
      if (auto *C = dyn_cast<Constant>(BI.getCondition())) {
        Cond = getOperand(C).first;
      } else {
        string msg = "Branch condition should be icmp ne";
        auto *BCond = BI.getCondition();
        raiseErrorIf(!isa<ICmpInst>(BCond), msg, BCond);

        auto *II = dyn_cast<ICmpInst>(BCond);
        raiseErrorIf(II->getPredicate() != ICmpInst::ICMP_NE, msg, BCond);

        auto *ShouldBeZero = dyn_cast<ConstantInt>(II->getOperand(1));
        raiseErrorIf(!ShouldBeZero || ShouldBeZero->getZExtValue() != 0, msg, BCond);

        Cond = getOperand(II->getOperand(0)).first;
      }
      emitAssembly("br", { Cond, (string)BI.getSuccessor(0)->getName(),
                                 (string)BI.getSuccessor(1)->getName()});
    }
  }
  void visitSwitchInst(SwitchInst &SI) {
    auto [Cond, _] = getOperand(SI.getCondition());
    vector<string> Args;
    Args.emplace_back(Cond);
    for (SwitchInst::CaseIt I = SI.case_begin(), E = SI.case_end();
         I != E; ++I) {
      Args.push_back(to_string(*I->getCaseValue()));
      Args.push_back(I->getCaseSuccessor()->getName().str());
    }
    Args.push_back(SI.getDefaultDest()->getName().str());
    emitAssembly("switch", Args);
  }
};

};

void AssemblyEmitter::run(Module *DepromotedM) {
  AssemblyEmitterImpl Em;
  unsigned TotalStackUsage = 0;
  for (auto &F : *DepromotedM) {
    if (F.isDeclaration())
      continue;

    Em.visit(F);
    *fout << "\n";
    *fout << "; Function " << F.getName() << "\n";
    *fout << "start " << F.getName() << " " << F.arg_size() << ":\n";

    assert(Em.FnBody.size() > 0);
    raiseErrorIf(Em.CurrentStackFrame.UsedStackSize >= 10240,
                 "Stack usage is larger than STACK_MAX!");
    TotalStackUsage += Em.CurrentStackFrame.UsedStackSize;
    raiseErrorIf(TotalStackUsage >= 10240, "Stack usage is larger than STACK_MAX!");

    *fout << "  " << Em.FnBody[0] << "\n";
    if (Em.CurrentStackFrame.UsedStackSize > 0) {
      *fout << "    ; init sp!\n";
      *fout << "    sp = sub sp "
            << Em.CurrentStackFrame.UsedStackSize << " 64\n";
    }

    for (unsigned i = 1; i < Em.FnBody.size(); ++i) {
      assert(Em.FnBody[i].size() > 0);
      if (Em.FnBody[i][0] == '.')
        // Basic block
        *fout << "\n  " << Em.FnBody[i] << "\n";
      else
        // Instruction
        *fout << "    " << Em.FnBody[i] << "\n";
    }

    *fout << "end " << F.getName() << "\n";
  }
}
