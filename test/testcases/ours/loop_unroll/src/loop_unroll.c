#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

int main() {
  uint64_t n = read();
  uint64_t *a = (uint64_t*) malloc(sizeof(uint64_t) * (n+1));

  for (uint64_t i = 1; i <= n; i++) {
    a[i] = read();
  }

  for (uint64_t i = n; i > 0; i--) {
    write(a[i]);
  }

  return 0;
}
