// This code is to see the role of `free'
#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

uint64_t max(uint64_t a, uint64_t b) {
  return a > b? a : b;
}

int main() {
  uint64_t n = read();
  uint64_t *a = (uint64_t*) malloc(sizeof(uint64_t) * n);
  uint64_t *b = (uint64_t*) malloc(sizeof(uint64_t) * n);

  for (int i=0; i<n; i++) {
    b[i] = read();
  }

  for (int i=0; i<n; i++) {
    write(max(a[i], b[i]));
  }
  
  return 0;
}
