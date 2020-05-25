define dso_local i32 @main() {
entry:
  %call = call i64 (...) @read()
  br label %bb1

bb1:
  %d = phi i64 [ 10, %entry ], [ %e, %bb3 ]
  %e = phi i64 [ %call, %entry ], [ %f, %bb3 ]
  %f = phi i64 [ 30, %entry ], [ %d, %bb3 ]
  call void @write(i64 %d)
  call void @write(i64 %e)
  call void @write(i64 %f)
  br label %bb2

bb2:
  br label %bb3

bb3:
  %cmp = icmp eq i64 %d, 10
  br i1 %cmp, label %bb1, label %exit

exit:
  call void @write(i64 %d)
  call void @write(i64 %e)
  call void @write(i64 %f)
  ret i32 0
}

declare dso_local i64 @read(...) #2

declare dso_local void @write(i64) #2
