; ModuleID = './workspace/testcases/alloca_bytes/src/alloca_bytes.raw.ll'
source_filename = "./workspace/testcases/alloca_bytes/src/alloca_bytes.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

; Function Attrs: nounwind ssp uwtable
define i8* @__alloca_bytes__(i64 %size) #0 {
entry:
  %call = call i8* @malloc(i64 %size) #4
  ret i8* %call
}

; Function Attrs: allocsize(0)
declare i8* @malloc(i64) #1

; Function Attrs: nounwind ssp uwtable
define void @heavy_func(i64 %a1, i64 %a2, i64 %a3, i64 %a4, i64 %a5, i64 %a6, i64 %a7, i64 %a8, i64 %a9, i64 %a10, i64 %a11, i64 %a12, i64 %a13, i64 %a14, i64 %a15, i64 %a16) #0 {
entry:
  %add = add i64 %a1, %a2
  %add1 = add i64 %add, %a3
  %add2 = add i64 %add1, %a4
  %add3 = add i64 %add2, %a5
  %add4 = add i64 %add3, %a6
  %add5 = add i64 %add4, %a7
  %add6 = add i64 %add5, %a8
  %add7 = add i64 %add6, %a9
  %add8 = add i64 %add7, %a10
  %add9 = add i64 %add8, %a11
  %add10 = add i64 %add9, %a12
  %add11 = add i64 %add10, %a13
  %add12 = add i64 %add11, %a14
  %add13 = add i64 %add12, %a15
  %add14 = add i64 %add13, %a16
  call void @write(i64 %add14)
  ret void
}

declare void @write(i64) #2

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %call = call i8* @__alloca_bytes__(i64 8)
  %call1 = call i64 (...) @read()
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %r.0 = phi i64 [ %call1, %entry ], [ %mul, %for.inc ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, 8
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %conv = trunc i64 %r.0 to i8
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds i8, i8* %call, i64 %idxprom
  store i8 %conv, i8* %arrayidx, align 1
  %shr = lshr i64 %r.0, 8
  %mul = mul i64 %shr, -1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  br label %for.cond3

for.cond3:                                        ; preds = %for.inc11, %for.end
  %r.1 = phi i64 [ 0, %for.end ], [ %add, %for.inc11 ]
  %i2.0 = phi i32 [ 0, %for.end ], [ %inc12, %for.inc11 ]
  %cmp4 = icmp slt i32 %i2.0, 8
  br i1 %cmp4, label %for.body7, label %for.cond.cleanup6

for.cond.cleanup6:                                ; preds = %for.cond3
  br label %for.end13

for.body7:                                        ; preds = %for.cond3
  %idxprom8 = sext i32 %i2.0 to i64
  %arrayidx9 = getelementptr inbounds i8, i8* %call, i64 %idxprom8
  %tmp = load i8, i8* %arrayidx9, align 1
  %conv10 = zext i8 %tmp to i64
  %add = add i64 %r.1, %conv10
  br label %for.inc11

for.inc11:                                        ; preds = %for.body7
  %inc12 = add nsw i32 %i2.0, 1
  br label %for.cond3

for.end13:                                        ; preds = %for.cond.cleanup6
  call void @write(i64 %r.1)
  %call14 = call i64 (...) @read()
  %call15 = call i64 (...) @read()
  %call16 = call i64 (...) @read()
  %call17 = call i64 (...) @read()
  %call18 = call i64 (...) @read()
  %call19 = call i64 (...) @read()
  %call20 = call i64 (...) @read()
  %call21 = call i64 (...) @read()
  %call22 = call i64 (...) @read()
  %call23 = call i64 (...) @read()
  %call24 = call i64 (...) @read()
  %call25 = call i64 (...) @read()
  %call26 = call i64 (...) @read()
  %call27 = call i64 (...) @read()
  %call28 = call i64 (...) @read()
  %call29 = call i64 (...) @read()
  call void @heavy_func(i64 %call14, i64 %call15, i64 %call16, i64 %call17, i64 %call18, i64 %call19, i64 %call20, i64 %call21, i64 %call22, i64 %call23, i64 %call24, i64 %call25, i64 %call26, i64 %call27, i64 %call28, i64 %call29)
  %call30 = call i64 (...) @read()
  %call31 = call i64 (...) @read()
  %call32 = call i64 (...) @read()
  %call33 = call i64 (...) @read()
  %call34 = call i64 (...) @read()
  %call35 = call i64 (...) @read()
  %call36 = call i64 (...) @read()
  %call37 = call i64 (...) @read()
  %call38 = call i64 (...) @read()
  %call39 = call i64 (...) @read()
  %call40 = call i64 (...) @read()
  %call41 = call i64 (...) @read()
  %call42 = call i64 (...) @read()
  %call43 = call i64 (...) @read()
  %call44 = call i64 (...) @read()
  call void @heavy_func(i64 %call30, i64 %call31, i64 %call32, i64 %call33, i64 %call34, i64 %call35, i64 %call36, i64 0, i64 %call37, i64 %call38, i64 %call39, i64 %call40, i64 %call41, i64 %call42, i64 %call43, i64 %call44)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

declare i64 @read(...) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { allocsize(0) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { allocsize(0) }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [3 x i32] [i32 10, i32 15, i32 4]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 10.0.1 (git@github.com:llvm/llvm-project.git 92d5c1be9ee93850c0a8903f05f36a23ee835dc2)"}
