#ifndef BACKEND_H
#define BACKEND_H

#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include <string>

const std::string AllocaBytesName = "__alloca_bytes__";
const std::string SetRefName = "__set_ref__";
const std::string SpillRefName = "__spill_ref__";

class Backend : public llvm::PassInfoMixin<Backend> {
  std::string outputFile;
  bool printDepromotedModule;

public:
  Backend(std::string outputFile, bool printDepromotedModule) :
      outputFile(outputFile), printDepromotedModule(printDepromotedModule) {}
  llvm::PreservedAnalyses run(llvm::Module &M, llvm::ModuleAnalysisManager &MAM);
};

class AssemblyEmitter {
  llvm::raw_ostream *fout;
public:
  AssemblyEmitter(llvm::raw_ostream *fout) : fout(fout) {}
  void run(llvm::Module *M);
};

unsigned getAccessSize(llvm::Type *T);

#endif