#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);


void copy_mask(uint32_t dim, uint32_t row, uint32_t col, uint64_t* mat, uint64_t* mask) {
  uint8_t i, j;
  row = row;
  col = col;

  for (i = 0; i < 4; i++)
    for (j = 0; j < 4; j++)
      mask[i * 4 + j] = mat[(row + i) * dim + col + j];
}

void add_mask(uint32_t dim, uint32_t row, uint32_t col, uint64_t* mat, uint64_t* mask) {
  uint8_t i, j;
  row = row;
  col = col;

  for (i = 0; i < 4; i++)
    for (j = 0; j < 4; j++)
      mat[(row + i) * dim + col + j] += mask[i * 4 + j];
}

void mask_mul(uint64_t* c, uint64_t* a, uint64_t *b) {
  uint8_t i, j, k;
  
  for (i = 0; i < 4; i++)
    for (j = 0; j < 4; j++) {
      uint64_t sum = 0;
      for (k = 0; k < 4; k++)
        sum += a[i * 4 + k] * b[k * 4 + j];
      c[i * 4 + j] = sum;
    }
}

// suppose dim % 4 = 0
void matmul(uint32_t dim, uint64_t* c, uint64_t* a, uint64_t *b) {
  uint32_t i, j, k;
  uint64_t c_mask[16], a_mask[16], b_mask[16];

  // C = AB
  for (i = 0; i < dim; i += 4) {
    for (j = 0; j < dim; j += 4) {
      for (k = 0; k < dim; k += 4) {
        copy_mask(dim, i, k, a, a_mask);
        copy_mask(dim, k, j, b, b_mask);
        mask_mul(c_mask, a_mask, b_mask);
        add_mask(dim, i, j, c, c_mask);
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
