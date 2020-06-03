; ModuleID = 'test/testcases/ours/dynamic_square/src/dynamic_square.raw.ll'
source_filename = "test/testcases/ours/dynamic_square/src/dynamic_square.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  %mul = mul i64 8, %call
  %call1 = call noalias i8* @malloc(i64 %mul) #4
  %tmp = bitcast i8* %call1 to i64*
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %conv = sext i32 %i.0 to i64
  %cmp = icmp ult i64 %conv, %call
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %call3 = call i64 (...) @read()
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds i64, i64* %tmp, i64 %idxprom
  store i64 %call3, i64* %arrayidx, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  %sub = sub i64 %call, 1
  %conv5 = trunc i64 %sub to i32
  br label %for.cond6

for.cond6:                                        ; preds = %for.inc16, %for.end
  %ans.0 = phi i64 [ 0, %for.end ], [ %add, %for.inc16 ]
  %i4.0 = phi i32 [ %conv5, %for.end ], [ %dec, %for.inc16 ]
  %cmp7 = icmp sge i32 %i4.0, 0
  br i1 %cmp7, label %for.body10, label %for.cond.cleanup9

for.cond.cleanup9:                                ; preds = %for.cond6
  br label %for.end17

for.body10:                                       ; preds = %for.cond6
  %idxprom11 = sext i32 %i4.0 to i64
  %arrayidx12 = getelementptr inbounds i64, i64* %tmp, i64 %idxprom11
  %tmp16 = load i64, i64* %arrayidx12, align 8
  %idxprom13 = sext i32 %i4.0 to i64
  %arrayidx14 = getelementptr inbounds i64, i64* %tmp, i64 %idxprom13
  %tmp17 = load i64, i64* %arrayidx14, align 8
  %mul15 = mul i64 %tmp16, %tmp17
  %add = add i64 %ans.0, %mul15
  br label %for.inc16

for.inc16:                                        ; preds = %for.body10
  %dec = add nsw i32 %i4.0, -1
  br label %for.cond6

for.end17:                                        ; preds = %for.cond.cleanup9
  call void @write(i64 %ans.0)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local i64 @read(...) #2

; Function Attrs: nounwind
declare dso_local noalias i8* @malloc(i64) #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local void @write(i64) #2

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (https://github.com/llvm/llvm-project.git f79cd71e145c6fd005ba4dd1238128dfa0dc2cb6)"}
