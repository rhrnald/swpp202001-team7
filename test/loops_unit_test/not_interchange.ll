;Should Not Interchange Testcase. Same to:
;int main() {
;  uint64_t n = read();
;  uint64_t a[10][10];
;  for (uint64_t i = 0; i < n; i++) {
;    for (uint64_t j = 0; j < n; j++) {
;      a[i][j] = i + j;
;    }
;  }
;  return 0;
;}
define dso_local i32 @main() {
entry:
  %a = alloca [10 x [10 x i64]], align 16
  %n = call i64 (...) @read()
  br label %for.i.cond

for.i.cond:
  %i = phi i64 [ 0, %entry ], [ %i.inc, %for.i.inc ]
  %cmp = icmp ult i64 %i, %n
  br i1 %cmp, label %for.i.body, label %for.i.cond.cleanup

for.i.cond.cleanup:
  br label %for.i.end

for.i.body:
  br label %for.j.cond

for.j.cond:
  %j = phi i64 [ 0, %for.i.body ], [ %j.inc, %for.j.inc ]
  %cmp2 = icmp ult i64 %j, %n
  br i1 %cmp2, label %for.j.body, label %for.j.cond.cleanup

for.j.cond.cleanup:
  br label %for.j.end

for.j.body:
  %add = add i64 %i, %j
  %arrayidx = getelementptr inbounds [10 x [10 x i64]], [10 x [10 x i64]]* %a, i64 0, i64 %i
  %arrayidx2 = getelementptr inbounds [10 x i64], [10 x i64]* %arrayidx, i64 0, i64 %j
  store i64 %add, i64* %arrayidx2, align 8
  br label %for.j.inc

for.j.inc:
  %j.inc = add i64 %j, 1
  br label %for.j.cond

for.j.end:
  br label %for.i.inc

for.i.inc:
  %i.inc = add i64 %i, 1
  br label %for.i.cond

for.i.end:
  ret i32 0
}

declare dso_local i64 @read(...)
