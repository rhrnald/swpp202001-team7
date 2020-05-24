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
  %tmp21 = bitcast i8* %call to i64*
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i64 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i64 %i.0, 50
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %arrayidx = getelementptr inbounds [50 x i64], [50 x i64]* %a, i64 0, i64 %i.0
  store i64 %i.0, i64* %arrayidx, align 8
  %sub = sub nsw i64 49, %i.0
  %arrayidx1 = getelementptr inbounds i64, i64* %tmp21, i64 %i.0
  store i64 %sub, i64* %arrayidx1, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i64 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  br label %for.cond3

for.cond3:                                        ; preds = %for.inc16, %for.end
  %sum.0 = phi i64 [ 0, %for.end ], [ %add15, %for.inc16 ]
  %i2.0 = phi i64 [ 0, %for.end ], [ %inc17, %for.inc16 ]
  %cmp4 = icmp slt i64 %i2.0, 50
  br i1 %cmp4, label %for.body6, label %for.cond.cleanup5

for.cond.cleanup5:                                ; preds = %for.cond3
  br label %for.end18

for.body6:                                        ; preds = %for.cond3
  %arrayidx7 = getelementptr inbounds [50 x i64], [50 x i64]* %a, i64 0, i64 %i2.0
  %tmp22 = load i64, i64* %arrayidx7, align 8
  %add = add nsw i64 %sum.0, %tmp22
  %arrayidx8 = getelementptr inbounds i64, i64* %tmp21, i64 %i2.0
  %tmp23 = load i64, i64* %arrayidx8, align 8
  %add9 = add nsw i64 %add, %tmp23
  %sub10 = sub nsw i64 49, %i2.0
  %arrayidx11 = getelementptr inbounds [50 x i64], [50 x i64]* %a, i64 0, i64 %sub10
  %tmp24 = load i64, i64* %arrayidx11, align 8
  %add12 = add nsw i64 %add9, %tmp24
  %sub13 = sub nsw i64 49, %i2.0
  %arrayidx14 = getelementptr inbounds i64, i64* %tmp21, i64 %sub13
  %tmp25 = load i64, i64* %arrayidx14, align 8
  %add15 = add nsw i64 %add12, %tmp25
  br label %for.inc16

for.inc16:                                        ; preds = %for.body6
  %inc17 = add nsw i64 %i2.0, 1
  br label %for.cond3

for.end18:                                        ; preds = %for.cond.cleanup5
  call void @write(i64 %sum.0)
  %tmp26 = bitcast [50 x i64]* %a to i8*
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind
declare dso_local noalias i8* @malloc(i64) #2

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
!1 = !{!"clang version 10.0.1 (https://github.com/llvm/llvm-project.git eaae6dfc545000e335e6f89abb9c78818383d7ad)"}
