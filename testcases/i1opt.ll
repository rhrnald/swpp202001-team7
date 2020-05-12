define i32 @main(i32 %a, i32 %b, i32 %c) {
  %cond1 = icmp eq i32 %a, %b
  %cond2 = icmp eq i32 %b, %c
  %cond = and i1 %cond1, %cond2
  br i1 %cond, label %ret1, label %ret0
  
ret1:
  ret i32 1

ret0:
  ret i32 0
}