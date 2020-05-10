#include "size.h"


int msize_of(MSize msize) {
  switch (msize) {
    case MSize1:
      return 1;
    case MSize2:
      return 2;
    case MSize4:
      return 4;
    case MSize8:
      return 8;
  }
}

int bw_of(Size size) {
  switch (size) {
    case Size1:
      return 1;
    case Size8:
      return 8;
    case Size16:
      return 16;
    case Size32:
      return 32;
    case Size64:
      return 64;
  }
}
