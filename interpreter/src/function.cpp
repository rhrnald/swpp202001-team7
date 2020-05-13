#include "function.h"


Function::Function(string _fname, int _nargs):
fname(std::move(_fname)), nargs(_nargs), first_bb(), bb_map() {}

const string & Function::get_fname() const { return fname; }

int Function::get_nargs() const { return nargs; }

Stmt* Function::get_first_bb() const {
  auto it = bb_map.find(first_bb);
  if (it == bb_map.end())
    return nullptr;
  return it->second;
}

void Function::set_first_bb(const string& bb) { first_bb = bb; }

Stmt* Function::get_bb(const string &bbname) const {
  auto it = bb_map.find(bbname);
  if (it == bb_map.end())
    return nullptr;
  return it->second;
}

bool Function::set_bb(const string &bbname, Stmt *stmt) {
  auto it = bb_map.find(bbname);
  if (it != bb_map.end())
    return false;
  bb_map.insert(pair<string, Stmt*>(bbname, stmt));
  return true;
}
