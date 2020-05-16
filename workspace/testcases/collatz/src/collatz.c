#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

uint32_t collatz(int16_t* iter, uint32_t n) {
  write(n);
  if (n <= 1) return n;
  if (*iter < 0) return -1;

  *iter = *iter + 1;
  n = n % 2 == 0 ? n / 2 : 3 * n + 1;
  return collatz(iter, n);
}

int main() {
  uint32_t n = read();
  int16_t iter = 0;

  collatz(&iter, n);
  write(iter);
}
