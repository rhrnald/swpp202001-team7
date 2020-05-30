#include<stdint.h>

uint64_t read();
void write(uint64_t);

extern int N;
extern int *input;
extern int **A;
extern int height;

void *malloc_upto_8(uint64_t x) {
  return malloc((x + 7) / 8 * 8);
}

int min(int x, int y) {
  return x < y ? x : y;
}

void initA() {
  // Fix height.
  int64_t j = 0;
  while ((1 << j) <= (int64_t)N) {
    j++;
  }
  height = (int)j;
  A = (int **)malloc_upto_8(sizeof(int *) * height);
  A[0] = input;

  j = 1;
  while ((1 << j) <= (int64_t)N) {
    int wid = (int)(1 << j);

    int *newarr = (int *)malloc_upto_8(sizeof(int) * (N - wid + 1));
    A[j] = newarr;
    for (int i = 0; i <= N - wid; i++) {
      A[j][i] = min(A[j - 1][i], A[j - 1][i + wid / 2]);
    }
    j++;
  }
}

int count_leading_zeros(int x) {
  int count = 0;
  for (int i = 31; i >= 0; i--) {
    if (x & (1 << i))
      break;
    count++;
  }
  return count;
}

int main() {
  N = read();
  input = (int *)malloc_upto_8(sizeof(int) * N);
  for (int i = 0; i < N; i++) {
    input[i] = read();
  }

  initA();

  int Q = read();
  while (Q--) {
    int beg = read();
    int end = read();

    unsigned int wid = end - beg + 1;
    // 2^len2
    int len2 = 32 - count_leading_zeros(wid);
    int answ = min(A[len2 - 1][beg],
                   A[len2 - 1][end - (1 << (len2 - 1)) + 1]);

    write(answ);
  }

  return 0;
}
