; ModuleID = '/tmp/a.ll'
source_filename = "binary_tree/src/binary_tree.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

; Function Attrs: nounwind ssp uwtable
define i64 @insert(i64* %root, i64 %data) #0 {
entry:
  br label %while.cond

while.cond:                                       ; preds = %cleanup, %entry
  %curr.0 = phi i64* [ %root, %entry ], [ %curr.1, %cleanup ]
  %retval.0 = phi i64 [ 0, %entry ], [ %retval.1, %cleanup ]
  br label %while.body

while.body:                                       ; preds = %while.cond
  %0 = load i64, i64* %curr.0, align 8
  %cmp = icmp ugt i64 %0, %data
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %while.body
  %add.ptr = getelementptr inbounds i64, i64* %curr.0, i64 1
  %1 = load i64, i64* %add.ptr, align 8
  %2 = inttoptr i64 %1 to i64*
  %cmp1 = icmp eq i64* %2, null
  br i1 %cmp1, label %if.then2, label %if.end

if.then2:                                         ; preds = %if.then
  %call = call noalias i8* @malloc(i64 24) #4
  %3 = bitcast i8* %call to i64*
  store i64 %data, i64* %3, align 8
  %add.ptr3 = getelementptr inbounds i64, i64* %3, i64 1
  store i64 0, i64* %add.ptr3, align 8
  %add.ptr4 = getelementptr inbounds i64, i64* %3, i64 2
  store i64 0, i64* %add.ptr4, align 8
  %4 = ptrtoint i64* %3 to i64
  %add.ptr5 = getelementptr inbounds i64, i64* %curr.0, i64 1
  store i64 %4, i64* %add.ptr5, align 8
  br label %cleanup

if.end:                                           ; preds = %if.then
  br label %cleanup

if.else:                                          ; preds = %while.body
  %cmp6 = icmp ult i64 %0, %data
  br i1 %cmp6, label %if.then7, label %if.else17

if.then7:                                         ; preds = %if.else
  %add.ptr8 = getelementptr inbounds i64, i64* %curr.0, i64 2
  %5 = load i64, i64* %add.ptr8, align 8
  %6 = inttoptr i64 %5 to i64*
  %cmp9 = icmp eq i64* %6, null
  br i1 %cmp9, label %if.then10, label %if.end16

if.then10:                                        ; preds = %if.then7
  %call12 = call noalias i8* @malloc(i64 24) #4
  %7 = bitcast i8* %call12 to i64*
  store i64 %data, i64* %7, align 8
  %add.ptr13 = getelementptr inbounds i64, i64* %7, i64 1
  store i64 0, i64* %add.ptr13, align 8
  %add.ptr14 = getelementptr inbounds i64, i64* %7, i64 2
  store i64 0, i64* %add.ptr14, align 8
  %8 = ptrtoint i64* %7 to i64
  %add.ptr15 = getelementptr inbounds i64, i64* %curr.0, i64 2
  store i64 %8, i64* %add.ptr15, align 8
  br label %cleanup

if.end16:                                         ; preds = %if.then7
  br label %cleanup

if.else17:                                        ; preds = %if.else
  br label %cleanup

cleanup:                                          ; preds = %if.else17, %if.end16, %if.then10, %if.end, %if.then2
  %curr.1 = phi i64* [ %curr.0, %if.then2 ], [ %2, %if.end ], [ %curr.0, %if.then10 ], [ %6, %if.end16 ], [ %curr.0, %if.else17 ]
  %cleanup.dest.slot.0 = phi i32 [ 1, %if.then2 ], [ 2, %if.end ], [ 1, %if.then10 ], [ 2, %if.end16 ], [ 1, %if.else17 ]
  %retval.1 = phi i64 [ 1, %if.then2 ], [ %retval.0, %if.end ], [ 1, %if.then10 ], [ %retval.0, %if.end16 ], [ 0, %if.else17 ]
  switch i32 %cleanup.dest.slot.0, label %cleanup19 [
    i32 2, label %while.cond
  ]

cleanup19:                                        ; preds = %cleanup
  ret i64 %retval.1
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: allocsize(0)
declare noalias i8* @malloc(i64) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind ssp uwtable
define i64* @adjust(i64* %node) #0 {
entry:
  %add.ptr = getelementptr inbounds i64, i64* %node, i64 1
  %0 = load i64, i64* %add.ptr, align 8
  %1 = inttoptr i64 %0 to i64*
  %cmp = icmp eq i64* %1, null
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %add.ptr1 = getelementptr inbounds i64, i64* %node, i64 2
  %2 = load i64, i64* %add.ptr1, align 8
  %3 = inttoptr i64 %2 to i64*
  br label %cleanup

