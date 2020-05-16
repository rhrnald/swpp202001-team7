# Progress Report for Sprint 1

### Overall

During the Sprint 1, we spent a lot of time getting used to GitHub and the overall project system. We made some mistakes making Pull Requests but in the end, everything went fine. The two optimization passes that we wanted to implement are now working well, and the project structure became clearer. The testing system is also established, hence now we can make a new test and run it easily. It can compare the cost and check the validity of outputs.



### About Project

#### Project Hierarchy
```
swpp202001-team7
├── documents
│   └── (documentation files)
├── interpreter (From TA's repository)
├── src
│   ├── core
│   │   ├── AssemblyEmitter.cpp
│   │   ├── Backend.cpp
│   │   ├── Backend.h
│   │   └── main.cpp
│   ├── passes
│   │   ├── CheckConstExpr.cpp
│   │   ├── CheckConstExpr.h
│   │   ├── PackRegisters.cpp
│   │   ├── PackRegisters.h
│   │   ├── RemoveUnsupportedOps.cpp
│   │   ├── RemoveUnsupportedOps.h
│   │   ├── WeirdArithmetic.cpp
│   │   ├── WeirdArithmetic.h
│   │   └── Wrapper.h
│   └── test
│       ├── AssemblyEmitter.cpp
│       ├── SimpleBackend.cpp
│       ├── SimpleBackend.h
│       ├── test_main.cpp
│       └── vanilla_main.cpp
├── workspace
│   ├── testcases
│   │   └── (testcase name)
│   │       ├── src
│   │       │   ├── (testcase name).c
│   │       │   ├── (testcase name).ll
│   │       │   └── (testcase name).s
│   │       └── test
│   │           └── inputX.txt
│   ├── Manual.md
│   ├── c-to-ll.sh
│   ├── checker.sh
│   ├── log_checker.py
│   ├── template.c
│   └── test-gen.sh
├── Makefile.template
├── README.md
├── configure.sh
└── llvm-10.0.json
```



#### About Development

Programs on this project are divided into the three parts.

  * Compiler(`src/core`)
    * This is for making the main compiler that uses optimization passes.
    * Also, there is a backend that translates IR code to Assembly.
  * Optimization(`src/passes`)
    * It contains every optimization created by ourselves.
    * Also, there are several passes from TA's repository.
  * Test(`src/test`)
    * It contains codes for testing.
    * It will be used to make the vanilla compiler to compare with.

To execute a c code, we need to turn it into a machine friendly language. It can be done with gcc compiler easily, but it's too easy that it's hard to expect good performance.

![alt text](resources/diagram.png "Diagram")

Our compiler will read the same c code to make better assembly code using LLVM optimization. It will first transfer c code into ll with llc in LLVM. Then it will apply optimization passes, and transfer to assembly language using the backend. To execute assembly and measure the cost, we need an interpreter, which is also included in our project.

Our test code will compare the outputs and costs between the optimized compiler and vanilla one. The vanilla compiler does not optimize anything. The test program will compare two outputs and interpreter's logs from each assembly code.



#### How to run project

* Build
  ```
  make #or make all
  ```
  ```make``` command will automatically build 3 executable programs inside ```bin``` directory: sf-compiler-team7, interpret, sf-compiler-test-team7, sf-compiler-vanilla.

* Test
  ```
  make test
  ```
  ```make test``` command will check if the compiler runs with no error with given test cases. It will also compare performance with the vanilla compiler.



#### How to execute individual programs.

* sf-compiler-team7 (./bin/)
  ```
  ./bin/sf-compiler-team7 <input.ll> -o <output.s> -d <output.ll>
  ```
  Our compiler compiles IR code(.ll) to assembly code(.s). It links `read` and `write` functions in the LLVM library, applies passes, and then translates to assembly code. "-o" flag specifies the name of the output assembly file. If it is not given, it will be set to default value "a.s". "-d" flag is optional. It specifies the name for output IR code. If it is given, it also prints IR code which the optimization passes are applied from the original IR code.

* checker.sh (./workspace/)
  ```
  ./workspace/checker.sh <testcase path(s)>
  ```
  This is a shell script which ```make test``` command calls. It checks every given testcase directory. There are `.c`, `.ll` and `.s` files on each src folder, which are the compilation results from the vanilla compiler. It first translates IR(`.ll`) code to assembly code using our compiler: sf-compiler-team7. It will check if the outputs of two assembly codes are the same values, and compare their costs.

* sf-compiler-test-team7 (./bin/)
  ```
  ./bin/sf-compiler-test-team7
  ```
  This is googletest. It currently checks nothing.

* test-gen.sh (./workspace/)
  ```
  ./workspace/test-gen.sh <testcase dir> [<llvm bin path>]
  ```
  This program generates `.ll` and `.s` files from `.c` using the vanilla compiler. After that, it becomes a valid testcase folder. If the llvm bin path is not passed, then it contruct a testcase structure at the given testcase dir using `./workspace/template.c`.



### Individual Accomplishments

#### Woosung Song

* Implemented PackRegisters optimization pass.
* Helped Chaewon to found the fundamental environment.
  * Made _Wrapper_ to apply our optimizations easily.
* Improved testing system.



#### Jiyong Kang

