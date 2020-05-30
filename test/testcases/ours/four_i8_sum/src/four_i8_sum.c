// https://www.geeksforgeeks.org/count-set-bits-in-an-integer/
#include<stdint.h>

int64_t read();
void write(int64_t);

int8_t sum_of(int8_t a, int8_t b, int8_t c, int8_t d) {
  return a + b + c + d;
}

int main() {
  int8_t a = (int8_t) read();
  int8_t b = (int8_t) read();
  int8_t c = (int8_t) read();
  int8_t d = (int8_t) read();
  write((unsigned int)sum_of(a, b, c, d));
  return 0;
}
