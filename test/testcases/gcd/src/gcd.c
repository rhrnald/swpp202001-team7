#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

uint64_t gcd(uint64_t x, uint64_t y) {
  if (x == 0) return y;
  if (y == 0) return x;

  if (x > y) x %= y;
  else y %= x;

  return gcd(x, y);
}

int main() {
  uint64_t x, y;
  x = read();
  y = read();

  write(gcd(x, y));
}
