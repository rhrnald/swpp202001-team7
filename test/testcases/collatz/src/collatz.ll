; ModuleID = '/tmp/a.ll'
source_filename = "collatz/src/collatz.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

; Function Attrs: nounwind ssp uwtable
define i32 @collatz(i16* %iter, i32 %n) #0 {
entry:
  %conv = zext i32 %n to i64
  call void @write(i64 %conv)
  %cmp = icmp ule i32 %n, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  %0 = load i16, i16* %iter, align 2
  %conv2 = sext i16 %0 to i32
  %cmp3 = icmp slt i32 %conv2, 0
  br i1 %cmp3, label %if.then5, label %if.end6

if.then5:                                         ; preds = %if.end
  br label %return

if.end6:                                          ; preds = %if.end
  %1 = load i16, i16* %iter, align 2
  %conv7 = sext i16 %1 to i32
  %add = add nsw i32 %conv7, 1
  %conv8 = trunc i32 %add to i16
  store i16 %conv8, i16* %iter, align 2
  %rem = urem i32 %n, 2
  %cmp9 = icmp eq i32 %rem, 0
  br i1 %cmp9, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.end6
  %div = udiv i32 %n, 2
  br label %cond.end

cond.false:                                       ; preds = %if.end6
  %mul = mul i32 3, %n
  %add11 = add i32 %mul, 1
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %div, %cond.true ], [ %add11, %cond.false ]
  %call = call i32 @collatz(i16* %iter, i32 %cond)
  br label %return

return:                                           ; preds = %cond.end, %if.then5, %if.then
  %retval.0 = phi i32 [ %n, %if.then ], [ -1, %if.then5 ], [ %call, %cond.end ]
  ret i32 %retval.0
}

declare void @write(i64) #1

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %iter = alloca i16, align 2
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i32
  store i16 0, i16* %iter, align 2
  %call1 = call i32 @collatz(i16* %iter, i32 %conv)
  %0 = load i16, i16* %iter, align 2
  %conv2 = sext i16 %0 to i64
  call void @write(i64 %conv2)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

declare i64 @read(...) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 10, i32 15]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 10.0.0 (git@github.com:llvm/llvm-project.git d32170dbd5b0d54436537b6b75beaf44324e0c28)"}
