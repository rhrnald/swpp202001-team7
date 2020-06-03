// This code is to see the role of `free'
#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

int main() {
  uint64_t n = read();
  uint64_t *a = (uint64_t*) malloc(sizeof(uint64_t) * n);

  for (int i=0; i<n; i++) {
    a[i] = read();
  }

  uint64_t ans = 0;
  for (int i=n-1; i>=0; i--) {
    ans += a[i] * a[i];
  }

  write(ans);
  
  return 0;
}
