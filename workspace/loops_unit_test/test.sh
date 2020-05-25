#!/bin/bash
LLVM_BIN="/home/woosung/llvmscript/llvm-10.0-release/bin"
DIR=$(dirname $0)

opt=$LLVM_BIN/opt

$opt 

LoopPrePasses="-loop-simplify -loop-deletion";
LoopBasicPasses="-lcssa -licm -loop-vectorize -loop-unswitch -loop-distribute -loop-data-prefetch -loop-idiom -loop-simplifycfg"
LoopMainPasses="-simplifycfg -loop-rotate -loop-interchange -loop-unroll -unroll-runtime -unroll-count=8";
LoopEndPasses="-gvn -aggressive-instcombine";

function apply_loop_optimizations() {
  tmp1=.tmp1.ll
  tmp2=.tmp2.ll
  tmp3=.tmp3.ll
  $opt $LoopPrePasses $1 -S -o $tmp1
  $opt $LoopBasicPasses $tmp1 -S -o $tmp2
  $opt $LoopMainPasses $tmp2 -S -o $tmp3
  $opt $LoopPostPasses $tmp3 -S -o $2
  rm $tmp.1 $tmp.2 $tmp.3
}


