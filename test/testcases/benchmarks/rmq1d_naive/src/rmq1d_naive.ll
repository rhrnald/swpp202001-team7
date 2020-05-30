; ModuleID = '/tmp/a.ll'
source_filename = "rmq1d_naive/src/rmq1d_naive.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

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
define i32 @min_element(i32* %p, i32* %q) #0 {
entry:
  %0 = load i32, i32* %p, align 4
  br label %while.cond

while.cond:                                       ; preds = %if.end, %entry
  %p.addr.0 = phi i32* [ %p, %entry ], [ %incdec.ptr, %if.end ]
  %e.0 = phi i32 [ %0, %entry ], [ %e.1, %if.end ]
  %cmp = icmp ne i32* %p.addr.0, %q
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %1 = load i32, i32* %p.addr.0, align 4
  %cmp1 = icmp slt i32 %1, %e.0
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  %2 = load i32, i32* %p.addr.0, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %while.body
  %e.1 = phi i32 [ %2, %if.then ], [ %e.0, %while.body ]
  %incdec.ptr = getelementptr inbounds i32, i32* %p.addr.0, i64 1
  br label %while.cond

while.end:                                        ; preds = %while.cond
  ret i32 %e.0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i32
  %conv1 = sext i32 %conv to i64
  %mul = mul i64 4, %conv1
  %call2 = call i8* @malloc_upto_8(i64 %mul)
  %0 = bitcast i8* %call2 to i32*
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, %conv
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %call4 = call i64 (...) @read()
  %conv5 = trunc i64 %call4 to i32
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %idxprom
  store i32 %conv5, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  %call6 = call i64 (...) @read()
  %conv7 = trunc i64 %call6 to i32
  br label %while.cond

while.cond:                                       ; preds = %while.body, %for.end
  %Q.0 = phi i32 [ %conv7, %for.end ], [ %dec, %while.body ]
  %dec = add nsw i32 %Q.0, -1
  %tobool = icmp ne i32 %Q.0, 0
  br i1 %tobool, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %call8 = call i64 (...) @read()
  %conv9 = trunc i64 %call8 to i32
  %call10 = call i64 (...) @read()
  %conv11 = trunc i64 %call10 to i32
  %idx.ext = sext i32 %conv9 to i64
  %add.ptr = getelementptr inbounds i32, i32* %0, i64 %idx.ext
  %idx.ext12 = sext i32 %conv11 to i64
  %add.ptr13 = getelementptr inbounds i32, i32* %0, i64 %idx.ext12
  %add.ptr14 = getelementptr inbounds i32, i32* %add.ptr13, i64 1
  %call15 = call i32 @min_element(i32* %add.ptr, i32* %add.ptr14)
  %conv16 = sext i32 %call15 to i64
  call void @write(i64 %conv16)
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
