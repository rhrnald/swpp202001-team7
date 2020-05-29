#/bin/bash

DIR=$(dirname $0)

echo
echo Case test start

python3 $DIR/log_checker.py

dir=$1

if [ $# -eq 2 ]; then
  flag="-except $2"
else
  flag="-nopass"
fi

echo Case test for our own testcases has been started

for tc in $dir/ours/*; do
  echo Testing $tc/

  orig_ll=$tc/src/*.ll
  bef_s=$tc/"bef.s"
  aft_s=$tc/"aft.s"
  log="sf-interpreter.log"
  log1=$tc/"log1"
  log2=$tc/"log2"

  $DIR/../bin/sf-compiler-team7 $orig_ll -o $bef_s $flag
  $DIR/../bin/sf-compiler-team7 $orig_ll -o $aft_s

  for inp in $tc/test/input*; do
    $DIR/../bin/interpreter $bef_s < $inp > $tc/.tmp1
    mv $log $log1
    $DIR/../bin/interpreter $aft_s < $inp > $tc/.tmp2
    mv $log $log2
    python3 $DIR/log_checker.py $inp $tc/.tmp1 $tc/.tmp2 $log1 $log2
    rm $tc/.tmp1 $tc/.tmp2 $log1 $log2
  done
  rm $bef_s $aft_s
done


echo Case test for the benchmarks has been started

for tc in $dir/benchmarks/*; do
  echo Testing $tc/

  orig_ll=$tc/src/*.ll
  bef_s=$tc/"bef.s"
  aft_s=$tc/"aft.s"
  log="sf-interpreter.log"
  log1=$tc/"log1"
  log2=$tc/"log2"

  $DIR/../bin/sf-compiler-team7 $orig_ll -o $bef_s $flag
  $DIR/../bin/sf-compiler-team7 $orig_ll -o $aft_s

  for inp in $tc/test/input*; do
    $DIR/../bin/interpreter $bef_s < $inp > $tc/.tmp1
    mv $log $log1
    $DIR/../bin/interpreter $aft_s < $inp > $tc/.tmp2
    mv $log $log2
    python3 $DIR/log_checker.py $inp $tc/.tmp1 $tc/.tmp2 $log1 $log2
    rm $tc/.tmp1 $tc/.tmp2 $log1 $log2
  done
  rm $bef_s $aft_s
done

echo Case test done
