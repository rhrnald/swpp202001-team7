# Progress Report for Sprint 2

### Overall

During the Sprint 2, we improved cost and made preparations for the next sprint. First of all, we renovated the backend so that it supports new stack allocation/deallocation functions named `alloca_bytes`/`free_bytes` for `malloc` to `alloca_bytes` conversion. Also, we made a basic interface of register allocation on the backend which we are going to develop on the sprint 3. Secondly, we made a memory reordering optimization pass to reduce the switching access between HEAP and STACK areas. Finally, we tuned the the existing loop-related optimization to maximize the improvement for the general test benchmarks.

Besides that, we found an error on the last sprint(WeirdArithmetic) and the given SimpleBackend(PHI Node error) and made a bug-fix PRs. Also, we improved our case test system. The upgraded compiler passed all test benchmarks and the general cost improvement(of costs sums) was about 11% compared to the last sprint.

![alt text](resources/plot_benchmark.png "Plotting Result")



### Added Feature of Compiler and Test

#### Compiler

```bash
./bin/sf-compiler-team7 input.ll -o output.s -d output.ll -except "WeirdArith,PackRegister"

./bin/sf-compiler-team7 input.ll -o output.s -d output.ll -nopass
```
With the "except" flag, we can choose which passes not to apply while compiling. To apply none of the pass, we can use "nopass" option.

#### Test

```bash
#google check + shell unit test + compare(vanilla, whole pass)
make test

#google check + shell unit test + compare(whole pass, whole-(Pass1,Pass2))
make test PASSES="Pass1,Pass2"
#make test PASSES=Pass1,Pass2
```
By giving arguments to `make test`, we can check the performance of individual passes. It will compare performance with and without selected passes. Group of passes are also available.

Also, the graph plotting is possible for logs. You can run

```bash
python3 test/plot.py
```

after running `make test`. You need to install `python3`, `numpy`, `matplotlib` to run this feature.



### Individual Accomplishments

#### Woosung Song

* Find an efficient order and options about loop-related optimization passes.
* Detected a bug(on PHI instruction) in the previous backend and fixed it.
* Detected a bug in WeirdArithmetic.cpp from the last sprint and fixed it.
* Improved testing system.

#### Jiyong Kang

* Enhanced and modified Backend and AssemblyEmitter to handle `alloca_bytes`.
* Prepared for Register Allocation for the next sprint.


#### Chaewon Kim

* Implement new pass : ReorderMemAccess
* Add option to compiler and "make test".
* Improved testing system.



### Implementations

#### Backend Renovation

Enhanced _Backend_ from _SimpleBackend_, making the following changes.

1. There are some changes in low-level translation.
   * **SExtInst**: _SimpleBackend_ was calculating a mask and taking OR with the operand of SExtInst. In total it used `and`, `sub`, and `or`. However, this can be done with `mul` and `ashr`, by just shifting it to the MSB and shifting back. _cost: 2.6 => 1.4_
   * **TruncInst**: `and` => `urem`. _cost: 0.8 => 0.6_

2. `__alloca_bytes__`
   * `i8* @__alloca_bytes__(i64 size, i1 free_in_this_block, i64 alignment)`
   * **alloca_bytes**: This feature is suggested by Woosung, and he is going to use this in the next sprint. It allocates `size` bytes in the **stack area**, and if a BasicBlock has only `__alloca_bytes__` calls with `free_in_this_block = 1`, _Backend_ will automatically free them all at the end of the block. This is done with `__free_bytes__`.
   * Currently, the _Backend_ does not create `__alloca_bytes__` by itself. In other words, the input IR code should have a declaration of it. _**This can be updated if needed!**_.

3. `__free_bytes__`
   * `void @__free_bytes__(i64 size)`
   * This function is an internal function for _Backend_ and _AssemblyEmitter_, and it frees `size` bytes of the dynamically allocated stack area.
   * Currently, the input IR code should have a declaration of `__free_bytes__` as well. However, note that using this function could be dangerous! Prohibiting the use of `__free_bytes__` before coming into _Backend_ is being considered.

4. Reference Stack Pointer
   * To implement dynamic stack allocation, _AssemblyEmitter_ possesses one register(`r16` for the current version), and uses it as a _Reference Stack Pointer_. Normal `load` and `store` instructions will use this _ref sp_ as `sp`. And dynamic _Real Stack Pointer_ is `sp`, which `__alloca_bytes__` and `__free_bytes__` are using.
   * **_Issue 1: Register occupation_** - However, this will limit the number of available registers(16 => 15), hence _ref sp_ arises only when it is needed. In the current version, once the _ref sp_ is set, only 15 registers are available until the function finishes.
   * **_Issue 2: Heavy functions_** - When the _ref sp_ is set, only 15 registers are available. In that case, function calls with full 16 non-constant arguments are not available. In order to resolve this, I took this as a corner-case, and before such heavy function calls, an internal function `__spill_ref__` is inserted. This will 'spill' the _ref sp_ at `sp - 8`, and free the _ref sp_ for the moment. Then all 16 arguments can be ready, and after the function call, AssemblyEmitter 'fill'(=restore) the _ref sp_ back.

5. Some minor code improvements.



#### Register Allocation Interface

For the next sprint, a register allocation interface is now ready. It is called _RegisterAllocator_, and it manages the allocation of registers. _Backend_ will inquire and request registers to _RegisterAllocator_, and decide whether an eviction is needed. Each register is allocated to an `Instruction`, say a requester. Also they are connected to a `Value` that is emitted to the depromoted module, say an emission. Note that a single requester can have multiple emissions but not at the same moment. Therefore, each register in the "ActiveSet" has a requester `Instruction` and an emission `Value`. Some expected scenarios are as following:

1. Inquiry of the register allocated to an `Instruction`.
   * _Backend_ wants to know which register is allocated for an `Instruction`. If the `Instruction` is in "ActiveSet", then _RegisterAllocator_ will return the register id of it. Otherwise, it will return zero. Then _Backend_ will request a register for it.

2. Request for a register.
   * There are two kinds of requests; normal registers allocated for `Instruction`s, and temporary registers. Temporary registers are used when a register is needed without existing `Instruction` for it during the instruction translation.
   * If there is a free register, then _RegisterAllocator_ will return a pointer of `struct Allocation`, which includes the register id, the requester `Instruction`, and the emission `Value`, after setting the register id. Then _Backend_ will set the emission `Value` of it.
   * Requested temporary registers should be returned.
   * It is possible to request a temporary register with a specific id, to handle the reference stack pointer.

3. Eviction.
   * If there were no free registers, then _RegiterAllocator_ would return `nullptr`. Then _Backend_ will request an eviction and _RegisterAllocator_ returns which `Instruction` should be evicted. It is possible to evict a specific register.



#### ReorderMemAccess

This is a pass which reorders instructions in order to reduce cost of memory accessing. It cost a lot to move between heap and stack. So without changing the program's behavior, this pass will reorder instructions, reducing moves between heap and stack.

##### Brief Idea
- First, we need to get information about dominance between instructions. This dominance will help keeping program's behavior not to change. Here, dominance is not order, it's information about if instruction must be executed before other instruction(in other words, switching location of two instructions changes the behavior) . Accessing memory is very hard to find dominance(if two instructions access the same address?), so I let two instructions accessing the same memory space to always have dominance.

- With this dominance, we will construct the entire block in new order. There are three types of instructions: HEAP related(1), STACK related(2), none related(3). My purpose was to separate (1) and (2) as much as possible. So I first push every (1), (3) which can be executed considering dominance. Then push every (1), (2) which can be executed, (1), (3) again, ... until every instruction is in the block.

##### Required function
※ Following two functions can be used in various situation. There might exist reference, but I wasn't able to find source, so I implemented myself. I cannot handle every general cases, so I had handled them case by case. Currently, it has no problem for our test cases, but it may cause lots of bug, so applying this function must be very careful. If additional bug is found, please let me know.

- checkBlockType()
This function checks the type of instruction if it is related to HEAP or STACK. It have to check if value was from malloc, global variable. We need to check const expression either. 

- checkDom()
This function checks dominance of the two instructions. It doesn't check indirect dominance( in other words, A->B, B->C, then A->C), but it is enough to check only direct dominance. It gives dominance if second instruction has first instruction as operand. It also give dominance of the instructions if they have same type(HEAP or STACK).



#### Loop Optimization

I tried to use the built-in loop optimizations and tune them much efficiently on the benchmark I can. As a result, this optimization calls the following sequence of pass in order.

- Loop Pre Passes: To simplify and remove redundant loops.
  - loop-simplify, loop-deletion, lcssa, licmm, .. further.
- Loop Basic Passes: The basic loop patches before interchange and unroll.
  - loop-unswitch(for-if to if-for), loop-data-prefetch
  - loop-idiom, loop-load-elim, loop-prediction, loop-reduce
  - loop-simplifycfg, loop-rotate(important for main passes)
