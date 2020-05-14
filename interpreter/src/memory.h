#ifndef SWPP_ASM_INTERPRETER_MEMORY_H
#define SWPP_ASM_INTERPRETER_MEMORY_H

#include <cinttypes>
#include <limits>
#include <vector>
#include <map>
#include <set>

#include "size.h"

#define STACK_MIN ((uint64_t)0)
#define STACK_MAX ((uint64_t)10240)
#define HEAP_MIN ((uint64_t)20480)
#define HEAP_MAX ((uint64_t)(numeric_limits<uint64_t>::max() - 7))

using namespace std;

typedef pair<uint64_t, uint64_t> block_t;
typedef pair<block_t, uint8_t*> alloc_t;


class Memory {
private:
  uint64_t head;
  uint8_t stack[STACK_MAX];
  set<alloc_t> alloced;
  set<block_t> freed;
  uint64_t alloced_size;
  uint64_t max_alloced_size;

  alloc_t find_block(uint64_t addr) const;
  uint64_t load_stack(MSize size, uint64_t addr) const;
  uint64_t load_heap(MSize size, uint64_t addr) const;
  void store_stack(MSize size, uint64_t addr, uint64_t val);
  void store_heap(MSize size, uint64_t addr, uint64_t val);

public:
  Memory();

  uint64_t get_alloced_size() const;
  uint64_t get_max_alloced_size() const;
  double exec_load(MSize size, uint64_t addr, uint64_t& result);
  double exec_store(MSize size, uint64_t addr, uint64_t val);
  double exec_malloc(uint64_t size, uint64_t& result);
  double exec_free(uint64_t addr);
  double exec_reset_stack();
  double exec_reset_heap();
};

#endif //SWPP_ASM_INTERPRETER_MEMORY_H
