#ifndef SWPP_ASM_INTERPRETER_VALUE_H
#define SWPP_ASM_INTERPRETER_VALUE_H

#include <cinttypes>

#include "regfile.h"


class Value {
private:
  const bool kind;
  const Reg reg;
  const uint64_t literal;

public:
  explicit Value(Reg _reg);
  explicit Value(uint64_t _literal);

  uint64_t get_value(const RegFile& regfile) const;
};

#endif //SWPP_ASM_INTERPRETER_VALUE_H
