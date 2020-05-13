#ifndef SWPP_ASM_INTERPRETER_PROGRAM_H
#define SWPP_ASM_INTERPRETER_PROGRAM_H

#include <map>

#include "function.h"

using namespace std;


class Program {
private:
  map<string, Function*> function_map;

public:
  Program();

  Function* get_function(const string& fname);
  bool set_function(const string& fname, Function* function);
};

#endif //SWPP_ASM_INTERPRETER_PROGRAM_H
