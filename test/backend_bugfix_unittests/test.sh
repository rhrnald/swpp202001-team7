#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "test.sh <llvm bin path>"
  echo "(ex: test.sh ~/llvmscript/my-llvm-release/bin)"
  exit 1
fi

DIR=$(dirname $0)
read_write=$DIR/read_write.c

echo "Backend Bugfix Test"
echo "  If there is no diff output, then the test is passed"
echo "  (See workspace/backend_bugfix_unittests/test.sh)"

for tc in $DIR/testcases/*; do
  echo ">> Testing $tc"
  orig_ll=$tc/src/*.ll

  backend_s=$tc/.tmp1.s
  backend_out=$tc/.tmp1.txt
  log="sf-interpreter.log"

  # backend's assembly (compiled by the sf-compiler)
  $DIR/../../bin/sf-compiler-team7 $orig_ll -o $backend_s
  
  for i in {1..3} ; do
    # backend's output (made by the interpreter)
    in=$tc/test/input$i.txt
    # clang's output (made by executable object file)
    clang_out=$tc/test/output$i.txt
    # backend's output (made by interpreter)
    $DIR/../../bin/interpreter $backend_s < $in > $backend_out
    # Check if the output is different
    diff $backend_out $clang_out
  done

  # remove generated files
  rm $backend_s
  rm $backend_out
  rm $log
done

echo "Backend Bugfix Test End"