* Implemented WeirdArithmetic optimization pass.
  * Analyzed InstCombine pass, and modified the WeirdArithmetic pass slightly.
* Improved testing system.



#### Chaewon Kim

* Founded the fundamental development environment.
  * Established the Makefile system and directory structure.
* Applied InstCombine optimization pass.
* Improved testing system.



### Implementation of Optimization

#### PackRegisters

PackRegisters is for reducing the number of arguments in a function. It packs function arguments into a single one if it has any advantage on the cost. From our calculation, it is better to pack registers when more than or equal to 3 of them can be put into a single 64 bits word.

This packing method is safe because there is no linking on the test. To be safe, I only optimized functions that are defined in the given module. (e.x., It does not optimize malloc, which is a declaration.)

In the callee function, the merged argument is unpacked using repeated `urem` and `udiv` instructions. In the caller function, the candidate parameters are packed using repeated `mul` and `xor` instructions. To avoid syntax error in LLVM, these arguments are resized by `zext` and `trunc` instructions, which do not appear in .s file.

Also, this optimization sorts arguments in increasing order of bit sizes to maximize the packing candidates.
* E.x., i8, i32, i32, i8: cannot pack / i8, i8, i32, i32: can pack

Furthermore, it packs arguments into the minimal bit-sized one. 

* E.x., 4 of i8 are packed into i32, not i64

Because there was no easy way to change the function arguments in LLVM, we cloned every callee function and caller instruction. These clones reserved every attribute of the original ones.



#### WeirdArithmetic

WeirdArithmetic is a 'customized' set of arithmetic optimizations, which suits our unusual machine specification. For example, multiplications and divisions are cheaper than any other arithmetic operations. For such a weird machine, we have presented a weird arithmetic optimization pass.

Before applying this pass, the existing _InstCombine_ pass will be applied. Then we can consider much fewer cases. The following are the implemented optimizations.

1. `sub iN 0, %x` can be lowered to `mul iN %x, -1`. Since `sub` instruction costs 1.2 and `mul` 0.6, it halves in cost.

2. `and iN %x, C` or `and iN C, %x` can be lowered to `urem %x, C+1` when `C` is `2^n-1` for some `n`. However, there are some special cases that we can still optimize even if `C` does not meet the condition. For example, _InstCombine_ pass changes LSBs of `C` to zeros when `%x` is a `shl` instruction. In such a case, we can modify the LSBs of `C` which will have no effect because the same LSBs of `%x` are zeros. The current implementation considers the case that `%x` is a `shl` instruction.

3. `shl iN %x, C` can be lowered to `mul iN %x, 2^C`, and `ashr iN %x, C` can be lowered to `udiv iN %x, 2^C`. The cost reduces by 0.2, from 0.8 to 0.6.

4. `and i1 %x, %y` can be lowered to `mul i1 %x, %y`. The cost also reduces by 0.2. This could be useful for `and` instructions among conditions.



### Test Results

#### PackRegisters

