#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

uint8_t *__alloca_bytes__(uint64_t size, uint64_t free_in_this_block, uint64_t align) {
  return (uint8_t *) malloc(size);
}

void __free_bytes__(uint64_t size);

int main() {
  uint64_t r = read();
  for (int i=0; i<8; ++i) {
    uint8_t *p = __alloca_bytes__((i+1) * 8, 1, 0);
    *p = (uint8_t) r;
    r >>= 8;
    write(*p);
  }
  return 0;
}
