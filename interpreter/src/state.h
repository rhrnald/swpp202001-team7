#ifndef SWPP_ASM_INTERPRETER_STATE_H
#define SWPP_ASM_INTERPRETER_STATE_H

#include <vector>

#include "regfile.h"
#include "memory.h"
#include "program.h"

using namespace std;


class State {
private:
  RegFile regfile;
  Memory memory;
  double cost;
  Program* program;

public:
  State();

  void set_program(Program* _program);
  double get_cost() const;
  uint64_t get_max_alloced_size() const;
  uint64_t exec_function(Function* function);
};

#endif //SWPP_ASM_INTERPRETER_STATE_H
