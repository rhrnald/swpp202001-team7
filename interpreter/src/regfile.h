#ifndef SWPP_ASM_INTERPRETER_REGFILE_H
#define SWPP_ASM_INTERPRETER_REGFILE_H

#include <cinttypes>
#include <string>

#include "reg.h"

using namespace std;


class RegFile {
private:
  uint64_t regfile[NREGS];
  int nargs;

public:
  RegFile();

  void set_nargs(int _nargs);
  void set_value(Reg reg, uint64_t val);
  uint64_t read_reg(Reg reg) const;
  void write_reg(Reg reg, uint64_t val);
  string to_string() const;
};

#endif //SWPP_ASM_INTERPRETER_REGFILE_H
