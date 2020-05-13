#include <fstream>
#include <sstream>
#include <string>
#include <regex>

#include "error.h"
#include "parser.h"

#define PAREN(X) ("(" + (X) + ")")
#define SPACED(X) (PAREN(tESpace + (X) + tESpace))

const static string tSpace = "(\\s+)";
const static string tESpace = "(\\s*)";

const static string tAssign = SPACED("(=)");
const static string tReg = "(((r|arg)([1-9]|1[0-6]))|sp)";
const static string tConst = "([0-9]+)";
const static string tValue = PAREN(tReg + "|" + tConst);
const static string tName = "(([a-z]|[A-Z]|[0-9]|-|_|\\.)+)";
const static string tBBName = PAREN("\\." + tName);

const static string tArgN = "([0-9]|1[0-6])";
const static string tMSize = "(1|2|4|8)";
const static string tSize = "(1|8|16|32|64)";

const static string tStart = "(start)";
const static string tEnd = "(end)";
const static string tMalloc = "(malloc)";
const static string tFree = "(free)";
const static string tLoad = "(load)";
const static string tStore = "(store)";

const static string tRet = "(ret)";
const static string tBr = "(br)";
const static string tSwitch = "(switch)";

const static string tBop = "(udiv|sdiv|urem|srem|mul|shl|lshr|ashr|and|or|xor|add|sub)";
const static string tIcmp = "(icmp)";
const static string tCond = "(eq|ne|ugt|uge|ult|ule|sgt|sge|slt|sle)";
const static string tSelect = "(select)";

const static string tCall = "(call)";
const static string tAssert = "(assert_eq)";

const static string tRead = "(read)";
const static string tWrite = "(write)";

const static string rComment = SPACED("(;.*)");
const static string rStartFuncion = SPACED(tStart + tSpace + tName + tSpace + tArgN + tESpace + "(:)");
const static string rEndFunction = SPACED(tEnd + tSpace + tName);
const static string rBBStart = SPACED(tBBName + tESpace + "(:)");

const static string rMalloc = SPACED(tReg + tAssign + tMalloc + tSpace + tValue);
const static string rFree = SPACED(tFree + tSpace + tValue);
const static string rLoad = SPACED(tReg + tAssign + tLoad + tSpace + tMSize + tSpace + tValue + tSpace + tConst);
const static string rStore = SPACED(tStore + tSpace + tMSize + tSpace + tValue + tSpace + tValue + tSpace + tConst);
const static string rResetStack = SPACED("reset" + tSpace + "stack");
const static string rResetHeap = SPACED("reset" + tSpace + "heap");

const static string rRet = SPACED(tRet);
const static string rRetVal = SPACED(tRet + tSpace + tValue);
const static string rBrUncond = SPACED(tBr + tSpace + tBBName);
const static string rBrCond = SPACED(tBr + tSpace + tValue + tSpace + tBBName + tSpace + tBBName);
const static string rTable = "((" + tSpace + tConst + tSpace + tBBName + ")*)";
const static string rSwitch = SPACED(tSwitch + tSpace + tValue + rTable + tSpace + tBBName);

const static string rBop = SPACED(tReg + tAssign + tBop + tSpace + tValue + tSpace + tValue + tSpace + tSize);
const static string rIcmp = SPACED(tReg + tAssign + tIcmp + tSpace + tCond + tSpace + tValue + tSpace + tValue + tSpace + tSize);
const static string rSelect = SPACED(tReg + tAssign + tSelect + tSpace + tValue + tSpace + tValue + tSpace + tValue);

const static string rAssign = "((" + tReg + tAssign + ")?)";
const static string rArgs = "((" + tSpace + tValue + ")*)";
const static string rRead = SPACED(rAssign + tCall + tSpace + tRead);
const static string rWrite = SPACED(rAssign + tCall + tSpace + tWrite + tSpace + tValue);
const static string rCall = SPACED(rAssign + tCall + tSpace + tName + rArgs);
const static string rAssert = SPACED(tAssert + tSpace + tValue + tSpace + tValue);


enum ParserState {
  PSBegin = 0,
  PSStartFunction,
  PSStartBB,
  PSNormal,
  PSEndBB,
  PSEndFunction
};

Reg parse_reg(const string& reg) {
  if (regex_match(reg, regex("r.*"))) {
    int num = stoi(reg.substr(1));
    return (Reg)(num - 1);
  }

  if (regex_match(reg, regex("arg.*"))) {
    int num = stoi(reg.substr(3));
    return (Reg)((int)R16 + num);
  }

  if (reg == "sp") {
    return RegSp;
  }

  return RegNone;
}

