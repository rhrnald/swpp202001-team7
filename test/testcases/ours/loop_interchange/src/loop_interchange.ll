; ModuleID = 'workspace/testcases/loop_interchange/src/loop_interchange.raw.ll'
source_filename = "workspace/testcases/loop_interchange/src/loop_interchange.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %a = alloca [30 x [30 x i64]], align 16
  %call = call i64 (...) @read()
  %tmp = bitcast [30 x [30 x i64]]* %a to i8*
  br label %for.cond

for.cond:                                         ; preds = %for.inc6, %entry
  %i.0 = phi i64 [ 0, %entry ], [ %inc7, %for.inc6 ]
  %cmp = icmp ult i64 %i.0, %call
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end8

for.body:                                         ; preds = %for.cond
  br label %for.cond1

for.cond1:                                        ; preds = %for.inc, %for.body
  %j.0 = phi i64 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp ult i64 %j.0, %call
  br i1 %cmp2, label %for.body4, label %for.cond.cleanup3

for.cond.cleanup3:                                ; preds = %for.cond1
  br label %for.end

for.body4:                                        ; preds = %for.cond1
  %add = add i64 %i.0, %j.0
  %arrayidx = getelementptr inbounds [30 x [30 x i64]], [30 x [30 x i64]]* %a, i64 0, i64 %j.0
  %arrayidx5 = getelementptr inbounds [30 x i64], [30 x i64]* %arrayidx, i64 0, i64 %i.0
  store i64 %add, i64* %arrayidx5, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body4
  %inc = add i64 %j.0, 1
  br label %for.cond1

for.end:                                          ; preds = %for.cond.cleanup3
  br label %for.inc6

for.inc6:                                         ; preds = %for.end
  %inc7 = add i64 %i.0, 1
  br label %for.cond

for.end8:                                         ; preds = %for.cond.cleanup
  br label %for.cond10

for.cond10:                                       ; preds = %for.inc24, %for.end8
  %i9.0 = phi i64 [ 0, %for.end8 ], [ %inc25, %for.inc24 ]
  %cmp11 = icmp ult i64 %i9.0, %call
  br i1 %cmp11, label %for.body13, label %for.cond.cleanup12

for.cond.cleanup12:                               ; preds = %for.cond10
  br label %for.end26

for.body13:                                       ; preds = %for.cond10
  br label %for.cond15

for.cond15:                                       ; preds = %for.inc21, %for.body13
  %j14.0 = phi i64 [ 0, %for.body13 ], [ %inc22, %for.inc21 ]
  %cmp16 = icmp ult i64 %j14.0, %call
  br i1 %cmp16, label %for.body18, label %for.cond.cleanup17

for.cond.cleanup17:                               ; preds = %for.cond15
  br label %for.end23

for.body18:                                       ; preds = %for.cond15
  %arrayidx19 = getelementptr inbounds [30 x [30 x i64]], [30 x [30 x i64]]* %a, i64 0, i64 %i9.0
  %arrayidx20 = getelementptr inbounds [30 x i64], [30 x i64]* %arrayidx19, i64 0, i64 %j14.0
  %tmp19 = load i64, i64* %arrayidx20, align 8
  call void @write(i64 %tmp19)
  br label %for.inc21

for.inc21:                                        ; preds = %for.body18
  %inc22 = add i64 %j14.0, 1
  br label %for.cond15

for.end23:                                        ; preds = %for.cond.cleanup17
  br label %for.inc24

for.inc24:                                        ; preds = %for.end23
  %inc25 = add i64 %i9.0, 1
  br label %for.cond10

for.end26:                                        ; preds = %for.cond.cleanup12
  %tmp20 = bitcast [30 x [30 x i64]]* %a to i8*
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local i64 @read(...) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local void @write(i64) #2

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (https://github.com/llvm/llvm-project.git f79cd71e145c6fd005ba4dd1238128dfa0dc2cb6)"}
