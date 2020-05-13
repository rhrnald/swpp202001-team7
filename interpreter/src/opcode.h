#ifndef SWPP_ASM_INTERPRETER_OPCODE_H
#define SWPP_ASM_INTERPRETER_OPCODE_H


enum Opcode {
  // memory operations
  Malloc = 0,
  Free,
  Load,
  Store,
  ResetStack,
  ResetHeap,

  // terminators
  Ret,
  BrUncond,
  BrCond,
  Switch,

  // binary operations
  Bop,

  // ternary operation
  Select,

  // function call
  Call,

  // assertion
  Assert,

  // read and write
  Read,
  Write
};

enum BopKind {
  // arithmetic operations
  Udiv = 0,
  Sdiv,
  Urem,
  Srem,
  Mul,

  // logical operations
  Shl,
  Lshr,
  Ashr,
  And,
  Or,
  Xor,
  Add,
  Sub,

  // comparisons
  Eq,
  Ne,
  Ugt,
  Uge,
  Ult,
  Ule,
  Sgt,
  Sge,
  Slt,
  Sle
};

class Cost {
public:
  // cost of memory operations
  constexpr static double MALLOC = 1.0;
  constexpr static double FREE = 1.0;
  constexpr static double STACK = 2.0;
  constexpr static double HEAP = 4.0;
  constexpr static double PER_BYTE = 0.0004;
  constexpr static double RESET = 2.0;

  // cost of terminators
  constexpr static double TERMINATOR = 1.0;

  // cost of binary operations
  constexpr static double MULDIV = 0.6;
  constexpr static double LOGICAL = 0.8;
  constexpr static double ADDSUB = 1.2;
  constexpr static double COMP = 1.0;

  // cost of ternary operation
  constexpr static double TERNARY = 1.2;

  // cost of function call
  constexpr static double CALL = 2.0;
  constexpr static double PER_ARG = 1.0;

  // cost of assertion
  constexpr static double ASSERT = 0.0;
};


#endif //SWPP_ASM_INTERPRETER_OPCODE_H
