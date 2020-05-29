
; Function malloc_upto_8
start malloc_upto_8 1:
  .entry:
    ; init sp!
    sp = sub sp 32 64
    r1 = add arg1 7 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = udiv r1 8 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = mul r1 8 64
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = malloc r1
    store 8 r1 sp 24
    r1 = load 8 sp 24
    ret r1
end malloc_upto_8

; Function min_element
start min_element 2:
  .entry:
    ; init sp!
    sp = sub sp 96 64
    r1 = load 4 arg1 0
    store 8 r1 sp 0
    store 8 arg1 sp 16
    r1 = load 8 sp 0
    store 8 r1 sp 32
    r1 = load 8 sp 16
    store 8 r1 sp 8
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .while.cond

  .while.cond:
    r1 = load 8 sp 8
    r1 = icmp ne r1 arg2 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .while.body .while.end

  .while.body:
    r1 = load 8 sp 8
    r1 = load 4 r1 0
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r2 = load 8 sp 24
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 56
    r1 = load 8 sp 24
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 72
    r1 = load 8 sp 56
    br r1 .if.then .if.end

  .if.then:
    r1 = load 8 sp 8
    r1 = load 4 r1 0
    store 8 r1 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 72
    br .if.end

  .if.end:
    r1 = load 8 sp 8
    r1 = add r1 4 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 16
    r1 = load 8 sp 72
    store 8 r1 sp 32
    r1 = load 8 sp 16
    store 8 r1 sp 8
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .while.cond

  .while.end:
    r1 = load 8 sp 24
    ret r1
end min_element

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 248 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = and r1 4294967295 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 16
    r2 = load 8 sp 16
    r1 = mul 4 r2 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r1 = call malloc_upto_8 r1
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 40
    store 8 0 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond

  .for.cond:
    r1 = load 8 sp 48
    r2 = load 8 sp 8
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 64
    r1 = load 8 sp 64
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = call read
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = and r1 4294967295 64
    store 8 r1 sp 80
    r1 = load 8 sp 48
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 88
    r1 = load 8 sp 40
    r2 = load 8 sp 88
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 96
    r1 = load 8 sp 80
    r2 = load 8 sp 96
    store 4 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 48
    r1 = add r1 1 32
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond

  .for.end:
    r1 = call read
    store 8 r1 sp 112
    r1 = load 8 sp 112
    r1 = and r1 4294967295 64
    store 8 r1 sp 120
    r1 = load 8 sp 120
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 128
    br .while.cond

  .while.cond:
    r1 = load 8 sp 128
    r1 = add r1 4294967295 32
    store 8 r1 sp 144
    r1 = load 8 sp 128
    r1 = icmp ne r1 0 32
    store 8 r1 sp 152
    r1 = load 8 sp 152
    br r1 .while.body .while.end

  .while.body:
    r1 = call read
    store 8 r1 sp 160
    r1 = load 8 sp 160
    r1 = and r1 4294967295 64
    store 8 r1 sp 168
    r1 = call read
    store 8 r1 sp 176
    r1 = load 8 sp 176
    r1 = and r1 4294967295 64
    store 8 r1 sp 184
    r1 = load 8 sp 168
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 192
    r1 = load 8 sp 40
    r2 = load 8 sp 192
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 200
    r1 = load 8 sp 184
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 208
    r1 = load 8 sp 40
    r2 = load 8 sp 208
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 216
    r1 = load 8 sp 216
    r1 = add r1 4 64
    store 8 r1 sp 224
    r1 = load 8 sp 200
    r2 = load 8 sp 224
    r1 = call min_element r1 r2
    store 8 r1 sp 232
    r1 = load 8 sp 232
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 240
    r1 = load 8 sp 240
    call write r1
    r1 = load 8 sp 144
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 128
    br .while.cond

  .while.end:
    ret 0
end main
