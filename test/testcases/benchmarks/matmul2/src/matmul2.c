#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);


void matmul(uint32_t dim, uint64_t* c, uint64_t* a, uint64_t *b) {
  uint32_t i, j, k;

  // C = AB
  for (i = 0; i < dim; i++ )
    for (j = 0; j < dim; j++ )
      for (k = 0; k < dim; k++ )
        c[i * dim + j] += a[i * dim + k] * b[k * dim + j];
}

void read_mat(uint32_t dim, uint64_t* mat) {
  uint32_t i, j;

  for (i = 0; i < dim; i++)
    for (j = 0; j < dim; j++)
      mat[i * dim + j] = read();
}

void print_mat(uint32_t dim, uint64_t* mat) {
  uint32_t i, j;

  for (i = 0; i < dim; i++)
    for (j = 0; j < dim; j++)
      write(mat[i * dim + j]);
}

int main() {
  uint32_t dim;

  dim = read();
  uint64_t* a = (uint64_t*)malloc(dim * dim * sizeof(uint64_t*));
  uint64_t* b = (uint64_t*)malloc(dim * dim * sizeof(uint64_t*));
  uint64_t* c = (uint64_t*)malloc(dim * dim * sizeof(uint64_t*));

  read_mat(dim, a);
  read_mat(dim, b);

  matmul(dim, c, a, b);
  print_mat(dim, c);

  return 0;
}
