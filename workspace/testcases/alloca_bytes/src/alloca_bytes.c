#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

uint8_t *__alloca_bytes__(uint64_t size) {
  return (uint8_t *) malloc(size);
}

void heavy_func(uint64_t a1, uint64_t a2, uint64_t a3, uint64_t a4,
                uint64_t a5, uint64_t a6, uint64_t a7, uint64_t a8, 
                uint64_t a9, uint64_t a10, uint64_t a11, uint64_t a12,
                uint64_t a13, uint64_t a14, uint64_t a15, uint64_t a16) {
  write(a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9
        + a10 + a11 + a12 + a13 + a14 + a15 + a16);
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

  // this is for checking a function call with full arguments.
  // for a simpler .ll code, you can comment this out!
  heavy_func(read(), read(), read(), read(), read(), read(), read(), read(), 
             read(), read(), read(), read(), read(), read(), read(), read());

  heavy_func(read(), read(), read(), read(), read(), read(), read(), 0, 
             read(), read(), read(), read(), read(), read(), read(), read());
  
  return 0;
}
