define void @shoot(i8 %a, i64 %b, i16 %c, i32 %d) {
  %cc = zext i16 %c to i32
  call void @print(i32 %cc)
  ret void
}

<<<<<<< HEAD
define void @main(i32 %t) {
=======
define void @main(i32 %a) {
>>>>>>> PackRegisters: Callee part has been done
; CHECK: start main 0:
  %x = add i32 1, 2
  %y = add i32 2, 3
  %z = add i32 %x, %y
  call void @print(i32 %z)
<<<<<<< HEAD
  %a = add i8 2, 3
  %b = add i64 2, 3
  %c = add i16 2, 3
  %d = add i32 2, 3
  call void @shoot(i8 %a, i64 %b, i16 %c, i32 %d)
=======
>>>>>>> PackRegisters: Callee part has been done
  ret void
}
; CHECK: end main

declare void @print(i32 %x);
