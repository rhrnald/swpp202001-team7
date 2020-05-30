; ModuleID = 'workspace/testcases/various_types_sum/src/various_types_sum.raw.ll'
source_filename = "workspace/testcases/various_types_sum/src/various_types_sum.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i64 @sum_of(i8 signext %a, i32 %b, i32 %c, i8 signext %d, i8* %e) #0 {
entry:
  %conv = sext i8 %a to i32
  %add = add nsw i32 %conv, %b
  %add1 = add nsw i32 %add, %c
  %conv2 = sext i8 %d to i32
  %add3 = add nsw i32 %add1, %conv2
  %conv4 = sext i32 %add3 to i64
  %tmp = ptrtoint i8* %e to i64
  %add5 = add nsw i64 %conv4, %tmp
  ret i64 %add5
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %l.0 = phi i64 [ %call, %entry ], [ %dec, %while.body ]
  %dec = add nsw i64 %l.0, -1
  %tobool = icmp ne i64 %l.0, 0
  br i1 %tobool, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %call1 = call i64 (...) @read()
  %conv = trunc i64 %call1 to i8
  %call2 = call i64 (...) @read()
  %conv3 = trunc i64 %call2 to i32
  %call4 = call i64 (...) @read()
  %conv5 = trunc i64 %call4 to i32
  %call6 = call i64 (...) @read()
  %conv7 = trunc i64 %call6 to i8
  %call8 = call i64 @sum_of(i8 signext %conv, i32 %conv3, i32 %conv5, i8 signext %conv7, i8* null)
  %conv9 = trunc i64 %call8 to i32
  %conv10 = zext i32 %conv9 to i64
  call void @write(i64 %conv10)
  br label %while.cond

while.end:                                        ; preds = %while.cond
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
