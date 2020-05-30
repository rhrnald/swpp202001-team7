
; Function countSetBits
start countSetBits 1:
  .entry:
    ; init sp!
    sp = sub sp 168 64
    r1 = and arg1 255 32
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 8
    r2 = load 8 sp 8
    r2 = mul r2 4 64
    r1 = add 20480 r2 64
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = load 4 r1 0
    store 8 r1 sp 24
    r1 = ashr arg1 8 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = and r1 255 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 48
    r2 = load 8 sp 48
    r2 = mul r2 4 64
    r1 = add 20480 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r1 = load 4 r1 0
    store 8 r1 sp 64
    r1 = load 8 sp 24
    r2 = load 8 sp 64
    r1 = add r1 r2 32
    store 8 r1 sp 72
    r1 = ashr arg1 16 32
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r1 = and r1 255 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 96
    r2 = load 8 sp 96
    r2 = mul r2 4 64
    r1 = add 20480 r2 64
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r1 = load 4 r1 0
    store 8 r1 sp 112
    r1 = load 8 sp 72
    r2 = load 8 sp 112
    r1 = add r1 r2 32
    store 8 r1 sp 120
    r1 = ashr arg1 24 32
    store 8 r1 sp 128
    r1 = load 8 sp 128
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 136
    r2 = load 8 sp 136
    r2 = mul r2 4 64
    r1 = add 20480 r2 64
    store 8 r1 sp 144
    r1 = load 8 sp 144
    r1 = load 4 r1 0
    store 8 r1 sp 152
    r1 = load 8 sp 120
    r2 = load 8 sp 152
    r1 = add r1 r2 32
    store 8 r1 sp 160
    r1 = load 8 sp 160
    ret r1
end countSetBits

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 136 64
    r1 = malloc 1024
    store 8 20480 sp 0
    r2 = load 8 sp 0
    store 4 0 r2 0
    store 8 0 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .for.cond

  .for.cond:
    r1 = load 8 sp 8
    r1 = icmp slt r1 256 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = load 8 sp 8
    r1 = and r1 1 32
    store 8 r1 sp 32
    r1 = load 8 sp 8
    r1 = sdiv r1 2 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 48
    r2 = load 8 sp 48
    r2 = mul r2 4 64
    r1 = add 20480 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r1 = load 4 r1 0
    store 8 r1 sp 64
    r1 = load 8 sp 32
    r2 = load 8 sp 64
    r1 = add r1 r2 32
    store 8 r1 sp 72
    r1 = load 8 sp 8
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 80
    r2 = load 8 sp 80
    r2 = mul r2 4 64
    r1 = add 20480 r2 64
    store 8 r1 sp 88
    r1 = load 8 sp 72
    r2 = load 8 sp 88
    store 4 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 8
    r1 = add r1 1 32
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .for.cond

  .for.end:
    r1 = call read
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r1 = and r1 4294967295 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    r1 = call countSetBits r1
    store 8 r1 sp 120
    r1 = load 8 sp 120
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 128
    r1 = load 8 sp 128
    call write r1
    ret 0
end main
