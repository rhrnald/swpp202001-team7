; ModuleID = './workspace/testcases/expnear/src/expnear.raw.ll'
source_filename = "./workspace/testcases/expnear/src/expnear.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %i.0 = phi i64 [ 1, %entry ], [ %add, %while.body ]
  %cmp = icmp ult i64 %i.0, %call
  %conv = zext i1 %cmp to i32
  %sub = sub i64 0, %i.0
  %sub1 = sub i64 0, %call
  %cmp2 = icmp ugt i64 %sub, %sub1
  %conv3 = zext i1 %cmp2 to i32
  %and = and i32 %conv, %conv3
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %add = add i64 %i.0, %i.0
  br label %while.cond

while.end:                                        ; preds = %while.cond
  call void @write(i64 %i.0)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare i64 @read(...) #2

declare void @write(i64) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [3 x i32] [i32 10, i32 15, i32 4]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 10.0.1 (git@github.com:llvm/llvm-project.git 92d5c1be9ee93850c0a8903f05f36a23ee835dc2)"}