uint64_t parse_const(const string& val) {
  try {
    uint64_t ret = stoull(val);
    return ret;
  } catch (exception& e) {
    invoke_syntax_error("constant out of range");
    return 0;
  }
}

Value parse_value(const string& val) {
  if (regex_match(val, regex(tReg)))
    return Value(parse_reg(val));
  else
    return Value(parse_const(val));
}

MSize parse_msize(const string& msize) {
  if (msize == "1") return MSize1;
  if (msize == "2") return MSize2;
  if (msize == "4") return MSize4;
  if (msize == "8") return MSize8;

  invoke_syntax_error("invalid size for memory operations");
  return MSize1;
}

Size parse_size(const string& size) {
  if (size == "1") return Size1;
  if (size == "8") return Size8;
  if (size == "16") return Size16;
  if (size == "32") return Size32;
  if (size == "64") return Size64;

  invoke_syntax_error("invalid bit width for arithmetic operations");
  return Size1;
}

Function* parse_start_function(const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  string fname;
  int nargs;

  ss >> token; // start
  ss >> fname; // fname
  ss >> token; // nargs
  nargs = stoi(token);

  return new Function(fname, nargs);
}

bool parse_end_function(const string& instr, const string& fname) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // end
  ss >> token; // fname

  return token == fname;
}

string parse_bbname(const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // bbname:
  return token.substr(0, token.length() - 1);
}

Stmt* parse_malloc(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // lhs
  Reg lhs = parse_reg(token);
  ss >> token; // malloc
  ss >> token; // val
  Value val = parse_value(token);

  return new StmtMalloc(line, lhs, val);
}

Stmt* parse_free(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // malloc
  ss >> token; // ptr
  Value ptr = parse_value(token);

  return new StmtFree(line, ptr);
}

Stmt* parse_load(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // lhs
  Reg lhs = parse_reg(token);
  ss >> token; // load
  ss >> token; // size
  MSize msize = parse_msize(token);
  ss >> token; // ptr
  Value ptr = parse_value(token);
  ss >> token; // ofs
  uint64_t ofs = parse_const(token);

  return new StmtLoad(line, lhs, msize, ptr, ofs);
}

Stmt* parse_store(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // store
  ss >> token; // size
  MSize msize = parse_msize(token);
  ss >> token; // val
  Value val = parse_value(token);
  ss >> token; // ptr
  Value ptr = parse_value(token);
  ss >> token; // ofs
  uint64_t ofs = parse_const(token);

  return new StmtStore(line, msize, val, ptr, ofs);
}

Stmt* parse_ret(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // ret

  if (ss >> token) {
    Value val = parse_value(token);
    return new StmtRet(line, val);
  }

  return new StmtRet(line, Value(0));
}

Stmt* parse_br_uncond(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // br
  ss >> token; // bbname
  string bbname = token;

  return new StmtBrUncond(line, bbname);
}

Stmt* parse_br_cond(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // br
  ss >> token; // cond
  Value cond = parse_value(token);
  ss >> token; // true_bb
  string true_bb = token;
  ss >> token; // false_bb
  string false_bb = token;

  return new StmtBrCond(line, cond, true_bb, false_bb);
}

Stmt* parse_switch(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // switch
  ss >> token; // cond
  Value cond = parse_value(token);
  auto stmt = new StmtSwitch(line, cond);

  while (true) {
    string token1, token2;
    ss >> token1;

    if (ss >> token2) {
      uint64_t val = parse_const(token1);
      if (stmt->case_exists(val)) {
        invoke_syntax_error("duplicated case in switch statement");
        return nullptr;
      }
      stmt->set_bb(val, token2);
      continue;
    }

    stmt->set_default(token1);
    break;
  }

  return stmt;
}

Stmt* parse_bop(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // reg
  Reg lhs = parse_reg(token);

  ss >> token; // bop kind
  BopKind kind;
  if (token == "udiv") kind = Udiv;
  else if (token == "sdiv") kind = Sdiv;
  else if (token == "urem") kind = Urem;
  else if (token == "srem") kind = Srem;
  else if (token == "mul") kind = Mul;
  else if (token == "shl") kind = Shl;
  else if (token == "lshr") kind = Lshr;
  else if (token == "ashr") kind = Ashr;
  else if (token == "and") kind = And;
  else if (token == "or") kind = Or;
  else if (token == "xor") kind = Xor;
  else if (token == "add") kind = Add;
  else if (token == "sub") kind = Sub;
  else {
    invoke_syntax_error("invalid binary operation");
    return nullptr;
  }

  ss >> token; // val1
  Value val1 = parse_value(token);
  ss >> token; // val2
  Value val2 = parse_value(token);
  ss >> token; // bw
  Size size = parse_size(token);

  return new StmtBop(line, lhs, kind, val1, val2, size);
}

