; ModuleID = './workspace/testcases/free_bytes/src/free_bytes.raw.ll'
source_filename = "./workspace/testcases/free_bytes/src/free_bytes.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

; Function Attrs: nounwind ssp uwtable
define i8* @__alloca_bytes__(i64 %size, i64 %free_in_this_block, i64 %align) #0 {
entry:
  %call = call i8* @malloc(i64 %size) #4
  ret i8* %call
}

; Function Attrs: allocsize(0)
declare i8* @malloc(i64) #1

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  %call1 = call i8* @__alloca_bytes__(i64 8, i64 0, i64 0)
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %s.0 = phi i8 [ 0, %entry ], [ %conv8, %for.inc ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %r.0 = phi i64 [ %call, %entry ], [ %shr, %for.inc ]
  %cmp = icmp slt i32 %i.0, 8
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %add = add nsw i32 %i.0, 1
  %mul = mul nsw i32 %add, 8
  %conv = sext i32 %mul to i64
  %call2 = call i8* @__alloca_bytes__(i64 %conv, i64 1, i64 0)
  %conv3 = trunc i64 %r.0 to i8
  store i8 %conv3, i8* %call2, align 1
  %shr = lshr i64 %r.0, 8
  %tmp = load i8, i8* %call2, align 1
  %conv4 = zext i8 %tmp to i64
  call void @write(i64 %conv4)
  %tmp12 = load i8, i8* %call2, align 1
  %conv5 = zext i8 %tmp12 to i32
  %conv6 = zext i8 %s.0 to i32
  %add7 = add nsw i32 %conv6, %conv5
  %conv8 = trunc i32 %add7 to i8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  store i8 %s.0, i8* %call1, align 1
  %tmp13 = load i8, i8* %call1, align 1
  %conv9 = zext i8 %tmp13 to i64
  call void @write(i64 %conv9)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

declare i64 @read(...) #3

declare void @write(i64) #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { allocsize(0) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { allocsize(0) }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [3 x i32] [i32 10, i32 15, i32 4]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 10.0.1 (git@github.com:llvm/llvm-project.git 92d5c1be9ee93850c0a8903f05f36a23ee835dc2)"}