- Loop Main Passes
  - loop-interchange: calculates the payoff, and apply it if it became cheaper.
  - loop-unroll: plus options of "-unroll-runtime -unroll-count=8 -unroll-remainder"
    - the experimental result of this option was the best on the benchmarks
- Loop End Passes: Clean the loop dirties.
  - instcombine, simplifycfg, ...

Also, I made a `runBuiltinOpt` function on the `src/core/main.cpp`. This function redirects `$LLVM_BIN/opt` by running `system` system call in C++, and applies the existing optimization. I used this option because all specific pass options(including loop-unroll) were protected by `static` definition. Therefore, I was not able to add any specific option on `PassBuilder` itself. This function is very easy to call on general uses, I think Chaewon Kim will use it frequently on the next sprint.



#### Backend PHI Node Bugfix

I found the bug on the given backend by applying the loop optimization passes, especially `loop-rotate`. Although I only applied the built-in passes, the interpreter's output was different from what I linked with `clang++`. This was because of the error on treating `PHI` instructions on the given backend. Thanks to TA, I had enough time to fix it.

For example of IR code,
```assembly
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%i.inc %loop]
  %i.inc = add i64 %i, 1
  ...
  br i1 %cmp, label %loop, label %exit
exit:
  call void @write(i64 %i)
```
The original Backend processed like this.
```assembly
entry:
  store i64 0, %i_phi_tmp_slot
  %i = load i64, i64* %i_phi_tmp_slot
loop:
  ; %i value is already set
  %i.inc = add i64 %i, 1
  ...
  store i64 %i.inc, %i_phi_tmp_slot
  %i = load i64, i64* %i_phi_tmp_slot
exit:
  call void @write(i64 %i)
```
This code is errormatic since `%i` is restored before reaching the PHI instruction.
In the `exit` block, `%i` is same to `%i.inc`, which we did not intend to be. The fixed version processes like this.
```assembly
entry:
  store i64 0, %i_phi_tmp_slot
loop:
  %i = load i64, i64* %i_phi_tmp_slot
  %i.inc = add i64 %i, 1
  ...
  store i64 %i.inc, %i_phi_tmp_slot
exit:
  call void @write(i64 %i)
```
This code is safe since it modifies `%i` when reaching the PHI node. After modifying this, the compiler passed all tests.



### Test Results

#### Backend Renovation Test

