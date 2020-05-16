
; Function sum_of
start sum_of 6:
  .entry:
    ; init sp!
    sp = sub sp 40 64
    r1 = sub arg1 arg2 32
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = add r1 arg3 32
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = sub r1 arg4 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = add r1 arg5 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r1 = sub r1 arg6 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    ret r1
end sum_of

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 152 64
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
    r1 = and r1 4294967295 64
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
    r1 = and r1 4294967295 64
    store 8 r1 sp 96
    r1 = call read
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r1 = and r1 4294967295 64
    store 8 r1 sp 112
    r1 = call read
    store 8 r1 sp 120
    r1 = load 8 sp 120
    r1 = and r1 4294967295 64
    store 8 r1 sp 128
    r1 = load 8 sp 48
    r2 = load 8 sp 64
    r3 = load 8 sp 80
    r4 = load 8 sp 96
    r5 = load 8 sp 112
    r6 = load 8 sp 128
    r1 = call sum_of r1 r2 r3 r4 r5 r6
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 144
    r1 = load 8 sp 144
    call write r1
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .while.cond

  .while.end:
    ret 0
end main