**PackRegisters did not show any improvement to cost because the given backend was too simple.** It didn't allocate any further registers, but just put every variable into the stack. Therefore the cost became more expensive after the optimization. However, since we have planned to upgrade the backend on the next two sprints, we expect that this optimization will become more efficient.

  * `four_i8_sum.c`

    ```c
    #include<stdint.h>
    
    int64_t read();
    void write(int64_t);
    
    int8_t sum_of(int8_t a, int8_t b, int8_t c, int8_t d) {
      return a + b + c + d;
    }
    
    int main() {
      int8_t a = (int8_t) read();
      int8_t b = (int8_t) read();
      int8_t c = (int8_t) read();
      int8_t d = (int8_t) read();
      write((unsigned int)sum_of(a, b, c, d));
      return 0;
    }
    
    ```

    * Optimization result

      The small size arguments `a`, `b`, `c`, `d` are packed into a single register `%merged` in the LLVM file. The converted code has passed the output diff test. Actually this test was for checking the correctness of the optimization.

      ```assembly
      ; Before
      ...
      ; Function Attrs: nounwind uwtable
      define dso_local signext i8 @sum_of(i8 signext %a, i8 signext %b, i8 signext %c, i8 signext %d) #0 {
      entry:
        %conv = sext i8 %a to i32
        %conv1 = sext i8 %b to i32
        %add = add nsw i32 %conv, %conv1
        %conv2 = sext i8 %c to i32
        %add3 = add nsw i32 %add, %conv2
        %conv4 = sext i8 %d to i32
        %add5 = add nsw i32 %add3, %conv4
        %conv6 = trunc i32 %add5 to i8
        ret i8 %conv6
      }
      
      ; Function Attrs: nounwind uwtable
      define dso_local i32 @main() #0 {
      entry:
        %call = call i64 (...) @read()
        %conv = trunc i64 %call to i8
        %call1 = call i64 (...) @read()
        %conv2 = trunc i64 %call1 to i8
        %call3 = call i64 (...) @read()
        %conv4 = trunc i64 %call3 to i8
        %call5 = call i64 (...) @read()
        %conv6 = trunc i64 %call5 to i8
        %call7 = call signext i8 @sum_of(i8 signext %conv, i8 signext %conv2, i8 signext %conv4, i8 signext %conv6)
        %conv8 = sext i8 %call7 to i32
        %conv9 = zext i32 %conv8 to i64
        call void @write(i64 %conv9)
        ret i32 0
      }
      ...
      
      ; After
      ...
      ; Function Attrs: nounwind uwtable
      define i8 @sum_of(i32 %merged) #0 {
      split_reg:
        %zext.a = urem i32 %merged, 256
        %merge = udiv i32 %merged, 256
        %zext.b = urem i32 %merge, 256
        %merge1 = udiv i32 %merge, 256
        %zext.c = urem i32 %merge1, 256
        %merge2 = udiv i32 %merge1, 256
        %trunc.a = trunc i32 %zext.a to i8
        %trunc.b = trunc i32 %zext.b to i8
        %trunc.c = trunc i32 %zext.c to i8
        %trunc.d = trunc i32 %merge2 to i8
        br label %entry
      
      entry:                                            ; preds = %split_reg
        %add = add i8 %trunc.a, %trunc.b
        %add3 = add i8 %add, %trunc.c
        %add5 = add i8 %add3, %trunc.d
        ret i8 %add5
      }
      
      ; Function Attrs: nounwind uwtable
      define i32 @main() #0 {
      entry:
        %call = call i64 (...) @read() #3
        %conv = trunc i64 %call to i8
        %call1 = call i64 (...) @read() #3
        %conv2 = trunc i64 %call1 to i8
        %call3 = call i64 (...) @read() #3
        %conv4 = trunc i64 %call3 to i8
        %call5 = call i64 (...) @read() #3
        %conv6 = trunc i64 %call5 to i8
        %zext.conv = zext i8 %conv to i32
        %zext.conv2 = zext i8 %conv2 to i32
        %zext.conv4 = zext i8 %conv4 to i32
        %zext.conv6 = zext i8 %conv6 to i32
        %merge = mul nuw i32 %zext.conv6, 256
        %merge1 = xor i32 %merge, %zext.conv4
        %merge2 = mul nuw i32 %merge1, 256
        %merge3 = xor i32 %merge2, %zext.conv2
        %merge4 = mul nuw i32 %merge3, 256
        %merge5 = xor i32 %merge4, %zext.conv
        %call76 = call i8 @sum_of(i32 %merge5)
        %conv8 = sext i8 %call76 to i64
        %conv9 = urem i64 %conv8, 4294967296
        call void @write(i64 %conv9) #3
        ret i32 0
      }
      ...
      ```

    * The cost(heap usage) changes from the test cases:

      * input1.txt: 117.1856(0) --> 179.2208(0)  +62.04(0)
      * input2.txt: 117.1856(0) --> 179.2208(0)  +62.04(0)
      * input3.txt: 117.1856(0) --> 179.2208(0)  +62.04(0)
        * This input contains an extremal case: `127 -127 127 -127`
      * input4.txt: 117.1856(0) --> 179.2208(0)  +62.04(0)