Backend Renovation includes low-level efficiency enhancement and new feature `alloca_bytes`. Hence the tests can show the performance increase and the special cases using `alloca_bytes`.

   * `collatz.c` from the benchmark
      ```C
      #include <inttypes.h>
      #include <stdlib.h>

      uint64_t read();
      void write(uint64_t val);

      uint32_t collatz(int16_t* iter, uint32_t n) {
        write(n);
        if (n <= 1) return n;
        if (*iter < 0) return -1;

        *iter = *iter + 1;
        n = n % 2 == 0 ? n / 2 : 3 * n + 1;
        return collatz(iter, n);
      }

      int main() {
        uint32_t n = read();
        int16_t iter = 0;

        collatz(&iter, n);
        write(iter);
      }

      ```
      
      * Assembly comparison - Before
      ```assembly
      ; Function collatz
      start collatz 2:
        .entry:
          ; init sp!
          sp = sub sp 152 64
          store 8 arg2 sp 0
          r1 = load 8 sp 0
          call write r1
          r1 = icmp ule arg2 1 32
          store 8 r1 sp 8
          r1 = load 8 sp 8
          br r1 .if.then .if.end

        .if.then:
          store 8 arg2 sp 144
          r1 = load 8 sp 144
          store 8 r1 sp 136
          br .return

        .if.end:
          r1 = load 2 arg1 0
          store 8 r1 sp 16
          r1 = load 8 sp 16
          r2 = and r1 32768 64
          r2 = sub 0 r2 64
          r1 = or r2 r1 64
          store 8 r1 sp 24
          r1 = load 8 sp 24
          r1 = icmp slt r1 0 32
          store 8 r1 sp 32
          r1 = load 8 sp 32
          br r1 .if.then5 .if.end6

        .if.then5:
          store 8 4294967295 sp 144
          r1 = load 8 sp 144
          store 8 r1 sp 136
          br .return

        .if.end6:
          r1 = load 2 arg1 0
          store 8 r1 sp 40
          r1 = load 8 sp 40
          r2 = and r1 32768 64
          r2 = sub 0 r2 64
          r1 = or r2 r1 64
          store 8 r1 sp 48
          r1 = load 8 sp 48
          r1 = add r1 1 32
          store 8 r1 sp 56
          r1 = load 8 sp 56
          r1 = and r1 65535 64
          store 8 r1 sp 64
          r1 = load 8 sp 64
          store 2 r1 arg1 0
          r1 = urem arg2 2 32
          store 8 r1 sp 72
          r1 = load 8 sp 72
          r1 = icmp eq r1 0 32
          store 8 r1 sp 80
          r1 = load 8 sp 80
          br r1 .cond.true .cond.false

        .cond.true:
          r1 = udiv arg2 2 32
          store 8 r1 sp 88
          r1 = load 8 sp 88
          store 8 r1 sp 120
          r1 = load 8 sp 120
          store 8 r1 sp 112
          br .cond.end

        .cond.false:
          r1 = mul 3 arg2 32
          store 8 r1 sp 96
          r1 = load 8 sp 96
          r1 = add r1 1 32
          store 8 r1 sp 104
          r1 = load 8 sp 104
          store 8 r1 sp 120
          r1 = load 8 sp 120
          store 8 r1 sp 112
          br .cond.end

        .cond.end:
          r2 = load 8 sp 112
          r1 = call collatz arg1 r2
          store 8 r1 sp 128
          r1 = load 8 sp 128
          store 8 r1 sp 144
          r1 = load 8 sp 144
          store 8 r1 sp 136
          br .return

        .return:
          r1 = load 8 sp 136
          ret r1
      end collatz

      ; Function main
      start main 0:
        .entry:
          ; init sp!
          sp = sub sp 56 64
          r1 = add sp 48 64
          store 8 r1 sp 0
          r1 = call read
          store 8 r1 sp 8
          r1 = load 8 sp 8
          r1 = and r1 4294967295 64
          store 8 r1 sp 16
          r2 = load 8 sp 0
          store 2 0 r2 0
          r1 = load 8 sp 0
          r2 = load 8 sp 16
          r1 = call collatz r1 r2
          store 8 r1 sp 24
          r1 = load 8 sp 0
          r1 = load 2 r1 0
          store 8 r1 sp 32
          r1 = load 8 sp 32
          r2 = and r1 32768 64
          r2 = sub 0 r2 64
          r1 = or r2 r1 64
          store 8 r1 sp 40
          r1 = load 8 sp 40
          call write r1
          ret 0
      end main

      ```

      * Assembly comparison - After
      ```assembly
      ; Function collatz
      start collatz 2:
        .entry:
          ; init sp!
          sp = sub sp 152 64
          store 8 arg2 sp 0
          r1 = load 8 sp 0
          call write r1
          r1 = icmp ule arg2 1 32
          store 8 r1 sp 8
          r1 = load 8 sp 8
          br r1 .if.then .if.end

        .if.then:
          store 8 arg2 sp 144
          r1 = load 8 sp 144
          store 8 r1 sp 136
          br .return

        .if.end:
          r1 = load 2 arg1 0
          store 8 r1 sp 16
          r1 = load 8 sp 16
          r1 = mul r1 281474976710656 64
          r1 = ashr r1 48 64
          store 8 r1 sp 24
          r1 = load 8 sp 24
          r1 = icmp slt r1 0 32
          store 8 r1 sp 32
          r1 = load 8 sp 32
          br r1 .if.then5 .if.end6

        .if.then5:
          store 8 4294967295 sp 144
          r1 = load 8 sp 144
          store 8 r1 sp 136
          br .return

        .if.end6:
          r1 = load 2 arg1 0
          store 8 r1 sp 40
          r1 = load 8 sp 40
          r1 = mul r1 281474976710656 64
          r1 = ashr r1 48 64
          store 8 r1 sp 48
          r1 = load 8 sp 48
          r1 = add r1 1 32
          store 8 r1 sp 56
          r1 = load 8 sp 56
          r1 = urem r1 65536 64
          store 8 r1 sp 64
          r1 = load 8 sp 64
          store 2 r1 arg1 0
          r1 = urem arg2 2 32
          store 8 r1 sp 72
          r1 = load 8 sp 72
          r1 = icmp eq r1 0 32
          store 8 r1 sp 80
          r1 = load 8 sp 80
          br r1 .cond.true .cond.false

        .cond.true:
          r1 = udiv arg2 2 32
          store 8 r1 sp 88
          r1 = load 8 sp 88
          store 8 r1 sp 120
          r1 = load 8 sp 120
          store 8 r1 sp 112
          br .cond.end

        .cond.false:
          r1 = mul 3 arg2 32
          store 8 r1 sp 96
          r1 = load 8 sp 96
          r1 = add r1 1 32
          store 8 r1 sp 104
          r1 = load 8 sp 104
          store 8 r1 sp 120
          r1 = load 8 sp 120
          store 8 r1 sp 112
          br .cond.end

        .cond.end:
          r2 = load 8 sp 112
          r1 = call collatz arg1 r2
          store 8 r1 sp 128
          r1 = load 8 sp 128
          store 8 r1 sp 144
          r1 = load 8 sp 144
          store 8 r1 sp 136
          br .return

        .return:
          r1 = load 8 sp 136
          ret r1
      end collatz

      ; Function main
      start main 0:
        .entry:
          ; init sp!
          sp = sub sp 56 64
          r1 = add sp 48 64
          store 8 r1 sp 0
          r1 = call read
          store 8 r1 sp 8
          r1 = load 8 sp 8
          r1 = urem r1 4294967296 64
          store 8 r1 sp 16
          r2 = load 8 sp 0
          store 2 0 r2 0
          r1 = load 8 sp 0
          r2 = load 8 sp 16
          r1 = call collatz r1 r2
          store 8 r1 sp 24
          r1 = load 8 sp 0
          r1 = load 2 r1 0
          store 8 r1 sp 32
          r1 = load 8 sp 32
          r1 = mul r1 281474976710656 64
          r1 = ashr r1 48 64
          store 8 r1 sp 40
          r1 = load 8 sp 40
          call write r1
          ret 0
      end main
      ```

      * Cost comparison
         * 68.44(0)     --> 66.84(0)              -1.6(0)

   * `free_bytes.c`
      ```C
      #include <inttypes.h>
      #include <stdlib.h>

      uint64_t read();
      void write(uint64_t val);

      uint8_t *__alloca_bytes__(uint64_t size, uint64_t free_in_this_block, uint64_t align) {
        return (uint8_t *) malloc(size);
      }

      void __free_bytes__(uint64_t size);

      int main() {
        uint64_t r = read();
        uint8_t *p_out = __alloca_bytes__(8, 0, 8);
        uint8_t s = 0;
        for (int i=0; i<8; ++i) {
          uint8_t *p = __alloca_bytes__((i+1) * 8, 1, 8);
          *p = (uint8_t) r;
          r >>= 8;
          write(*p);
          s += *p;
        }
        *p_out = s;
        write(*p_out);
        return 0;
      }

      ```

      * Assembly comparison - Before
      ```assembly
      ; Function __alloca_bytes__
      start __alloca_bytes__ 3:
        .entry:
          ; init sp!
          sp = sub sp 8 64
          r1 = malloc arg1
          store 8 r1 sp 0
          r1 = load 8 sp 0
          ret r1
      end __alloca_bytes__

      ; Function main
      start main 0:
        .entry:
          ; init sp!
          sp = sub sp 200 64
          r1 = call read
          store 8 r1 sp 0
          r1 = call __alloca_bytes__ 8 0 0
          store 8 r1 sp 8
          store 8 0 sp 24
          store 8 0 sp 40
          r1 = load 8 sp 0
          store 8 r1 sp 56
          r1 = load 8 sp 24
          store 8 r1 sp 16
          r1 = load 8 sp 40
          store 8 r1 sp 32
          r1 = load 8 sp 56
          store 8 r1 sp 48
          br .for.cond

        .for.cond:
          r1 = load 8 sp 32
          r1 = icmp slt r1 8 32
          store 8 r1 sp 64
          r1 = load 8 sp 64
          br r1 .for.body .for.cond.cleanup

        .for.cond.cleanup:
          br .for.end

        .for.body:
          r1 = load 8 sp 32
          r1 = add r1 1 32
          store 8 r1 sp 72
          r1 = load 8 sp 72
          r1 = mul r1 8 32
          store 8 r1 sp 80
          r1 = load 8 sp 80
          r2 = and r1 2147483648 64
          r2 = sub 0 r2 64
          r1 = or r2 r1 64
          store 8 r1 sp 88
          r1 = load 8 sp 88
          r1 = call __alloca_bytes__ r1 1 0
          store 8 r1 sp 96
          r1 = load 8 sp 48
          r1 = and r1 255 64
          store 8 r1 sp 104
          r1 = load 8 sp 104
          r2 = load 8 sp 96
          store 1 r1 r2 0
          r1 = load 8 sp 48
          r1 = lshr r1 8 64
          store 8 r1 sp 112
          r1 = load 8 sp 96
          r1 = load 1 r1 0
          store 8 r1 sp 120
          r1 = load 8 sp 120
          store 8 r1 sp 128
          r1 = load 8 sp 128
          call write r1
          r1 = load 8 sp 96
          r1 = load 1 r1 0
          store 8 r1 sp 136
          r1 = load 8 sp 136
          store 8 r1 sp 144
          r1 = load 8 sp 16
          store 8 r1 sp 152
          r1 = load 8 sp 152
          r2 = load 8 sp 144
          r1 = add r1 r2 32
          store 8 r1 sp 160
          r1 = load 8 sp 160
          r1 = and r1 255 64
          store 8 r1 sp 168
          br .for.inc

        .for.inc:
          r1 = load 8 sp 32
          r1 = add r1 1 32
          store 8 r1 sp 176
          r1 = load 8 sp 168
          store 8 r1 sp 24
          r1 = load 8 sp 176
          store 8 r1 sp 40
          r1 = load 8 sp 112
          store 8 r1 sp 56
          r1 = load 8 sp 24
          store 8 r1 sp 16
          r1 = load 8 sp 40
          store 8 r1 sp 32
          r1 = load 8 sp 56
          store 8 r1 sp 48
          br .for.cond

        .for.end:
          r1 = load 8 sp 16
          r2 = load 8 sp 8
          store 1 r1 r2 0
          r1 = load 8 sp 8
          r1 = load 1 r1 0
          store 8 r1 sp 184
          r1 = load 8 sp 184
          store 8 r1 sp 192
          r1 = load 8 sp 192
          call write r1
          ret 0
      end main
      ```

      * Assembly comparison - After
      ```assembly
      ; Function __alloca_bytes__
      start __alloca_bytes__ 3:
        .entry:
          ; init sp!
          sp = sub sp 8 64
          r1 = malloc arg1
          store 8 r1 sp 0
          r1 = load 8 sp 0
          ret r1
      end __alloca_bytes__

      ; Function main
      start main 0:
        .entry:
          ; init sp!
          sp = sub sp 160 64
          r1 = call read
          store 8 r1 sp 0
          ; set ref sp
          r16 = mul sp 1 64
          ; __alloca_bytes__ 8
          sp = sub sp 8 64
          r1 = mul sp 1 64
          store 8 r1 r16 8
          store 8 0 r16 24
          store 8 0 r16 40
          r1 = load 8 r16 0
          store 8 r1 r16 56
          r1 = load 8 r16 24
          store 8 r1 r16 16
          r1 = load 8 r16 40
          store 8 r1 r16 32
          r1 = load 8 r16 56
          store 8 r1 r16 48
          br .for.cond

        .for.cond:
          r1 = load 8 r16 32
          r1 = icmp ult r1 8 32
          store 8 r1 r16 64
          r1 = load 8 r16 64
          br r1 .for.body .for.cond.cleanup

        .for.cond.cleanup:
          br .for.end

        .for.body:
          r1 = load 8 r16 32
          r1 = mul r1 8 32
          store 8 r1 r16 72
          r1 = load 8 r16 72
          r1 = add r1 8 32
          store 8 r1 r16 80
          r1 = load 8 r16 80
          r1 = mul r1 4294967296 64
          r1 = ashr r1 32 64
          store 8 r1 r16 88
          r1 = load 8 r16 88
          ; __alloca_bytes__ r1
          sp = sub sp r1 64
          r1 = mul sp 1 64
          store 8 r1 r16 96
          r1 = load 8 r16 48
          r1 = urem r1 256 64
          store 8 r1 r16 104
          r1 = load 8 r16 104
          r2 = load 8 r16 96
          store 1 r1 r2 0
          r1 = load 8 r16 48
          r1 = urem r1 256 64
          store 8 r1 r16 112
          r1 = load 8 r16 112
          call write r1
          r1 = load 8 r16 88
          ; __free_bytes__ r1
          sp = add sp r1 64
          br .for.inc

        .for.inc:
          r1 = load 8 r16 96
          r1 = load 1 r1 0
          store 8 r1 r16 120
          r1 = load 8 r16 16
          r2 = load 8 r16 120
          r1 = add r1 r2 8
          store 8 r1 r16 128
          r1 = load 8 r16 48
          r1 = udiv r1 256 64
          store 8 r1 r16 136
          r1 = load 8 r16 32
          r1 = add r1 1 32
          store 8 r1 r16 144
          r1 = load 8 r16 128
          store 8 r1 r16 24
          r1 = load 8 r16 144
          store 8 r1 r16 40
          r1 = load 8 r16 136
          store 8 r1 r16 56
          r1 = load 8 r16 24
          store 8 r1 r16 16
          r1 = load 8 r16 40
          store 8 r1 r16 32
          r1 = load 8 r16 56
          store 8 r1 r16 48
          br .for.cond

        .for.end:
          r1 = load 8 r16 16
          r2 = load 8 r16 8
          store 1 r1 r2 0
          r1 = load 8 r16 16
          store 8 r1 r16 152
          r1 = load 8 r16 152
          call write r1
          ret 0
      end main
      ```

   * `alloca_bytes.c`
      ```C
      #include <inttypes.h>
      #include <stdlib.h>

      uint64_t read();
      void write(uint64_t val);

      uint8_t *__alloca_bytes__(uint64_t size, uint64_t free_in_this_block, uint64_t align) {
        return (uint8_t *) malloc(size);
      }

      void heavy_func(uint64_t a1, uint64_t a2, uint64_t a3, uint64_t a4,
      uint64_t a5, uint64_t a6, uint64_t a7, uint64_t a8, 
      uint64_t a9, uint64_t a10, uint64_t a11, uint64_t a12,
      uint64_t a13, uint64_t a14, uint64_t a15, uint64_t a16) {
        write(a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9
              + a10 + a11 + a12 + a13 + a14 + a15 + a16);
      }

      int main() {
        uint8_t *p = __alloca_bytes__(8, 0);
        uint64_t r = read();
        for (int i=0; i<8; ++i) {
          p[i] = (uint8_t) r;
          r >>= 8;
          r *= -1;
        }
        r = 0;
        for (int i=0; i<8; ++i) {
          r += p[i];
        }
        write(r);

        // this is for checking a function call with full arguments.
        // for a simpler .ll code, you can comment this out!
        heavy_func(read(), read(), read(), read(), read(), read(), read(), read(), 
        read(), read(), read(), read(), read(), read(), read(), read());

        heavy_func(read(), read(), read(), read(), read(), read(), read(), 0, 
        read(), read(), read(), read(), read(), read(), read(), read());

        return 0;
      }
      ```

      * Assembly comparison - Before
      ```assembly
      ; Function __alloca_bytes__
      start __alloca_bytes__ 2:
        .entry:
          ; init sp!
          sp = sub sp 8 64
          r1 = malloc arg1
          store 8 r1 sp 0
          r1 = load 8 sp 0
          ret r1
      end __alloca_bytes__

      ; Function heavy_func
      start heavy_func 16:
        .entry:
          ; init sp!
          sp = sub sp 120 64
          r1 = add arg1 arg2 64
          store 8 r1 sp 0
          r1 = load 8 sp 0
          r1 = add r1 arg3 64
          store 8 r1 sp 8
          r1 = load 8 sp 8
          r1 = add r1 arg4 64
          store 8 r1 sp 16
          r1 = load 8 sp 16
          r1 = add r1 arg5 64
          store 8 r1 sp 24
          r1 = load 8 sp 24
          r1 = add r1 arg6 64
          store 8 r1 sp 32
          r1 = load 8 sp 32
          r1 = add r1 arg7 64
          store 8 r1 sp 40
          r1 = load 8 sp 40
          r1 = add r1 arg8 64
          store 8 r1 sp 48
          r1 = load 8 sp 48
          r1 = add r1 arg9 64
          store 8 r1 sp 56
          r1 = load 8 sp 56
          r1 = add r1 arg10 64
          store 8 r1 sp 64
          r1 = load 8 sp 64
          r1 = add r1 arg11 64
          store 8 r1 sp 72
          r1 = load 8 sp 72
          r1 = add r1 arg12 64
          store 8 r1 sp 80
          r1 = load 8 sp 80
          r1 = add r1 arg13 64
          store 8 r1 sp 88
          r1 = load 8 sp 88
          r1 = add r1 arg14 64
          store 8 r1 sp 96
          r1 = load 8 sp 96
          r1 = add r1 arg15 64
          store 8 r1 sp 104
          r1 = load 8 sp 104
          r1 = add r1 arg16 64
          store 8 r1 sp 112
          r1 = load 8 sp 112
          call write r1
          ret 0
      end heavy_func

      ; Function main
      start main 0:
        .entry:
          ; init sp!
          sp = sub sp 440 64
          r1 = call __alloca_bytes__ 8 0
          store 8 r1 sp 0
          r1 = call read
          store 8 r1 sp 8
          r1 = load 8 sp 8
          store 8 r1 sp 24
          store 8 0 sp 40
          r1 = load 8 sp 24
          store 8 r1 sp 16
          r1 = load 8 sp 40
          store 8 r1 sp 32
          br .for.cond

        .for.cond:
          r1 = load 8 sp 32
          r1 = icmp slt r1 8 32
          store 8 r1 sp 48
          r1 = load 8 sp 48
          br r1 .for.body .for.cond.cleanup

        .for.cond.cleanup:
          br .for.end

        .for.body:
          r1 = load 8 sp 16
          r1 = and r1 255 64
          store 8 r1 sp 56
          r1 = load 8 sp 32
          r2 = and r1 2147483648 64
          r2 = sub 0 r2 64
          r1 = or r2 r1 64
          store 8 r1 sp 64
          r1 = load 8 sp 0
          r2 = load 8 sp 64
          r1 = add r1 r2 64
          store 8 r1 sp 72
          r1 = load 8 sp 56
          r2 = load 8 sp 72
          store 1 r1 r2 0
          r1 = load 8 sp 16
          r1 = lshr r1 8 64
          store 8 r1 sp 80
          r1 = load 8 sp 80
          r1 = mul r1 18446744073709551615 64
          store 8 r1 sp 88
          br .for.inc

        .for.inc:
          r1 = load 8 sp 32
          r1 = add r1 1 32
          store 8 r1 sp 96
          r1 = load 8 sp 88
          store 8 r1 sp 24
          r1 = load 8 sp 96
          store 8 r1 sp 40
          r1 = load 8 sp 24
          store 8 r1 sp 16
          r1 = load 8 sp 40
          store 8 r1 sp 32
          br .for.cond

        .for.end:
          store 8 0 sp 112
          store 8 0 sp 128
          r1 = load 8 sp 112
          store 8 r1 sp 104
          r1 = load 8 sp 128
          store 8 r1 sp 120
          br .for.cond3

        .for.cond3:
          r1 = load 8 sp 120
          r1 = icmp slt r1 8 32
          store 8 r1 sp 136
          r1 = load 8 sp 136
          br r1 .for.body7 .for.cond.cleanup6

        .for.cond.cleanup6:
          br .for.end13

        .for.body7:
          r1 = load 8 sp 120
          r2 = and r1 2147483648 64
          r2 = sub 0 r2 64
          r1 = or r2 r1 64
          store 8 r1 sp 144
          r1 = load 8 sp 0
          r2 = load 8 sp 144
          r1 = add r1 r2 64
          store 8 r1 sp 152
          r1 = load 8 sp 152
          r1 = load 1 r1 0
          store 8 r1 sp 160
          r1 = load 8 sp 160
          store 8 r1 sp 168
          r1 = load 8 sp 104
          r2 = load 8 sp 168
          r1 = add r1 r2 64
          store 8 r1 sp 176
          br .for.inc11

        .for.inc11:
          r1 = load 8 sp 120
          r1 = add r1 1 32
          store 8 r1 sp 184
          r1 = load 8 sp 176
          store 8 r1 sp 112
          r1 = load 8 sp 184
          store 8 r1 sp 128
          r1 = load 8 sp 112
          store 8 r1 sp 104
          r1 = load 8 sp 128
          store 8 r1 sp 120
          br .for.cond3

        .for.end13:
          r1 = load 8 sp 104
          call write r1
          r1 = call read
          store 8 r1 sp 192
          r1 = call read
          store 8 r1 sp 200
          r1 = call read
          store 8 r1 sp 208
          r1 = call read
          store 8 r1 sp 216
          r1 = call read
          store 8 r1 sp 224
          r1 = call read
          store 8 r1 sp 232
          r1 = call read
          store 8 r1 sp 240
          r1 = call read
          store 8 r1 sp 248
          r1 = call read
          store 8 r1 sp 256
          r1 = call read
          store 8 r1 sp 264
          r1 = call read
          store 8 r1 sp 272
          r1 = call read
          store 8 r1 sp 280
          r1 = call read
          store 8 r1 sp 288
          r1 = call read
          store 8 r1 sp 296
          r1 = call read
          store 8 r1 sp 304
          r1 = call read
          store 8 r1 sp 312
          r1 = load 8 sp 192
          r2 = load 8 sp 200
          r3 = load 8 sp 208
          r4 = load 8 sp 216
          r5 = load 8 sp 224
          r6 = load 8 sp 232
          r7 = load 8 sp 240
          r8 = load 8 sp 248
          r9 = load 8 sp 256
          r10 = load 8 sp 264
          r11 = load 8 sp 272
          r12 = load 8 sp 280
          r13 = load 8 sp 288
          r14 = load 8 sp 296
          r15 = load 8 sp 304
          r16 = load 8 sp 312
          call heavy_func r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16
          r1 = call read
          store 8 r1 sp 320
          r1 = call read
          store 8 r1 sp 328
          r1 = call read
          store 8 r1 sp 336
          r1 = call read
          store 8 r1 sp 344
          r1 = call read
          store 8 r1 sp 352
          r1 = call read
          store 8 r1 sp 360
          r1 = call read
          store 8 r1 sp 368
          r1 = call read
          store 8 r1 sp 376
          r1 = call read
          store 8 r1 sp 384
          r1 = call read
          store 8 r1 sp 392
          r1 = call read
          store 8 r1 sp 400
          r1 = call read
          store 8 r1 sp 408
          r1 = call read
          store 8 r1 sp 416
          r1 = call read
          store 8 r1 sp 424
          r1 = call read
          store 8 r1 sp 432
          r1 = load 8 sp 320
          r2 = load 8 sp 328
          r3 = load 8 sp 336
          r4 = load 8 sp 344
          r5 = load 8 sp 352
          r6 = load 8 sp 360
          r7 = load 8 sp 368
          r9 = load 8 sp 376
          r10 = load 8 sp 384
          r11 = load 8 sp 392
          r12 = load 8 sp 400
          r13 = load 8 sp 408
          r14 = load 8 sp 416
          r15 = load 8 sp 424
          r16 = load 8 sp 432
          call heavy_func r1 r2 r3 r4 r5 r6 r7 0 r9 r10 r11 r12 r13 r14 r15 r16
          ret 0
      end main
      ```
      * Assembly comparison - After
      ```assembly
      ; Function __alloca_bytes__
      start __alloca_bytes__ 2:
        .entry:
          ; init sp!
          sp = sub sp 8 64
          r1 = malloc arg1
          store 8 r1 sp 0
          r1 = load 8 sp 0
          ret r1
      end __alloca_bytes__

      ; Function heavy_func
      start heavy_func 16:
        .entry:
          ; init sp!
          sp = sub sp 120 64
          r1 = add arg1 arg2 64
          store 8 r1 sp 0
          r1 = load 8 sp 0
          r1 = add r1 arg3 64
          store 8 r1 sp 8
          r1 = load 8 sp 8
          r1 = add r1 arg4 64
          store 8 r1 sp 16
          r1 = load 8 sp 16
          r1 = add r1 arg5 64
          store 8 r1 sp 24
          r1 = load 8 sp 24
          r1 = add r1 arg6 64
          store 8 r1 sp 32
          r1 = load 8 sp 32
          r1 = add r1 arg7 64
          store 8 r1 sp 40
          r1 = load 8 sp 40
          r1 = add r1 arg8 64
          store 8 r1 sp 48
          r1 = load 8 sp 48
          r1 = add r1 arg9 64
          store 8 r1 sp 56
          r1 = load 8 sp 56
          r1 = add r1 arg10 64
          store 8 r1 sp 64
          r1 = load 8 sp 64
          r1 = add r1 arg11 64
          store 8 r1 sp 72
          r1 = load 8 sp 72
          r1 = add r1 arg12 64
          store 8 r1 sp 80
          r1 = load 8 sp 80
          r1 = add r1 arg13 64
          store 8 r1 sp 88
          r1 = load 8 sp 88
          r1 = add r1 arg14 64
          store 8 r1 sp 96
          r1 = load 8 sp 96
          r1 = add r1 arg15 64
          store 8 r1 sp 104
          r1 = load 8 sp 104
          r1 = add r1 arg16 64
          store 8 r1 sp 112
          r1 = load 8 sp 112
          call write r1
          ret 0
      end heavy_func

      ; Function main
      start main 0:
        .entry:
          ; init sp!
          sp = sub sp 440 64
          ; set ref sp
          r16 = mul sp 1 64
          ; __alloca_bytes__ 8
          sp = sub sp 8 64
          r1 = mul sp 1 64
          store 8 r1 r16 0
          r1 = call read
          store 8 r1 r16 8
          r1 = load 8 r16 8
          store 8 r1 r16 24
          store 8 0 r16 40
          r1 = load 8 r16 24
          store 8 r1 r16 16
          r1 = load 8 r16 40
          store 8 r1 r16 32
          br .for.cond

        .for.cond:
          r1 = load 8 r16 32
          r1 = icmp ult r1 8 32
          store 8 r1 r16 48
          r1 = load 8 r16 48
          br r1 .for.body .for.cond.cleanup

        .for.cond.cleanup:
          br .for.end

        .for.body:
          r1 = load 8 r16 16
          r1 = urem r1 256 64
          store 8 r1 r16 56
          r1 = load 8 r16 32
          store 8 r1 r16 64
          r1 = load 8 r16 0
          r2 = load 8 r16 64
          r1 = add r1 r2 64
          store 8 r1 r16 72
          r1 = load 8 r16 56
          r2 = load 8 r16 72
          store 1 r1 r2 0
          br .for.inc

        .for.inc:
          r1 = load 8 r16 16
          r1 = udiv r1 256 64
          store 8 r1 r16 80
          r1 = load 8 r16 80
          r1 = mul r1 18446744073709551615 64
          store 8 r1 r16 88
          r1 = load 8 r16 32
          r1 = add r1 1 32
          store 8 r1 r16 96
          r1 = load 8 r16 88
          store 8 r1 r16 24
          r1 = load 8 r16 96
          store 8 r1 r16 40
          r1 = load 8 r16 24
          store 8 r1 r16 16
          r1 = load 8 r16 40
          store 8 r1 r16 32
          br .for.cond

        .for.end:
          store 8 0 r16 112
          store 8 0 r16 128
          r1 = load 8 r16 112
          store 8 r1 r16 104
          r1 = load 8 r16 128
          store 8 r1 r16 120
          br .for.cond3

        .for.cond3:
          r1 = load 8 r16 120
          r1 = icmp ult r1 8 32
          store 8 r1 r16 136
          r1 = load 8 r16 136
          br r1 .for.body7 .for.cond.cleanup6

        .for.cond.cleanup6:
          br .for.end13

        .for.body7:
          br .for.inc11

        .for.inc11:
          r1 = load 8 r16 120
          store 8 r1 r16 144
          r1 = load 8 r16 0
          r2 = load 8 r16 144
          r1 = add r1 r2 64
          store 8 r1 r16 152
          r1 = load 8 r16 152
          r1 = load 1 r1 0
          store 8 r1 r16 160
          r1 = load 8 r16 160
          store 8 r1 r16 168
          r1 = load 8 r16 104
          r2 = load 8 r16 168
          r1 = add r1 r2 64
          store 8 r1 r16 176
          r1 = load 8 r16 120
          r1 = add r1 1 32
          store 8 r1 r16 184
          r1 = load 8 r16 176
          store 8 r1 r16 112
          r1 = load 8 r16 184
          store 8 r1 r16 128
          r1 = load 8 r16 112
          store 8 r1 r16 104
          r1 = load 8 r16 128
          store 8 r1 r16 120
          br .for.cond3

        .for.end13:
          r1 = load 8 r16 104
          call write r1
          r1 = call read
          store 8 r1 r16 192
          r1 = call read
          store 8 r1 r16 200
          r1 = call read
          store 8 r1 r16 208
          r1 = call read
          store 8 r1 r16 216
          r1 = call read
          store 8 r1 r16 224
          r1 = call read
          store 8 r1 r16 232
          r1 = call read
          store 8 r1 r16 240
          r1 = call read
          store 8 r1 r16 248
          r1 = call read
          store 8 r1 r16 256
          r1 = call read
          store 8 r1 r16 264
          r1 = call read
          store 8 r1 r16 272
          r1 = call read
          store 8 r1 r16 280
          r1 = call read
          store 8 r1 r16 288
          r1 = call read
          store 8 r1 r16 296
          r1 = call read
          store 8 r1 r16 304
          r1 = call read
          store 8 r1 r16 312
          ; spill ref sp - step 1
          sp = sub sp 8 64
          store 8 r16 sp 0
          sp = add sp 8 64
          r1 = load 8 r16 192
          r2 = load 8 r16 200
          r3 = load 8 r16 208
          r4 = load 8 r16 216
          r5 = load 8 r16 224
          r6 = load 8 r16 232
          r7 = load 8 r16 240
          r8 = load 8 r16 248
          r9 = load 8 r16 256
          r10 = load 8 r16 264
          r11 = load 8 r16 272
          r12 = load 8 r16 280
          r13 = load 8 r16 288
          r14 = load 8 r16 296
          r15 = load 8 r16 304
          r16 = load 8 r16 312
          ; spill ref sp - step 2
          sp = sub sp 8 64
          call heavy_func r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16
          ; spill ref sp - step 3
          r16 = load 8 sp 0
          sp = add sp 8 64
          r1 = call read
          store 8 r1 r16 320
          r1 = call read
          store 8 r1 r16 328
          r1 = call read
          store 8 r1 r16 336
          r1 = call read
          store 8 r1 r16 344
          r1 = call read
          store 8 r1 r16 352
          r1 = call read
          store 8 r1 r16 360
          r1 = call read
          store 8 r1 r16 368
          r1 = call read
          store 8 r1 r16 376
          r1 = call read
          store 8 r1 r16 384
          r1 = call read
          store 8 r1 r16 392
          r1 = call read
          store 8 r1 r16 400
          r1 = call read
          store 8 r1 r16 408
          r1 = call read
          store 8 r1 r16 416
          r1 = call read
          store 8 r1 r16 424
          r1 = call read
          store 8 r1 r16 432
          r1 = load 8 r16 320
          r2 = load 8 r16 328
          r3 = load 8 r16 336
          r4 = load 8 r16 344
          r5 = load 8 r16 352
          r6 = load 8 r16 360
          r7 = load 8 r16 368
          r8 = load 8 r16 376
          r9 = load 8 r16 384
          r10 = load 8 r16 392
          r11 = load 8 r16 400
          r12 = load 8 r16 408
          r13 = load 8 r16 416
          r14 = load 8 r16 424
          r15 = load 8 r16 432
          call heavy_func r1 r2 r3 r4 r5 r6 r7 0 r8 r9 r10 r11 r12 r13 r14 r15
          ret 0
      end main
      ```
      * Cost comparison
         * 1652.9408(8)   --> 1438.9888(0)          -213.95(0)
         * Max heap usage has disappeared.


