
; Function sum_of
start sum_of 5:
  .entry:
    ; init sp!
    sp = sub sp 64 64
    r2 = and arg1 128 64
    r2 = sub 0 r2 64
    r1 = or r2 arg1 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = add r1 arg2 32
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = add r1 arg3 32
    store 8 r1 sp 16
    r2 = and arg4 128 64
    r2 = sub 0 r2 64
    r1 = or r2 arg4 64
    store 8 r1 sp 24
    r1 = load 8 sp 16
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 40
    r1 = mul arg5 1 64
    store 8 r1 sp 48
    r1 = load 8 sp 40
    r2 = load 8 sp 48
    r1 = add r1 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    ret r1
end sum_of

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 128 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .while.cond

  .while.cond:
    r1 = load 8 sp 8
    r1 = add r1 18446744073709551615 64
    store 8 r1 sp 24
    r1 = load 8 sp 8
    r1 = icmp ne r1 0 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    br r1 .while.body .while.end

  .while.body:
    r1 = call read
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r1 = and r1 255 64
    store 8 r1 sp 48
    r1 = call read
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r1 = and r1 4294967295 64
    store 8 r1 sp 64
    r1 = call read
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = and r1 4294967295 64
    store 8 r1 sp 80
    r1 = call read
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = and r1 255 64
    store 8 r1 sp 96
    r1 = load 8 sp 48
    r2 = load 8 sp 64
    r3 = load 8 sp 80
    r4 = load 8 sp 96
    r1 = call sum_of r1 r2 r3 r4 0
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r1 = and r1 4294967295 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    store 8 r1 sp 120
    r1 = load 8 sp 120
    call write r1
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .while.cond

  .while.end:
    ret 0
end main
