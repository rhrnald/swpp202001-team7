# Requirement and Specification

*This document is written before the Wrap-up.*

## Optimizations to Implement
*Codes to implement in Wrap-up.*

#### Global Variable Optimization
1. Outline
   - Class name: (No name. It is implemented by backend-modification.)
   - The global variables are initially declared in the heap, by `malloc`.
   - I think it could be moved to the stack if there is enough space.
   - Also, it is okay to call `malloc` just once, by aggregating the sizes of global variables in the heap.

2. Restriction
   - It is guaranteed to prevent the stack overflow.
      - It can be prejudged by the current stack frame structure in the backend.
   - It should obey the rule that the stack grows lower, and the heap grows higher addresses.
   - Also, the stack global variable should be declared in the entry block of the `main` function.
      - Then, it is guaranteed not to be overwritten while the execution. 
   
3. Pseudo-Code Algorithm

   ```pseudocode
   ; Initialize the offsets of global variables
   gv_stack_offset = 10240
   gv_heap_offset = 20480

   For G in GlobalVariables
      size = align_8bytes(G.size)
      If gv_stack_offset - size >= STACK_DANGEROUS_REGION
         gv_stack_offset -= size
         gv_offset_map[G] = gv_stack_offset
      Else
         gv_offset_map[G] = gv_heap_offset
         gv_heap_offset += size
      EndIf
   EndFor

   ; Create malloc for the heap variables
   BE ← The entry block of the main function
   if gv_heap_offset > 20480
      Add malloc(gv_heap_offset - 20480) in BE
   EndIf
   ```

4. Example IR Codes

   * ```assembly
     ;Example.1 Basic Optimization
     ;Before
     @N = external global i64
     @M = external global i32

     ;After
     @N is located in 10232,
     @M is located in 10224
     ```

     ```assembly
     ;Example.2 Size checked
     ;Before
     @N = external global [10 x i64]
     @M = external global [1000 x i64]
     @L = external global [100 x i64]

     ;After
     @N is located in 10160
     @M is located in 20480 (to prevent potential danger of stack overflow)
     @L is located in 9360
     
     There will be a malloc(8000) on the entry block of the main function.
     ```
     
     ```assembly
     ;Example.3 Malloc Combined
     ;Before
     @A = external global [500 x i64]
     @B = external global [500 x i64]
     @C = external global [500 x i64]
     @D = external global [500 x i64]

     ;After
     @A is located in 6240
     @B is located in 20480
     @C is located in 24480
     @D is located in 28480
     
     There will be a single malloc(12000) on the entry block of the main function.
     ```




## Optimizations we have done (SP3)
*Codes that were implemented in Sprint 3.*

#### Register Allocation (Developed during the SP2 and 3)
1. Outline
   - Class name: RegisterAllocator
   - Modifying: Backend and AssemblyEmitter
   - The current RA is inefficient; every time an instruction is used, `load` from its slot is called, and after uses, `store` to its slot is called.
   - Except `CallInst`, only `r1`-`r3` is used by now.

2. Restriction
   - Function-level RA would be dangerous because the block order might not flow in one direction.
   - On runtime, the eviction decision is not easy.
   - Block-level RA might be a bit inefficient, but it can be mitigated by checking the dominance. Also, some smarter eviction policies can happen.
   
   

#### Garbage Slot Elimination

1. Outline
   - Class name: GarbageSlotEliminator
   - Thanks to the Block-level RA, some instruction slots are not used. These garbage slots may be eliminated.

2. Restriction
   - This must be applied after the RA is applied.



#### Memory Use Optimization

1. Outline

   * Class name: MemUseOptimization
   * Accessing the heap(4) is more expensive than the stack(2).
   * Therefore, we are going to convert heap allocation into stack as much as possible with considering stack overflow cases.