​     

#### Loop Optimization Test

I tested loop-unroll and loop-interchange cases for the unit test. Also, I added a test case that the payoff of doing loop interchanging is more expensive. As a unit test, I just watched whether the loop unrolling(or interchanging) is applied or not by using `debug-only` and `analyze` option. I will not write the cost improvements of the unit test. Instead of that, I will write the cost improvements of the case test results of this unit optimization.

  * `unroll.c` (Unit test)

    ```assembly
    ;Unroll Testcase. Same to:
    ;int main() {
    ;  uint64_t n = read();
    ;  for (uint64_t i = 0; i < n; i++) {
    ;    write(i);
    ;  }
    ;  return 0;
    ;}
    define dso_local i32 @main() {
    entry:
      %call = call i64 (...) @read()
      br label %for.cond
    
    for.cond:
      %i = phi i64 [ 0, %entry ], [ %inc, %for.inc ]
      %cmp = icmp ult i64 %i, %call
      br i1 %cmp, label %for.body, label %for.cond.cleanup
    
    for.cond.cleanup:
      br label %for.end
    
    for.body:
      call void @write(i64 %i)
      br label %for.inc
    
    for.inc:
      %inc = add i64 %i, 1
      br label %for.cond
    
    for.end:
      ret i32 0
    }
    
    declare dso_local i64 @read(...)
    
    declare dso_local void @write(i64)
    ```

    * Optimization result

      The debug analyze log said that the loop was successfully unrolled. The resultant IR code is as below.

      ```assembly
      ...
      for.inc.1:                                        ; preds = %for.inc
        %inc.1 = add nuw nsw i64 %inc, 1
        %niter.nsub.1 = sub i64 %niter.nsub, 1
        call void @write(i64 %inc.1)
        br label %for.inc.2
      for.inc.2:                                        ; preds = %for.inc.1
        %inc.2 = add nuw nsw i64 %inc.1, 1
        %niter.nsub.2 = sub i64 %niter.nsub.1, 1
        call void @write(i64 %inc.2)
        br label %for.inc.3
      for.inc.3:                                        ; preds = %for.inc.2
        %inc.3 = add nuw nsw i64 %inc.2, 1
        %niter.nsub.3 = sub i64 %niter.nsub.2, 1
        call void @write(i64 %inc.3)
        br label %for.inc.4
      for.inc.4:                                        ; preds = %for.inc.3
        %inc.4 = add nuw nsw i64 %inc.3, 1
        %niter.nsub.4 = sub i64 %niter.nsub.3, 1
        call void @write(i64 %inc.4)
        br label %for.inc.5
      ...
      ```

