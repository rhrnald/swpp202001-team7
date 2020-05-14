# Planning

## Big Picture

#### Whole Plan 

First of all, we can use the existing well-made LLVM optimization passes without additional modification, only those who are compatible with our project. We are going to make some test codes, and decide which passes would bring a meaningful cost reduction. Following optimizations may be used - the numbering is from the github optList.
*  6. Malloc -> alloca conversion
*  8. Tail call elimination
*  9. Inlining
*  10. Lowering Allocas to IR registers
*  12. Loop Invariant Code Motion
*  13. Branch-related optimizations including br -> switch
*  14. Constant folding, removing identical instructions
*  16. Dead argument elimination
*  17. Loop interchange



#### Sprint 1 Plan

We are planning to complete very fundamental optimizations on the given weird hardware specification:
*  The cost for a function call is only proportional to the number of passing arguments, not to their sizes.
*  Finally, the costs for integer operations are unusual; multiplication & division(remainder) are cheaper than bitwise operations, and addition & subtraction are much more expensive.

Argument packing and arithmetic conversion are necessary and expected to be very efficient throughout the project. This will be what we are going to do among the sprint 1.

During the sprint, we will make observations about behaviors of the compiler; How it copes with ‘zext’ operators(if it produces any costly jobs or not). How it manages rN registers effectively and does any further optimizations related to the spare registers. For example in the case of using %sp register, and so on. From these experiences, we expect to see more possibilities of further optimizations.



#### Sprint 2 Plan

In our project, it is important to consider the order of memory accesses since the cost of store or load depends on how far the accessing address is from the previous one. We will try to reorder the memory accesses to reduce the cost and exploit the reset instruction by inserting it between a heap access and a stack access.

Also, we are going to optimize to reduce the memory access count. The cost for memory access operation is only proportional to the number of operations, not the size of each target block in our hardware. Therefore we plan to make buffered-read optimization with packing data, using the similar code with the argument packing implemented in the first sprint.

In addition, we are going to analyze and design optimizations for register allocation. It may give intuition for further possible other optimizations or improvements.

Also we can resolve some problems that occurred during Sprint 1 if they exist. 



#### Sprint 3 Plan

We are going to make optimizations on register allocation by combining the observations about the last two sprints. We expect to make a precise analysis of register usages and make some optimizations related to them.

Also, if we have time for more implementation, we can analyze loops.

We are going to check dependence relations among all passes and find the appropriate order. For instance, the arithmetic optimization for the weird hardware should be applied at the end. The analysis and implementation of register allocation may help this process.

As this is the final sprint, we plan to make massive amount of test codes since the consistency is the most important thing to check. After verifying the soundness of every optimization, we will attend the final competition.





## Sprint 1

#### Outline

Complete very fundamental optimizations on the given weird hardware specification. Our plan on LLVM optimization is as follow:

*  Packing registers. (PackRegister)
   - In this optimization, the small size registers will be packed into a single i64 register.
   - This optimization will be used for reducing the count of memory access operations and function argument passing compression.
   - It should be carefully applied since the optimization overhead cost can be more expensive. Therefore, the expected cost depreciation should be calculated precisely.

*  Arithmetic optimization. (WeirdArithmetic)
   - Use the weird hardware specification on the integer arithmetics.
   - Cost hierarchy:
     - Multiplication, Division and Remainder(0.6)
     - Bitwise Operations(0.8)
     - Addition and Subtraction(1.2)
   - Therefore, we should not fully rely on the ‘instcombine’ prebuilt pass on LLVM. Also, any LLVM prebuilt optimizations might produce codes that avoid ordinally-heavy operators(division and remainder), so we need to fix them.
   - Operator conversions to cheaper one should be applied after all optimizations.

​    

#### Individual Plan
Woosung Song
*  Implement PackRegisters optimization pass, and observe compiler behaviors related to it.

Jiyong Kang
*  Implement WeirdArithmetic optimization pass, and design another optimization pass for Reordering Memory Accesses.

Chaewon Kim
*  Load pass implemented by LLVM.
*  Make test codes about the optimizations.





## Sprint 2

#### Outline

Make optimizations relate to memory access. Also, make observations about the register allocation for the next sprint. Our plan on the sprint 2 is as follows.

* Reordering memory accesses
  * We will separate heap and stack access as much as possible remaining consistency.
    * Note that the cost of memory access is highly-related to the locality issues.
    * When it changes from heap to stack, then use ‘reset’ instruction properly to reduce the cost.
    * It will be better to minimize the number of reset calls.
  * Try to sort memory access indices as sequential as possible.
* Packing registers on memory access
  * Very similar to Packing register on the sprint 1.
  * The multiple smaller elements(i1, i8, …) can be fetched simultaneously.
  * Load and store them if any sequential load and store instructions are detected.
    * We expect to use it with loop unrolling pre-built optimization.(pass unroll)
* Observing the register allocation behavior and make register usage prediction
  * Observe the register allocation method to make a better policy.
  * Make a worst case number of rN register usage prediction module with much experience. We don’t expect it will be very precise, but the worst case would be predictable.
  * Using this prediction module, we will make some optimization ideas.
    * How to make less number of register allocation?
    * What other things can we do with the spare registers?



#### Individual Plan

Woosung Song

* Implement packing registers on memory access, continuing the process on the sprint 1(packing registers on function arguments).

Jiyong Kang

* Observe the register allocation behavior and design better algorithms for register allocation with register usage prediction.

Chaewon Kim

* Implement reordering memory access.





## Sprint 3

#### Outline

We will work on the register allocation optimization and probably a few other optimizations followed by a loop analysis. As this is the final sprint, we should wrap up the whole work we have done as well. Following are the related optimizations that we are interested in during this sprint:

* Register allocation
  * In this optimization, the whole register planning work will be done. Although the skeleton compiler does the basic register allocation, we are going to improve it. A sophisticated register allocation will enhance other optimizations as well.
* Rewriting loop counter to use cheaper operation
  * Since the hardware spec is weird with respect to arithmetic operations, loop control might be optimized in another way.
* Loop Invariant Code Motion
  * We may analyze the LICMPass, and see how we can apply this pass in a smarter way.
* Final preparation
  * Make a massive amount of test data to check the consistency of our optimizations.
    * Also, this data can be used for evaluating a benchmark of optimization.
  * Determine the optimal order of pass, which is the best on the benchmark. Consider the dependency among the passes carefully.



#### Individual Plan

Woosung Song

* Make some optimizations related to the loop counter. Also, observe how the loop-related prebuilt passes work, to determine the dependency.

Jiyong Kang

* Implement the register allocation optimization.

Chaewon Kim

* Merge and wrap up all the implementations done on 3 sprints for the final test. Optimize order for pass call, and make sure our passes and LLVM’s passes don’t collide.



#### Common Plan

Make a massive amount of sample test codes with general or corner cases. Use them as debugging the optimizations made by beforehand sprints.