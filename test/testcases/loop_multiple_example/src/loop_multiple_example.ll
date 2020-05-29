; ModuleID = 'workspace/testcases/loop_multiple_example/src/loop_multiple_example.raw.ll'
source_filename = "workspace/testcases/loop_multiple_example/src/loop_multiple_example.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %a = alloca [10 x [10 x [10 x i64]]], align 16
  %call = call i64 (...) @read()
  %call1 = call i64 (...) @read()
  %tmp = bitcast [10 x [10 x [10 x i64]]]* %a to i8*
  br label %for.cond

for.cond:                                         ; preds = %for.inc6, %entry
  %i.0 = phi i64 [ 0, %entry ], [ %inc7, %for.inc6 ]
  %cmp = icmp ult i64 %i.0, %call
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end8

for.body:                                         ; preds = %for.cond
  br label %for.cond2

for.cond2:                                        ; preds = %for.inc, %for.body
  %j.0 = phi i64 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp3 = icmp ult i64 %j.0, %call
  br i1 %cmp3, label %for.body5, label %for.cond.cleanup4

for.cond.cleanup4:                                ; preds = %for.cond2
  br label %for.end

for.body5:                                        ; preds = %for.cond2
  br label %for.inc

for.inc:                                          ; preds = %for.body5
  %inc = add i64 %j.0, 1
  br label %for.cond2

for.end:                                          ; preds = %for.cond.cleanup4
  br label %for.inc6

for.inc6:                                         ; preds = %for.end
  %inc7 = add i64 %i.0, 1
  br label %for.cond

for.end8:                                         ; preds = %for.cond.cleanup
  br label %for.cond10

for.cond10:                                       ; preds = %for.inc32, %for.end8
  %i9.0 = phi i64 [ 0, %for.end8 ], [ %inc33, %for.inc32 ]
  %cmp11 = icmp ult i64 %i9.0, %call
  br i1 %cmp11, label %for.body13, label %for.cond.cleanup12

for.cond.cleanup12:                               ; preds = %for.cond10
  br label %for.end34

for.body13:                                       ; preds = %for.cond10
  br label %for.cond15

for.cond15:                                       ; preds = %for.inc29, %for.body13
  %j14.0 = phi i64 [ 0, %for.body13 ], [ %inc30, %for.inc29 ]
  %cmp16 = icmp ult i64 %j14.0, %call
  br i1 %cmp16, label %for.body18, label %for.cond.cleanup17

for.cond.cleanup17:                               ; preds = %for.cond15
  br label %for.end31

for.body18:                                       ; preds = %for.cond15
  br label %for.cond19

for.cond19:                                       ; preds = %for.inc26, %for.body18
  %k.0 = phi i64 [ 0, %for.body18 ], [ %inc27, %for.inc26 ]
  %cmp20 = icmp ult i64 %k.0, %call
  br i1 %cmp20, label %for.body22, label %for.cond.cleanup21

for.cond.cleanup21:                               ; preds = %for.cond19
  br label %for.end28

for.body22:                                       ; preds = %for.cond19
  %mul23 = mul i64 %i9.0, %j14.0
  %add = add i64 %mul23, %k.0
  %arrayidx = getelementptr inbounds [10 x [10 x [10 x i64]]], [10 x [10 x [10 x i64]]]* %a, i64 0, i64 %k.0
  %arrayidx24 = getelementptr inbounds [10 x [10 x i64]], [10 x [10 x i64]]* %arrayidx, i64 0, i64 %i9.0
  %arrayidx25 = getelementptr inbounds [10 x i64], [10 x i64]* %arrayidx24, i64 0, i64 %j14.0
  store i64 %add, i64* %arrayidx25, align 8
  br label %for.inc26

for.inc26:                                        ; preds = %for.body22
  %inc27 = add i64 %k.0, 1
  br label %for.cond19

for.end28:                                        ; preds = %for.cond.cleanup21
  br label %for.inc29