* `interchange.ll` (Unit test)
    ```assembly
    ;Interchange Testcase. Same to:
    ;int main() {
    ;  uint64_t n = read();
    ;  uint64_t a[10][10];
    ;  for (uint64_t i = 0; i < n; i++) {
    ;    for (uint64_t j = 0; j < n; j++) {
    ;      a[j][i] = i + j;
    ;    }
    ;  }
    ;  return 0;
    ;}
    define dso_local i32 @main() {
    entry:
      %a = alloca [10 x [10 x i64]], align 16
      %n = call i64 (...) @read()
      br label %for.i.cond
    
    for.i.cond:
      %i = phi i64 [ 0, %entry ], [ %i.inc, %for.i.inc ]
      %cmp = icmp ult i64 %i, %n
      br i1 %cmp, label %for.i.body, label %for.i.cond.cleanup
    
    for.i.cond.cleanup:
      br label %for.i.end
    
    for.i.body:
      br label %for.j.cond
    
    for.j.cond:
      %j = phi i64 [ 0, %for.i.body ], [ %j.inc, %for.j.inc ]
      %cmp2 = icmp ult i64 %j, %n
      br i1 %cmp2, label %for.j.body, label %for.j.cond.cleanup
    
    for.j.cond.cleanup:
      br label %for.j.end
    
    for.j.body:
      %add = add i64 %i, %j
      %arrayidx = getelementptr inbounds [10 x [10 x i64]], [10 x [10 x i64]]* %a, i64 0, i64 %j
      %arrayidx2 = getelementptr inbounds [10 x i64], [10 x i64]* %arrayidx, i64 0, i64 %i
      store i64 %add, i64* %arrayidx2, align 8
      br label %for.j.inc
    
    for.j.inc:
      %j.inc = add i64 %j, 1
      br label %for.j.cond
    
    for.j.end:
      br label %for.i.inc
    
    for.i.inc:
      %i.inc = add i64 %i, 1
      br label %for.i.cond
    
    for.i.end:
      ret i32 0
    }
    
    declare dso_local i64 @read(...)
    ```

    * Optimization result

      The debug analyze log said that the loop was successfully interchanged. The resultant IR code is as below. (`%j2` - `%i4` nested loop; which is an interchanged one)

      ```assembly
      ...
      entry:
        %a = alloca [10 x [10 x i64]], align 16
        %n = call i64 (...) @read()
        %cmp3 = icmp ult i64 0, %n
        br i1 %cmp3, label %for.j.body.lr.ph, label %for.i.cond.cleanup
      ...
      for.j.body:                                       ; preds = %for.j.body.lr.ph, %for.j.body.split
        %j2 = phi i64 [ 0, %for.j.body.lr.ph ], [ %0, %for.j.body.split ]
        br label %for.i.body.lr.ph
      ...
      for.i.body:                                       ; preds = %for.i.body.lr.ph, %for.j.cond.cleanup
        %i4 = phi i64 [ 0, %for.i.body.lr.ph ], [ %i.inc, %for.j.cond.cleanup ]
        %cmp21 = icmp ult i64 0, %n
        br i1 %cmp21, label %for.j.body.split5, label %for.i.cond.for.i.cond.cleanup_crit_edge
      ...
      for.j.body.split5:                                ; preds = %for.i.body
        %add = add i64 %i4, %j2
        %arrayidx = getelementptr inbounds [10 x [10 x i64]], [10 x [10 x i64]]* %a, i64 0, i64 %j2
        %arrayidx2 = getelementptr inbounds [10 x i64], [10 x i64]* %arrayidx, i64 0, i64 %i4
        store i64 %add, i64* %arrayidx2, align 8
        %j.inc = add i64 %j2, 1
        %cmp2 = icmp ult i64 %j.inc, %n
        br label %for.j.cond.for.j.cond.cleanup_crit_edge
      ...
      ```

  * `not-interchange.ll` (Unit test)

    ```assembly
    ;Should Not Interchange Testcase. Same to:
    ;int main() {
    ;  uint64_t n = read();
    ;  uint64_t a[10][10];
    ;  for (uint64_t i = 0; i < n; i++) {
    ;    for (uint64_t j = 0; j < n; j++) {
    ;      a[i][j] = i + j;
    ;    }
    ;  }
    ;  return 0;
    ;}
    define dso_local i32 @main() {
    entry:
      %a = alloca [10 x [10 x i64]], align 16
      %n = call i64 (...) @read()
      br label %for.i.cond
    
    for.i.cond:
      %i = phi i64 [ 0, %entry ], [ %i.inc, %for.i.inc ]
      %cmp = icmp ult i64 %i, %n
      br i1 %cmp, label %for.i.body, label %for.i.cond.cleanup
    
    for.i.cond.cleanup:
      br label %for.i.end
    
    for.i.body:
      br label %for.j.cond
    
    for.j.cond:
      %j = phi i64 [ 0, %for.i.body ], [ %j.inc, %for.j.inc ]
      %cmp2 = icmp ult i64 %j, %n
      br i1 %cmp2, label %for.j.body, label %for.j.cond.cleanup
    
    for.j.cond.cleanup:
      br label %for.j.end
    
    for.j.body:
      %add = add i64 %i, %j
      %arrayidx = getelementptr inbounds [10 x [10 x i64]], [10 x [10 x i64]]* %a, i64 0, i64 %i
      %arrayidx2 = getelementptr inbounds [10 x i64], [10 x i64]* %arrayidx, i64 0, i64 %j
      store i64 %add, i64* %arrayidx2, align 8
      br label %for.j.inc
    
    for.j.inc:
      %j.inc = add i64 %j, 1
      br label %for.j.cond
    
    for.j.end:
      br label %for.i.inc
    
    for.i.inc:
      %i.inc = add i64 %i, 1
      br label %for.i.cond
    
    for.i.end:
      ret i32 0
    }
    
    declare dso_local i64 @read(...)
    ```

    * Optimization result

      The debug analyze log said that the loop was not interchanged, since the payoff is too expensive.(Which is correct.) The resultant IR code is almost identical to the before one.

  * `loop_unroll.c` (Case test)

    ```c
    #include <inttypes.h>
    #include <stdlib.h>
    
    uint64_t read();
    void write(uint64_t val);
    
    int main() {
      uint64_t n = read();
      uint64_t *a = (uint64_t*) malloc(sizeof(uint64_t) * (n+1));
    
      for (uint64_t i = 1; i <= n; i++) {
        a[i] = read();
      }
    
      for (uint64_t i = n; i > 0; i--) {
        write(a[i]);
      }
    
      return 0;
    }
    ```

    * The cost(heap usage) changes from the test cases:

      * input1.txt [AC]    2175.5152(168)  --> 2118.032(168)    -57.48(0)
      * input2.txt [AC]    10692.2512(808) --> 10186.768(808)   -505.48(0)
      * input3.txt [AC]    88708.0912(6408) --> 84240.0608(6408)  -4468.03(0)


  * `loop_interchange.c` (Case test)

    ```c
    #include <inttypes.h>
    #include <stdlib.h>
    
    uint64_t read();
    void write(uint64_t val);
    
    int main() {
      uint64_t n = read();
      uint64_t a[30][30];
    
      for (uint64_t i = 0; i < n; i++) {
        for (uint64_t j = 0; j < n; j++) {
          a[j][i] = i + j;
        }
      }
    
      for (uint64_t i = 0; i < n; i++) {
        for (uint64_t j = 0; j < n; j++) {
          write(a[i][j]);
        }
      }
    
      return 0;
    }
    ```

    * The cost(heap usage) changes from the test cases:

      * input1.txt [AC]    10924.9744(0)   --> 8305.9568(0)     -2619.02(0)
      * input2.txt [AC]    42627.2144(0)   --> 30065.8608(0)    -12561.35(0)
      * input3.txt [AC]    96340.6544(0)   --> 66528.1008(0)    -29812.55(0)


  * `loop_multiple_example.c` (Case test)

    ```c
    #include <inttypes.h>
    #include <stdlib.h>
    
    uint64_t read();
    void write(uint64_t val);
    
    int main() {
      uint64_t n = read(), m = read();
      uint64_t a[10][10][10];
      uint64_t b, ans = 0;
    
      for (uint64_t i = 0; i < n; i++) {
        for (uint64_t j = 0; j < n; j++) {
          b = i * j;
        }
      }
    
      for (uint64_t i = 0; i < n; i++) {
        for (uint64_t j = 0; j < n; j++) {
          for (uint64_t k = 0; k < n; k++) {
            a[k][i][j] = i * j + k;
          }
        }
      }
    
      for (uint64_t i = 0; i < n; i++) {
        for (uint64_t j = 0; j < n; j++) {
          for (uint64_t k = 0; k < n; k++) {
            if (m != n) {
              ans += 2 + a[j][k][i];
            }
          }
        }
      }
    
      write(ans);
    
      return 0;
    }
    ```

    * The cost(heap usage) changes from the test cases:

      * input1.txt [AC]    23409.5168(0)   --> 15390.3104(0)    -8019.21(0)
      * input2.txt [AC]    173015.0368(0)  --> 101263.6544(0)   -71751.38(0)
      * input3.txt [AC]    130589.4368(0)  --> 56212.16(0)      -74377.28(0)



