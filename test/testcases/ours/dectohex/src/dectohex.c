#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

int main() {
  int N = read();
  for (int i = 0; i < N; ++i) {
    unsigned int data = read();
    for (int j = 0; j < 8; ++j) {
      write(data & 15);
      data >>= 4;
    }
  }
  return 0;
}