* `various_types_sum.c`

  ```c
  #include<stdint.h>
  
  int64_t read();
  void write(int64_t);
  
  int64_t sum_of(int8_t a, int32_t b, int32_t c, int8_t d, int8_t *e) {
    return a + b + c + d + ((int64_t) e);
  }
  
  int main() {
    int64_t l = read();
    while (l--) {
      int8_t a = (int8_t) read();
      int32_t b = (int32_t) read();
      int32_t c = (int32_t) read();
      int8_t d = (int8_t) read();
      int8_t *e = 0;
      write((unsigned int)sum_of(a, b, c, d, e));
    }
    return 0;
  }
  ```

  * Optimization result

    The small size arguments cannot be packed in the given order. So this pass sorts arguments in their sizes, and makes it possible to pack. In this test case, the arguments `%a`, `%d`, `%b` are packed into a single `%merged`.

    ```assembly
    ; Before
    ...
    ; Function Attrs: nounwind uwtable
    define dso_local i64 @sum_of(i8 signext %a, i32 %b, i32 %c, i8 signext %d, i8* %e) #0 {
    entry:
      %conv = sext i8 %a to i32
      %add = add nsw i32 %conv, %b
      %add1 = add nsw i32 %add, %c
      %conv2 = sext i8 %d to i32
      %add3 = add nsw i32 %add1, %conv2
      %conv4 = sext i32 %add3 to i64
      %tmp = ptrtoint i8* %e to i64
      %add5 = add nsw i64 %conv4, %tmp
      ret i64 %add5
    }
    
    ; Function Attrs: nounwind uwtable
    define dso_local i32 @main() #0 {
    entry:
      %call = call i64 (...) @read()
      br label %while.cond
    
    while.cond:                                       ; preds = %while.body, %entry
      %l.0 = phi i64 [ %call, %entry ], [ %dec, %while.body ]
      %dec = add nsw i64 %l.0, -1
      %tobool = icmp ne i64 %l.0, 0
      br i1 %tobool, label %while.body, label %while.end
    
    while.body:                                       ; preds = %while.cond
      %call1 = call i64 (...) @read()
      %conv = trunc i64 %call1 to i8
      %call2 = call i64 (...) @read()
      %conv3 = trunc i64 %call2 to i32
      %call4 = call i64 (...) @read()
      %conv5 = trunc i64 %call4 to i32
      %call6 = call i64 (...) @read()
      %conv7 = trunc i64 %call6 to i8
      %call8 = call i64 @sum_of(i8 signext %conv, i32 %conv3, i32 %conv5, i8 signext %conv7, i8* null)
      %conv9 = trunc i64 %call8 to i32
      %conv10 = zext i32 %conv9 to i64
      call void @write(i64 %conv10)
      br label %while.cond
    
    while.end:                                        ; preds = %while.cond
      ret i32 0
    }
    ...
    
    ; After
    ...
    ; Function Attrs: nounwind uwtable
    define i64 @sum_of(i64 %merged, i32 %c, i8* %e) #0 {
    split_reg:
      %zext.a = urem i64 %merged, 256
      %merge = udiv i64 %merged, 256
      %zext.d = urem i64 %merge, 256
      %merge1 = udiv i64 %merge, 256
      %trunc.a = trunc i64 %zext.a to i8
      %trunc.b = trunc i64 %merge1 to i32
      %trunc.d = trunc i64 %zext.d to i8
      br label %entry
    
    entry:                                            ; preds = %split_reg
      %conv = sext i8 %trunc.a to i32
      %add = add nsw i32 %conv, %trunc.b
      %add1 = add nsw i32 %add, %c
      %conv2 = sext i8 %trunc.d to i32
      %add3 = add nsw i32 %add1, %conv2
      %conv4 = sext i32 %add3 to i64
      %tmp = ptrtoint i8* %e to i64
      %add5 = add nsw i64 %conv4, %tmp
      ret i64 %add5
    }
    
    ; Function Attrs: nounwind uwtable
    define i32 @main() #0 {
    entry:
      %call = call i64 (...) @read() #3
      br label %while.cond
    
    while.cond:                                       ; preds = %while.body, %entry
      %l.0 = phi i64 [ %call, %entry ], [ %dec, %while.body ]
      %tobool = icmp eq i64 %l.0, 0
      br i1 %tobool, label %while.end, label %while.body
    
    while.body:                                       ; preds = %while.cond
      %dec = add nsw i64 %l.0, -1
      %call1 = call i64 (...) @read() #3
      %conv = trunc i64 %call1 to i8
      %call2 = call i64 (...) @read() #3
      %conv3 = trunc i64 %call2 to i32
      %call4 = call i64 (...) @read() #3
      %conv5 = trunc i64 %call4 to i32
      %call6 = call i64 (...) @read() #3
      %conv7 = trunc i64 %call6 to i8
      %zext.conv = zext i8 %conv to i64
      %zext.conv7 = zext i8 %conv7 to i64
      %zext.conv3 = zext i32 %conv3 to i64
      %merge = mul nuw i64 %zext.conv3, 256
      %merge1 = xor i64 %merge, %zext.conv7
      %merge2 = mul nuw i64 %merge1, 256
      %merge3 = xor i64 %merge2, %zext.conv
      %call84 = call i64 @sum_of(i64 %merge3, i32 %conv5, i8* null)
      %conv10 = and i64 %call84, 4294967295
      call void @write(i64 %conv10) #3
      br label %while.cond
    
    while.end:                                        ; preds = %while.cond
      ret i32 0
    }
    ...
    ```

  * The cost(heap usage) changes from the test cases:

    * input1.txt: 162.9136(0) --> 218.4112(0)  +55.5(0)
    * input2.txt: 1391.248(0) --> 1993.168(0)  +601.92(0)
    * input3.txt: 2756.064(0) --> 3965.12(0)   +1209.06(0)
    * input4.txt: 299.3952(0) --> 415.6064(0)  +116.21(0)
      * This input contains an extremal case: `2147483647 ... -2147483648`

