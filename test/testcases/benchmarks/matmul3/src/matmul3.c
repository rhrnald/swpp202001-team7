#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);


// suppose dim % 4 = 0
void matmul(uint32_t dim, uint64_t* c, uint64_t* a, uint64_t *b) {
  uint32_t i, j, k;

  // C = AB
  for (i = 0; i < dim; i += 4) {
    for (j = 0; j < dim; j += 4) {
      for (k = 0; k < dim; k += 4) {
        uint64_t a00 = a[(i + 0) * dim + k + 0];
        uint64_t a01 = a[(i + 0) * dim + k + 1];
        uint64_t a02 = a[(i + 0) * dim + k + 2];
        uint64_t a03 = a[(i + 0) * dim + k + 3];
        uint64_t a10 = a[(i + 1) * dim + k + 0];
        uint64_t a11 = a[(i + 1) * dim + k + 1];
        uint64_t a12 = a[(i + 1) * dim + k + 2];
        uint64_t a13 = a[(i + 1) * dim + k + 3];
        uint64_t a20 = a[(i + 2) * dim + k + 0];
        uint64_t a21 = a[(i + 2) * dim + k + 1];
        uint64_t a22 = a[(i + 2) * dim + k + 2];
        uint64_t a23 = a[(i + 2) * dim + k + 3];
        uint64_t a30 = a[(i + 3) * dim + k + 0];
        uint64_t a31 = a[(i + 3) * dim + k + 1];
        uint64_t a32 = a[(i + 3) * dim + k + 2];
        uint64_t a33 = a[(i + 3) * dim + k + 3];

        uint64_t b00 = b[(k + 0) * dim + j + 0];
        uint64_t b01 = b[(k + 0) * dim + j + 1];
        uint64_t b02 = b[(k + 0) * dim + j + 2];
        uint64_t b03 = b[(k + 0) * dim + j + 3];
        uint64_t b10 = b[(k + 1) * dim + j + 0];
        uint64_t b11 = b[(k + 1) * dim + j + 1];
        uint64_t b12 = b[(k + 1) * dim + j + 2];
        uint64_t b13 = b[(k + 1) * dim + j + 3];
        uint64_t b20 = b[(k + 2) * dim + j + 0];
        uint64_t b21 = b[(k + 2) * dim + j + 1];
        uint64_t b22 = b[(k + 2) * dim + j + 2];
        uint64_t b23 = b[(k + 2) * dim + j + 3];
        uint64_t b30 = b[(k + 3) * dim + j + 0];
        uint64_t b31 = b[(k + 3) * dim + j + 1];
        uint64_t b32 = b[(k + 3) * dim + j + 2];
        uint64_t b33 = b[(k + 3) * dim + j + 3];

        c[(i + 0) * dim + j + 0] += a00 * b00 + a01 * b10 + a02 * b20 + a03 * b30;
        c[(i + 0) * dim + j + 1] += a00 * b01 + a01 * b11 + a02 * b21 + a03 * b31;
        c[(i + 0) * dim + j + 2] += a00 * b02 + a01 * b12 + a02 * b22 + a03 * b32;
        c[(i + 0) * dim + j + 3] += a00 * b03 + a01 * b13 + a02 * b23 + a03 * b33;
        c[(i + 1) * dim + j + 0] += a10 * b00 + a11 * b10 + a12 * b20 + a13 * b30;
        c[(i + 1) * dim + j + 1] += a10 * b01 + a11 * b11 + a12 * b21 + a13 * b31;
        c[(i + 1) * dim + j + 2] += a10 * b02 + a11 * b12 + a12 * b22 + a13 * b32;
        c[(i + 1) * dim + j + 3] += a10 * b03 + a11 * b13 + a12 * b23 + a13 * b33;
        c[(i + 2) * dim + j + 0] += a20 * b00 + a21 * b10 + a22 * b20 + a23 * b30;
        c[(i + 2) * dim + j + 1] += a20 * b01 + a21 * b11 + a22 * b21 + a23 * b31;
        c[(i + 2) * dim + j + 2] += a20 * b02 + a21 * b12 + a22 * b22 + a23 * b32;
        c[(i + 2) * dim + j + 3] += a20 * b03 + a21 * b13 + a22 * b23 + a23 * b33;
        c[(i + 3) * dim + j + 0] += a30 * b00 + a31 * b10 + a32 * b20 + a33 * b30;
        c[(i + 3) * dim + j + 1] += a30 * b01 + a31 * b11 + a32 * b21 + a33 * b31;
        c[(i + 3) * dim + j + 2] += a30 * b02 + a31 * b12 + a32 * b22 + a33 * b32;
        c[(i + 3) * dim + j + 3] += a30 * b03 + a31 * b13 + a32 * b23 + a33 * b33;
      }
    }
  }
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
  if (dim % 4 != 0)
    return 0;

  uint64_t* a = (uint64_t*)malloc(dim * dim * sizeof(uint64_t*));
  uint64_t* b = (uint64_t*)malloc(dim * dim * sizeof(uint64_t*));
  uint64_t* c = (uint64_t*)malloc(dim * dim * sizeof(uint64_t*));

  read_mat(dim, a);
  read_mat(dim, b);

  matmul(dim, c, a, b);
  print_mat(dim, c);

  return 0;
}