if.end:                                           ; preds = %entry
  br label %while.cond

while.cond:                                       ; preds = %while.body, %if.end
  %rightmost.0 = phi i64* [ %1, %if.end ], [ %7, %while.body ]
  %parent.0 = phi i64* [ null, %if.end ], [ %rightmost.0, %while.body ]
  %add.ptr2 = getelementptr inbounds i64, i64* %rightmost.0, i64 2
  %4 = load i64, i64* %add.ptr2, align 8
  %5 = inttoptr i64 %4 to i64*
  %cmp3 = icmp ne i64* %5, null
  br i1 %cmp3, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %add.ptr4 = getelementptr inbounds i64, i64* %rightmost.0, i64 2
  %6 = load i64, i64* %add.ptr4, align 8
  %7 = inttoptr i64 %6 to i64*
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %cmp5 = icmp ne i64* %parent.0, null
  br i1 %cmp5, label %if.then6, label %if.end9

if.then6:                                         ; preds = %while.end
  %add.ptr7 = getelementptr inbounds i64, i64* %rightmost.0, i64 1
  %8 = load i64, i64* %add.ptr7, align 8
  %add.ptr8 = getelementptr inbounds i64, i64* %parent.0, i64 2
  store i64 %8, i64* %add.ptr8, align 8
  br label %if.end9

if.end9:                                          ; preds = %if.then6, %while.end
  br label %cleanup

cleanup:                                          ; preds = %if.end9, %if.then
  %retval.0 = phi i64* [ %3, %if.then ], [ %rightmost.0, %if.end9 ]
  ret i64* %retval.0
}

; Function Attrs: nounwind ssp uwtable
define i64 @remove(i64* %root, i64 %data) #0 {
entry:
  %0 = load i64, i64* %root, align 8
  %cmp = icmp eq i64 %0, %data
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %cleanup24

if.end:                                           ; preds = %entry
  br label %while.cond

while.cond:                                       ; preds = %cleanup.cont, %cleanup, %if.end
  %curr.0 = phi i64* [ %root, %if.end ], [ %curr.1, %cleanup ], [ %curr.1, %cleanup.cont ]
  %retval.0 = phi i64 [ 0, %if.end ], [ %retval.1, %cleanup ], [ %retval.1, %cleanup.cont ]
  br label %while.body

while.body:                                       ; preds = %while.cond
  %1 = load i64, i64* %curr.0, align 8
  %cmp1 = icmp ugt i64 %1, %data
  br i1 %cmp1, label %if.then2, label %if.else

if.then2:                                         ; preds = %while.body
  %add.ptr = getelementptr inbounds i64, i64* %curr.0, i64 1
  %2 = load i64, i64* %add.ptr, align 8
  %3 = inttoptr i64 %2 to i64*
  %cmp3 = icmp eq i64* %3, null
  br i1 %cmp3, label %if.then4, label %if.end5

if.then4:                                         ; preds = %if.then2
  br label %cleanup

if.end5:                                          ; preds = %if.then2
  %4 = load i64, i64* %3, align 8
  %cmp6 = icmp eq i64 %4, %data
  br i1 %cmp6, label %if.then7, label %if.end9

if.then7:                                         ; preds = %if.end5
  %call = call i64* @adjust(i64* %3)
  %5 = ptrtoint i64* %call to i64
  %add.ptr8 = getelementptr inbounds i64, i64* %curr.0, i64 1
  store i64 %5, i64* %add.ptr8, align 8
  %6 = bitcast i64* %3 to i8*
  call void @free(i8* %6)
  br label %cleanup

if.end9:                                          ; preds = %if.end5
  br label %cleanup

if.else:                                          ; preds = %while.body
  %cmp10 = icmp ult i64 %1, %data
  br i1 %cmp10, label %if.then11, label %if.end21

if.then11:                                        ; preds = %if.else
  %add.ptr12 = getelementptr inbounds i64, i64* %curr.0, i64 2
  %7 = load i64, i64* %add.ptr12, align 8
  %8 = inttoptr i64 %7 to i64*
  %cmp13 = icmp eq i64* %8, null
  br i1 %cmp13, label %if.then14, label %if.end15

