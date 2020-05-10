#ifndef SWPP_ASM_INTERPRETER_SIZE_H
#define SWPP_ASM_INTERPRETER_SIZE_H


enum MSize {
  MSize1 = 0,
  MSize2,
  MSize4,
  MSize8
};

enum Size{
  Size1 = 0,
  Size8,
  Size16,
  Size32,
  Size64
};

int msize_of(MSize msize);

int bw_of(Size size);

#endif //SWPP_ASM_INTERPRETER_SIZE_H
