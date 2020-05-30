; ModuleID = '/tmp/a.ll'
source_filename = "prime/src/prime.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

@primes = external global i64*, align 8
@checked = external global i64, align 8
@tail = external global i64*, align 8

; Function Attrs: nounwind ssp uwtable
define i64 @check_with_primes(i64 %n) #0 {
entry:
  %0 = load i64*, i64** @primes, align 8
  br label %while.cond

while.cond:                                       ; preds = %cleanup.cont, %entry
  %curr.0 = phi i64* [ %0, %entry ], [ %curr.1, %cleanup.cont ]
  %retval.0 = phi i64 [ 0, %entry ], [ %retval.1, %cleanup.cont ]
  %cmp = icmp ne i64* %curr.0, null
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %1 = load i64, i64* %curr.0, align 8
  %mul = mul i64 %1, %1
  %cmp1 = icmp ugt i64 %mul, %n
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  br label %cleanup

if.end:                                           ; preds = %while.body
  %rem = urem i64 %n, %1
  %cmp2 = icmp eq i64 %rem, 0
  br i1 %cmp2, label %if.then3, label %if.end4

if.then3:                                         ; preds = %if.end
  br label %cleanup

if.end4:                                          ; preds = %if.end
  %add.ptr = getelementptr inbounds i64, i64* %curr.0, i64 1
  %2 = load i64, i64* %add.ptr, align 8
  %3 = inttoptr i64 %2 to i64*
  br label %cleanup

cleanup:                                          ; preds = %if.end4, %if.then3, %if.then
  %curr.1 = phi i64* [ %curr.0, %if.then ], [ %curr.0, %if.then3 ], [ %3, %if.end4 ]
  %retval.1 = phi i64 [ %retval.0, %if.then ], [ 0, %if.then3 ], [ %retval.0, %if.end4 ]
  %cleanup.dest.slot.0 = phi i32 [ 3, %if.then ], [ 1, %if.then3 ], [ 0, %if.end4 ]
  switch i32 %cleanup.dest.slot.0, label %cleanup5 [
    i32 0, label %cleanup.cont
    i32 3, label %while.end
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %while.cond

while.end:                                        ; preds = %cleanup, %while.cond
  br label %cleanup5

cleanup5:                                         ; preds = %while.end, %cleanup
  %retval.2 = phi i64 [ %retval.1, %cleanup ], [ 1, %while.end ]
  ret i64 %retval.2
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind ssp uwtable
define i64 @add_primes(i64 %n) #0 {
entry:
  br label %while.cond

while.cond:                                       ; preds = %if.end5, %entry
  %retval.0 = phi i64 [ 0, %entry ], [ %retval.2, %if.end5 ]
  %0 = load i64, i64* @checked, align 8
  %1 = load i64, i64* @checked, align 8
  %mul = mul i64 %0, %1
  %cmp = icmp ult i64 %mul, %n
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %2 = load i64, i64* @checked, align 8
  %inc = add i64 %2, 1
  store i64 %inc, i64* @checked, align 8
  %3 = load i64, i64* @checked, align 8
  %call = call i64 @check_with_primes(i64 %3)
  %tobool = icmp ne i64 %call, 0
  br i1 %tobool, label %if.then, label %if.end5

if.then:                                          ; preds = %while.body
  %call1 = call noalias i8* @malloc(i64 16) #4
  %4 = bitcast i8* %call1 to i64*
  %5 = load i64, i64* @checked, align 8
  store i64 %5, i64* %4, align 8
  %add.ptr = getelementptr inbounds i64, i64* %4, i64 1
  store i64 0, i64* %add.ptr, align 8
  %6 = ptrtoint i64* %4 to i64
  %7 = load i64*, i64** @tail, align 8
  %add.ptr2 = getelementptr inbounds i64, i64* %7, i64 1
  store i64 %6, i64* %add.ptr2, align 8
  store i64* %4, i64** @tail, align 8
  %8 = load i64, i64* @checked, align 8
  %rem = urem i64 %n, %8
  %cmp3 = icmp eq i64 %rem, 0
  br i1 %cmp3, label %if.then4, label %if.end

if.then4:                                         ; preds = %if.then
  br label %cleanup

if.end:                                           ; preds = %if.then
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then4
  %retval.1 = phi i64 [ 0, %if.then4 ], [ %retval.0, %if.end ]
  %cleanup.dest.slot.0 = phi i32 [ 1, %if.then4 ], [ 0, %if.end ]
  switch i32 %cleanup.dest.slot.0, label %unreachable [
    i32 0, label %cleanup.cont
    i32 1, label %return
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %if.end5

if.end5:                                          ; preds = %cleanup.cont, %while.body
  %retval.2 = phi i64 [ %retval.1, %cleanup.cont ], [ %retval.0, %while.body ]
  br label %while.cond

while.end:                                        ; preds = %while.cond
  br label %return

return:                                           ; preds = %while.end, %cleanup
  %retval.3 = phi i64 [ %retval.1, %cleanup ], [ 1, %while.end ]
  ret i64 %retval.3

unreachable:                                      ; preds = %cleanup
  ret i64 0
}

; Function Attrs: allocsize(0)
declare noalias i8* @malloc(i64) #2

; Function Attrs: nounwind ssp uwtable
define i64 @is_prime(i64 %n) #0 {
entry:
  %call = call i64 @check_with_primes(i64 %n)
  %cmp = icmp eq i64 %call, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call i64 @add_primes(i64 %n)
  br label %return

return:                                           ; preds = %if.end, %if.then
  %retval.0 = phi i64 [ 0, %if.then ], [ %call1, %if.end ]
  ret i64 %retval.0
}

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %call = call i8* @malloc(i64 16) #4
  %0 = bitcast i8* %call to i64*
  store i64* %0, i64** @primes, align 8
  %1 = load i64*, i64** @primes, align 8
  store i64 2, i64* %1, align 8
  %2 = load i64*, i64** @primes, align 8
  %add.ptr = getelementptr inbounds i64, i64* %2, i64 1
  store i64 0, i64* %add.ptr, align 8
  %3 = load i64*, i64** @primes, align 8
  store i64* %3, i64** @tail, align 8
  store i64 2, i64* @checked, align 8
  br label %while.body

while.body:                                       ; preds = %cleanup.cont, %entry
  %call1 = call i64 (...) @read()
  %cmp = icmp eq i64 %call1, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  br label %cleanup

if.end:                                           ; preds = %while.body
  %call2 = call i64 @is_prime(i64 %call1)
  call void @write(i64 %call2)
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  %cleanup.dest.slot.0 = phi i32 [ 3, %if.then ], [ 0, %if.end ]
  switch i32 %cleanup.dest.slot.0, label %unreachable [
    i32 0, label %cleanup.cont
    i32 3, label %while.end
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %while.body

while.end:                                        ; preds = %cleanup
  ret i32 0

unreachable:                                      ; preds = %cleanup
  ret i32 0
}

declare i64 @read(...) #3

declare void @write(i64) #3

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { allocsize(0) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { allocsize(0) }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 10, i32 15]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 10.0.0 (git@github.com:llvm/llvm-project.git d32170dbd5b0d54436537b6b75beaf44324e0c28)"}
