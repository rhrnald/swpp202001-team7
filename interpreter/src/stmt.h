#ifndef SWPP_ASM_INTERPRETER_STMT_H
#define SWPP_ASM_INTERPRETER_STMT_H

#include <string>
#include <map>

#include "opcode.h"
#include "value.h"
#include "size.h"
#include "memory.h"

using namespace std;


class Stmt {
private:
  const int line;
  const Reg lhs;
  const Opcode opcode;
  Stmt* next;

public:
  Stmt(int _line, Reg _lhs, Opcode _opcode);

  int get_line() const;
  Reg get_lhs() const;
  Opcode get_opcode() const;
  Stmt* get_next() const;
  void set_next(Stmt* stmt);

  virtual double exec(RegFile& regfile, Memory& memory) const = 0;
};


/** memory operations */

class StmtMalloc: public Stmt {
private:
  const Value val;

public:
  StmtMalloc(int _line, Reg _lhs, Value _val);

  double exec(RegFile& regfile, Memory& memory) const override;
};

class StmtFree: public Stmt {
private:
  const Value ptr;

public:
  explicit StmtFree(int _line, Value _ptr);

  double exec(RegFile& regfile, Memory& memory) const override;
};

class StmtLoad: public Stmt {
private:
  const MSize size;
  const Value ptr;
  const uint64_t ofs;

public:
  StmtLoad(int _line, Reg _lhs, MSize _size, Value _ptr, uint64_t _ofs);

  double exec(RegFile& regfile, Memory& memory) const override;
};

class StmtStore: public Stmt {
private:
  const MSize size;
  const Value val;
  const Value ptr;
  const uint64_t ofs;

public:
  StmtStore(int _line, MSize _size, Value _val, Value _ptr, uint64_t _ofs);

  double exec(RegFile& regfile, Memory& memory) const override;
};

class StmtResetStack: public Stmt {
public:
  StmtResetStack(int _line);

  double exec(RegFile& regfile, Memory& memory) const override;
};

class StmtResetHeap: public Stmt {
public:
  StmtResetHeap(int _line);

  double exec(RegFile& regfile, Memory& memory) const override;
};


/** terminators */

class StmtRet: public Stmt {
private:
  const Value val;

public:
  explicit StmtRet(int _line, Value _val);

  Value get_val() const;
  double exec(RegFile& regfile, Memory& memory) const override;
};

class StmtBrUncond: public Stmt {
private:
  const string bb;

public:
  explicit StmtBrUncond(int _line, string _bb);

  string get_bb() const;
  double exec(RegFile& regfile, Memory& memory) const override;
};

class StmtBrCond: public Stmt {
private:
  const Value cond;
  const string true_bb;
  const string false_bb;

public:
  StmtBrCond(int _line, Value _cond, string _true_bb, string _false_bb);

  string get_bb(const RegFile& regfile) const;
  double exec(RegFile& regfile, Memory& memory) const override;
};

class StmtSwitch: public Stmt {
private:
  const Value cond;
  map<uint64_t, string> bb_map;
  string default_bb;

public:
  explicit StmtSwitch(int _line, Value _cond);

  bool set_bb(uint64_t val, string bb);
  void set_default(string bb);
  bool case_exists(uint64_t val) const;
  string get_bb(const RegFile& regfile) const;
  double exec(RegFile& regfile, Memory& memory) const override;
};


/** binary operations */

class StmtBop: public Stmt {
private:
  const BopKind bop_kind;
  const Value val1;
  const Value val2;
  const Size size;

  uint64_t compute(uint64_t op1, uint64_t op2) const;

public:
  StmtBop(int _line, Reg _lhs, BopKind _bop_kind, Value _val1, Value _val2, Size size);

  double exec(RegFile& regfile, Memory& memory) const override;
};


/** ternary operation */

class StmtSelect: public Stmt {
private:
  const Value cond;
  const Value val_true;
  const Value val_false;

public:
  StmtSelect(int _line, Reg _lhs, Value _cond, Value _val_true, Value _val_false);

  double exec(RegFile& regfile, Memory& memory) const override;
};


/** function call */

class StmtCall: public Stmt {
private:
  const string fname;
  vector<Value> args;

public:
  StmtCall(int _line, Reg _lhs, string _fname);

  string get_fname() const;
  void push_arg(Value arg);
  int get_nargs();
  void setup_args(const RegFile& old, RegFile& regfile);
  double exec(RegFile& regfile, Memory& memory) const override;
};


/** assertion */

class StmtAssert: public Stmt {
private:
  const Value op1;
  const Value op2;

public:
  StmtAssert(int _line, Value _op1, Value _op2);

  double exec(RegFile& regfile, Memory& memory) const override;
};


/** read and write */

class StmtRead: public Stmt {
public:
  StmtRead(int _line, Reg _lhs);

  double exec(RegFile& regfile, Memory& memory) const override;
};

class StmtWrite: public Stmt {
private:
  const Value val;

public:
  StmtWrite(int _line, Reg _lhs, Value _val);

  double exec(RegFile& regfile, Memory& memory) const override;
};

#endif //SWPP_ASM_INTERPRETER_STMT_H
