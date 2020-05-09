define i32 @main(i32 %x) {
  %a = sub i32 0, 1
  %b = add i32 %a, %a
  %c = add i32 %b, %b
  %d = add i32 %c, 1
  %e = sub i32 0, %d
  %f.0 = add i32 %x, %x
  %f = add i32 %f.0, 1
  %g = and i32 %e, %f
  %h = sub i32 0, %g
  %i = add i32 %x, %h
  %j = ashr i32 %i, 2
  %k = lshr i32 %j, 3
  ret i32 %k
}