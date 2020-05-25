#include "Backend.h"

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
#include "../passes/Wrapper.h"

//Additional Pass
#include "llvm/Transforms/InstCombine/InstCombine.h"

#include <string>

//For Builtin Pass Runner
#include "./LLVMPath.h"

using namespace std;
using namespace llvm;


static cl::OptionCategory optCategory("SWPP Compiler options");

static cl::opt<string> optInput(
    cl::Positional, cl::desc("<input bitcode file>"), cl::Required,
    cl::value_desc("filename"), cl::cat(optCategory));

//Change -o option not to be required. If none, output "a.s" file.
static cl::opt<string> optOutput(
    "o", cl::desc("output assembly file"), cl::cat(optCategory),
    cl::init(""));

//Add -d option for debugging.
static cl::opt<string> optOutputLL(
    "d", cl::desc("Export LL file together"), cl::cat(optCategory), cl::init(""));

//Usage removed because our own debug way had asserted.
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

// Run builtin optimizations using LLVMBIN/opt
static void runBuiltinOpt(string OptPipeline, unique_ptr<Module> &M) {
  // System call to run builtin passes using `opt`.
  error_code EC;
  string InLL = ".input.ll";
  string OutLL = ".outputLL";
  raw_fd_ostream PrevModuleOut(InLL, EC);

  // Print the previous module info
  PrevModuleOut << *M;
  string Command = LLVM_BIN;
  Command += "/opt " + OptPipeline + " " + InLL + " -S -o " + OutLL;
  system(Command.c_str());

  // Reload and delete temporary files
  M = openInputFile(M->getContext(), OutLL);
  system(("rm " + InLL + " " + OutLL).c_str());
}

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

  // Loop builtin optimizations
  string LoopPrePasses = "-loop-simplify -loop-deletion";
  string LoopBasicPasses = "-lcssa -licm -loop-vectorize -loop-unswitch -loop-distribute -loop-data-prefetch -loop-idiom -loop-simplifycfg -loop-rotate";
  string LoopMainPasses = "-loop-interchange -loop-unroll -unroll-runtime -unroll-count=8";
  string LoopEndPasses = "-gvn -aggressive-instcombine";

  runBuiltinOpt(LoopPrePasses, M);
  runBuiltinOpt(LoopBasicPasses, M);
  runBuiltinOpt(LoopMainPasses, M);
  runBuiltinOpt(LoopEndPasses, M);

  // If you want to add a function-level pass, add FPM.addPass(MyPass()) here.
  FunctionPassManager FPM;

  FPM.addPass(SROA());
  FPM.addPass(ADCEPass());
  FPM.addPass(InstCombinePass());

  FPM.addPass(RemoveUnsupportedOps());

  // If you want to add your module-level pass, add MPM.addPass(MyPass2()) here.
  ModulePassManager MPM;
  MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));  

  MPM.addPass(CheckConstExpr());
  MPM.addPass(PackRegisters());
  MPM.addPass(WeirdArithmetic());

  // Run!
  string ll=optOutputLL;
  string s=optOutput;

  if(s=="") s="a.s";
  MPM.addPass(SimpleBackend(s, false));
  MPM.run(*M, MAM);

  if(ll!="") {
    error_code EC;
    raw_fd_ostream fout(ll, EC);
    fout << *M;
  }

  return 0;
}