#### ReorderMemPass

ReorderMemPass can be applied to any block, but the performance improved when there are frequent changes between heap access and stack access. These are test codes made to show effect of this pass.

##### Test on simple IR code

```assembly
; ModuleID = 'MyTestModule'
source_filename = "MyTestModule"

define void @test() {
entry:
  %p1 = call i8* @malloc(i64 8)   ;HEAP
  %0 = alloca i8                  ;STACK
  %p2 = call i8* @malloc(i64 8)   ;HEAP
  %1 = alloca i8                  ;STACK
  store i8 1, i8* %p1             ;HEAP
  store i8 1, i8* %0              ;STACK
  store i8 1, i8* %p2             ;HEAP
  store i8 1, i8* %1              ;STACK
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

declare i8* @malloc(i64)
```

This is simple IR code which access to heap and stack alternately. After applying ReorderMemPass, "entry" block changed like this

```assembly
entry:
  %0 = alloca i8                  ;STACK
  %1 = alloca i8                  ;STACK
  store i8 1, i8* %0              ;STACK
  store i8 1, i8* %1              ;STACK
  %p1 = call i8* @malloc(i64 8)   ;HEAP
  %p2 = call i8* @malloc(i64 8)   ;HEAP
  store i8 1, i8* %p1             ;HEAP
  store i8 1, i8* %p2             ;HEAP
  br label %exit
```

