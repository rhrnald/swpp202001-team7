// This code is to see the role of `free'
#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);


int main() {
  uint8_t *a = malloc(2048);
  uint8_t *b = malloc(2048);
  uint8_t *c = malloc(2048);
  *a = (uint8_t) read();
  *b = (uint8_t) read();
  *c = (uint8_t) read();
  write((uint64_t) a[0]);
  write((uint64_t) b[0]);
  write((uint64_t) c[0]);
  free(a);
  free(b);
  free(c);
  uint8_t *i = malloc(2048);
  uint8_t *j = malloc(2048);
  *i = (uint8_t) read();
  *j = (uint8_t) read();
  write((uint64_t) i[0]);
  write((uint64_t) j[0]);
  free(i);
  free(j);
  
  return 0;
}
