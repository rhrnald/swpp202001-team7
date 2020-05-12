#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "c-to-ll.sh <input.c file> <output.ll file> <clang dir>"
  echo "ex)  ./c-to-ll.sh ./bubble_sort/src/bubble_sort.c ./output.ll llvm-10.0-releaseassert/bin"
  exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  ISYSROOT="-isysroot `xcrun --show-sdk-path`"
else
  ISYSROOT=
fi

CXX=$3/clang

$CXX $ISYSROOT -O1 -fno-strict-aliasing -fno-discard-value-names -g0 $1 \
    -mllvm -disable-llvm-optzns -S -o $2 -emit-llvm