* `six_i32_sum.c`

  PackRegisters is efficient only when the number of packing arguments is >= 3. Therefore, the code below should not pack any of them.

  ```c
  #include<stdint.h>
  
  int64_t read();
  void write(int64_t);
  
  int32_t sum_of(int32_t a, int32_t b, int32_t c, int32_t d, int32_t e, int32_t f) {
    return a - b + c - d + e - f;
  }
  
  int main() {
    int64_t l = read();
    while (l--) {
      int32_t a = (int32_t) read();
      int32_t b = (int32_t) read();
      int32_t c = (int32_t) read();
      int32_t d = (int32_t) read();
      int32_t e = (int32_t) read();
      int32_t f = (int32_t) read();
      write((unsigned int)sum_of(a, b, c, d, e, f));
    }
    return 0;
  }
  ```

  * Optimization result

    This LLVM file shows that this pass did not optimize this example. This is a valid choice.

    ```Assembly
    ; Before
    ...
    ; Function Attrs: nounwind uwtable
    define dso_local i32 @sum_of(i32 %a, i32 %b, i32 %c, i32 %d, i32 %e, i32 %f) #0 {
    entry:
      %sub = sub nsw i32 %a, %b
      %add = add nsw i32 %sub, %c
      %sub1 = sub nsw i32 %add, %d
      %add2 = add nsw i32 %sub1, %e
      %sub3 = sub nsw i32 %add2, %f
      ret i32 %sub3
    }
    
    ; Function Attrs: nounwind uwtable
    define dso_local i32 @main() #0 {
    entry:
      %call = call i64 (...) @read()
      br label %while.cond
    
    while.cond:                                       ; preds = %while.body, %entry
      %l.0 = phi i64 [ %call, %entry ], [ %dec, %while.body ]
      %dec = add nsw i64 %l.0, -1
      %tobool = icmp ne i64 %l.0, 0
      br i1 %tobool, label %while.body, label %while.end
    
    while.body:                                       ; preds = %while.cond
      %call1 = call i64 (...) @read()
      %conv = trunc i64 %call1 to i32
      %call2 = call i64 (...) @read()
      %conv3 = trunc i64 %call2 to i32
      %call4 = call i64 (...) @read()
      %conv5 = trunc i64 %call4 to i32
      %call6 = call i64 (...) @read()
      %conv7 = trunc i64 %call6 to i32
      %call8 = call i64 (...) @read()
      %conv9 = trunc i64 %call8 to i32
      %call10 = call i64 (...) @read()
      %conv11 = trunc i64 %call10 to i32
      %call12 = call i32 @sum_of(i32 %conv, i32 %conv3, i32 %conv5, i32 %conv7, i32 %conv9, i32 %conv11)
      %conv13 = zext i32 %call12 to i64
      call void @write(i64 %conv13)
      br label %while.cond
    
    while.end:                                        ; preds = %while.cond
      ret i32 0
    }
    ...
  
    ; After
  ...
    ; Function Attrs: nounwind uwtable
    define i32 @sum_of(i32 %a, i32 %b, i32 %c, i32 %d, i32 %e, i32 %f) #0 {
    entry:
      %sub = sub nsw i32 %a, %b
      %add = add nsw i32 %sub, %c
      %sub1 = sub nsw i32 %add, %d
      %add2 = add nsw i32 %sub1, %e
      %sub3 = sub nsw i32 %add2, %f
      ret i32 %sub3
    }
    
    ; Function Attrs: nounwind uwtable
    define i32 @main() #0 {
    entry:
      %call = call i64 (...) @read() #3
      br label %while.cond
    
    while.cond:                                       ; preds = %while.body, %entry
      %l.0 = phi i64 [ %call, %entry ], [ %dec, %while.body ]
      %tobool = icmp eq i64 %l.0, 0
      br i1 %tobool, label %while.end, label %while.body
    
    while.body:                                       ; preds = %while.cond
      %dec = add nsw i64 %l.0, -1
      %call1 = call i64 (...) @read() #3
      %conv = trunc i64 %call1 to i32
      %call2 = call i64 (...) @read() #3
      %conv3 = trunc i64 %call2 to i32
      %call4 = call i64 (...) @read() #3
      %conv5 = trunc i64 %call4 to i32
      %call6 = call i64 (...) @read() #3
      %conv7 = trunc i64 %call6 to i32
      %call8 = call i64 (...) @read() #3
      %conv9 = trunc i64 %call8 to i32
      %call10 = call i64 (...) @read() #3
      %conv11 = trunc i64 %call10 to i32
      %call121 = call i32 @sum_of(i32 %conv, i32 %conv3, i32 %conv5, i32 %conv7, i32 %conv9, i32 %conv11)
      %conv13 = zext i32 %call121 to i64
      call void @write(i64 %conv13) #3
      br label %while.cond
    
    while.end:                                        ; preds = %while.cond
      ret i32 0
    }
    ...
    ```
  
  * The cost(heap usage) changes from the test cases:
  
    * 160.952(0)	--> 155.736(0)   -5.22(0)
    * 1371.632(0)	--> 1366.416(0)  -5.22(0)
    * 295.472(0)	--> 290.256(0)   -5.22(0)



#### WeirdArithmetic

* `expnear.ll`

  ```assembly
  define i32 @main() {
  entry:
    %call = call i64 (...) @read()
    br label %while.cond
  
  while.cond:                                       ; preds = %while.body, %entry
    %i.0 = phi i64 [ 1, %entry ], [ %add, %while.body ]
    %cmp = icmp ult i64 %i.0, %call
    %conv = zext i1 %cmp to i32
    %sub = sub i64 0, %i.0
    %sub1 = sub i64 0, %call
    %cmp2 = icmp ugt i64 %sub, %sub1
    %conv3 = zext i1 %cmp2 to i32
    %and = and i32 %conv, %conv3
    %tobool = icmp ne i32 %and, 0
    br i1 %tobool, label %while.body, label %while.end
  
  while.body:                                       ; preds = %while.cond
    %add = add i64 %i.0, %i.0
    br label %while.cond
  
  while.end:                                        ; preds = %while.cond
    call void @write(i64 %i.0)
    ret i32 0
  }
  ```

  This basically finds the nearest power-of-2-number to the input, which is greater than or equal to the input. To exploit the WeirdArithmetic optimization pass, instead of the condition `r < i` only, `r < i && -r > -i` is used.

  * Optimization result

    ```assembly
    ...
    ; Function Attrs: nounwind ssp uwtable
    define i32 @main() #0 {
    entry:
      %call = call i64 (...) @read() #3
      br label %while.cond
    
    while.cond:                                       ; preds = %while.body, %entry
      %i.0 = phi i64 [ 1, %entry ], [ %add, %while.body ]
      %cmp = icmp ult i64 %i.0, %call
      %sub = mul i64 %i.0, -1
      %sub1 = mul i64 %call, -1
      %cmp2 = icmp ugt i64 %sub, %sub1
      %and1 = mul i1 %cmp, %cmp2
      br i1 %and1, label %while.body, label %while.end
    
    while.body:                                       ; preds = %while.cond
      %add = mul i64 %i.0, 2
      br label %while.cond
    
    while.end:                                        ; preds = %while.cond
      call void @write(i64 %i.0) #3
      ret i32 0
    }
    ...
    ```

  With this code, test results are following:

  * 508.8352(0)  --> 374.9936(0)  
  * 699.6688(0)  --> 514.6544(0)
  * 1335.7808(0) --> 980.1904(0)
  * 2608.0048(0) --> 1911.2624(0)
  * 3880.2288(0) --> 2842.3344(0)

  Where inputs are 100, 1000, 1000000, 1000000000000, 1000000000000000000, respectively. Considering the excessive load/store cost due to the poor RA, this cost reduction seems remarkable.

