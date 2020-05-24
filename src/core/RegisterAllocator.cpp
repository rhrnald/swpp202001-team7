
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_os_ostream.h"

#include <stack>
#include <set>
#include <cstdlib>
#include <ctime>

// Since the current Backend is using r1-r3, let's just use r4-r16.
#define MAX_REG_N 16
#define MIN_REG_N 4

using namespace llvm;
using namespace std;

class RegisterAllocator {
public:
  struct Allocation {
    Value *EmitValue;
    Instruction *Requester;
    unsigned RegId;
    Allocation(Value *V, Instruction *I, unsigned Id)
                : EmitValue(V), Requester(I), RegId(Id) {}
  };

private:
  stack<unsigned> FreeRegisters;
  set<unsigned> TempRegisters;
  vector<Allocation *> ActiveSet;

  unsigned allocateNewRegister() {
    if (FreeRegisters.empty()) return 0;
    unsigned RegId = FreeRegisters.top();
    FreeRegisters.pop();
    return RegId;
  }

  vector<Allocation *>::iterator randomVictim() {
    return ActiveSet.begin() + (rand() % ActiveSet.size());
  }

public:
  RegisterAllocator() {
    // init
    for (unsigned i = MAX_REG_N; i >= MIN_REG_N; --i) {
      FreeRegisters.push(i);
    }
    srand(time(nullptr));
  }

  /*
   * find V in the allocated register.
   * return the id if it exists, zero o.w.
   */
  unsigned get(Value *V) {
    for (auto E : ActiveSet) {
      if (E->EmitValue == V) return E->RegId;
    }
    return 0;
  }

  /*
   * allocate a new register for V.
   * return the new Allocation on success, zero o.w.
   * the requester should fill in the Alloc->Emit.
   */
  Allocation *request(Value *V, Instruction *I) {
    for (auto E : ActiveSet) {
      assert(E->EmitValue != V && "Requested Value is already allocated.");
    }
    unsigned RegId = allocateNewRegister();
    if (RegId) {
      auto Alloc = new Allocation(V, I, RegId);
      ActiveSet.push_back(Alloc);
      return Alloc;
    }
    return nullptr;
  }

  /*
   * evict an allocation from ActiveSet.
   * return the evicted Instruction.
   */
  Instruction *evict() {
    if (ActiveSet.size() == 0) return nullptr;
    auto Victim = randomVictim();
    auto VictimRequester = (*Victim)->Requester;
    auto VictimId = (*Victim)->RegId;
    
    ActiveSet.erase(Victim);
    FreeRegisters.push(VictimId);
    outs() << "Register " << VictimId << " is freed. (" << FreeRegisters.size() << " left)\n";
    return VictimRequester;
  }

  // Here are the methods for temp registers. One might need registers
  // without mapping it to an Instruction or Value.
  unsigned requestTempRegister() {
    unsigned regId = allocateNewRegister();
    if (regId) {
      TempRegisters.insert(regId);
    }
    return regId;
  }

  void giveUpTempRegister(unsigned RegId) {
    assert(TempRegisters.count(RegId) &&
           "Cannot give up an unrequested temp register.");
    TempRegisters.erase(RegId);
    FreeRegisters.push(RegId);
  }
};