if.then14:                                        ; preds = %if.then11
  br label %cleanup

if.end15:                                         ; preds = %if.then11
  %9 = load i64, i64* %8, align 8
  %cmp16 = icmp eq i64 %9, %data
  br i1 %cmp16, label %if.then17, label %if.end20

if.then17:                                        ; preds = %if.end15
  %call18 = call i64* @adjust(i64* %8)
  %10 = ptrtoint i64* %call18 to i64
  %add.ptr19 = getelementptr inbounds i64, i64* %curr.0, i64 2
  store i64 %10, i64* %add.ptr19, align 8
  %11 = bitcast i64* %8 to i8*
  call void @free(i8* %11)
  br label %cleanup

if.end20:                                         ; preds = %if.end15
  br label %cleanup

if.end21:                                         ; preds = %if.else
  br label %if.end22

if.end22:                                         ; preds = %if.end21
  br label %cleanup

cleanup:                                          ; preds = %if.end22, %if.end20, %if.then17, %if.then14, %if.end9, %if.then7, %if.then4
  %curr.1 = phi i64* [ %curr.0, %if.then4 ], [ %curr.0, %if.then7 ], [ %3, %if.end9 ], [ %curr.0, %if.then14 ], [ %curr.0, %if.then17 ], [ %8, %if.end20 ], [ %curr.0, %if.end22 ]
  %cleanup.dest.slot.0 = phi i32 [ 1, %if.then4 ], [ 1, %if.then7 ], [ 2, %if.end9 ], [ 1, %if.then14 ], [ 1, %if.then17 ], [ 2, %if.end20 ], [ 0, %if.end22 ]
  %retval.1 = phi i64 [ 0, %if.then4 ], [ 1, %if.then7 ], [ %retval.0, %if.end9 ], [ 0, %if.then14 ], [ 1, %if.then17 ], [ %retval.0, %if.end20 ], [ %retval.0, %if.end22 ]
  switch i32 %cleanup.dest.slot.0, label %cleanup24 [
    i32 0, label %cleanup.cont
    i32 2, label %while.cond
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %while.cond

cleanup24:                                        ; preds = %cleanup, %if.then
  %retval.2 = phi i64 [ 0, %if.then ], [ %retval.1, %cleanup ]
  ret i64 %retval.2
}

declare void @free(i8*) #3

; Function Attrs: nounwind ssp uwtable
define void @traverse(i64* %node) #0 {
entry:
  %cmp = icmp eq i64* %node, null
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  %0 = load i64, i64* %node, align 8
  %add.ptr = getelementptr inbounds i64, i64* %node, i64 1
  %1 = load i64, i64* %add.ptr, align 8
  %2 = inttoptr i64 %1 to i64*
  %add.ptr1 = getelementptr inbounds i64, i64* %node, i64 2
  %3 = load i64, i64* %add.ptr1, align 8
  %4 = inttoptr i64 %3 to i64*
  call void @traverse(i64* %2)
  call void @write(i64 %0)
  call void @traverse(i64* %4)
  br label %return

return:                                           ; preds = %if.end, %if.then
  ret void
}

declare void @write(i64) #3

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %call = call i8* @malloc(i64 24) #4
  %0 = bitcast i8* %call to i64*
  %call1 = call i64 (...) @read()
  store i64 %call1, i64* %0, align 8
  %add.ptr = getelementptr inbounds i64, i64* %0, i64 1
  store i64 0, i64* %add.ptr, align 8
  %add.ptr2 = getelementptr inbounds i64, i64* %0, i64 2
  store i64 0, i64* %add.ptr2, align 8
  %call3 = call i64 (...) @read()
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i64 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp ult i64 %i.0, %call3
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %call4 = call i64 (...) @read()
  %call5 = call i64 (...) @read()
  %cmp6 = icmp eq i64 %call4, 0
  br i1 %cmp6, label %if.then, label %if.else

if.then:                                          ; preds = %for.body
  %call7 = call i64 @insert(i64* %0, i64 %call5)
  br label %if.end

if.else:                                          ; preds = %for.body
  %call8 = call i64 @remove(i64* %0, i64 %call5)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc = add i64 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond.cleanup
  call void @traverse(i64* %0)
  ret i32 0
}

declare i64 @read(...) #3

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
