// https://www.geeksforgeeks.org/count-set-bits-in-an-integer/
#include<stdint.h>

int64_t read();
void write(int64_t);

int64_t sum_of(int8_t a, int32_t b, int32_t c, int8_t d, int8_t *e) {
  return a + b + c + d + ((int64_t) e);
}

int main() {
  int64_t l = read();
  while (l--) {
    int8_t a = (int8_t) read();
    int32_t b = (int32_t) read();
    int32_t c = (int32_t) read();
    int8_t d = (int8_t) read();
    int8_t *e = 0;
    write((unsigned int)sum_of(a, b, c, d, e));
  }
  return 0;
}
