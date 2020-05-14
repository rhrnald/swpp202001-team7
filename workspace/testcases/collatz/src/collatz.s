
; Function collatz
start collatz 2:
  .entry:
    ; init sp!
    sp = sub sp 152 64
    store 8 arg2 sp 0
    r1 = load 8 sp 0
    call write r1
    r1 = icmp ule arg2 1 32
    store 8 r1 sp 8
    r1 = load 8 sp 8
    br r1 .if.then .if.end

  .if.then:
    store 8 arg2 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 136
    br .return

  .if.end:
    r1 = load 2 arg1 0
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r2 = and r1 32768 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r1 = icmp slt r1 0 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    br r1 .if.then5 .if.end6

  .if.then5:
    store 8 4294967295 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 136
    br .return

  .if.end6:
    r1 = load 2 arg1 0
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r2 = and r1 32768 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = add r1 1 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r1 = and r1 65535 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    store 2 r1 arg1 0
    r1 = urem arg2 2 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = icmp eq r1 0 32
    store 8 r1 sp 80
    r1 = load 8 sp 80
    br r1 .cond.true .cond.false

  .cond.true:
    r1 = udiv arg2 2 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 120
    r1 = load 8 sp 120
    store 8 r1 sp 112
    br .cond.end

  .cond.false:
    r1 = mul 3 arg2 32
    store 8 r1 sp 96
    r1 = load 8 sp 96
    r1 = add r1 1 32
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 120
    r1 = load 8 sp 120
    store 8 r1 sp 112
    br .cond.end

  .cond.end:
    r2 = load 8 sp 112
    r1 = call collatz arg1 r2
    store 8 r1 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 136
    br .return

  .return:
    r1 = load 8 sp 136
    ret r1
end collatz

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 56 64
    r1 = add sp 48 64
    store 8 r1 sp 0
    r1 = call read
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = and r1 4294967295 64
    store 8 r1 sp 16
    r2 = load 8 sp 0
    store 2 0 r2 0
    r1 = load 8 sp 0
    r2 = load 8 sp 16
    r1 = call collatz r1 r2
    store 8 r1 sp 24
    r1 = load 8 sp 0
    r1 = load 2 r1 0
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r2 = and r1 32768 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    call write r1
    ret 0
end main
