#include "llvm/IR/Instructions.h"

#include <stack>
#include <set>
#include <cstdlib>

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

  vector<Allocation *>::iterator getVictim(unsigned RegId) {
    vector<Allocation *>::iterator Victim;
    if (RegId) {
      for (auto I = ActiveSet.begin(), E = ActiveSet.end(); I != E; I++) {
        if ((*I)->RegId == RegId) {
          Victim = I;
          break;
        }
      }
    }
    else {
      // random policy
      Victim = ActiveSet.begin() + (rand() % ActiveSet.size());
    }
    return Victim;
  }

public:
  RegisterAllocator() {
    // init
    for (unsigned i = MAX_REG_N; i >= MIN_REG_N; --i) {
      FreeRegisters.push(i);
    }
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
   * evict a specific register when RegId is given.
   */
  Instruction *evict(unsigned RegId = 0) {
    if (ActiveSet.size() == 0) return nullptr;
    if (RegId) assert(TempRegisters.count(RegId) == 0);
    auto Victim = getVictim(RegId);
    auto VictimRequester = (*Victim)->Requester;
    auto VictimId = (*Victim)->RegId;
    
    ActiveSet.erase(Victim);
    FreeRegisters.push(VictimId);
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
  // Request a register with a specific id.
  // Returns zero when there is no register for RegId.
  // Note that RegId cannot be already in TempRegisters!
  unsigned requestTempRegister(unsigned RegId) {
    assert(TempRegisters.count(RegId) == 0);
    stack<unsigned> Temp;
    unsigned FoundId = 0;
    // Find RegId
    while (!FreeRegisters.empty()) {
      if (FreeRegisters.top() == RegId) {
        FoundId = RegId;
        break;
      }
      else {
        Temp.push(FreeRegisters.top());
        FreeRegisters.pop();
      }
    }
    // Refill the stack
    while (!Temp.empty()) {
      FreeRegisters.push(Temp.top());
      Temp.pop();
    }
    if (FoundId) {
      TempRegisters.insert(FoundId);
    }
    return FoundId;
  }

  void giveUpTempRegister(unsigned RegId) {
    assert(TempRegisters.count(RegId) &&
           "Cannot give up an unrequested temp register.");
    TempRegisters.erase(RegId);
    FreeRegisters.push(RegId);
  }
};