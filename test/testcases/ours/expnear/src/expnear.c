#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

int main() {
  uint64_t r = read();
  uint64_t i = 1;
  while ((i < r) & (-i > -r)) i += i;
  write(i);
  return 0;
}
