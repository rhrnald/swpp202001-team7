// https://www.geeksforgeeks.org/count-set-bits-in-an-integer/

#include<stdint.h>

int64_t read();
void write(int64_t);

extern int num_to_bits[16];
// { 0, 1, 1, 2, 1, 2, 2, 3,
//   1, 2, 2, 3, 2, 3, 3, 4 };

unsigned int countSetBitsRec(unsigned int num) {
  int nibble = 0;
  if (0 == num)
    return num_to_bits[0];

  nibble = num & 0xf;

  return num_to_bits[nibble] + countSetBitsRec(num >> 4);
}

int main() {
  num_to_bits[0] = 0;
  num_to_bits[1] = 1;
  num_to_bits[2] = 1;
  num_to_bits[3] = 2;

  num_to_bits[4] = 1;
  num_to_bits[5] = 2;
  num_to_bits[6] = 2;
  num_to_bits[7] = 3;

  num_to_bits[8]  = 1;
  num_to_bits[9]  = 2;
  num_to_bits[10] = 2;
  num_to_bits[11] = 3;

  num_to_bits[12] = 2;
  num_to_bits[13] = 3;
  num_to_bits[14] = 3;
  num_to_bits[15] = 4;

  write(countSetBitsRec(read()));
  return 0;
}
