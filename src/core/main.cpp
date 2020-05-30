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

//Add -except option for test.
static cl::opt<string> exPassList(
    "except", cl::desc("Passes not to included on building"), cl::cat(optCategory), cl::init(""));

//Add -nopass option for test.
static cl::opt<bool> noPass(
    "nopass", cl::desc("add no pass to compiler"), cl::cat(optCategory), cl::init(false));

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

// split passes by ,
void split(string &s, vector<string> &list) {
  int prv=0;
  int n=(int)s.size();
  for(int i=0; i<n-1; i++) {
    if(s[i]==',') {
      list.push_back(s.substr(prv, i-prv-1));
      prv=i+1;
    }
  }
  list.push_back(s.substr(prv, n-prv));
}

bool excepted(const char *c , vector<string> &list) {
  if(noPass) return true;
  string s(c);
  for(auto &e :list) if(e==s) return true;
  return false;
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

  // Pass pipeline processer
  vector<string> exceptList;
  split(exPassList, exceptList);

  if (!excepted("LoopOptimization", exceptList)) {
    // Loop builtin optimizations
    string LoopPrePasses = "-loop-simplify -loop-deletion -lcssa -licm -loop-distribute";
    string LoopBasicPasses = "-loop-unswitch -loop-data-prefetch -loop-idiom -loop-load-elim -loop-predication -loop-versioning -loop-reduce -loop-simplifycfg -loop-rotate";
    string LoopMainPasses = "-loop-interchange -loop-unroll -unroll-runtime -unroll-count=8 -unroll-remainder -unroll-threshold=100";
    string LoopEndPasses = "-instcombine -simplifycfg -loop-instsimplify -instcombine -aggressive-instcombine";

    runBuiltinOpt(LoopPrePasses, M);
    runBuiltinOpt(LoopBasicPasses, M);
    runBuiltinOpt(LoopMainPasses, M);
    runBuiltinOpt(LoopEndPasses, M);
  }

  // If you want to add a function-level pass, add FPM.addPass(MyPass()) here.
  FunctionPassManager FPM;

  FPM.addPass(SROA());
  FPM.addPass(ADCEPass());

  if (!excepted("InstCombinePass", exceptList))
    FPM.addPass(InstCombinePass());

  FPM.addPass(RemoveUnsupportedOps());

  // If you want to add your module-level pass, add MPM.addPass(MyPass2()) here.
  ModulePassManager MPM;
  MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));  

  if (!excepted("CheckConstExpr", exceptList))
    MPM.addPass(CheckConstExpr());
  if (!excepted("PackRegisters", exceptList))
    MPM.addPass(PackRegisters());
  
  if (!excepted("ReorderMemAccess", exceptList))
    MPM.addPass(ReorderMemAccess());
    
  if (!excepted("WeirdArithmetic", exceptList))
    MPM.addPass(WeirdArithmetic());

  // Run!
  string ll=optOutputLL;
  string s=optOutput;

  if(s=="") s="a.s";
  MPM.addPass(Backend(s, false));
  MPM.run(*M, MAM);

  if(ll!="") {
    error_code EC;
    raw_fd_ostream fout(ll, EC);
    fout << *M;
  }

  return 0;
}
