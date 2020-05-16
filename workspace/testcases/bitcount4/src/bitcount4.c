// https://www.geeksforgeeks.org/count-set-bits-in-an-integer/

#include<stdint.h>

extern int BitsSetTable256[256];
int64_t read();
void write(int64_t);

int countSetBits(int n) {
  return (BitsSetTable256[n & 0xff] +
          BitsSetTable256[(n >> 8) & 0xff] +
          BitsSetTable256[(n >> 16) & 0xff] +
          BitsSetTable256[n >> 24]);
}

int main() {
  BitsSetTable256[0] = 0;
  for (int i = 0; i < 256; i++) {
    BitsSetTable256[i] = (i & 1) +
    BitsSetTable256[i / 2];
  }
  write(countSetBits(read()));
}