2. Restriction

   * The conversion from `malloc` to `alloca` would be safe if there is enough space on the stack.
   * We decided that this conversion should be done only if
     * The target function is `main`. (Not recursively called)
     * The `malloc` is not on any loops.
       * To prevent the overhead(for conditional branched instruction) became multiplied.
   * Also, `free` has to be applied carefully since not every `malloc` is on the heap anymore.
     * Different to `malloc`, all `free` should be wrapped in a conditional branch.
     * Since the overheads can be unpredictable, therefore this pass is deactivated if
       * There is a `free` that outside the `main` function.
       * There is a `free` that on a loop.
   * I noticed that dynamic `alloca` is not supported by the interpreter. But in .s file, it can be implemented by changing `%sp` value.
     * This is already done by the last sprint; Backend Renovation by Jiyong.
     * I used `alloca_bytes` which is handled by the backend.
   * Since checking if `%sp` is safe is very important, and should be precise, I used `define i64 @__get_stack_pointer__()`.
     * It is handled by `AssemblyEmitter.cpp`.




#### Adding Reset Function

1. Outline

   * Class name: Backend2
   * Adding a reset function doesn't have any effect on the other part of code. So this part can be done at any moment. Because instructions change while passing through other passes, Reset function must be inserted as last as possible. So this backend2 will be applied after backend1, which was the last last pass before the assembly emitter. After backend1 throws out depromoted module, this backend2 will insert a rest function.
   * Reset function must be inserted between heap access and stack access, which can be determined with blockTypeCheck function.


2. Restriction
   - This pass should be applied right before assembly emitter.



## Optimizations we have done (SP2)
*Codes that were implemented in Sprint 2.*

#### Memory Access Reordering
1. Outline
   - Class name: ReorderMemAcc
   - Accessing stack and heap simultaneously is very inefficient. 
   - Can reduce cost of memory access by reordering instruction to separate stack access and heap access.

2. Restriction
   - Reordering memory access must be careful.
      - Reordering without any rule can make the program totally different. We need to check if reordering is valid.
      - We have to reorder in purpose to reduce cross-access of heap and stack.
   - Optimizing perfectly might be very hard because of complex corner cases, so we need to optimize well and achieve good performance for general cases. Try several optimizations and use the best performance optimization. Combining is also possible.



## Optimizations we have done (SP1)

*Codes that were implemented in Sprint 1.*

#### Packing Registers
1. Outline
   - Class name: PackRegisters
   - Function call cost 2 * (1 + arg #) is independent to number of bits in arguments.
   - Can reduce cost of function call by compressing several small arguments in one big argument. Using mul, div, rem which have low cost will be efficient.
   
2. Restriction
   - (use in function call) Embedding more than 2 arguments into a single 64bit word will have benefit.
     - Cost of encoding and decoding must be cheaper than argument passing in function call.
     - It costs 0.4 + 2.6n for encoding n arguments, passing them through a function call and decoding them back.
       - Cost for encoding n arguments: 0.6(n-1) + 0.8(n-1) = 1.4(n-1)
       - Cost for argument passing : 2
       - Cost for decoding n arguments: 1 + 0.6(n-1) + 0.6(n-1) = -0.2 + 1.2n
         - register load: 1(read arg)
         - decode one: 0.6(rem) + 0.6(div)
         - after this no additional cost occurs by reading arg
     - Cost for original function call : 2n+k(k=number of argument read)
       - After DeadArgElim, k>=n, so cost >=3n.

 

#### Arithmetic optimizations

1. Outline

   * Class name: WeirdArithmetic
   * Because of the weird cost of arithmetic instructions, some instructions still can be optimized after the existing LLVM arithmetic optimizations. Following are the specific cases. * indicates that the operands of the marked instruction may be swapped.
     * NegWithMul: sub(cost 1.2) => mul(cost 0.6)
       sub iN 0, %x => mul iN %x, -1
     * AndToRem: and(cost 0.8) => urem(cost 0.6)
       *and iN %x, C => urem iN %x, C'
       **if** %x matches shl iN %? D **then** change C into C | (2^D-1).
       after this, optimize this when C is 2^n-1 for some n, with C' = 2^n.
     * ShiftToMulDiv: shl(cost 0.8) => mul(cost 0.6), lshr(cost 0.8) => udiv(cost 0.6)
       shl iN %x, C => mul iN %x, 2^C
       lshr iN %x, C => udiv iN %x, 2^C
     * AndToMul: and(cost 0.8) => mul(cost 0.6)
       and i1 %x, %y => mul i1 %x, %y


2. Restriction

   * This pass should be applied after other passes since this optimization is unusual, which might disturb other optimizations.




