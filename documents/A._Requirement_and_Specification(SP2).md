# Requirement and Specification

*This document is written before the sprint 2.*

## Optimizations to Implement
*Codes to implement in Sprint 2.*

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
   
3. Pseudo-Code Algorithm

   ```pseudocode
   ; Base Idea
   For Inst in Block
      NxtInst ← Inst.getNextInstruction()

      If Dominance(NxtInst, Inst) is false
         If swapping NxtInst and Inst is good
            swap(NxtInst, Inst)
         EndIf
      EndIf
   EndFor

   ; Optimization 1.
   If Inst is Heap access
      swap(Inst, PrvInst)
   EndIf

   If Inst is Stack access
      swap(Inst, NxtInst)
   EndIf

   ;Optimization 2.
   bef=cost()
   swap(Inst, NxtInst)
   aft=cost()
   If aft>bef
      swap(Inst, NxtInst)
   EndIf

   ```

5. Example IR Codes

   * ```assembly
     ;Example.1 Simple case
     
     ;Before
     define void @main() {
       %ptr = call i8* @malloc(i64 %size)
       %h1 = getelementptr inbounds i8, i8* %ptr, i64 0
       %h2 = getelementptr inbounds i8, i8* %ptr, i64 4
       %s1 = alloca i8, align 2
       %s2 = alloca i8, align 2

       %x = load i8, i8* %h1, align 1
       %y = load i8, i8* %s1, align 1
       %z = load i8, i8* %h2, align 1
       %w = load i8, i8* %s2, align 1
     }
     ```

     ```assembly
     ;Example.2 Complicate case
     ;Before
     define void @main() {
       ; %hi = heap pointer
       ; %pi = stack pointer

       %x.1 = load i8, i8* %h1, align 1
       save i8 1, i8* %s1, align 1
       %x.2 = load i8, i8* %h2, align 1
       %x.3 = load i8, i8* %s1, align 1
       save i8 1, i8* %h2, align 1
       %x.4 = load i8, i8* %s1, align 1
       save i8 1, i8* %h3, align 1
       %x.5 = load i8, i8* %s2, align 1
       %x.6 = load i8, i8* %h2, align 1
       %x.7 = load i8, i8* %s3, align 1
       save i8 1, i8* %h1, align 1
       %x.8 = load i8, i8* %s2, align 1
     }

     ;After
     define void @main() {
       ; %hi = heap pointer
       ; %pi = stack pointer

       %x.1 = load i8, i8* %h1, align 1
       save i8 1, i8* %h1, align 1
       %x.2 = load i8, i8* %h2, align 1
       save i8 1, i8* %h2, align 1
       %x.6 = load i8, i8* %h2, align 1
       save i8 1, i8* %h3, align 1

       save i8 1, i8* %s1, align 1
       %x.3 = load i8, i8* %s1, align 1
       %x.4 = load i8, i8* %s1, align 1
       %x.5 = load i8, i8* %s2, align 1
       %x.8 = load i8, i8* %s2, align 1
       %x.7 = load i8, i8* %s3, align 1
     }
     ```
     
     ```assembly
      ;Example.3 Dominance is important case
     
     define void @main() {
       ; %hi = heap pointer
       ; %pi = stack pointer

       %x = load i8, i8* %h1, align 1
       %y = load i8, i8* %s2, align 1
       %z = add i8, %x, %y
       store i8 %z, i8* %h1, align 1
     }
     
     ; heap->stack->heap but can’t be optimized
     ```



#### Reducing Memory Access

1. Outline

   * Class name: ReduceMemAcc
   * Accessing the heap(4) is more expensive than the stack(2).
   * The cost for accessing memory does not depend on the bits size of the structure.
   * Therefore we can reduce the cost of memory access by packing and load/store with buffering, and by changing as many malloc as to alloca.

2. Restriction

   * This pass seems to be more efficient when it is applied after 'Memory Access Reordering' and 'Loop Unrolling' because they might increase the number of contiguous packing candidates.
   * Also, the replacement of malloc to alloca is only valid when the given malloc instruction is guaranteed never to be used out of the callee function.
   * I noticed that alloca is only available for maximal 64 bytes in LLVM. But in .s file, it is implemented by changing %sp value.
     * I will make a declaration @alloca_byte to replace malloc.
     * This declaration will be efficiently handled by the backend.

