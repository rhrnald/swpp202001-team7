# Requirement and Specification

*This document is written before the sprint 1.*

## Apply optimization provided by LLVM

Passes to use which LLVM provides - the numbering is from the github optList.

* 6. Malloc -> alloca conversion (GlobalOptPass)
* 8. Tail call elimination (TailCallElimPass)
* 9. Inlining (InlinerPass)
* 11. Loop unrolling
* 12. Loop Invariant Code Motion
* 13. Branch-related optimizations including br -> switch (SimplifyCFGPass)
* 14. Constant folding, removing identical instructions (GVNPass)
* 16. Dead argument elimination (DeadArgumentEliminationPass)
* 17. Loop interchange (LoopInterchange)



## Optimization to Implement
*Codes to implement in Sprint 1.*

#### Packing Registers
1. Outline
   - Class name: PackRegisters
   - Function call cost 2 * (1 + arg #) is independent to number of bits in arguments.
   - Can reduce cost of function call by compressing several small arguments in one big arguments. Using mul, div, rem which have low cost will be efficient.
   
2. Restriction
   - (use in function call) Embedding more than 2 arguments into a single 64bit word will have benefit.
     - Cost of encoding and decoding must be cheaper than argument passing in function call.
     - It costs 1.8 + 2.6n for encoding n arguments, passing them through a function call and decoding them back.
       - Cost for encoding n arguments: 0.6(n-1) + 0.8n = -0.6 + 1.4n
         - Cost for merging additional argument 0.6(mul) + 0.8(xor)
       - Cost for argument passing : 2
       - Cost for decoding n arguments:1.6 + 1.2(n-1) = 0.4 + 1.2n
         - register load: 1(read arg) + 0.6(mul by 1)
         - decode one: 0.6(rem) + 0.6(div)
         - after this no additional cost occurs by reading arg
     - Cost for original function call : 2n+k(k=number of argument read)
       - After DeadArgElim, k>=n, so cost >=3n.
   
3. Functions in Class
   - ArgumentsSortBySize()
     - Sort every function’s arguments by their bit sizes so that they can be greedily packed.
   - PackCandidates()
     - Find all candidates of function arguments that are cheaper when they are optimized.
   - Pack()
     - Wrap multiple function arguments into a single(but long-lengthen) argument. Use unsigned integer multiplication, xor and division(remainder operator) to encode & decode.
   
4. Pseudo-Code Algorithm

   ```pseudocode
   For Function in Module
   	; Arguments will be sorted by their bit sizes.
   	Function.ArgumentsSortBySize()
   	
   	; [(%x1, %x2, %x3), (%y1, %y2, %y3), ...] ← PackCandidates()
   	For (%x1, %x2, ...) in PackCandidates()
   		%merge ← new argument(will pack %x1, %x2, ...)
   		Replace (%x1, %x2, ...) ← %merge in the Argument of Function
   		
   		Create New Instructions [
               %x1.parse = urem i32 %merge, 2^sizeof(%x1)
               %merge.1 ← sdiv %merge, 2^sizeof(%x1)
               %x2.parse = urem i32 %merge, 2^sizeof(%x2)
               %merge.2 ← sdiv %merge.1, 2^sizeof(%x2)
               ...
               %x1 = trunc sizeof(%merge) %x1.parse to sizeof(%x1)
               %x2 = trunc sizeof(%merge) %x1.parse to sizeof(%x2)
               ...
       	] in Function's Head
       	
       	For each 'call' Inst of Function
       		%merge ← new register(will pack %x1, %x2, ...)
   			Replace (%x1, %x2, ...) ← %merge in the Argument of Inst
   			
   			Create New Instructions [
                   %x1.zext = zext sizeof(%x1) %x1 to sizeof(%x)
                   %x2.zext = zext sizeof(%x2) %x2 to sizeof(%x)
                   ...
                   %merge.1 = mul sizeof(%merge) %x1.zext, sizeof(%x2)
                   %merge.2 = xor sizeof(%merge) %merge.1, %x2.zext
                   %merge.3 = mul sizeof(%merge) %x2.zext, sizeof(%x2)
                   %merge.4 = xor sizeof(%merge) %merge.3, %x3.zext
                   ...
   			] before Inst
       	EndFor
   	EndFor
   EndFor
   ```

5. Example IR Codes

   * ```assembly
     ;Example.1 General Optimization
     
     ;Before
     define void @main() {
     	%x = i8…
     	%y = i8 …
     	%z = i8 …
     	%w = i8 …
     
     	call void @f(i8 %x, i8 %y, i8 %z, i8 %w)
     }
     
     define void @f(i8 %a, i8 %b, i8 %c, i8 %d) {
     	...
     }
     
     
     ;After
     define void @main() {
     	%x = i8…
     	%y = i8 …
     	%z = i8 …
     	%w = i8 …
     
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
     
     	call void @f(i32 %merge.6)
     }
     
     define void @f(i32 %merge) {
     	%d.32 = urem i32 %merge, 256
     	%merge.1 = sdiv i32 %merge, 256
     	%c.32 = urem i32 %merge.1, 256
     	%merge.2 = sdiv i32 %merge.1, 256
     	%b.32 = urem i32 %merge.2, 256
     	%merge.3 = sdiv i32 %merge.2, 256
     	%a.32 = urem i32 %merge, 256
     
     	%a = trunc i32 %a.32 to i8
     	%b = trunc i32 %b.32 to i8
     	%c = trunc i32 %c.32 to i8
     	%d = trunc i32 %d.32 to i8
     	...
     }
     ```

   * ```assembly
     ;Example.2 Sort is important
     
     ;Can't be packed
     define void @main() {
     	call void @f(i8 %x, i8 %y, i64 %X, i8 %z, i8 %w)
     }
     
     define void @f(i8 %a, i8 %b, i64 %X, i8 %c, i8 %d) {
     	...
     }
     
     ;So, first reorder argument
     define void @main() {
     	call void @f(i8 %x, i8 %y, i8 %z, i8 %w, i64 %X)
     }
     
     define void @f(i8 %a, i8 %b, i8 %c, i8 %d, i64 %X) {
     	...
     }
     
     ;And then pack
     define void @main() {
     	call void @f(i32 %merge, i64 %X)
     }
     
     define void @f(i32 %merge, i64 %X) {
     	...
     }
     ```

   * ```assembly
     ;Example.3 Optimization is redundant.
     
     ;Before
     define void @main() {
     	call void @f(i8 %x, i8 %y)
     }
     
     define void @f(i8 %a, i8 %b) {
     	...
     }
     
     
     ;After - Cost Increases! Don’t pack!
     define void @main() {
     	…
     	%x.32 = zext i8 %x to i16
     	%y.32 = zext i8 %y to i16
     
     	%merge.1 = mul i16 %x.32, 256
     	%merge.2 = xor i16 %merge.1, %y.32
     	
     	call void @f(i16 %merge.2)
     	...
     }
     
     define void @f(i16 %merge) {
     	%b.16 = urem i16 %merge, 256
     	%merge.1 = sdiv i16 %merge, 256
     	%a.16 = urem i16 %merge.1, 256
     
     	%a = trunc i16 %x to i8
     	%b = trunc i16 %y to i8
     	...
     }
     ```

 

#### Arithmetic optimizations

1. Outline

   * Class name: WeirdArithmetic
   * Because of the weird cost of arithmetic instructions, some instructions still can be optimized after the existing LLVM arithmetic optimizations. Following are the specific cases. * indicates that the operands of the marked instruction may be swapped.
     * AddToMul: add(cost 1.2) => mul(cost 0.6)
       add iN %x, %x => mul iN %x, 2
     * NegWithMul: sub(cost 1.2) => mul(cost 0.6)
       sub iN 0, %x => mul iN %x, -1
     * AndToRem: and(cost 0.8) => urem(cost 0.6)
       *and iN %x, 2^n-1 => urem iN %x, 2^n

2. Restriction

   * This pass should be applied after other passes since this optimization is unusual, which might disturb other optimizations.

3. Pseudo-Code Algorithm

   ```pseudocode
   For Inst in Function
       If Inst match (add iN %x, %x)
           Inst ← mul iN %x, 2
       ElseIf Inst match (sub iN 0, %x)
           Inst ← mul iN %x, -1
       ElseIf Inst match (and iN %x, 2^n-1) or match (and iN 2^n-1, %x)
           Inst ← urem iN %x, 2^n
       EndIf
   EndFor
   ```

4. Example IR Codes

   * ```assembly
     ;Example.1 Addition to Multiplication
     
     ;Before
     %y = add i32 %x, %x
     
     ;After
     %y = mul i32 %x, 2
     ```

   * ```assembly
     ;Example.2 Subraction from zero to Multiplication
     
     ;Before
     %y = sub i8 0, %x
     
     ;After
     %y = mul i8 %x, -1
     ```

   * ```assembly
     ;Example.3 Special case of bitwise operator to Remainder
     
     ;Before
     %y = and i64 %x, 7
     
     ;After
     %y = urem i64 %x, 8
     ```

