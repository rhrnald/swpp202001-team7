#!/bin/bash

set -e
trap 'kill $(jobs -p)' SIGINT

DIR=$(dirname $0)
tc=$1

python3 $DIR/log_checker.py

echo Testing $tc/

echo "" > $DIR/original.log
echo "" > $DIR/converted.log

orig_ll=$tc/src/*.ll
bef_s=$tc/"bef.s"
aft_s=$tc/"aft.s"

if [ $# -eq 2 ]; then
  $DIR/../bin/sf-compiler-team7 $orig_ll -o $bef_s "-except $2" &
else
  $DIR/../bin/sf-compiler-vanilla $orig_ll -o $bef_s &
fi

$DIR/../bin/sf-compiler-team7 $orig_ll -o $aft_s &

for job in `jobs -p`
do
  wait $job
done

for inp in $tc/test/input*.txt; do
  $DIR/tc_checker.sh $tc $inp &
done

for job in `jobs -p`
do
  wait $job
done

for inp in $tc/test/input*.txt; do
  log1="$inp.original.log"
  log2="$inp.converted.log"
  out1="$inp.original.out"
  out2="$inp.converted.out"
  python3 $DIR/log_checker.py $inp $out1 $out2 $log1 $log2
  rm $log1 $log2 $out1 $out2
done

rm $bef_s $aft_s

echo Case test done
