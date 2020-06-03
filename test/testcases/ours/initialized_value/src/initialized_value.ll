; ModuleID = 'test/testcases/ours/initialized_value/src/initialized_value.raw.ll'
source_filename = "test/testcases/ours/initialized_value/src/initialized_value.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i64 @max(i64 %a, i64 %b) #0 {
entry:
  %cmp = icmp ugt i64 %a, %b
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i64 [ %a, %cond.true ], [ %b, %cond.false ]
  ret i64 %cond
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  %mul = mul i64 8, %call
  %call1 = call noalias i8* @malloc(i64 %mul) #4
  %tmp = bitcast i8* %call1 to i64*
  %mul2 = mul i64 8, %call
  %call3 = call noalias i8* @malloc(i64 %mul2) #4
  %tmp15 = bitcast i8* %call3 to i64*
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %conv = sext i32 %i.0 to i64
  %cmp = icmp ult i64 %conv, %call
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %call5 = call i64 (...) @read()
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds i64, i64* %tmp15, i64 %idxprom
  store i64 %call5, i64* %arrayidx, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  br label %for.cond7

for.cond7:                                        ; preds = %for.inc18, %for.end
  %i6.0 = phi i32 [ 0, %for.end ], [ %inc19, %for.inc18 ]
  %conv8 = sext i32 %i6.0 to i64
  %cmp9 = icmp ult i64 %conv8, %call
  br i1 %cmp9, label %for.body12, label %for.cond.cleanup11

for.cond.cleanup11:                               ; preds = %for.cond7
  br label %for.end20

for.body12:                                       ; preds = %for.cond7
  %idxprom13 = sext i32 %i6.0 to i64
  %arrayidx14 = getelementptr inbounds i64, i64* %tmp, i64 %idxprom13
  %tmp16 = load i64, i64* %arrayidx14, align 8
  %idxprom15 = sext i32 %i6.0 to i64
  %arrayidx16 = getelementptr inbounds i64, i64* %tmp15, i64 %idxprom15
  %tmp17 = load i64, i64* %arrayidx16, align 8
  %call17 = call i64 @max(i64 %tmp16, i64 %tmp17)
  call void @write(i64 %call17)
  br label %for.inc18

for.inc18:                                        ; preds = %for.body12
  %inc19 = add nsw i32 %i6.0, 1
  br label %for.cond7

for.end20:                                        ; preds = %for.cond.cleanup11
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
