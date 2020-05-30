# Requirement and Specification

*This document is written before the sprint 3.*

## Optimizations to Implement
*Codes to implement in Sprint 3.*

#### Register Allocation
1. Outline
   - Class name: RegisterAllocator
   - Modifying: Backend and AssemblyEmitter
   - The current RA is inefficient; every time an instruction is used, `load` from its slot is called, and after uses, `store` to its slot is called.
   - Except `CallInst`, only `r1`-`r3` is used by now.

2. Restriction
   - Function-level RA would be dangerous because the block order might not flow in one direction.
   - On runtime, the eviction decision is not easy.
   - Block-level RA might be a bit inefficient, but it can be mitigated by checking the dominance. Also, some smarter eviction policies can happen.

3. Pseudo-Code Algorithm
   ```pseudocode
   RegisterAllocator RA
   ; eviction routine
   Def evictRoutine(Eviction E)
      If E->Use is in a loop or is not the last use of E->Inst
         spill
      EndIf
   EndDef
   ; request routine
   Def requestRoutine(Instruction I)
      Alloc ← RA.request(I)
      If Alloc is null
         evictRoutine(RA.evict())
         Alloc ← RA.request(I)
      EndIf
      return Alloc
   EndDef
   ; when Instruction I is used
   RegId ← RA.get(I)
   If RegId is not zero
      ; hit
      use the register RegId
   Else
      ; miss
      Alloc ← requestRoutine(I)
      fill and use the register Alloc->RegId
   EndIf
   ; when Instruction I is declared
   Alloc ← requestRoutine(I)
   use the register Alloc->RegId, without filling
   ```

