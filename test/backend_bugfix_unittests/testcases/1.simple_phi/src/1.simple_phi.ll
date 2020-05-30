define dso_local i32 @main() {
entry:
  %call = call i64 (...) @read()
  br label %loop

loop:
  %i = phi i64 [ 1, %entry ], [ %i.inc, %loop ]
  call void @write(i64 %i)
  %cmp = icmp ne i64 %i, %call
  %i.inc = add i64 %i, 1
  br i1 %cmp, label %loop, label %end

end:
  call void @write(i64 %i)
  ret i32 0
}

declare dso_local i64 @read(...)

declare dso_local void @write(i64)
