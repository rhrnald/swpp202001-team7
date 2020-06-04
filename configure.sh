#!/bin/bash

if [ "$#" -ne 1 ]; then
  if [ "$#" -ne 2 ]; then
    echo "configure.sh <clang dir>"
    echo "ex)  ./configure.sh ~/llvm-10.0-releaseassert/bin"
    exit 1
  fi
  TEST_THREADS=$2
else
  TEST_THREADS=16
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  ISYSROOT="-isysroot `xcrun --show-sdk-path`"
else
  ISYSROOT=
fi

LLVMCONFIG=$1/llvm-config

CXXFLAGS=`$LLVMCONFIG --cxxflags`
SRCROOT=`$LLVMCONFIG --src-root`
CXXFLAGS="$CXXFLAGS -std=c++17 -g -I${SRCROOT}/include ${ISYSROOT}"
CXXFLAGS="$CXXFLAGS -I${SRCROOT}/utils/unittest/googletest/include"
CXXFLAGS="$CXXFLAGS -I${SRCROOT}/utils/unittest/googletest/"

GTESTSRC="${SRCROOT}/utils/unittest/googletest/src/gtest-all.cc"

LDFLAGS=`$LLVMCONFIG --ldflags`
LIBS=`$LLVMCONFIG --libs core irreader bitreader support analysis asmparser passes --system-libs`
LDFLAGS="$LDFLAGS -Wl,-rpath,`$LLVMCONFIG --libdir`"
LDFLAGS="$LDFLAGS $LIBS -lpthread -lm -fPIC"

echo "CXX=$1/clang++" >Makefile
echo "CXXFLAGS=${CXXFLAGS}" >>Makefile
echo "LDFLAGS=${LDFLAGS}" >>Makefile
echo "GTESTSRC=${GTESTSRC}" >> Makefile
echo "FILECHECK_PATH=$1/FileCheck" >> Makefile
echo "LLVM_BIN=$1" >> Makefile
cat Makefile.template >>Makefile

echo "// Well modified by configure.sh" > src/core/LLVMPath.h
echo "#define LLVM_BIN \"$1\"" >> src/core/LLVMPath.h

echo "LLVM_BIN = \"$1\"" > test/loops_unit_test/test.py
cat test/loops_unit_test/test.py.template >> test/loops_unit_test/test.py

echo "#!/bin/bash" > test/checker.sh
echo "TEST_THREADS=$TEST_THREADS" >> test/checker.sh
cat test/checker.sh.template >> test/checker.sh
chmod +x test/checker.sh

echo "#!/bin/bash" > test/single_checker.sh
echo "TEST_THREADS=$TEST_THREADS" >> test/single_checker.sh
cat test/single_checker.sh.template >> test/single_checker.sh
chmod +x test/single_checker.sh