Stmt* parse_icmp(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // reg
  Reg lhs = parse_reg(token);
  ss >> token; // icmp

  ss >> token; // cond
  BopKind kind;
  if (token == "eq") kind = Eq;
  else if (token == "ne") kind = Ne;
  else if (token == "ugt") kind = Ugt;
  else if (token == "uge") kind = Uge;
  else if (token == "ult") kind = Ult;
  else if (token == "ule") kind = Ule;
  else if (token == "sgt") kind = Sgt;
  else if (token == "sge") kind = Sge;
  else if (token == "slt") kind = Slt;
  else if (token == "sle") kind = Sle;
  else {
    invoke_syntax_error("invalid comparison");
    return nullptr;
  }

  ss >> token; // val1
  Value val1 = parse_value(token);
  ss >> token; // val2
  Value val2 = parse_value(token);
  ss >> token; // bw
  Size size = parse_size(token);

  return new StmtBop(line, lhs, kind, val1, val2, size);
}

Stmt* parse_select(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // lhs
  Reg lhs = parse_reg(token);
  ss >> token; // select
  ss >> token; // val_cond
  Value val_cond = parse_value(token);
  ss >> token; // val_true
  Value val_true = parse_value(token);
  ss >> token; // val_false
  Value val_false = parse_value(token);

  return new StmtSelect(line, lhs, val_cond, val_true, val_false);
}

Stmt* parse_call(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // reg or call
  Reg lhs = RegNone;
  if (regex_match(token, regex(tReg))) {
    lhs = parse_reg(token);
    ss >> token; // call
  }

  ss >> token; // fname
  string fname = token;
  auto stmt = new StmtCall(line, lhs, fname);

  while (ss >> token) {
    Value val = parse_value(token);
    stmt->push_arg(val);
  }

  return stmt;
}

Stmt* parse_assert(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // assert_eq
  ss >> token; // val1
  Value val1 = parse_value(token);
  ss >> token; // val2
  Value val2 = parse_value(token);

  return new StmtAssert(line, val1, val2);
}

Stmt* parse_read(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // reg or call
  Reg lhs = RegNone;
  if (regex_match(token, regex(tReg))) {
    lhs = parse_reg(token);
    ss >> token; // call
  }

  ss >> token; // fname
  if (token != "read")
    invoke_syntax_error("call to read function expected");

  return new StmtRead(line, lhs);
}

Stmt* parse_write(int line, const string& instr) {
  string rep = regex_replace(instr, regex(tAssign), " ");
  stringstream ss;
  string token;
  ss << rep;

  ss >> token; // reg or call
  Reg lhs = RegNone;
  if (regex_match(token, regex(tReg))) {
    lhs = parse_reg(token);
    ss >> token; // call
  }

  ss >> token; // fname
  if (token != "write")
    invoke_syntax_error("call to write function expected");

  ss >> token; // val
  Value val = parse_value(token);

  return new StmtWrite(line, lhs, val);
}

Stmt* parse_normal_stmt(int line, const string& instr) {
  if (regex_match(instr, regex(rMalloc)))
    return parse_malloc(line, instr);
  if (regex_match(instr, regex(rFree)))
    return parse_free(line, instr);
  if (regex_match(instr, regex(rLoad)))
    return parse_load(line, instr);
  if (regex_match(instr, regex(rStore)))
    return parse_store(line, instr);
  if (regex_match(instr, regex(rResetStack)))
    return new StmtResetStack(line);
  if (regex_match(instr, regex(rResetHeap)))
    return new StmtResetHeap(line);

  if (regex_match(instr, regex(rBop)))
    return parse_bop(line, instr);
  if (regex_match(instr, regex(rIcmp)))
    return parse_icmp(line, instr);
  if (regex_match(instr, regex(rSelect)))
    return parse_select(line, instr);

  if (regex_match(instr, regex(rRead)))
    return parse_read(line, instr);
  if (regex_match(instr, regex(rWrite)))
    return parse_write(line, instr);
  if (regex_match(instr, regex(rCall)))
    return parse_call(line, instr);

  if (regex_match(instr, regex(rAssert)))
    return parse_assert(line, instr);

  return nullptr;
}

