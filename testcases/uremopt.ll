define i32 @main(i32 %x) {
  %a = shl i32 %x, 2
  %b = and i32 %a, 13
  ret i32 %b
}