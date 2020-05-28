; ModuleID = 'workspace/testcases/reorder/src/reorder.raw.ll'
source_filename = "workspace/testcases/reorder/src/reorder.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %a = alloca [50 x i64], align 16
  %tmp = bitcast [50 x i64]* %a to i8*
  %call = call noalias i8* @malloc(i64 400) #4
  %tmp24 = bitcast i8* %call to i64*
  %call1 = call i64 (...) @read()
  %cmp = icmp sgt i64 %call1, 50
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %limit.0 = phi i64 [ 50, %if.then ], [ %call1, %entry ]
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.end
  %i.0 = phi i64 [ 0, %if.end ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i64 %i.0, %limit.0
  br i1 %cmp2, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %arrayidx = getelementptr inbounds [50 x i64], [50 x i64]* %a, i64 0, i64 %i.0
  store i64 %i.0, i64* %arrayidx, align 8
  %sub = sub nsw i64 49, %i.0
  %arrayidx3 = getelementptr inbounds i64, i64* %tmp24, i64 %i.0
  store i64 %sub, i64* %arrayidx3, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i64 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  br label %for.cond5

for.cond5:                                        ; preds = %for.inc18, %for.end
  %sum.0 = phi i64 [ 0, %for.end ], [ %add17, %for.inc18 ]
  %i4.0 = phi i64 [ 0, %for.end ], [ %inc19, %for.inc18 ]
  %cmp6 = icmp slt i64 %i4.0, %limit.0
  br i1 %cmp6, label %for.body8, label %for.cond.cleanup7

for.cond.cleanup7:                                ; preds = %for.cond5
  br label %for.end20

for.body8:                                        ; preds = %for.cond5
  %arrayidx9 = getelementptr inbounds [50 x i64], [50 x i64]* %a, i64 0, i64 %i4.0
  %tmp25 = load i64, i64* %arrayidx9, align 8
  %add = add nsw i64 %sum.0, %tmp25
  %arrayidx10 = getelementptr inbounds i64, i64* %tmp24, i64 %i4.0
  %tmp26 = load i64, i64* %arrayidx10, align 8
  %add11 = add nsw i64 %add, %tmp26
  %sub12 = sub nsw i64 49, %i4.0
  %arrayidx13 = getelementptr inbounds [50 x i64], [50 x i64]* %a, i64 0, i64 %sub12
  %tmp27 = load i64, i64* %arrayidx13, align 8
  %add14 = add nsw i64 %add11, %tmp27
  %sub15 = sub nsw i64 49, %i4.0
  %arrayidx16 = getelementptr inbounds i64, i64* %tmp24, i64 %sub15
  %tmp28 = load i64, i64* %arrayidx16, align 8
  %add17 = add nsw i64 %add14, %tmp28
  br label %for.inc18

for.inc18:                                        ; preds = %for.body8
  %inc19 = add nsw i64 %i4.0, 1
  br label %for.cond5

for.end20:                                        ; preds = %for.cond.cleanup7
  call void @write(i64 %sum.0)
  %tmp29 = bitcast [50 x i64]* %a to i8*
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind
declare dso_local noalias i8* @malloc(i64) #2

declare dso_local i64 @read(...) #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local void @write(i64) #3

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (https://github.com/llvm/llvm-project.git f79cd71e145c6fd005ba4dd1238128dfa0dc2cb6)"}
