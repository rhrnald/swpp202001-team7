#ifndef SIMPLE_BACKEND_H
#define SIMPLE_BACKEND_H

#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include <string>

class SimpleBackend : public llvm::PassInfoMixin<SimpleBackend> {
  std::string outputFile;
  bool printDepromotedModule;

public:
  SimpleBackend(std::string outputFile, bool printDepromotedModule) :
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