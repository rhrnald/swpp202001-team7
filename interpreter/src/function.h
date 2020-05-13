#ifndef SWPP_ASM_INTERPRETER_FUNCTION_H
#define SWPP_ASM_INTERPRETER_FUNCTION_H

#include <map>

#include "stmt.h"

using namespace std;


class Function {
private:
  const string fname;
  const int nargs;
  string first_bb;
  map<string, Stmt*> bb_map;

public:
  Function(string _fname, int _nargs);

  const string& get_fname() const;
  int get_nargs() const;
  Stmt* get_first_bb() const;
  void set_first_bb(const string& bb);
  Stmt* get_bb(const string& bbname) const;
  bool set_bb(const string& bbname, Stmt* stmt);
};

#endif //SWPP_ASM_INTERPRETER_FUNCTION_H
