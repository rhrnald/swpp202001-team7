; ModuleID = '/tmp/a.ll'
source_filename = "bubble_sort/src/bubble_sort.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

; Function Attrs: nounwind ssp uwtable
define i64* @get_inputs(i64 %n) #0 {
entry:
  %cmp = icmp eq i64 %n, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  %mul = mul i64 %n, 8
  %call = call noalias i8* @malloc(i64 %mul) #4
  %0 = bitcast i8* %call to i64*
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.end
  %i.0 = phi i64 [ 0, %if.end ], [ %inc, %for.inc ]
  %cmp1 = icmp ult i64 %i.0, %n
  br i1 %cmp1, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %call2 = call i64 (...) @read()
  %arrayidx = getelementptr inbounds i64, i64* %0, i64 %i.0
  store i64 %call2, i64* %arrayidx, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add i64 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  br label %return

return:                                           ; preds = %for.end, %if.then
  %retval.0 = phi i64* [ null, %if.then ], [ %0, %for.end ]
  ret i64* %retval.0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: allocsize(0)
declare noalias i8* @malloc(i64) #2

declare i64 @read(...) #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind ssp uwtable
define void @sort(i64 %n, i64* %ptr) #0 {
entry:
  %cmp = icmp eq i64 %n, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %for.end15

if.end:                                           ; preds = %entry
  br label %for.cond

for.cond:                                         ; preds = %for.inc14, %if.end
  %i.0 = phi i64 [ 0, %if.end ], [ %inc, %for.inc14 ]
  %cmp1 = icmp ult i64 %i.0, %n
  br i1 %cmp1, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end15

for.body:                                         ; preds = %for.cond
  %sub = sub i64 %n, 1
  br label %for.cond2

for.cond2:                                        ; preds = %for.inc, %for.body
  %j.0 = phi i64 [ %sub, %for.body ], [ %dec, %for.inc ]
  %cmp3 = icmp ugt i64 %j.0, %i.0
  br i1 %cmp3, label %for.body5, label %for.cond.cleanup4

for.cond.cleanup4:                                ; preds = %for.cond2
  br label %for.end

for.body5:                                        ; preds = %for.cond2
  %arrayidx = getelementptr inbounds i64, i64* %ptr, i64 %j.0
  %0 = load i64, i64* %arrayidx, align 8
  %sub6 = sub i64 %j.0, 1
  %arrayidx7 = getelementptr inbounds i64, i64* %ptr, i64 %sub6
  %1 = load i64, i64* %arrayidx7, align 8
  %cmp8 = icmp ult i64 %0, %1
  br i1 %cmp8, label %if.then9, label %if.end13

if.then9:                                         ; preds = %for.body5
  %arrayidx10 = getelementptr inbounds i64, i64* %ptr, i64 %j.0
  store i64 %1, i64* %arrayidx10, align 8
  %sub11 = sub i64 %j.0, 1
  %arrayidx12 = getelementptr inbounds i64, i64* %ptr, i64 %sub11
  store i64 %0, i64* %arrayidx12, align 8
  br label %if.end13

if.end13:                                         ; preds = %if.then9, %for.body5
  br label %for.inc

for.inc:                                          ; preds = %if.end13
  %dec = add i64 %j.0, -1
  br label %for.cond2

for.end:                                          ; preds = %for.cond.cleanup4
  br label %for.inc14

for.inc14:                                        ; preds = %for.end
  %inc = add i64 %i.0, 1
  br label %for.cond

for.end15:                                        ; preds = %for.cond.cleanup, %if.then
  ret void
}

; Function Attrs: nounwind ssp uwtable
define void @put_inputs(i64 %n, i64* %ptr) #0 {
entry:
  %cmp = icmp eq i64 %n, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %for.end

if.end:                                           ; preds = %entry
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.end
  %i.0 = phi i64 [ 0, %if.end ], [ %inc, %for.inc ]
  %cmp1 = icmp ult i64 %i.0, %n
  br i1 %cmp1, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %arrayidx = getelementptr inbounds i64, i64* %ptr, i64 %i.0
  %0 = load i64, i64* %arrayidx, align 8
  call void @write(i64 %0)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add i64 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup, %if.then
  ret void
}

declare void @write(i64) #3

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  %cmp = icmp eq i64 %call, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %cleanup

if.end:                                           ; preds = %entry
  %call1 = call i64* @get_inputs(i64 %call)
  call void @sort(i64 %call, i64* %call1)
  call void @put_inputs(i64 %call, i64* %call1)
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  ret i32 0
}

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { allocsize(0) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { allocsize(0) }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 10, i32 15]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 10.0.0 (git@github.com:llvm/llvm-project.git d32170dbd5b0d54436537b6b75beaf44324e0c28)"}
