#include <cstring>

#include "error.h"
#include "opcode.h"
#include "memory.h"


Memory::Memory() {
  head = -1;
  memset(stack, 0, STACK_MAX);
  freed.insert(block_t(HEAP_MIN, HEAP_MAX));
  alloced_size = 0;
  max_alloced_size = 0;
}

alloc_t Memory::find_block(uint64_t addr) const {
  auto lb = alloced.lower_bound(alloc_t(block_t(addr, -1), nullptr));

  if (lb == alloced.begin()) {
    invoke_runtime_error("accessing non-allocated memory");
  }

  lb--;
  if (lb->first.second <= addr) {
    invoke_runtime_error("accessing non-allocated memory");
  }

  return *lb;
}

uint64_t load_little_endian(int size, uint8_t* ptr) {
  uint64_t sum = 0;
  ptr = ptr + size;

  for (int i = 0; i < size; i++) {
    sum = sum << (uint64_t)8;
    ptr--;
    sum += *ptr;
  }

  return sum;
}

uint64_t Memory::load_stack(MSize size, uint64_t addr) const {
  uint8_t* ptr = (uint8_t*)&stack[0];
  return load_little_endian(msize_of(size), ptr + addr);
}

uint64_t Memory::load_heap(MSize size, uint64_t addr) const {
  alloc_t block = find_block(addr);
  uint64_t start = block.first.first;
  uint64_t ofs = addr - start;
  uint8_t* ptr = block.second + ofs;

  return load_little_endian(msize_of(size), ptr);
}

void store_little_endian(int size, uint8_t* ptr, uint64_t val) {
  uint64_t mask = 0xFF;
  for (int i = 0; i < size; i++) {
    *ptr = val & mask;
    ptr++;
    val = val >> (uint64_t)8;
  }
}

void Memory::store_stack(MSize size, uint64_t addr, uint64_t val) {
  uint8_t* ptr = (uint8_t*)&stack[0];
  return store_little_endian(msize_of(size), ptr + addr, val);
}

void Memory::store_heap(MSize size, uint64_t addr, uint64_t val) {
  alloc_t block = find_block(addr);
  uint64_t start = block.first.first;
  uint64_t ofs = addr - start;
  uint8_t* ptr = block.second + ofs;

  store_little_endian(msize_of(size), ptr, val);
}

bool is_stack(MSize size, uint64_t addr) {
  return addr + msize_of(size) <= STACK_MAX;
}

bool is_heap(MSize size, uint64_t addr) {
  return HEAP_MIN <= addr && addr + msize_of(size) <= HEAP_MAX;
}

bool is_alligned(MSize size, uint64_t addr) {
  return addr % msize_of(size) == 0;
}

double Memory::exec_load(MSize size, uint64_t addr, uint64_t& result) {
  if (!is_alligned(size, addr)) {
    invoke_runtime_error("address not aligned");
    return 0;
  }

  if (is_stack(size, addr)) {
    result = load_stack(size, addr);
    uint64_t dist = addr > head ? addr - head : head - addr;
    double cost = Cost::STACK + Cost::PER_BYTE * dist;
    if (head == (uint64_t)-1)
      cost = 0;
    head = addr;
    return cost;
  }

  if (is_heap(size, addr)) {
    result = load_heap(size, addr);
    uint64_t dist = addr > head ? addr - head : head - addr;
    double cost = Cost::HEAP + Cost::PER_BYTE * dist;
    if (head == (uint64_t)-1)
      cost = 0;
    head = addr;
    return cost;
  }

  invoke_runtime_error("accessing address between 10248 and 20480");
  return 0;
}

double Memory::exec_store(MSize size, uint64_t addr, uint64_t val) {
  if (!is_alligned(size, addr)) {
    invoke_runtime_error("address not aligned");
    return 0;
  }

  if (is_stack(size, addr)) {
    store_stack(size, addr, val);
    uint64_t dist = addr > head ? addr - head : head - addr;
    double cost = Cost::STACK + Cost::PER_BYTE * dist;
    if (head == (uint64_t)-1)
      cost = 0;
    head = addr;
    return cost;
  }

  if (is_heap(size, addr)) {
    store_heap(size, addr, val);
    uint64_t dist = addr > head ? addr - head : head - addr;
    double cost = Cost::HEAP + Cost::PER_BYTE * dist;
    if (head == (uint64_t)-1)
      cost = 0;
    head = addr;
    return cost;
  }

  invoke_runtime_error("acessing address between 10240 and 20480");
  return 0;
}

double Memory::exec_malloc(uint64_t size, uint64_t& result) {
  if (size == 0)
    invoke_runtime_error("allocation size should not be 0");
  if (size % 8 != 0)
    invoke_runtime_error("allocation size should be multiple of 8");

  for (auto it = freed.begin(); it != freed.end(); it++) {
    if (it->second - it->first < size)
      continue;

    block_t block = *it;
    freed.erase(block);
    freed.insert(block_t(block.first + size, block.second));
    uint8_t* ptr = (uint8_t*)calloc(size, sizeof(uint8_t));

    if (ptr == nullptr) {
      invoke_runtime_error("out-of-memory");
      return 0;
    }

    alloced.insert(alloc_t(block_t(block.first, block.first + size), ptr));
    result = block.first;
    alloced_size += size;
    if (max_alloced_size < alloced_size)
      max_alloced_size = alloced_size;
    return Cost::MALLOC;
  }

  invoke_runtime_error("out-of-memory");
  return 0;
}

double Memory::exec_free(uint64_t addr) {
  auto alloc_lb = alloced.lower_bound(alloc_t(block_t(addr, 0), nullptr));

  if (alloc_lb == alloced.end() || alloc_lb->first.first != addr) {
    invoke_runtime_error("freeing non-allocated address");
    return 0;
  }

  block_t block = alloc_lb->first;
  uint8_t* ptr = alloc_lb->second;
  uint64_t size = block.second - block.first;
  alloced.erase(alloc_lb);
  free(ptr);

  auto next = freed.lower_bound(block);

  if (next != freed.begin()) {
    auto prev = next;
    prev--;

    if (prev->second == block.first) {
      block = block_t(prev->first, block.second);
      freed.erase(prev);
    }
  }

  if (next != freed.end()) {
    if (next->first == block.second) {
      block = block_t(block.first, next->second);
      freed.erase(next);
    }
  }

  freed.insert(block);
  alloced_size -= size;
  return Cost::FREE;
}

double Memory::exec_reset_stack() {
  head = STACK_MAX;
  return Cost::RESET;
}

double Memory::exec_reset_heap() {
  head = HEAP_MIN;
  return Cost::RESET;
}

uint64_t Memory::get_alloced_size() const { return alloced_size; }

uint64_t Memory::get_max_alloced_size() const { return max_alloced_size; }
