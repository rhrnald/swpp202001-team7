#!/bin/bash

set -e

DIR=$(dirname $0)
tc=$1
inp=$2

orig_ll=$tc/src/*.ll
bef_s=$tc/"bef.s"
aft_s=$tc/"aft.s"

log1="$inp.original.log"
log2="$inp.converted.log"
out1="$inp.original.out"
out2="$inp.converted.out"

$DIR/../bin/interpreter $bef_s $log1 < $inp > $out1 &
$DIR/../bin/interpreter $aft_s $log2 < $inp > $out2 &

for job in `jobs -p`
do
  wait $job
done

python3 $DIR/log_checker.py $inp $out1 $out2 $log1 $log2 silence
