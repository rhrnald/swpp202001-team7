#include "SimpleBackend.h"

#include "llvm/IR/PassManager.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Transforms/Scalar/SROA.h"
#include "llvm/Transforms/Scalar/ADCE.h"

//Our Optimization
#include "../optimizations/Wrapper.h"

//Additional Pass
#include "llvm/Transforms/InstCombine/InstCombine.h"

#include <string>

using namespace std;
using namespace llvm;


static cl::OptionCategory optCategory("SWPP Compiler options");

static cl::opt<string> optInput(
    cl::Positional, cl::desc("<input bitcode file>"), cl::Required,
    cl::value_desc("filename"), cl::cat(optCategory));

static cl::opt<string> optOutput(
    "o", cl::desc("output assembly file"), cl::cat(optCategory),
    cl::init(""));

static cl::opt<string> optOutputLL(
    "d", cl::desc("LL to LL "), cl::cat(optCategory), cl::init(""));

static cl::opt<bool> optPrintDepromotedModule(
    "print-depromoted-module", cl::desc("print depromoted module"),
    cl::cat(optCategory), cl::init(false));

static llvm::ExitOnError ExitOnErr;


// adapted from llvm-dis.cpp
static unique_ptr<Module> openInputFile(LLVMContext &Context,
                                        string InputFilename) {
  auto MB = ExitOnErr(errorOrToExpected(MemoryBuffer::getFile(InputFilename)));
  SMDiagnostic Diag;
  auto M = getLazyIRModule(move(MB), Diag, Context, true);
  if (!M) {
    Diag.print("", errs(), false);
    return 0;
  }
  ExitOnErr(M->materializeAll());
  return M;
}

class RemoveUnsupportedOps : public llvm::PassInfoMixin<RemoveUnsupportedOps> {
  Constant *getZero(Type *T) {
    return T->isPointerTy() ?
        ConstantPointerNull::get(dyn_cast<PointerType>(T)) :
        ConstantInt::get(T, 0);
  }

public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    vector<Instruction *> V;
    for (auto I = inst_begin(F), E = inst_end(F); I != E; ++I) {
      Instruction *II = &*I;
      bool Deleted = false;
      if (auto *Intr = dyn_cast<IntrinsicInst>(II)) {
        if (Intr->getIntrinsicID() == Intrinsic::lifetime_start ||
            Intr->getIntrinsicID() == Intrinsic::lifetime_end) {
          V.push_back(Intr);
          Deleted = true;
        }
      } else if (auto *UI = dyn_cast<UnreachableInst>(II)) {
        LLVMContext &Cxt = F.getParent()->getContext();
        auto *RE = F.getReturnType()->isVoidTy() ? ReturnInst::Create(Cxt) :
            ReturnInst::Create(Cxt, getZero(F.getReturnType()));
        RE->insertBefore(UI);
        V.push_back(UI);
        Deleted = true;
      }

      if (!Deleted) {
        for (unsigned i = 0; i < II->getNumOperands(); ++i) {
          Value *V = II->getOperand(i);
          if (isa<UndefValue>(V)) {
            auto *T = V->getType();
            II->setOperand(i, getZero(T));
          }
        }
      }
    }

    for (auto *I : V)
      I->eraseFromParent();
    return PreservedAnalyses::all();
  }
};

class CheckConstExpr : public llvm::PassInfoMixin<CheckConstExpr> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
    for (auto &G : M.globals()) {
      if (auto *F = dyn_cast<Function>(&G)) {
        for (auto I = inst_begin(F), E = inst_end(F); I != E; ++I) {
          Instruction *II = &*I;
          for (auto &V : I->operands()) {
            if (isa<ConstantExpr>(V)) {
              errs() << "ERROR: Constant expressions should not exist!\n";
              errs() << "\t" << *I << "\n";
              exit(1);
            }
          }
        }
      } else if (auto *GV = dyn_cast<GlobalVariable>(&G)) {
        if (GV->hasInitializer()) {
          errs() << "ERROR: Global variables should not have initializers!\n";
          errs() << "\t" << *GV << "\n";
          exit(1);
        }
      }
    }
    return PreservedAnalyses::all();
  }
};
class DoNothingPass : public llvm::PassInfoMixin<DoNothingPass> {
  std::string outputFile;

public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    //outs() << "Hi! " << F.getName() << "\n";
    return PreservedAnalyses::all();
  }
};

int main(int argc, char **argv) {
  sys::PrintStackTraceOnErrorSignal(argv[0]);
  PrettyStackTraceProgram X(argc, argv);
  EnableDebugBuffering = true;

  cl::ParseCommandLineOptions(argc, argv);

  LLVMContext Context;
  // Read the module
  auto M = openInputFile(Context, optInput);
  if (!M)
    return 1;

  LoopAnalysisManager LAM;
  FunctionAnalysisManager FAM;
  CGSCCAnalysisManager CGAM;
  ModuleAnalysisManager MAM;
  PassBuilder PB;
  // Register all the basic analyses with the managers.
  PB.registerModuleAnalyses(MAM);
  PB.registerCGSCCAnalyses(CGAM);
  PB.registerFunctionAnalyses(FAM);
  PB.registerLoopAnalyses(LAM);
  PB.crossRegisterProxies(LAM, FAM, CGAM, MAM);


  FunctionPassManager FPM;
  // If you want to add a function-level pass, add FPM.addPass(MyPass()) here.

  FPM.addPass(SROA());
  FPM.addPass(RemoveUnsupportedOps());
  FPM.addPass(ADCEPass());

  //FPM.addPass(InstCombinePass());
  //FPM.addPass(PackRegisters());
  //FPM.addPass(WeirdArithmetic());

  ModulePassManager MPM;
  MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));  
  MPM.addPass(CheckConstExpr());

  // If you want to add your module-level pass, add MPM.addPass(MyPass2()) here.

  // Run!
  string ll=optOutputLL;
  string s=optOutput;

  if(ll=="" && s=="") s="a.s";

  if(ll!="") {
    error_code EC;
    raw_fd_ostream fout(ll, EC);
    fout << *M;
  }
  if(s!="") {
    MPM.addPass(SimpleBackend(s, optPrintDepromotedModule));
    MPM.run(*M, MAM);
  }

  return 0;
}
