define dso_local i32 @main() {
entry:
  %call = call i64 (...) @read()
  br label %while.cond

while.cond:
  %i.0 = phi i64 [ 1, %entry ], [ %add, %while.cond ]
  %cmp = icmp ult i64 %i.0, %call
  %sub = sub i64 0, %i.0
  %sub1 = sub i64 0, %call
  %cmp2 = icmp ugt i64 %sub, %sub1
  %and1 = and i1 %cmp, %cmp2
  %add = shl i64 %i.0, 1
  br i1 %and1, label %while.cond, label %while.end

while.end:
  call void @write(i64 %i.0)
  ret i32 0
}

declare dso_local i64 @read(...)

declare dso_local void @write(i64)
