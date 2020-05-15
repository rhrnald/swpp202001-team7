#/bin/bash

PREVWD=$PWD
cd $(dirname $0)

echo
echo Case test start

python3 log_checker.py

for tc in testcases/*/; do
  echo Testing $tc
  cd $tc

  orig_ll=src/*.ll
  orig_s=src/*.s
  test_s="ours.s"
  log="sf-interpreter.log"
  log1="log1"
  log2="log2"

  ../../../bin/sf-compiler-team7 $orig_ll -o $test_s

  for inp in test/input*; do
    ../../../bin/interpreter $orig_s < $inp > .tmp1
    mv $log $log1
    ../../../bin/interpreter $test_s < $inp > .tmp2
    mv $log $log2
    python3 ../../log_checker.py $inp .tmp1 .tmp2 $log1 $log2
    rm .tmp1 .tmp2 $log1 $log2
  done
  rm $test_s
  cd ../..
done

cd $PREVWD