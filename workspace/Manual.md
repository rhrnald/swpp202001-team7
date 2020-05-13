```
; make sf-compiler-team7 & interpreter in bin dir
make all

;c to ll
$llvmP/clang -O1 -fno-strict-aliasing -fno-discard-value-names -g0 sample.c\
    -mllvm -disable-llvm-optzns -S -o input.ll -emit-llvm

;ll to s
bin/sf-compiler-team7 input.ll -o output.s -d output.ll

;excute s
bin/interpreter sample.s

```
