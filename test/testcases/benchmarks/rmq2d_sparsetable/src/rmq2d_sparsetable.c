#include <stdint.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t);

extern int *_input;
extern int N, M; // height, width
extern int **_A;
extern int N2, M2; // floor(log2(N)), floor(log2(M))

void *malloc_upto_8(uint64_t x) {
  return malloc((x + 7) / 8 * 8);
}

int min(int x, int y) {
  return x < y ? x : y;
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

int floorlog2(int x) {
  return 32 - count_leading_zeros(x) - 1;
}

int *input(int i, int j) {
  return &_input[i * M + j];
}

int width(int j) {
  int res = M - (1 << j) + 1;
  return res;
}

int height(int i) {
  int res = N - (1 << i) + 1;
  return res;
}

int **A(int i, int j) {
  return &_A[i * (M2 + 1) + j];
}

int P(int i, int j, int ii, int jj) {
  int *p = *A(i, j);
  return p[ii * width(j) + jj];
}

void preprocess() {
  N2 = floorlog2(N);
  M2 = floorlog2(M);
  _A = (int **)malloc_upto_8(sizeof(int *) * (N2 + 1) * (M2 + 1));
  *A(0, 0) = _input;
  int i, j;

  for (i = 0; i <= N2; i++) {
    for (j = 0; j <= M2; j++) {
      if (i == 0 && j == 0)
        continue;
      *A(i, j) = (int *)malloc_upto_8(sizeof(int) * height(i) * width(j));
    }
  }

  for (i = 0; i <= N2; i++) {
    for (j = 0; j <= M2; j++) {
      if (i == 0 && j == 0) continue;

      int *ptr = *A(i, j);
      for (int ii = 0; ii < height(i); ii++) {
        for (int jj = 0; jj < width(j); jj++) {
          if (j != 0) {
            int *ptr_prev = *A(i, j - 1);
            int wid_prev = width(j - 1);
            int v1 = ptr_prev[ii * wid_prev + jj];
            int v2 = ptr_prev[ii * wid_prev + jj + (1 << (j - 1))];
            ptr[ii * width(j) + jj] = min(v1, v2);
          } else {
            int *ptr_prev = *A(i - 1, j);
            int hei_prev = height(i - 1);
            int v1 = ptr_prev[ii * width(j) + jj];
            int v2 = ptr_prev[(ii + (1 << (i - 1))) * width(j) + jj];
            ptr[ii * width(j) + jj] = min(v1, v2);
          }
        }
      }
    }
  }
}

int main() {
  N = read();
  M = read();
  _input = (int *)malloc_upto_8(sizeof(int) * N * M);

  for (int i = 0; i < N; i++) {
    for (int j = 0; j < M; j++) {
      *input(i, j) = read();
    }
  }

  preprocess();

  int Q = read();
  while (Q--) {
    int from_i = read();
    int to_i = read();
    int from_j = read();
    int to_j = read();

    int n = floorlog2(to_i - from_i + 1);
    int m = floorlog2(to_j - from_j + 1);

    int res1 = P(n, m, from_i, from_j);
    int res2 = P(n, m, to_i + 1 - (1 << n), from_j);
    int res3 = P(n, m, from_i,              to_j + 1 - (1 << m));
    int res4 = P(n, m, to_i + 1 - (1 << n), to_j + 1 - (1 << m));

    int res = min(min(res1, res2), min(res3, res4));
    write(res);
  }

  return 0;
}
