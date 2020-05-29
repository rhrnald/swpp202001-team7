#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

int main() {
  uint64_t n = read(), m = read();
  uint64_t a[10][10][10];
  uint64_t b, ans = 0;

  for (uint64_t i = 0; i < n; i++) {
    for (uint64_t j = 0; j < n; j++) {
      b = i * j;
    }
  }

  for (uint64_t i = 0; i < n; i++) {
    for (uint64_t j = 0; j < n; j++) {
      for (uint64_t k = 0; k < n; k++) {
        a[k][i][j] = i * j + k;
      }
    }
  }

  for (uint64_t i = 0; i < n; i++) {
    for (uint64_t j = 0; j < n; j++) {
      for (uint64_t k = 0; k < n; k++) {
        if (m != n) {
          ans += 2 + a[j][k][i];
        }
      }
    }
  }

  write(ans);

  return 0;
}
