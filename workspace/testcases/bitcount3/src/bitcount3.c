// https://www.geeksforgeeks.org/count-set-bits-in-an-integer/

#include<stdint.h>

int64_t read();
void write(int64_t);

unsigned int countSetBits(int n) {
  unsigned int count = 0;
  while (n) {
    n &= (n - 1);
    count++;
  }
  return count;
}

int main() {
  write(countSetBits(read()));
  return 0;
}
