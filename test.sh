#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  EXT=".dylib"
  ISYSROOT="-isysroot `xcrun --show-sdk-path`"
else
  EXT=".so"
  ISYSROOT=
fi

OPTLIB="./libTeam7"$EXT
TESTDIR="testcases"
TESTTMP="tmp"
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
  LIBS=`$LLVMCONFIG --libs core irreader bitreader support analysis asmparser passes --system-libs`
  LDFLAGS="$LDFLAGS -Wl,-rpath,`$LLVMCONFIG --libdir`"
  LDFLAGS="$LDFLAGS $LIBS -lpthread -lm -fPIC"

  SRCROOT=`$LLVMCONFIG --src-root`

  CXX=$2/clang++
  CXXFLAGS="$CXXFLAGS -std=c++17 -g -I${SRCROOT}/include ${ISYSROOT}"
  CXXFLAGS="$CXXFLAGS -I${SRCROOT}/utils/unittest/googletest/include"
  CXXFLAGS="$CXXFLAGS -I${SRCROOT}/utils/unittest/googletest/"
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

  if [[ ! -e $TESTOUTPUT ]]; then
    mkdir $TESTOUTPUT
  fi

  mkdir 1$TESTTMP
  mkdir 2$TESTTMP

  for f in `ls -1 $TESTDIR` ; do
    echo "== optimizing $TESTDIR/${f} =="
    $2/opt -passes="instcombine" $TESTDIR/${f} -S -o 1$TESTTMP/${f}
    $2/opt -load-pass-plugin=$OPTLIB \
           -passes="pack-regs-arg" 1$TESTTMP/${f} -S -o 2$TESTTMP/${f}
    $2/opt -load-pass-plugin=$OPTLIB \
           -passes="weird-arith" 2$TESTTMP/${f} -S -o $TESTOUTPUT/${f}
  done

  rm -rf 1$TESTTMP
  rm -rf 2$TESTTMP
fi

if [[ "$1" == "clean" ]]; then
  rm -rf $TESTOUTPUT
  rm $OPTLIB
fi