None of the instruction's contents have changed. Only there order had changed. There is none of dependency between heap access, so optimization had applied perfectly, separating area of heap access and stack access.

##### Test on Complex IR code.
```assembly
; ModuleID = 'MyTestModule'
source_filename = "MyTestModule"

define void @test() {
entry:
  %p1 = call i8* @malloc(i64 8)  ;HEAP
  %0 = alloca i8                 ;STACK
  %p2 = call i8* @malloc(i64 8)  ;HEAP
  %1 = alloca i8                 ;STACK
  store i8 1, i8* %p1            ;HEAP
  store i8 1, i8* %0             ;STACK
  %l1 = load i8, i8* %p1         ;HEAP
  store i8 1, i8* %p2            ;HEAP
  store i8 %l1, i8* %1           ;STACK
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

declare i8* @malloc(i64)
```

Single instruction is added which loads data from the heap area and stores it in the stack area. This instruction restricts some instructions changing order freely. Following code is result after applying ReorderMemAccess.

```assembly
entry:
  %0 = alloca i8                 ;STACK
  %1 = alloca i8                 ;STACK
  store i8 1, i8* %0             ;STACK
  %p1 = call i8* @malloc(i64 8)  ;HEAP
  %p2 = call i8* @malloc(i64 8)  ;HEAP
  store i8 1, i8* %p1            ;HEAP
  %l1 = load i8, i8* %p1         ;HEAP
  store i8 1, i8* %p2            ;HEAP
  store i8 %l1, i8* %1           ;STACK
  br label %exit
```

In this case, instructions cannot change their order freely. We can checked that ReorderMemAccess had optimized well, without changing its behavior.

##### Testing performance on C code

```c
#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

int main() {
  long long a[50];
  long long *m1 = (long long*)malloc(sizeof(long long)*50);

  long long limit;
  limit = read();

  if(limit > 50) limit=50;

  for(long long i=0; i<limit; i++) {
    a[i]=i;
    m1[i]=49-i;
  }

  long long sum=0; 
  for(long long i=0; i<limit; i++) {
    sum+=a[i];
    sum+=m1[i];
    sum+=a[49-i];
    sum+=m1[49-i];
  }

  write(sum);
  return 0;
}
```
This is c code I made it for test. I had test for three limit(3,10,44) and this is following result.

    * The cost(heap usage) changes from the test cases:
      *input1.txt      [AC]    845.248(400) --> 844.6784(400) -0.57(0)
      *input2.txt      [AC]    2399.3088(400) --> 2397.9904(400) -1.32(0)
      *input3.txt      [AC]    9776.1024(400) --> 9772.9152(400)-3.19(0)

This result can be reappeared by executing following command :
```
test/single_checker.sh test/testcases/ours/reorder/ "ReorderMemAccess"
```
Combining with roop unrolling, it can have better effect. But currently, RA is not completed yet, so performance is not improved yet.




#### All Test Case Result

This is the log from `make test`. Our compiler generated valid assembly files, as all outputs were correct(`[AC]`).

