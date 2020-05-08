#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  EXT=".dylib"
  ISYSROOT="-isysroot `xcrun --show-sdk-path`"
else
  EXT=".so"
  ISYSROOT=
fi

OPTLIB="./libTeam7"$EXT
PASSES="instcombine,pack-regs-arg,weird-arith"
TESTDIR="testcases"
TESTOUTPUT="outputs"

function warning() {
  echo "test.sh build <clang dir>"
  echo "test.sh run <clang dir>"
  echo "test.sh all <clang dir>"
  echo "test.sh clean"
  echo "ex)  ./test.sh all ~/llvm-10.0-releaseassert/bin"
  exit 1
}

if [[ "$#" -eq 0 ]]; then
  warning
fi

if [[ "$1" == "build" || "$1" == "all" ]]; then
  if [ "$#" -ne 2 ]; then
    warning
  fi

  echo "----- build -----"
  LLVMCONFIG=$2/llvm-config
  CXXFLAGS=`$LLVMCONFIG --cxxflags`
  LDFLAGS=`$LLVMCONFIG --ldflags`
  LIBS=`$LLVMCONFIG --libs core irreader bitreader support --system-libs`
  SRCROOT=`$LLVMCONFIG --src-root`

  CXX=$2/clang++
  CXXFLAGS="$CXXFLAGS -std=c++17 -I\"${SRCROOT}/include\""
  set -e

  $CXX $ISYSROOT $CXXFLAGS $LDFLAGS $LIBS \
	  optimizations/Wrapper.cpp \
	  -o ./libTeam7$EXT -shared -fPIC -g
fi

if [[ "$1" == "run" || "$1" == "all" ]]; then
  if [ "$#" -ne 2 ]; then
    warning
  fi

  echo "----- run -----"
  set +e

  mkdir $TESTOUTPUT

  for f in `ls -1 $TESTDIR` ; do
    echo "== optimizing $TESTDIR/${f} =="
    $2/opt -load-pass-plugin=$OPTLIB \
           -passes=$PASSES $TESTDIR/${f} -S -o $TESTOUTPUT/${f}
  done
fi

if [[ "$1" == "clean" ]]; then
  rm -rf $TESTOUTPUT
  rm $OPTLIB
fi
