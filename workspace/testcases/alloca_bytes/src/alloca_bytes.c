#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

uint8_t *__alloca_bytes__(uint64_t size) {
  return (uint8_t *) malloc(size);
}

int main() {
  uint8_t *p = __alloca_bytes__(8);
  uint64_t r = read();
  for (int i=0; i<8; ++i) {
    p[i] = (uint8_t) r;
    r >>= 8;
    r *= -1;
  }
  r = 0;
  for (int i=0; i<8; ++i) {
    r += p[i];
  }
  write(r);

  return 0;
}
