#include <sstream>

#include "error.h"
#include "regfile.h"
#include "memory.h"

using namespace std;


RegFile::RegFile(): nargs(0) {
  for (uint64_t& i: regfile)
    i = 0;
  regfile[RegSp] = STACK_MAX;
}

void RegFile::set_nargs(int _nargs) { nargs = _nargs; }

void RegFile::set_value(Reg reg, uint64_t val) {
  if (reg == RegNone)
    return;
  regfile[reg] = val;
}

uint64_t RegFile::read_reg(Reg reg) const {
  if ((int)A1 + nargs <= reg && reg <= A16)
    invoke_runtime_error("reading out-of-range argument");
  if (reg == RegNone)
    invoke_runtime_error("reading an unknown register");
  return regfile[reg];
}

void RegFile::write_reg(Reg reg, uint64_t val) {
  if (reg == RegNone)
    return;
  if (A1 <= reg && reg <= A16)
    invoke_runtime_error("writing to a read-only register");
  regfile[reg] = val;
}

string RegFile::to_string() const {
  stringstream ss;
  for (int i = 0; i < 16; i++)
    ss << "r" << (i + 1) << "[" << regfile[i] << "]" << " ";
  for (int i = 16; i < 32; i++)
    ss << "arg" << (i - 15) << "[" << regfile[i] << "]" << " ";
  ss << "sp[" << regfile[32] << "]";

  return ss.str();
}