* `dectohex.c`

  ```c
  int main() {
    int N = read();
    for (int i = 0; i < N; ++i) {
      unsigned int data = read();
      for (int j = 0; j < 8; ++j) {
        write(data & 15);
        data >>= 4;
      }
    }
    return 0;
  }
  ```

  C code is presented for the readability. The compiled .ll code was used for the testing. The code reads the first input N, and then takes N more inputs. For each input, it prints out every 4bits out of the read 32bits.

  * Optimization result

    ```assembly
    ; Before
    ...
    ; Function Attrs: nounwind ssp uwtable
    define i32 @main() #0 {
    entry:
      %call = call i64 (...) @read()
      %conv = trunc i64 %call to i32
      br label %for.cond
    
    for.cond:                                         ; preds = %for.inc10, %entry
      %i.0 = phi i32 [ 0, %entry ], [ %inc11, %for.inc10 ]
      %cmp = icmp slt i32 %i.0, %conv
      br i1 %cmp, label %for.body, label %for.cond.cleanup
    
    for.cond.cleanup:                                 ; preds = %for.cond
      br label %for.end12
    
    for.body:                                         ; preds = %for.cond
      %call2 = call i64 (...) @read()
      %conv3 = trunc i64 %call2 to i32
      br label %for.cond4
    
    for.cond4:                                        ; preds = %for.inc, %for.body
      %data.0 = phi i32 [ %conv3, %for.body ], [ %shr, %for.inc ]
      %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
      %cmp5 = icmp slt i32 %j.0, 8
      br i1 %cmp5, label %for.body8, label %for.cond.cleanup7
    
    for.cond.cleanup7:                                ; preds = %for.cond4
      br label %for.end
    
    for.body8:                                        ; preds = %for.cond4
      %and = and i32 %data.0, 15
      %conv9 = zext i32 %and to i64
      call void @write(i64 %conv9)
      %shr = lshr i32 %data.0, 4
      br label %for.inc
    
    for.inc:                                          ; preds = %for.body8
      %inc = add nsw i32 %j.0, 1
      br label %for.cond4
    
    for.end:                                          ; preds = %for.cond.cleanup7
      br label %for.inc10
    
    for.inc10:                                        ; preds = %for.end
      %inc11 = add nsw i32 %i.0, 1
      br label %for.cond
    
    for.end12:                                        ; preds = %for.cond.cleanup
      ret i32 0
    }
    ...
    
    ; After
    ...
    ; Function Attrs: nounwind ssp uwtable
    define i32 @main() #0 {
    entry:
      %call = call i64 (...) @read() #3
      %conv = trunc i64 %call to i32
      br label %for.cond
    
    for.cond:                                         ; preds = %for.inc10, %entry
      %i.0 = phi i32 [ 0, %entry ], [ %inc11, %for.inc10 ]
      %cmp = icmp slt i32 %i.0, %conv
      br i1 %cmp, label %for.body, label %for.cond.cleanup
    
    for.cond.cleanup:                                 ; preds = %for.cond
      br label %for.end12
    
    for.body:                                         ; preds = %for.cond
      %call2 = call i64 (...) @read() #3
      %conv3 = trunc i64 %call2 to i32
      br label %for.cond4
    
    for.cond4:                                        ; preds = %for.inc, %for.body
      %data.0 = phi i32 [ %conv3, %for.body ], [ %shr, %for.inc ]
      %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
      %cmp5 = icmp ult i32 %j.0, 8
      br i1 %cmp5, label %for.body8, label %for.cond.cleanup7
    
    for.cond.cleanup7:                                ; preds = %for.cond4
      br label %for.end
    
    for.body8:                                        ; preds = %for.cond4
      %and = urem i32 %data.0, 16
      %conv9 = zext i32 %and to i64
      call void @write(i64 %conv9) #3
      br label %for.inc
    
    for.inc:                                          ; preds = %for.body8
      %shr = udiv i32 %data.0, 16
      %inc = add nuw nsw i32 %j.0, 1
      br label %for.cond4
    
    for.end:                                          ; preds = %for.cond.cleanup7
      br label %for.inc10
    
    for.inc10:                                        ; preds = %for.end
      %inc11 = add nuw nsw i32 %i.0, 1
      br label %for.cond
    
    for.end12:                                        ; preds = %for.cond.cleanup
      ret i32 0
    }
    ...
    ```

  The test results are:

    * 2317.8576(0)  --> 2301.8576(0)
    * 4608.6896(0)  --> 4576.6896(0)
    * 45843.6656(0) --> 45523.6656(0)

  Where the first inputs(the number of inputs of each input) are 10, 20, and 100. Even though the cost reduction seems very subtle, the difference is twice or thrice the size of input. There are many non-optimizable instructions like `++`, compare, branch, write, and load/store, which is generated by the vanilla RA.