```
Case test for the benchmarks has been started
Testing test/testcases/benchmarks/binary_tree/
>> input1.txt [AC]    2362.656(144)   --> 2441.208(144)    +78.55(0)
>> input2.txt [AC]    4230.4064(144)  --> 4315.2128(144)   +84.81(0)
>> input3.txt [AC]    65112.4912(1176) --> 66352.2448(1176)  +1239.75(0)
>> input4.txt [AC]    1020825.2272(14136) --> 1047825.8848(14136)  +27000.66(0)
>> input5.txt [AC]    1975083148.5003(1660152) --> 1981975552.4551(1660152)  +6892403.95(0)
Testing test/testcases/benchmarks/bitcount1/
>> input1.txt [AC]    218.0288(0)     --> 177.736(0)       -40.29(0)
>> input2.txt [AC]    1351.4672(0)    --> 1002.0976(0)     -349.37(0)
>> input3.txt [AC]    385.9456(0)     --> 301.352(0)       -84.59(0)
>> input4.txt [AC]    50.112(0)       --> 41.3616(0)       -8.75(0)
>> input5.txt [AC]    92.0912(0)      --> 91.864(0)        -0.23(0)
Testing test/testcases/benchmarks/bitcount2/
>> input1.txt [AC]    199.7744(0)     --> 206.1664(0)      +6.39(0)
>> input2.txt [AC]    1254.848(0)     --> 1310.8768(0)     +56.03(0)
>> input3.txt [AC]    356.0816(0)     --> 369.8272(0)      +13.75(0)
>> input4.txt [AC]    43.4672(0)      --> 42.5056(0)       -0.96(0)
>> input5.txt [AC]    82.544(0)       --> 83.4208(0)       +0.88(0)
Testing test/testcases/benchmarks/bitcount3/
>> input1.txt [AC]    134.8832(0)     --> 121.288(0)       -13.6(0)
>> input2.txt [AC]    1364.0656(0)    --> 1016.3888(0)     -347.68(0)
>> input3.txt [AC]    346.8112(0)     --> 266.984(0)       -79.83(0)
>> input4.txt [AC]    50.112(0)       --> 41.3616(0)       -8.75(0)
>> input5.txt [AC]    92.4976(0)      --> 92.264(0)        -0.23(0)
Testing test/testcases/benchmarks/bitcount4/
>> input1.txt [AC]    24676.8304(1024) --> 8559.7488(1024)  -16117.08(0)
>> input2.txt [AC]    24679.656(1024) --> 8562.5744(1024)  -16117.08(0)
>> input3.txt [AC]    24677.6144(1024) --> 8560.5328(1024)  -16117.08(0)
>> input4.txt [AC]    24676.8016(1024) --> 8559.72(1024)    -16117.08(0)
>> input5.txt [AC]    24676.8048(1024) --> 8559.7232(1024)  -16117.08(0)
Testing test/testcases/benchmarks/bitcount5/
>> input1.txt [AC]    391.0752(64)    --> 389.2688(64)     -1.81(0)
>> input2.txt [AC]    860.9872(64)    --> 846.536(64)      -14.45(0)
>> input3.txt [AC]    457.992(64)     --> 454.3792(64)     -3.61(0)
>> input4.txt [AC]    324.2704(64)    --> 324.2704(64)     0.0(0)
>> input5.txt [AC]    391.0496(64)    --> 389.2432(64)     -1.81(0)
Testing test/testcases/benchmarks/bubble_sort/
>> input1.txt [AC]    6628.936(80)    --> 6049.9728(80)    -578.96(0)
>> input2.txt [AC]    562437.2464(800) --> 521584.7024(800)  -40852.54(0)
>> input3.txt [AC]    61987402.0422(8000) --> 58138044.9115(8000)  -3849357.13(0)
Testing test/testcases/benchmarks/collatz/
>> input1.txt [AC]    66.84(0)        --> 65.8848(0)       -0.96(0)
>> input2.txt [AC]    66.84(0)        --> 65.8848(0)       -0.96(0)
Testing test/testcases/benchmarks/gcd/
>> input1.txt [AC]    46.5024(0)      --> 47.6368(0)       +1.13(0)
>> input2.txt [AC]    105.4816(0)     --> 110.7504(0)      +5.27(0)
>> input3.txt [AC]    223.4272(0)     --> 236.9648(0)      +13.54(0)
>> input4.txt [AC]    1043.0336(0)    --> 1112.3888(0)     +69.36(0)
Testing test/testcases/benchmarks/matmul1/
>> input1.txt [AC]    2607.9088(96)   --> 2486.2208(96)    -121.69(0)
>> input2.txt [AC]    13201.4704(384) --> 11738.7296(384)  -1462.74(0)
>> input3.txt [AC]    594334.0144(6144) --> 477765.6544(6144)  -116568.36(0)
Testing test/testcases/benchmarks/matmul2/
>> input1.txt [AC]    2804.1072(96)   --> 2585.1904(96)    -218.92(0)
>> input2.txt [AC]    15513.656(384)  --> 13151.7344(384)  -2361.92(0)
>> input3.txt [AC]    807544.2224(6144) --> 638147.44(6144)  -169396.78(0)
Testing test/testcases/benchmarks/matmul3/
>> input1.txt [AC]    7797.448(384)   --> 6905.9376(384)   -891.51(0)
>> input2.txt [AC]    7797.448(384)   --> 6905.9376(384)   -891.51(0)
>> input3.txt [AC]    313852.2352(6144) --> 243073.7584(6144)  -70778.48(0)
Testing test/testcases/benchmarks/matmul4/
>> input1.txt [AC]    20683.6976(384) --> 8418.6608(384)   -12265.04(0)
>> input2.txt [AC]    20683.6976(384) --> 8418.6608(384)   -12265.04(0)
>> input3.txt [AC]    1138447.6784(6144) --> 369178.8928(6144)  -769268.79(0)
Testing test/testcases/benchmarks/prime/
>> input1.txt [AC]    117.44(40)      --> 114.5584(40)     -2.88(0)
>> input2.txt [AC]    6582.184(72)    --> 5966.2528(72)    -615.93(0)
>> input3.txt [AC]    1516992.736(6040) --> 1345224.1472(6040)  -171768.59(0)
>> input4.txt [AC]    5507400.9664(16472) --> 4920681.4608(16472)  -586719.51(0)
Testing test/testcases/benchmarks/rmq1d_naive/
>> input1.txt [AC]    362.3072(8)     --> 446.5616(8)      +84.25(0)
>> input2.txt [AC]    2987.9568(16)   --> 3455.1504(16)    +467.19(0)
>> input3.txt [AC]    4692.8672(24)   --> 5413.296(24)     +720.43(0)
>> input4.txt [AC]    5443.72(40)     --> 5676.608(40)     +232.89(0)
>> input5.txt [AC]    2426282.6912(400) --> 1878452.5808(400)  -547830.11(0)
>> input6.txt [AC]    11450800.3411(2000) --> 8252583.1105(2000)  -3198217.23(0)
>> input7.txt [AC]    2721896020.0221(40000) --> 2067428338.1375(40000)  -654467681.88(0)
Testing test/testcases/benchmarks/rmq1d_sparsetable/
>> input1.txt [AC]    2547.3232(48)   --> 1868.696(48)     -678.63(0)
>> input2.txt [AC]    22293.5616(96)  --> 16015.1632(96)   -6278.4(0)
>> input3.txt [AC]    32711.512(104)  --> 23398.2464(104)  -9313.27(0)
>> input4.txt [AC]    27171.3424(192) --> 20655.4144(192)  -6515.93(0)
>> input5.txt [AC]    1947154.2496(2432) --> 1404825.5632(2432)  -542328.69(0)
>> input6.txt [AC]    2887076.1664(16128) --> 2313258.4624(16128)  -573817.7(0)
>> input7.txt [AC]    134553296.5285(494720) --> 127720194.7398(494720)  -6833101.79(0)
Testing test/testcases/benchmarks/rmq2d_naive/
>> input1.txt [AC]    701.0672(24)    --> 649.0112(24)     -52.06(0)
>> input2.txt [AC]    4887.1616(32)   --> 4396.0016(32)    -491.16(0)
>> input3.txt [AC]    42251.3824(80)  --> 38690.7056(80)   -3560.68(0)
>> input4.txt [AC]    31675.528(408)  --> 27393.3936(408)  -4282.13(0)
>> input5.txt [AC]    22565511.8652(48808) --> 20355153.7503(48808)  -2210358.11(0)
Testing test/testcases/benchmarks/rmq2d_sparsetable/
>> input1.txt [AC]    8971.8592(64)   --> 6513.7248(64)    -2458.13(0)
>> input2.txt [AC]    52232.512(112)  --> 39002.9632(112)  -13229.55(0)
>> input3.txt [AC]    288167.16(264)  --> 215213.3088(264)  -72953.85(0)
>> input4.txt [AC]    326853.2336(2648) --> 307001.5952(2648)  -19851.64(0)
>> input5.txt [AC]    992828214.2768(1670984) --> 986545683.336(1670984)  -6282530.94(0)
Case test done
```