4. Sample IR/Assembly Codes
   ```assembly
   ;Example.1
   ;[Source IR code]
   ;Function starts here
   %a = ...
   %b = ...
   %x = add i64 %a, %b
   %y = add i64 %a, %x
   ret 0
   
	   ;[Assembly code]
   ;Before
   r1 = %a = ...
   store 8 r1 sp 0
   r1 = %b = ...
   store 8 r1 sp 8
   r1 = load 8 sp 0
   r2 = load 8 sp 8
   r1 = add r1 r2 64
   store 8 r1 sp 16
   r1 = load 8 sp 0
   r2 = load 8 sp 16
   r1 = add r1 r2 64
   store 8 r1 sp 24
   ret 0

   ;After
   r1 = %a = ...
   r2 = %b = ...
   r3 = add r1 r2 64
   r4 = add r1 r3 64
   ret 0
   ```

   ```assembly
   ;Example.2
   ;[Source IR code]
   ;Function starts here
   entry:
     %a = ...
     %b = ...
     %x = add i64 %a, %b
     %cond = icmp sgt i64 %x, 0
     br i1 %cond, label %gt, label %le
   gt:
     %y = add i64 %a, %x
     ret 0
   le:
     %z = mul i64 %a, %x
     ret 0
   
	   ;[Assembly code]
   ;Before
   .entry:
     r1 = %a = ...
     store 8 r1 sp 0   ;%a
     r1 = %b = ...
     store 8 r1 sp 8   ;%b
     r1 = load 8 sp 0
     r2 = load 8 sp 8
     r1 = add r1 r2 64
     store 8 r1 sp 16  ;%x
     r1 = load 8 sp 16
     r1 = icmp sgt r1 0 64
     store 8 r1 sp 24  ;%cond
     r1 = load 8 sp 24
     br r1 .gt .le
   
   .gt:
     r1 = load 8 sp 0
     r2 = load 8 sp 16
     r1 = add r1 r2 64
     store 8 r1 sp 32  ;%y
     ret 0
   
   .le:
     r1 = load 8 sp 0
     r2 = load 8 sp 16
     r1 = mul r1 r2 64
     store 8 r1 sp 40  ;%z
     ret 0

   ;After
   .entry:
     r1 = %a = ...
     r2 = %b = ...
     r3 = add r1 r2 64
     r4 = icmp sgt r3 0 64
     store 8 r1 sp 0   ;spill %a
     store 8 r3 sp 16  ;spill %x
     br r4 .gt .le
   
   .gt:
     r1 = load 8 sp 0  ;fill %a
     r2 = load 8 sp 16 ;fill %x
     r3 = add r1 r2 64
     ret 0
   
   .le:
     r1 = load 8 sp 8  ;fill %a
     r2 = load 8 sp 16 ;fill %x
     r3 = mul r1 r2 64
     ret 0
   ```

   ```assembly
   ;Example.3
   ;[Source IR code]
   ;Function starts here
   entry:
     br label %loop
   loop:
     %a = phi i64 [ 0, %entry ], [ %y, %gt ]
     %b = ...
     %x = add i64 %a, %b
     %cond = icmp sgt i64 %x, 0
     br i1 %cond, label %gt, label %le
   gt:
     %y = add i64 %a, %x
     br label %loop
   le:
     %z = mul i64 %a, %x
     ret 0
   
	   ;[Assembly code]
   ;Before
   .entry:
     store 8 0 sp 8
     br .loop

   .loop:
     r1 = load 8 sp 8
     store 8 r1 sp 0   ;%a
     r1 = %b = ... 
     store 8 r1 sp 16  ;%b
     r1 = load 8 sp 0
     r2 = load 8 sp 16
     r1 = add r1 r2 64
     store 8 r1 sp 24  ;%x
     r1 = load 8 sp 24
     r1 = icmp sgt r1 0 64
     store 8 r1 sp 32  ;%cond
     r1 = load 8 sp 32
     br r1 .gt .le
   
   .gt:
     r1 = load 8 sp 0
     r2 = load 8 sp 24
     r1 = add r1 r2 64
     store 8 r1 sp 40  ;%y
     r1 = load 8 sp 40
     store 8 r1 sp 8
     br .loop
   
   .le:
     r1 = load 8 sp 0
     r2 = load 8 sp 24
     r1 = mul r1 r2 64
     store 8 r1 sp 48  ;%z
     ret 0

   ;After
   .entry:
     store 8 0 sp 8
     br .loop

   .loop:
     r1 = load 8 sp 8
     r2 = %b = ... 
     r3 = add r1 r2 64
     r4 = icmp sgt r3 0 64
     store 8 r1 sp 0
     store 8 r2 sp 16
     store 8 r3 sp 24
     store 8 r4 sp 32
     br r4 .gt .le
   
   .gt:
     r1 = load 8 sp 0
     r2 = load 8 sp 24
     r3 = add r1 r2 64
     store 8 r3 sp 8
     store 8 r3 sp 40
     br .loop
   
   .le:
     r1 = load 8 sp 0
     r2 = load 8 sp 24
     r3 = mul r1 r2 64
     ret 0
   ```



#### Memory Use Optimization

1. Outline

   * Class name: MemUseOptimization
   * Accessing the heap(4) is more expensive than the stack(2).
   * Therefore, we are going to convert heap allocation into stack as much as possible with considering stack overflow cases.

2. Restriction

   * The conversion from `malloc` to `alloca` would be safe if there is enough space on the stack.
     * But the checker conditional branch is too expensive overhead. (Note that `malloc` only costs 1.)
     * Also, if there is a recursive function that calls `malloc`(e.x., `prime`), then it should also be very expensive.
   * Therefore, we decided that this conversion should be done only if
     * The target function is `main`. (Not recursively called)
     * The `malloc` is not on any loops.
       * To prevent the overhead became multiplied.
   * I noticed that dynamic `alloca` is not supported by the interpreter. But in .s file, it can be implemented by changing %sp value.
     * This is already done by the last sprint; Backend Renovation by Jiyong.
     * I will use `alloca_bytes` which is handled by the backend.
  * Since checking if `%sp` is safe is very important, and should be precise, I will use `define i64 @__stack_pointer__` that will be handled by the backend.
     * In this sprint, it will return 10240. (rough value)
     * It should not be inlined. I will add a metadata that prevent it.
     * The precise implementation will be done in the wrap-up sprint, to avoid the dependency issue.

