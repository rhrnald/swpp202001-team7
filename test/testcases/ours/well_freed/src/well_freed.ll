; ModuleID = 'test/testcases/ours/well_freed/src/well_freed.raw.ll'
source_filename = "test/testcases/ours/well_freed/src/well_freed.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %call = call noalias i8* @malloc(i64 2048) #4
  %call1 = call noalias i8* @malloc(i64 2048) #4
  %call2 = call noalias i8* @malloc(i64 2048) #4
  %call3 = call i64 (...) @read()
  %conv = trunc i64 %call3 to i8
  store i8 %conv, i8* %call, align 1
  %call4 = call i64 (...) @read()
  %conv5 = trunc i64 %call4 to i8
  store i8 %conv5, i8* %call1, align 1
  %call6 = call i64 (...) @read()
  %conv7 = trunc i64 %call6 to i8
  store i8 %conv7, i8* %call2, align 1
  %arrayidx = getelementptr inbounds i8, i8* %call, i64 0
  %tmp = load i8, i8* %arrayidx, align 1
  %conv8 = zext i8 %tmp to i64
  call void @write(i64 %conv8)
  %arrayidx9 = getelementptr inbounds i8, i8* %call1, i64 0
  %tmp16 = load i8, i8* %arrayidx9, align 1
  %conv10 = zext i8 %tmp16 to i64
  call void @write(i64 %conv10)
  %arrayidx11 = getelementptr inbounds i8, i8* %call2, i64 0
  %tmp17 = load i8, i8* %arrayidx11, align 1
  %conv12 = zext i8 %tmp17 to i64
  call void @write(i64 %conv12)
  call void @free(i8* %call) #4
  call void @free(i8* %call1) #4
  call void @free(i8* %call2) #4
  %call13 = call noalias i8* @malloc(i64 2048) #4
  %call14 = call noalias i8* @malloc(i64 2048) #4
  %call15 = call i64 (...) @read()
  %conv16 = trunc i64 %call15 to i8
  store i8 %conv16, i8* %call13, align 1
  %call17 = call i64 (...) @read()
  %conv18 = trunc i64 %call17 to i8
  store i8 %conv18, i8* %call14, align 1
  %arrayidx19 = getelementptr inbounds i8, i8* %call13, i64 0
  %tmp18 = load i8, i8* %arrayidx19, align 1
  %conv20 = zext i8 %tmp18 to i64
  call void @write(i64 %conv20)
  %arrayidx21 = getelementptr inbounds i8, i8* %call14, i64 0
  %tmp19 = load i8, i8* %arrayidx21, align 1
  %conv22 = zext i8 %tmp19 to i64
  call void @write(i64 %conv22)
  call void @free(i8* %call13) #4
  call void @free(i8* %call14) #4
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind
declare dso_local noalias i8* @malloc(i64) #2

declare dso_local i64 @read(...) #3

declare dso_local void @write(i64) #3

; Function Attrs: nounwind
declare dso_local void @free(i8*) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (https://github.com/llvm/llvm-project.git f79cd71e145c6fd005ba4dd1238128dfa0dc2cb6)"}
