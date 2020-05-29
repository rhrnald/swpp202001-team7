#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

extern uint64_t* primes;
extern uint64_t* tail;
extern uint64_t checked;

uint64_t check_with_primes(uint64_t n) {
  uint64_t* curr = primes;

  while (curr != NULL) {
    uint64_t prime = *curr;
    if (prime * prime > n)
      break;
    if (n % prime == 0)
      return 0;

    curr = (uint64_t*)*(curr + 1);
  }

  return 1;
}

uint64_t add_primes(uint64_t n) {
  while (checked * checked < n) {
    checked++;
    if (check_with_primes(checked)) {
      uint64_t* node = (uint64_t*)malloc(2 * sizeof(uint64_t));
      *node = checked;
      *(node + 1) = (uint64_t)NULL;
      *(tail + 1) = (uint64_t)node;
      tail = node;

      if (n % checked == 0)
        return 0;
    }
  }

  return 1;
}

uint64_t is_prime(uint64_t n) {
  if (check_with_primes(n) == 0)
    return 0;

  return add_primes(n);
}

int main() {
  primes = (uint64_t*)malloc(2 * sizeof(uint64_t));
  *primes = 2;
  *(primes + 1) = (uint64_t)NULL;
  tail = primes;
  checked = 2;

  while (1) {
    uint64_t n = read();

    if (n == 0) break;

    write(is_prime(n));
  }
}
