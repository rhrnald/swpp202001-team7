; ModuleID = '/tmp/a.ll'
source_filename = "rmq2d_naive/src/rmq2d_naive.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

@v = external global i32**, align 8

; Function Attrs: nounwind ssp uwtable
define i8* @malloc_upto_8(i64 %x) #0 {
entry:
  %add = add i64 %x, 7
  %div = udiv i64 %add, 8
  %mul = mul i64 %div, 8
  %call = call noalias i8* @malloc(i64 %mul) #4
  ret i8* %call
}

; Function Attrs: allocsize(0)
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind ssp uwtable
define i32 @min(i32 %x, i32 %y) #0 {
entry:
  %cmp = icmp slt i32 %x, %y
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %x, %cond.true ], [ %y, %cond.false ]
  ret i32 %cond
}

; Function Attrs: nounwind ssp uwtable
define i32* @min_element(i32* %p, i32* %q) #0 {
entry:
  br label %while.cond

while.cond:                                       ; preds = %if.end, %entry
  %p.addr.0 = phi i32* [ %p, %entry ], [ %incdec.ptr, %if.end ]
  %e.0 = phi i32* [ %p, %entry ], [ %e.1, %if.end ]
  %cmp = icmp ne i32* %p.addr.0, %q
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %0 = load i32, i32* %p.addr.0, align 4
  %1 = load i32, i32* %e.0, align 4
  %cmp1 = icmp slt i32 %0, %1
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  br label %if.end

if.end:                                           ; preds = %if.then, %while.body
  %e.1 = phi i32* [ %p.addr.0, %if.then ], [ %e.0, %while.body ]
  %incdec.ptr = getelementptr inbounds i32, i32* %p.addr.0, i64 1
  br label %while.cond

while.end:                                        ; preds = %while.cond
  ret i32* %e.0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: nounwind ssp uwtable
define i32 @min_at_row(i32 %row, i32 %from_j, i32 %to_j) #0 {
entry:
  %0 = load i32**, i32*** @v, align 8
  %idx.ext = sext i32 %row to i64
  %add.ptr = getelementptr inbounds i32*, i32** %0, i64 %idx.ext
  %1 = load i32*, i32** %add.ptr, align 8
  %idx.ext1 = sext i32 %from_j to i64
  %add.ptr2 = getelementptr inbounds i32, i32* %1, i64 %idx.ext1
  %2 = load i32*, i32** %add.ptr, align 8
  %idx.ext3 = sext i32 %to_j to i64
  %add.ptr4 = getelementptr inbounds i32, i32* %2, i64 %idx.ext3
  %add.ptr5 = getelementptr inbounds i32, i32* %add.ptr4, i64 1
  %call = call i32* @min_element(i32* %add.ptr2, i32* %add.ptr5)
  %3 = load i32, i32* %call, align 4
  ret i32 %3
}

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i32
  %call1 = call i64 (...) @read()
  %conv2 = trunc i64 %call1 to i32
  %conv3 = sext i32 %conv to i64
  %mul = mul i64 8, %conv3
  %call4 = call i8* @malloc_upto_8(i64 %mul)
  %0 = bitcast i8* %call4 to i32**
  store i32** %0, i32*** @v, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc20, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc21, %for.inc20 ]
  %cmp = icmp slt i32 %i.0, %conv
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end22

for.body:                                         ; preds = %for.cond
  %conv6 = sext i32 %conv2 to i64
  %mul7 = mul i64 4, %conv6
  %call8 = call i8* @malloc_upto_8(i64 %mul7)
  %1 = bitcast i8* %call8 to i32*
  %2 = load i32**, i32*** @v, align 8
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds i32*, i32** %2, i64 %idxprom
  store i32* %1, i32** %arrayidx, align 8
  br label %for.cond9

for.cond9:                                        ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp10 = icmp slt i32 %j.0, %conv2
  br i1 %cmp10, label %for.body13, label %for.cond.cleanup12

for.cond.cleanup12:                               ; preds = %for.cond9
  br label %for.end

for.body13:                                       ; preds = %for.cond9
  %call14 = call i64 (...) @read()
  %conv15 = trunc i64 %call14 to i32
  %3 = load i32**, i32*** @v, align 8
  %idxprom16 = sext i32 %i.0 to i64
  %arrayidx17 = getelementptr inbounds i32*, i32** %3, i64 %idxprom16
  %4 = load i32*, i32** %arrayidx17, align 8
  %idxprom18 = sext i32 %j.0 to i64
  %arrayidx19 = getelementptr inbounds i32, i32* %4, i64 %idxprom18
  store i32 %conv15, i32* %arrayidx19, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body13
  %inc = add nsw i32 %j.0, 1
  br label %for.cond9

for.end:                                          ; preds = %for.cond.cleanup12
  br label %for.inc20

for.inc20:                                        ; preds = %for.end
  %inc21 = add nsw i32 %i.0, 1
  br label %for.cond

for.end22:                                        ; preds = %for.cond.cleanup
  %call23 = call i64 (...) @read()
  %conv24 = trunc i64 %call23 to i32
  br label %while.cond

while.cond:                                       ; preds = %for.end44, %for.end22
  %Q.0 = phi i32 [ %conv24, %for.end22 ], [ %dec, %for.end44 ]
  %dec = add nsw i32 %Q.0, -1
  %tobool = icmp ne i32 %Q.0, 0
  br i1 %tobool, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %call25 = call i64 (...) @read()
  %conv26 = trunc i64 %call25 to i32
  %call27 = call i64 (...) @read()
  %conv28 = trunc i64 %call27 to i32
  %call29 = call i64 (...) @read()
  %conv30 = trunc i64 %call29 to i32
  %call31 = call i64 (...) @read()
  %conv32 = trunc i64 %call31 to i32
  %call33 = call i32 @min_at_row(i32 %conv26, i32 %conv30, i32 %conv32)
  %add = add nsw i32 %conv26, 1
  br label %for.cond35

for.cond35:                                       ; preds = %for.inc42, %while.body
  %res.0 = phi i32 [ %call33, %while.body ], [ %call41, %for.inc42 ]
  %i34.0 = phi i32 [ %add, %while.body ], [ %inc43, %for.inc42 ]
  %cmp36 = icmp sle i32 %i34.0, %conv28
  br i1 %cmp36, label %for.body39, label %for.cond.cleanup38

for.cond.cleanup38:                               ; preds = %for.cond35
  br label %for.end44

for.body39:                                       ; preds = %for.cond35
  %call40 = call i32 @min_at_row(i32 %i34.0, i32 %conv30, i32 %conv32)
  %call41 = call i32 @min(i32 %res.0, i32 %call40)
  br label %for.inc42

for.inc42:                                        ; preds = %for.body39
  %inc43 = add nsw i32 %i34.0, 1
  br label %for.cond35

for.end44:                                        ; preds = %for.cond.cleanup38
  %conv45 = sext i32 %res.0 to i64
  call void @write(i64 %conv45)
  br label %while.cond

while.end:                                        ; preds = %while.cond
  ret i32 0
}

declare i64 @read(...) #3

declare void @write(i64) #3

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { allocsize(0) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { allocsize(0) }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 10, i32 15]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 10.0.0 (git@github.com:llvm/llvm-project.git d32170dbd5b0d54436537b6b75beaf44324e0c28)"}
