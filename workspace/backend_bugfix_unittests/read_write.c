#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

uint64_t read() {
  uint64_t b;
  scanf("%lu", &b);
  return b;
}

void write(uint64_t a) {
  printf("%lu\n", a);
}

