define i32 @main(i32 %x) {
  %a = ashr i32 %x, 3
  %b = lshr i32 %a, 2
  %c = shl i32 %b, 1
  %d = ashr i32 %c, 4
  ret i32 %d
}