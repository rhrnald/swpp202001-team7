#!/bin/bash

set -e
trap 'kill $(jobs -p)' SIGINT

DIR=$(dirname $0)

echo
echo Case test start

python3 $DIR/log_checker.py

dir=$1

echo "" > $DIR/original.log
echo "" > $DIR/converted.log

echo =========================================================
echo Case test for our own testcases has been started
echo =========================================================

# Compiler Phase (Cannot Duplicated.. from main.cpp)
for tc in $dir/ours/*; do
  echo "Compiling $tc..."

  orig_ll=$tc/src/*.ll
  bef_s=$tc/"bef.s"
  aft_s=$tc/"aft.s"
  if [ $# -eq 2 ]; then
    $DIR/../bin/sf-compiler-team7 $orig_ll -o $bef_s "-except $2"
  else
    $DIR/../bin/sf-compiler-vanilla $orig_ll -o $bef_s
  fi
  $DIR/../bin/sf-compiler-team7 $orig_ll -o $aft_s
done

echo =========================================================
echo Running interpreter in parallel
echo =========================================================

# Interpreter Phase
for tc in $dir/ours/*; do
  for inp in $tc/test/input*.txt; do
    $DIR/tc_checker.sh $tc $inp &
  done
done

# Reaping child process
for job in `jobs -p`
do
  wait $job
done

echo =========================================================
echo Case test for our own testcases has been finished!
echo =========================================================
echo This is the summary of our own testcases result
echo =========================================================

for tc in $dir/ours/*; do
  echo "Testing $tc"
  bef_s=$tc/"bef.s"
  aft_s=$tc/"aft.s"
  for inp in $tc/test/input*.txt; do
    log1="$inp.original.log"
    log2="$inp.converted.log"
    out1="$inp.original.out"
    out2="$inp.converted.out"

    python3 $DIR/log_checker.py $inp $out1 $out2 $log1 $log2
    rm $log1 $log2 $out1 $out2
  done
  rm $bef_s $aft_s
done




echo =========================================================
echo Case test for the benchmark testcases has been started
echo =========================================================

# Compiler Phase (Cannot Duplicated.. from main.cpp)
for tc in $dir/benchmarks/*; do
  echo "Compiling $tc..."

  orig_ll=$tc/src/*.ll
  bef_s=$tc/"bef.s"
  aft_s=$tc/"aft.s"
  if [ $# -eq 2 ]; then
    $DIR/../bin/sf-compiler-team7 $orig_ll -o $bef_s "-except $2"
  else
    $DIR/../bin/sf-compiler-vanilla $orig_ll -o $bef_s
  fi
  $DIR/../bin/sf-compiler-team7 $orig_ll -o $aft_s
done

echo =========================================================
echo Running interpreter in parallel
echo =========================================================

# Interpreter Phase
for tc in $dir/benchmarks/*; do
  for inp in $tc/test/input*.txt; do
    $DIR/tc_checker.sh $tc $inp &
  done
done

for job in `jobs -p`
do
  wait $job
done

echo =========================================================
echo Case test for the benchmark testcases has been finished!
echo =========================================================
echo This is the summary of the benchmark testcases result
echo =========================================================

for tc in $dir/benchmarks/*; do
  echo "Testing $tc"
  bef_s=$tc/"bef.s"
  aft_s=$tc/"aft.s"
  for inp in $tc/test/input*.txt; do
    log1="$inp.original.log"
    log2="$inp.converted.log"
    out1="$inp.original.out"
    out2="$inp.converted.out"

    python3 $DIR/log_checker.py $inp $out1 $out2 $log1 $log2
    rm $log1 $log2 $out1 $out2
  done
  rm $bef_s $aft_s
done



echo =========================================================
echo Case test done
echo Result logs are generated in test/*.log
echo =========================================================
