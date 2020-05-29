; ModuleID = 'workspace/testcases/four_i8_sum/src/four_i8_sum.raw.ll'
source_filename = "workspace/testcases/four_i8_sum/src/four_i8_sum.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local signext i8 @sum_of(i8 signext %a, i8 signext %b, i8 signext %c, i8 signext %d) #0 {
entry:
  %conv = sext i8 %a to i32
  %conv1 = sext i8 %b to i32
  %add = add nsw i32 %conv, %conv1
  %conv2 = sext i8 %c to i32
  %add3 = add nsw i32 %add, %conv2
  %conv4 = sext i8 %d to i32
  %add5 = add nsw i32 %add3, %conv4
  %conv6 = trunc i32 %add5 to i8
  ret i8 %conv6
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i8
  %call1 = call i64 (...) @read()
  %conv2 = trunc i64 %call1 to i8
  %call3 = call i64 (...) @read()
  %conv4 = trunc i64 %call3 to i8
  %call5 = call i64 (...) @read()
  %conv6 = trunc i64 %call5 to i8
  %call7 = call signext i8 @sum_of(i8 signext %conv, i8 signext %conv2, i8 signext %conv4, i8 signext %conv6)
  %conv8 = sext i8 %call7 to i32
  %conv9 = zext i32 %conv8 to i64
  call void @write(i64 %conv9)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local i64 @read(...) #2

declare dso_local void @write(i64) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:llvm/llvm-project.git b11ecd196540d87cb7db190d405056984740d2ce)"}
