#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

uint64_t insert(uint64_t* root, uint64_t data) {
  uint64_t* curr = root;

  while (1) {
    uint64_t curr_data = *curr;
    uint64_t* next;

    if (curr_data > data) {
      next = (uint64_t*)*(curr + 1);
      if (next == NULL) {
        uint64_t* node = (uint64_t*)malloc(3 * sizeof(uint64_t));
        *node = data;
        *(node + 1) = (uint64_t)NULL;
        *(node + 2) = (uint64_t)NULL;
        *(curr + 1) = (uint64_t)node;
        return 1;
      }
      curr = next;
      continue;
    }
    else if (curr_data < data) {
      next = (uint64_t*)*(curr + 2);
      if (next == NULL) {
        uint64_t* node = (uint64_t*)malloc(3 * sizeof(uint64_t));
        *node = data;
        *(node + 1) = (uint64_t)NULL;
        *(node + 2) = (uint64_t)NULL;
        *(curr + 2) = (uint64_t)node;
        return 1;
      }
      curr = next;
      continue;
    }
    else return 0;
  }
}

uint64_t* adjust(uint64_t* node) {
  uint64_t* rightmost = (uint64_t*)*(node + 1);
  if (rightmost == NULL)
    return (uint64_t*)*(node + 2);

  uint64_t* parent = NULL;

  while ((uint64_t*)*(rightmost + 2) != NULL) {
    parent = rightmost;
    rightmost = (uint64_t*)*(rightmost + 2);
  }

  if (parent != NULL)
    *(parent + 2) = *(rightmost + 1);

  return rightmost;
}

uint64_t remove(uint64_t* root, uint64_t data) {
  uint64_t* curr = root;

  if (*curr == data)
    return 0;

  while (1) {
    uint64_t curr_data = *curr;
    uint64_t* next;

    if (curr_data > data) {
      next = (uint64_t*)*(curr + 1);
      if (next == NULL)
        return 0;

      if (*next == data) {
        *(curr + 1) = (uint64_t)adjust(next);
        free(next);
        return 1;
      }

      curr = next;
      continue;
    }
    else if (curr_data < data) {
      next = (uint64_t*)*(curr + 2);
      if (next == NULL)
        return 0;

      if (*next == data) {
        *(curr + 2) = (uint64_t)adjust(next);
        free(next);
        return 1;
      }

      curr = next;
      continue;
    }
  }
}

void traverse(uint64_t* node) {
  if (node == NULL) return;

  uint64_t data = *node;
  uint64_t* left = (uint64_t*)*(node + 1);
  uint64_t* right = (uint64_t*)*(node + 2);

  traverse(left);
  write(data);
  traverse(right);

  return;
}

int main() {
  uint64_t* head = (uint64_t*)malloc(3 * sizeof(uint64_t));
  uint64_t init = read();

  *head = init;
  *(head + 1) = (uint64_t)NULL;
  *(head + 2) = (uint64_t)NULL;

  uint64_t n = read();

  for (uint64_t i = 0; i < n; i++) {
    uint64_t action = read();
    uint64_t data = read();

    if (action == 0)
      insert(head, data);
    else
      remove(head, data);
  }

  traverse(head);
}
