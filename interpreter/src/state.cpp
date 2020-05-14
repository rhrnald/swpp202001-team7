#include "state.h"
#include "error.h"


State::State(): regfile(), memory(), cost(0), program(nullptr) {}

void State::set_program(Program* _program) {
  if (program == nullptr)
    program = _program;
}

double State::get_cost() const { return cost; }

uint64_t State::get_max_alloced_size() const {
  return memory.get_max_alloced_size();
}

uint64_t State::exec_function(Function* function) {
  Stmt* curr = function->get_first_bb();
  if (curr == nullptr)
    invoke_runtime_error("missing first basic block");

  while (true) {
    error_line_num = curr->get_line();

    switch (curr->get_opcode()) {
      case Ret: {
        auto stmt = dynamic_cast<StmtRet*>(curr);
        uint64_t ret = stmt->get_val().get_value(regfile);
        cost += Cost::TERMINATOR;
        return ret;
      }
      case BrUncond: {
        auto stmt = dynamic_cast<StmtBrUncond*>(curr);
        string bb = stmt->get_bb();
        curr = function->get_bb(bb);
        if (curr == nullptr) {
          invoke_runtime_error("branching to an undefined basic block");
          return 0;
        }
        cost += Cost::TERMINATOR;
        break;
      }
      case BrCond: {
        auto stmt = dynamic_cast<StmtBrCond*>(curr);
        string bb = stmt->get_bb(regfile);
        curr = function->get_bb(bb);
        if (curr == nullptr) {
          invoke_runtime_error("branching to an undefined basic block");
          return 0;
        }
        cost += Cost::TERMINATOR;
        break;
      }
      case Switch: {
        auto stmt = dynamic_cast<StmtSwitch*>(curr);
        string bb = stmt->get_bb(regfile);
        curr = function->get_bb(bb);
        if (curr == nullptr) {
          invoke_runtime_error("branching to an undefined basic block");
          return 0;
        }
        cost += Cost::TERMINATOR;
        break;
      }
      case Call: {
        auto stmt = dynamic_cast<StmtCall*>(curr);
        string fname = stmt->get_fname();
        Function* callee = program->get_function(fname);
        if (callee == nullptr) {
          invoke_runtime_error("calling an undefined function");
          return 0;
        }

        int nargs = callee->get_nargs();
        if (nargs != stmt->get_nargs()) {
          invoke_runtime_error("calling with incorrect number of arguments");
          return 0;
        }

        RegFile old = regfile;

        regfile.set_nargs(nargs);
        stmt->setup_args(old, regfile);
        cost += (Cost::CALL + nargs * Cost::PER_ARG);
        uint64_t ret = exec_function(callee);
        regfile = old;
        regfile.write_reg(curr->get_lhs(), ret);

        curr = stmt->get_next();
        break;
      }
      default: {
        cost += curr->exec(regfile, memory);
        curr = curr->get_next();
      }
    }
  }
}
