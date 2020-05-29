#!/bin/bash

if [ "$#" -eq 1 ]; then
  mkdir -p $1
  cd $1
  mkdir -p src
  mkdir -p test
  cp ../../template.c src/$(basename $1).c
  cd -
  exit 0
fi

if [ "$#" -ne 2 ]; then
  echo "test-gen.sh <testcase dir> [<clang dir>]"
  echo "  ex)  ./test-gen.sh ./testcases/binary_tree ~/llvm-10.0-releaseassert/bin" 
  echo "if there is no <clang dir>, it will just create the testcase structure."
  echo "  ex) ./test-gen.sh ./testcases/new_test"
  exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  ISYSROOT="-isysroot `xcrun --show-sdk-path`"
else
  ISYSROOT=
fi

DIR=$(dirname $0)
NAME=$(basename $1)
SRC=$1/src
TEST=$1/test
CXX=$2/clang

# compile NAME.c => NAME.raw.ll
echo "Compiling $NAME.c to $NAME.ll ..."
$CXX $ISYSROOT -O1 -fno-strict-aliasing -fno-discard-value-names -g0 $SRC/$NAME.c \
    -mllvm -disable-llvm-optzns -S -o $SRC/$NAME.raw.ll -emit-llvm

# vanilla compile NAME.raw.ll => NAME.ll => NAME.s
echo "Compiling $NAME.ll to $NAME.s ..."
$DIR/../bin/sf-compiler-vanilla $SRC/$NAME.raw.ll -d $SRC/$NAME.ll -o $SRC/$NAME.s
rm -f $SRC/$NAME.raw.ll