define i32 @shoot(i8 %a, i64 %b, i16 %c, i32 %d) {
  %cc = zext i16 %c to i32
  call void @print(i32 %cc)
  ret i32 %d
}

define void @main(i32 %t) {
; CHECK: start main 0:
  %x = add i32 1, 2
  %y = add i32 2, 3
  %z = add i32 %x, %y
  call void @print(i32 %z)
  %a = add i8 2, 3
  %b = add i64 2, 3
  %c = add i16 2, 3
  %d = add i32 2, 3
  %e = call i32 @shoot(i8 %a, i64 %b, i16 %c, i32 %d)
  call void @print(i32 %e)
  ret void
}
; CHECK: end main

declare void @print(i32 %x);
