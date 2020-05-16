// https://www.geeksforgeeks.org/count-set-bits-in-an-integer/
#include<stdint.h>

int64_t read();
void write(int64_t);

unsigned int countSetBits(unsigned int n) {
  unsigned int count = 0;
  while (n) {
    count += n & 1;
    n >>= 1;
  }
  return count;
}

int main() {
  int64_t i = read();
  write((unsigned int)countSetBits(i));
  return 0;
}
