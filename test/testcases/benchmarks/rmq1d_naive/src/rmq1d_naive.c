#include<stdint.h>
#include<stdlib.h>

uint64_t read();
void write(uint64_t);

void *malloc_upto_8(uint64_t x) {
  return malloc((x + 7) / 8 * 8);
}

int min_element(int *p, int *q) {
  int e = *p;
  while (p != q) {
    if (*p < e)
      e = *p;
    ++p;
  }
  return e;
}

int main() {
  int N = read();
  int *v = (int *)malloc_upto_8(sizeof(int) * N);
  for (int i = 0; i < N; i++) {
    v[i] = (int64_t)read();
  }

  int Q = read();

  while (Q--) {
    int from = read();
    int to = read();

    int res = min_element(v + from, v + to + 1);

    write(res);
  }

  return 0;
}
