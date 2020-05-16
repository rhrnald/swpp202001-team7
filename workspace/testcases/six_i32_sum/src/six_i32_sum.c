// https://www.geeksforgeeks.org/count-set-bits-in-an-integer/
#include<stdint.h>

int64_t read();
void write(int64_t);

int32_t sum_of(int32_t a, int32_t b, int32_t c, int32_t d, int32_t e, int32_t f) {
  return a - b + c - d + e - f;
}

int main() {
  int64_t l = read();
  while (l--) {
    int32_t a = (int32_t) read();
    int32_t b = (int32_t) read();
    int32_t c = (int32_t) read();
    int32_t d = (int32_t) read();
    int32_t e = (int32_t) read();
    int32_t f = (int32_t) read();
    write((unsigned int)sum_of(a, b, c, d, e, f));
  }
  return 0;
}