* `weirdarith.ll`

  ```assembly
  define i32 @main() {
  entry:
    %call = call i64 (...) @read()
    br label %while.cond
  
  while.cond:                                       ; preds = %while.body, %entry
    %r.0 = phi i64 [ %call, %entry ], [ %add, %while.body ]
    %m.0 = phi i64 [ -1, %entry ], [ %shr, %while.body ]
    %sub = sub i64 0, %r.0
    %cmp = icmp ne i64 %r.0, %sub
    br i1 %cmp, label %while.body, label %while.end
  
  while.body:                                       ; preds = %while.cond
    %and = and i64 %r.0, %m.0
    %add = add i64 %and, %and
    %shr = lshr i64 %m.0, 1
    br label %while.cond
  
  while.end:                                        ; preds = %while.cond
    call void @write(i64 %m.0)
    ret i32 0
  }
  ```

  This program is just a toy for WeirdArithmetic pass, that has some optimizable instructions.
  
  * Optimization result
    
    ```assembly
    ...
    ; Function Attrs: nounwind ssp uwtable
    define i32 @main() #0 {
    entry:
    %call = call i64 (...) @read() #3
      br label %while.cond
    
    while.cond:                                       ; preds = %while.body, %entry
      %r.0 = phi i64 [ %call, %entry ], [ %add, %while.body ]
      %m.0 = phi i64 [ -1, %entry ], [ %shr, %while.body ]
      %sub = mul i64 %r.0, -1
      %cmp = icmp eq i64 %r.0, %sub
      br i1 %cmp, label %while.end, label %while.body
    
    while.body:                                       ; preds = %while.cond
      %and = and i64 %r.0, %m.0
      %add = mul i64 %and, 2
      %shr = udiv i64 %m.0, 2
      br label %while.cond
    
    while.end:                                        ; preds = %while.cond
      call void @write(i64 %m.0) #3
      ret i32 0
    }
    ...
    ```
  
  The results are:
    * 1729.2512(0) --> 1616.4512(0)
    * 1626.8416(0) --> 1520.8416(0)
    * 1473.2272(0) --> 1377.4272(0)
    * 705.1552(0)  --> 660.3552(0)
  
  Where the inputs are 1, 981151712, 1024, 1099511627776. This shows the cost reduction.



#### All Test Case Result

This is the log from `make test`. Our compiler generated valid assembly files, as all outputs were correct(`[AC]`).

