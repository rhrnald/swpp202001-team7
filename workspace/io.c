#include <stdio.h>
#include <stdint.h>

int64_t read() {
  int64_t ret;
  scanf("%ld", &ret);
  return ret;
}
void write(int64_t r) {
  printf("%ld", r);
}
