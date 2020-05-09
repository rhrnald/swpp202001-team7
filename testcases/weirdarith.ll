define i32 @main(i32 %x) {
  %a = sub i32 0, 1
  %b = add i32 %a, %a
  %c = add i32 %b, %b
  %d = add i32 %c, 1
  %e = sub i32 0, %d
  %f = add i32 %x, 1
  %g = and i32 %e, %f
  %h = sub i32 0, %g
  ret i32 %h
}