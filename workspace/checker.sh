#/bin/bash

DIR=$(dirname $0)

echo
echo Case test start

python3 $DIR/log_checker.py

for tc in $@; do
  echo Testing $tc/

  orig_ll=$tc/src/*.ll
  orig_s=$tc/src/*.s
  test_s=$tc/"ours.s"
  log="sf-interpreter.log"
  log1=$tc/"log1"
  log2=$tc/"log2"

  $DIR/../bin/sf-compiler-team7 $orig_ll -o $test_s

  for inp in $tc/test/input*; do
    $DIR/../bin/interpreter $orig_s < $inp > $tc/.tmp1
    mv $log $log1
    $DIR/../bin/interpreter $test_s < $inp > $tc/.tmp2
    mv $log $log2
    python3 $DIR/log_checker.py $inp $tc/.tmp1 $tc/.tmp2 $log1 $log2
    rm $tc/.tmp1 $tc/.tmp2 $log1 $log2
  done
  rm $test_s
done

echo Case test done