for.inc29:                                        ; preds = %for.end28
  %inc30 = add i64 %j14.0, 1
  br label %for.cond15

for.end31:                                        ; preds = %for.cond.cleanup17
  br label %for.inc32

for.inc32:                                        ; preds = %for.end31
  %inc33 = add i64 %i9.0, 1
  br label %for.cond10

for.end34:                                        ; preds = %for.cond.cleanup12
  br label %for.cond36

for.cond36:                                       ; preds = %for.inc62, %for.end34
  %ans.0 = phi i64 [ 0, %for.end34 ], [ %ans.1, %for.inc62 ]
  %i35.0 = phi i64 [ 0, %for.end34 ], [ %inc63, %for.inc62 ]
  %cmp37 = icmp ult i64 %i35.0, %call
  br i1 %cmp37, label %for.body39, label %for.cond.cleanup38

for.cond.cleanup38:                               ; preds = %for.cond36
  br label %for.end64

for.body39:                                       ; preds = %for.cond36
  br label %for.cond41

for.cond41:                                       ; preds = %for.inc59, %for.body39
  %ans.1 = phi i64 [ %ans.0, %for.body39 ], [ %ans.2, %for.inc59 ]
  %j40.0 = phi i64 [ 0, %for.body39 ], [ %inc60, %for.inc59 ]
  %cmp42 = icmp ult i64 %j40.0, %call
  br i1 %cmp42, label %for.body44, label %for.cond.cleanup43

for.cond.cleanup43:                               ; preds = %for.cond41
  br label %for.end61

for.body44:                                       ; preds = %for.cond41
  br label %for.cond46

for.cond46:                                       ; preds = %for.inc56, %for.body44
  %ans.2 = phi i64 [ %ans.1, %for.body44 ], [ %ans.3, %for.inc56 ]
  %k45.0 = phi i64 [ 0, %for.body44 ], [ %inc57, %for.inc56 ]
  %cmp47 = icmp ult i64 %k45.0, %call
  br i1 %cmp47, label %for.body49, label %for.cond.cleanup48

for.cond.cleanup48:                               ; preds = %for.cond46
  br label %for.end58

for.body49:                                       ; preds = %for.cond46
  %cmp50 = icmp ne i64 %call1, %call
  br i1 %cmp50, label %if.then, label %if.end

if.then:                                          ; preds = %for.body49
  %arrayidx51 = getelementptr inbounds [10 x [10 x [10 x i64]]], [10 x [10 x [10 x i64]]]* %a, i64 0, i64 %j40.0
  %arrayidx52 = getelementptr inbounds [10 x [10 x i64]], [10 x [10 x i64]]* %arrayidx51, i64 0, i64 %k45.0
  %arrayidx53 = getelementptr inbounds [10 x i64], [10 x i64]* %arrayidx52, i64 0, i64 %i35.0
  %tmp41 = load i64, i64* %arrayidx53, align 8
  %add54 = add i64 2, %tmp41
  %add55 = add i64 %ans.2, %add54
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body49
  %ans.3 = phi i64 [ %add55, %if.then ], [ %ans.2, %for.body49 ]
  br label %for.inc56

for.inc56:                                        ; preds = %if.end
  %inc57 = add i64 %k45.0, 1
  br label %for.cond46

for.end58:                                        ; preds = %for.cond.cleanup48
  br label %for.inc59

for.inc59:                                        ; preds = %for.end58
  %inc60 = add i64 %j40.0, 1
  br label %for.cond41

for.end61:                                        ; preds = %for.cond.cleanup43
  br label %for.inc62

for.inc62:                                        ; preds = %for.end61
  %inc63 = add i64 %i35.0, 1
  br label %for.cond36

for.end64:                                        ; preds = %for.cond.cleanup38
  call void @write(i64 %ans.0)
  %tmp42 = bitcast [10 x [10 x [10 x i64]]]* %a to i8*
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
