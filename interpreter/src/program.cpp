#include "program.h"


Program::Program(): function_map() {}

Function * Program::get_function(const string &fname) {
  auto it = function_map.find(fname);
  if (it == function_map.end())
    return nullptr;
  return it->second;
}

bool Program::set_function(const string &fname, Function * function) {
  auto it = function_map.find(fname);
  if (it != function_map.end())
    return false;
  function_map.insert(pair<string, Function*>(fname, function));
  return true;
}