3. Pseudo-Code Algorithm

   ```pseudocode
   For Function in Module
       ; Replacement of malloc -> alloca
       For every malloc Instruction I in Function:
           If there is always free(I) Instruction among every path to ret:
               replace I ← alloca
               erase every free(I) from the Function
           EndIf
           If there is no domination from I to every ret Instruction:
               If there is no domination from I to every Instruction that updating pointer Arguments:
                   replace I ← alloca
                   erase every free(I) from the Function
               EndIf
           EndIf
       EndFor

       ; Contiguous char read buffer
       For every contiguous heap load Instructions (I1, I2, ... , IN) in Function:
           If (I1, I2, ... , IN) can be packed in one of [i8, i32, i64]:
               x1.parse = urem i32 %merge, 2^sizeof(%x1)
               merge.1 ← udiv %merge, 2^sizeof(%x1)
               x2.parse = urem i32 %merge, 2^sizeof(%x2)
               merge.2 ← udiv %merge.1, 2^sizeof(%x2)
               ...
               %x1 = trunc sizeof(%merge) %x1.parse to sizeof(%x1)
               %x2 = trunc sizeof(%merge) %x1.parse to sizeof(%x2)
               ...
	         load %merge.N on I1.loadaddr
           EndIf
       EndFor

       For every contiguous heap store Instructions (I1, I2, ... , IN) in Function:
           If (I1, I2, ... , IN) can be packed in one of [i8, i32, i64]:
               %x1.zext = zext sizeof(%x1) %x1 to sizeof(%x)
               %x2.zext = zext sizeof(%x2) %x2 to sizeof(%x)
               ...
               %merge.1 = mul sizeof(%merge) %x1.zext, sizeof(%x2)
               %merge.2 = xor sizeof(%merge) %merge.1, %x2.zext
               %merge.3 = mul sizeof(%merge) %x2.zext, sizeof(%x2)
               %merge.4 = xor sizeof(%merge) %merge.3, %x3.zext
               ...
    	         store %merge.N on I1.storeaddr
           EndIf
       EndFor
   EndFor
   ```

4. Example IR Codes

   * ```assembly
     ;Example.1 Replacing malloc to alloca
     
     ;Before
     define i8 @foo(i64 %size) {
       %ptr = call i8* @malloc(i64 %size)
       %p0 = getelementptr inbounds i8, i8* %ptr, i64 0
       %p1 = getelementptr inbounds i8, i8* %ptr, i64 4
       %p2 = getelementptr inbounds i8, i8* %ptr, i64 7

       store i8 1, i8* %p0, align 0
       store i8 1, i8* %p1, align 0
       store i8 1, i8* %p2, align 0
       %x = load i8, i8* %p2, align 1
       call void @free(i8* %ptr)
       ret i8 %x
     }

     ;After
     define i8 @foo(i64 %size) {
       %ptr = call i8* @alloca_byte(i64 %size) ; will be handled by backend
       %p0 = getelementptr inbounds i8, i8* %ptr, i64 0
       %p1 = getelementptr inbounds i8, i8* %ptr, i64 4
       %p2 = getelementptr inbounds i8, i8* %ptr, i64 7

       store i8 1, i8* %x, align 0
       store i8 1, i8* %x, align 0
       store i8 1, i8* %x, align 0
       %x = load i8, i8* %p2, align 1
       ret i8 %x
     }
     ```

   * ```assembly
     ;Example.2 Must not be optimized!
 
     define void @foo(i64 %size, i8** %a) {
       %ptr = call i8* @malloc(i64 %size)
       store i8* %ptr, i8** %a, align 8 ; used for function argument's ptr
       ret void
     }
     ```

   * ```assembly
     ;Example.3 Char read buffer (Packing)
     
     ;Before
     define void @foo(i64 %size, i8 %x, i8 %y, i8 %z, i8 %w) {
       %ptr = call i8* @malloc(i64 %size)
       %p0 = getelementptr inbounds i8, i8* %ptr, i64 0
       %p1 = getelementptr inbounds i8, i8* %ptr, i64 1
       %p2 = getelementptr inbounds i8, i8* %ptr, i64 2
       %p3 = getelementptr inbounds i8, i8* %ptr, i64 3

       store i8 %x, i8* %p0, align 0
       store i8 %y, i8* %p0, align 0
       store i8 %z, i8* %p0, align 0
       store i8 %w, i8* %p0, align 0
       ret void
     }

     ;After
     define void @foo(i64 %size, i8 %x, i8 %y, i8 %z, i8 %w) {
       %ptr = call i8* @malloc(i64 %size)
       %ptr.pack = bitcast i8* %ptr to i32*
       %p0 = getelementptr inbounds i32, i32* %ptr.pack, i64 0
       
       %x.32 = zext i8 %x to i32
       %y.32 = zext i8 %y to i32
       %z.32 = zext i8 %z to i32
       %w.32 = zext i8 %w to i32
     
       %merge.1 = mul i32 %x.32, 256
       %merge.2 = xor i32 %merge.1, %y.32
       %merge.3 = mul i32 %merge.2, 256
       %merge.4 = xor i32 %merge.3, %z.32
       %merge.5 = mul i32 %merge.4, 256
       %merge.6 = xor i32 %merge.5, %w.32

       store i32 %merge.6, i32* %ptr.pack, align 0
       ret void
     }
     ```



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