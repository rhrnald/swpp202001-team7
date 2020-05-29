;Unroll Testcase. Same to:
;int main() {
;  uint64_t n = read();
;  for (uint64_t i = 0; i < n; i++) {
;    write(i);
;  }
;  return 0;
;}
define dso_local i32 @main() {
entry:
  %call = call i64 (...) @read()
  br label %for.cond

for.cond:
  %i = phi i64 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp ult i64 %i, %call
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:
  br label %for.end

for.body:
  call void @write(i64 %i)
  br label %for.inc

for.inc:
  %inc = add i64 %i, 1
  br label %for.cond

for.end:
  ret i32 0
}

declare dso_local i64 @read(...)

declare dso_local void @write(i64)