Stmt* parse_terminator(int line, const string& instr) {
  if (regex_match(instr, regex(rRet)))
    return parse_ret(line, instr);
  if (regex_match(instr, regex(rRetVal)))
    return parse_ret(line, instr);
  if (regex_match(instr, regex(rBrUncond)))
    return parse_br_uncond(line, instr);
  if (regex_match(instr, regex(rBrCond)))
    return parse_br_cond(line, instr);
  if (regex_match(instr, regex(rSwitch)))
    return parse_switch(line, instr);

  return nullptr;
}

Program* parse(const string& filename) {
  ParserState state = PSBegin;
  ifstream input(filename);

  if (!input.is_open())
    return nullptr;

  int line = 0;
  string instr;
  regex re(tESpace);
  auto program = new Program();
  Function* curr_function = nullptr;
  string curr_bb;
  Stmt* prev_stmt;
  Stmt* curr_stmt;

  while (getline(input, instr)) {
    error_line_num = ++line;
    if (regex_match(instr, regex(tESpace + "|" + rComment))) {
      continue;
    }

    switch (state) {
      /** start parsing */
      case PSBegin: {
        if (!regex_match(instr, regex(rStartFuncion)))
          invoke_syntax_error("start of a function expected");

        curr_function = parse_start_function(instr);
        string fname = curr_function->get_fname();
        if (fname == "read" || fname == "write")
          invoke_syntax_error("duplicated function name");

        program->set_function(fname, curr_function);
        state = PSStartFunction;
        break;
      }
      /** parsed a function start */
      case PSStartFunction: {
        if (!regex_match(instr, regex(rBBStart)))
          invoke_syntax_error("start of a basic block expected");

        curr_bb = parse_bbname(instr);
        curr_function->set_first_bb(curr_bb);
        state = PSStartBB;
        break;
      }
      /** parsed a basic block name */
      case PSStartBB: {
        curr_stmt = parse_normal_stmt(line, instr);
        if (curr_stmt != nullptr) {
          if (!curr_function->set_bb(curr_bb, curr_stmt))
            invoke_syntax_error("duplicated basic block");
          prev_stmt = curr_stmt;
          state = PSNormal;
          break;
        }

        curr_stmt = parse_terminator(line, instr);
        if (curr_stmt != nullptr) {
          curr_function->set_bb(curr_bb, curr_stmt);
          state = PSEndBB;
          break;
        }

        invoke_syntax_error("instruction expected");
        break;
      }
      /** parsed a non-terminating instruction */
      case PSNormal: {
        curr_stmt = parse_normal_stmt(line, instr);
        if (curr_stmt != nullptr) {
          prev_stmt->set_next(curr_stmt);
          prev_stmt = curr_stmt;
          state = PSNormal;
          break;
        }

        curr_stmt = parse_terminator(line, instr);
        if (curr_stmt != nullptr) {
          prev_stmt->set_next(curr_stmt);
          state = PSEndBB;
          break;
        }

        invoke_syntax_error("instruction expected");
        break;
      }
      /** parsed end of basic block */
      case PSEndBB: {
        if (regex_match(instr, regex(rBBStart))) {
          curr_bb = parse_bbname(instr);
          state = PSStartBB;
          break;
        }

        if (regex_match(instr, regex(rEndFunction))) {
          if (!parse_end_function(instr, curr_function->get_fname()))
            invoke_syntax_error("unmatching function name");
          state = PSEndFunction;
          break;
        }

        invoke_syntax_error("bbname or end of function expected");
        break;
      }
      /** parsed end of function */
      case PSEndFunction: {
        if (!regex_match(instr, regex(rStartFuncion)))
          invoke_syntax_error("start of a function expected");

        curr_function = parse_start_function(instr);
        string fname = curr_function->get_fname();
        if (fname == "read" || fname == "write" || !program->set_function(fname, curr_function))
          invoke_syntax_error("duplicated function name");
        state = PSStartFunction;
        break;
      }
    }
  }

  input.close();

  if (state != PSEndFunction)
    invoke_syntax_error("function not ended");

  error_line_num = 0;

  Function* main = program->get_function("main");
  if (main == nullptr)
    invoke_syntax_error("missing main function");
  if (main->get_nargs() != 0)
    invoke_syntax_error("main function should take 0 arguments");

  return program;
}
