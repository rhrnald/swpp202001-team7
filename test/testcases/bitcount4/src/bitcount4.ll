; ModuleID = '/tmp/a.ll'
source_filename = "bitcount4/src/bitcount4.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

@BitsSetTable256 = external global [256 x i32], align 16

; Function Attrs: nounwind ssp uwtable
define i32 @countSetBits(i32 %n) #0 {
entry:
  %and = and i32 %n, 255
  %idxprom = sext i32 %and to i64
  %arrayidx = getelementptr inbounds [256 x i32], [256 x i32]* @BitsSetTable256, i64 0, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4
  %shr = ashr i32 %n, 8
  %and1 = and i32 %shr, 255
  %idxprom2 = sext i32 %and1 to i64
  %arrayidx3 = getelementptr inbounds [256 x i32], [256 x i32]* @BitsSetTable256, i64 0, i64 %idxprom2
  %1 = load i32, i32* %arrayidx3, align 4
  %add = add nsw i32 %0, %1
  %shr4 = ashr i32 %n, 16
  %and5 = and i32 %shr4, 255
  %idxprom6 = sext i32 %and5 to i64
  %arrayidx7 = getelementptr inbounds [256 x i32], [256 x i32]* @BitsSetTable256, i64 0, i64 %idxprom6
  %2 = load i32, i32* %arrayidx7, align 4
  %add8 = add nsw i32 %add, %2
  %shr9 = ashr i32 %n, 24
  %idxprom10 = sext i32 %shr9 to i64
  %arrayidx11 = getelementptr inbounds [256 x i32], [256 x i32]* @BitsSetTable256, i64 0, i64 %idxprom10
  %3 = load i32, i32* %arrayidx11, align 4
  %add12 = add nsw i32 %add8, %3
  ret i32 %add12
}

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  store i32 0, i32* getelementptr inbounds ([256 x i32], [256 x i32]* @BitsSetTable256, i64 0, i64 0), align 16
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, 256
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %and = and i32 %i.0, 1
  %div = sdiv i32 %i.0, 2
  %idxprom = sext i32 %div to i64
  %arrayidx = getelementptr inbounds [256 x i32], [256 x i32]* @BitsSetTable256, i64 0, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4
  %add = add nsw i32 %and, %0
  %idxprom1 = sext i32 %i.0 to i64
  %arrayidx2 = getelementptr inbounds [256 x i32], [256 x i32]* @BitsSetTable256, i64 0, i64 %idxprom1
  store i32 %add, i32* %arrayidx2, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i32
  %call3 = call i32 @countSetBits(i32 %conv)
  %conv4 = sext i32 %call3 to i64
  call void @write(i64 %conv4)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

declare void @write(i64) #2

declare i64 @read(...) #2

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 10, i32 15]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 10.0.0 (git@github.com:llvm/llvm-project.git d32170dbd5b0d54436537b6b75beaf44324e0c28)"}
