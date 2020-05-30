#include<stdint.h>
#include<stdlib.h>

uint64_t read();
void write(uint64_t);

extern int **v;

void *malloc_upto_8(uint64_t x) {
  return malloc((x + 7) / 8 * 8);
}

int min(int x, int y) {
  return x < y ? x : y;
}

int *min_element(int *p, int *q) {
  int *e = p;
  while (p != q) {
    if (*p < *e)
      e = p;
    ++p;
  }
  return e;
}

int min_at_row(int row, int from_j, int to_j) {
  int **itr = v + row;
  return *min_element(*itr + from_j, *itr + to_j + 1);
}

int main() {
  int N = read();
  int M = read();
  v = (int **)malloc_upto_8(sizeof(int *) * N);

  for (int i = 0; i < N; i++) {
    v[i] = (int *)malloc_upto_8(sizeof(int) * M);
    for (int j = 0; j < M; j++)
      v[i][j] = read();
  }

  int Q = read();
  while (Q--) {
    int from_i = read();
    int to_i = read();
    int from_j = read();
    int to_j = read();

    int res = min_at_row(from_i, from_j, to_j);
    for (int i = from_i + 1; i <= to_i; i++) {
      res = min(res, min_at_row(i, from_j, to_j));
    }

    write(res);
  }

  return 0;
}