```
Case test start
========================================
We wrote test outputs as the below form:
>> [original cost]([original heap usage]) --> [optimized cost]([optimized heap usage])

And the following labels:
>> [AC] to represent 'ACcepted output!'
>> [RE] to represent 'Runtime Error!'  (different return values)
>> [WA] to represent 'Wrong Answer!'   (different outputs)
========================================
Testing workspace/testcases/binary_tree/
>> input1.txt [AC]    2402.8096(144)  --> 2453.4464(144)   +50.64(0)
>> input2.txt [AC]    4310.6816(144)  --> 4378.784(144)    +68.1(0)
>> input3.txt [AC]    66113.1696(1176) --> 66664.3184(1176)  +551.15(0)
>> input4.txt [AC]    1033485.1248(14136) --> 1040097.6944(14136)  +6612.57(0)
>> input5.txt [AC]    1977050335.4539(1660152) --> 1977885428.8991(1660152)  +835093.45(0)
Testing workspace/testcases/bitcount1/
>> input1.txt [AC]    218.2288(0)     --> 216.6288(0)      -1.6(0)
>> input2.txt [AC]    1351.6672(0)    --> 1339.2672(0)     -12.4(0)
>> input3.txt [AC]    386.1456(0)     --> 382.9456(0)      -3.2(0)
>> input4.txt [AC]    50.312(0)       --> 50.312(0)        0.0(0)
>> input5.txt [AC]    92.2912(0)      --> 91.8912(0)       -0.4(0)
Testing workspace/testcases/bitcount2/
>> input1.txt [AC]    201.3744(0)     --> 200.5744(0)      -0.8(0)
>> input2.txt [AC]    1256.448(0)     --> 1250.248(0)      -6.2(0)
>> input3.txt [AC]    357.6816(0)     --> 356.0816(0)      -1.6(0)
>> input4.txt [AC]    45.0672(0)      --> 45.0672(0)       0.0(0)
>> input5.txt [AC]    84.144(0)       --> 83.944(0)        -0.2(0)
Testing workspace/testcases/bitcount3/
>> input1.txt [AC]    135.0832(0)     --> 135.0832(0)      0.0(0)
>> input2.txt [AC]    1364.2656(0)    --> 1364.2656(0)     0.0(0)
>> input3.txt [AC]    347.0112(0)     --> 347.0112(0)      0.0(0)
>> input4.txt [AC]    50.312(0)       --> 50.312(0)        0.0(0)
>> input5.txt [AC]    92.6976(0)      --> 92.6976(0)       0.0(0)
Testing workspace/testcases/bitcount4/
>> input1.txt [AC]    25401.8304(2048) --> 23906.6304(1024)  -1495.2(0)
>> input2.txt [AC]    25404.656(2048) --> 23909.456(1024)  -1495.2(0)
>> input3.txt [AC]    25402.6144(2048) --> 23907.4144(1024)  -1495.2(0)
>> input4.txt [AC]    25401.8016(2048) --> 23906.6016(1024)  -1495.2(0)
>> input5.txt [AC]    25401.8048(2048) --> 23906.6048(1024)  -1495.2(0)
Testing workspace/testcases/bitcount5/
>> input1.txt [AC]    394.6752(192)   --> 389.4752(64)     -5.2(0)
>> input2.txt [AC]    881.3872(640)   --> 846.7872(64)     -34.6(0)
>> input3.txt [AC]    463.992(256)    --> 454.592(64)      -9.4(0)
>> input4.txt [AC]    325.4704(128)   --> 324.4704(64)     -1.0(0)
>> input5.txt [AC]    394.6496(192)   --> 389.4496(64)     -5.2(0)
Testing workspace/testcases/bubble_sort/
>> input1.txt [AC]    6628.936(80)    --> 6625.192(80)     -3.74(0)
>> input2.txt [AC]    562437.2464(800) --> 562028.28(800)   -408.97(0)
>> input3.txt [AC]    61987402.0422(8000) --> 61945849.599(8000)  -41552.44(0)
Testing workspace/testcases/collatz/
>> input1.txt [AC]    68.44(0)        --> 68.408(0)        -0.03(0)
>> input2.txt [AC]    68.44(0)        --> 68.408(0)        -0.03(0)
Testing workspace/testcases/dectohex/
>> input1.txt [AC]    2317.8576(0)    --> 2301.8576(0)     -16.0(0)
>> input2.txt [AC]    4608.6896(0)    --> 4576.6896(0)     -32.0(0)
>> input3.txt [AC]    45843.6656(0)   --> 45523.6656(0)    -320.0(0)
Testing workspace/testcases/expnear/
>> input1.txt [AC]    508.8352(0)     --> 374.9936(0)      -133.84(0)
>> input2.txt [AC]    699.6688(0)     --> 514.6544(0)      -185.01(0)
>> input3.txt [AC]    1335.7808(0)    --> 980.1904(0)      -355.59(0)
>> input4.txt [AC]    2608.0048(0)    --> 1911.2624(0)     -696.74(0)
>> input5.txt [AC]    3880.2288(0)    --> 2842.3344(0)     -1037.89(0)
Testing workspace/testcases/four_i8_sum/
>> input1.txt [AC]    117.1856(0)     --> 179.2208(0)      +62.04(0)
>> input2.txt [AC]    117.1856(0)     --> 179.2208(0)      +62.04(0)
>> input3.txt [AC]    117.1856(0)     --> 179.2208(0)      +62.04(0)
>> input4.txt [AC]    117.1856(0)     --> 179.2208(0)      +62.04(0)
Testing workspace/testcases/gcd/
>> input1.txt [AC]    46.5024(0)      --> 46.5024(0)       0.0(0)
>> input2.txt [AC]    105.4816(0)     --> 105.4816(0)      0.0(0)
>> input3.txt [AC]    223.4272(0)     --> 223.4272(0)      0.0(0)
>> input4.txt [AC]    1043.0336(0)    --> 1043.0336(0)     0.0(0)
Testing workspace/testcases/prime/
>> input1.txt [AC]    117.44(40)      --> 131.7472(40)     +14.31(0)
>> input2.txt [AC]    6841.0128(1320) --> 5830.9136(72)    -1010.1(0)
>> input3.txt [AC]    1602526.9936(68272) --> 1287326.976(6040)  -315200.02(0)
>> input4.txt [AC]    5903604.9681(213152) --> 4697654.9312(16472)  -1205950.04(0)
Testing workspace/testcases/six_i32_sum/
>> input1.txt [AC]    160.952(0)      --> 155.736(0)       -5.22(0)
>> input2.txt [AC]    1371.632(0)     --> 1366.416(0)      -5.22(0)
>> input3.txt [AC]    295.472(0)      --> 290.256(0)       -5.22(0)
Testing workspace/testcases/various_types_sum/
>> input1.txt [AC]    162.9136(0)     --> 218.4112(0)      +55.5(0)
>> input2.txt [AC]    1391.248(0)     --> 1993.168(0)      +601.92(0)
>> input3.txt [AC]    2756.064(0)     --> 3965.12(0)       +1209.06(0)
>> input4.txt [AC]    299.3952(0)     --> 415.6064(0)      +116.21(0)
Testing workspace/testcases/weirdarith/
>> input1.txt [AC]    1729.2512(0)    --> 1616.4512(0)     -112.8(0)
>> input2.txt [AC]    1626.8416(0)    --> 1520.8416(0)     -106.0(0)
>> input3.txt [AC]    1473.2272(0)    --> 1377.4272(0)     -95.8(0)
>> input4.txt [AC]    705.1552(0)     --> 660.3552(0)      -44.8(0)
Case test done
```


