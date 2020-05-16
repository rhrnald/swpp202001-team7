#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

int main() {
  uint64_t r = read();
  uint64_t m = -1;
  while(r != -r) {
    r &= m;
    r += r;
    m >>= 1;
  }
  write(m);
  return 0;
}
