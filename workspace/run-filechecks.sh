#/bin/bash

echo
echo Case test start

for i in `find ./ -name "sample*"` ; do
  echo Testing $i
  cd $i
  echo Building..
  gcc src.c ../io.c -o a.out
  bash ../c-to-ll.sh src.c src.ll $1
  ../../bin/sf-compiler-team7 src.ll -o opt.s

  mkdir -p out_gcc out_llvm

  for j in `ls ./input/`; do
    echo case: $j
    ./a.out <input/$j >out_gcc/$j
    ../../bin/interpreter opt.s <input/$j >out_llvm/$j
    diff -w out_gcc/$j out_llvm/$j
  done
  echo Testing $i done
  echo
  cd ..
done