3. Pseudo-Code Algorithm
   ```pseudocode
   Malloc To Alloca
   F : "main" function
   %stack_usage ← call i64 @__stack_pointer__(); calculate %sp
   For BB in F
     If BB is in loop
       Continue
     End If
     For I in BB
       If I is `malloc(i64 %a)`
         %lookforward_stack_usage = %stack_usage - %a
         if %lookforward_stack_usage < STACK_DANGEROUS_BOUND
           DO NOT CONVERT
         Else
           Convert it as `alloca_bytes(i64 %a)`
           %stack_usage = %lookforward_stack_usage
         End If
       End If
     End For
   End For
   ```

4. Sample IR/Assembly Codes
   ```assembly
   ;Example.1
   ;General Optimization Case
   ;In the entry block of the main function
   ;Before
   entry:
     %a = call i8* @malloc(i64 1024)
     ...

   ;After
   entry:
     %stack_usage = call i64 @stack_pointer()
     %stack_usage.lookforward = sub i64 %stack_usage, 1024
     %cmp = icmp ult i64 %stack_usage.lookforward, STACK_DANGEROUS_BOUND
     br i1 %cmp, label %do.malloc, label %do.alloca_bytes
   do.malloc:
     %b = call i8* @malloc(1024)
     br label %entry.divided
   do.alloca_bytes:
     %c = call i8* @alloca_bytes(1024) ; is handled by the backend in SP2
     br label %entry.divided
   entry.divided:
     %a = phi i8* [ %b, label %do.malloc ], [ %c, label %do.alloca_bytes ]
     %stack_usage.next = phi i64 [ %stack_usage, label %do.malloc ], [ %stack_usage.lookforward, label %do.alloca_bytes ]
     ...
   ```

   ```assembly
   ;Example.2
   ;DO NOT Optimize in the loop
   ;In the entry block of the main function
   entry:
     br label %loop
   loop:
     %a = call i8* @malloc(16)
     ...
     br i1 %cmp, label %loop, label %exit
   exit:
     ...
   ;This one should not be optimized
   ;since the cost overhead is multiplied when it is in the loop
   ```

   ```assembly
   ;Example.3
   ;DO NOT Optimize outside the main function
   ;In the function linked_list
   entry:
     %a = call i8* @malloc(16)
     store i8 1, %a
     %b = bitcast i8* %a to i8**
     %c = getelementptr inbounds i8*, i8** %b, i64 1
     %d = call i8* linked_list(..)
     store i8* %d, i8** %c, align 8
   ;This one should not be optimized
   ;Since the recursive call could increase too much overhead
   ```



#### Adding Reset Function

1. Outline

   * Class name: Backend2
   * Adding a reset function doesn't have any effect on the other part of code. So this part can be done at any moment. Because instructions change while passing through other passes, Reset function must be inserted as last as possible. So this backend2 will be applied after backend1, which was the last last pass before the assembly emitter. After backend1 throws out depromoted module, this backend2 will insert a rest function.
   * Reset function must be inserted between heap access and stack access, which can be determined with blockTypeCheck function.


2. Restriction

   * This pass should be applied right before assembly emitter.

3. Pseudo Code

   ```assembly
   pointerLoc = STACK
   for inst in BasicBlock
   	if blockType(inst)!=pointerLoc
   		insert reset_{blockType(inst)} before inst
   		pointerLoc = blockType(inst)
   	endif
   endfor
   ```

4. IR code

   ```assembly
   ;Before
   store i8 1, i8* %p1            ;HEAP
   store i8 1, i8* %s1            ;STACK
   
   ;After 
   store i8 1, i8* %p1            ;HEAP
   call void @reset_STACK()
   store i8 1, i8* %s1            ;STACK
   ```

   ```assembly
   ;Before
   store i8 1, i8* %s1            ;STACK
   store i8 1, i8* %p1            ;HEAP
   
   ;After 
   store i8 1, i8* %s1            ;STACK
   call void @reset_HEAP()
   store i8 1, i8* %p1            ;HEAP
   ```

   ```assembly
   ;Before
   store i8 1, i8* %s1            ;STACK
   add i8 %a, %b                  ;UNKNOWN
   store i8 1, i8* %p1            ;HEAP
   
   
   ;After 
   store i8 1, i8* %s1            ;STACK
   add i8 %a, %b                  ;UNKNOWN
   call void @reset_HEAP()
   store i8 1, i8* %p1            ;HEAP
   ```



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


