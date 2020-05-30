#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

uint64_t* get_inputs(uint64_t n) {
  if (n == 0) return NULL;

  uint64_t* ptr = (uint64_t*)malloc(n * sizeof(uint64_t));

  for (uint64_t i = 0; i < n; i++) {
    ptr[i] = read();
  }

  return ptr;
}

void sort(uint64_t n, uint64_t* ptr) {
  if (n == 0) return;

  for (uint64_t i = 0; i < n; i++) {
    for (uint64_t j = n - 1; j > i; j--) {
      uint64_t val1 = ptr[j];
      uint64_t val2 = ptr[j-1];
      if (val1 < val2) {
        ptr[j] = val2;
        ptr[j-1] = val1;
      }
    }
  }
}

void put_inputs(uint64_t n, uint64_t* ptr) {
  if (n == 0) return;

  for (uint64_t i = 0; i < n; i++) {
    write(ptr[i]);
  }
}

int main() {
  uint64_t n = read();
  if (n == 0) return 0;

  uint64_t* ptr = get_inputs(n);
  sort(n, ptr);
  put_inputs(n, ptr);

  return 0;
}
