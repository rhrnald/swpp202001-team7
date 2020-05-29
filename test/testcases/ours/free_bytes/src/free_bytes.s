
; Function __alloca_bytes__
start __alloca_bytes__ 3:
  .entry:
    ; init sp!
    sp = sub sp 8 64
    r1 = malloc arg1
    store 8 r1 sp 0
    r1 = load 8 sp 0
    ret r1
end __alloca_bytes__

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 200 64
    r1 = call read
    store 8 r1 sp 0
    r1 = call __alloca_bytes__ 8 0 0
    store 8 r1 sp 8
    store 8 0 sp 24
    store 8 0 sp 40
    r1 = load 8 sp 0
    store 8 r1 sp 56
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 40
    store 8 r1 sp 32
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond

  .for.cond:
    r1 = load 8 sp 32
    r1 = icmp slt r1 8 32
    store 8 r1 sp 64
    r1 = load 8 sp 64
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = load 8 sp 32
    r1 = add r1 1 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = mul r1 8 32
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = call __alloca_bytes__ r1 1 0
    store 8 r1 sp 96
    r1 = load 8 sp 48
    r1 = and r1 255 64
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r2 = load 8 sp 96
    store 1 r1 r2 0
    r1 = load 8 sp 48
    r1 = lshr r1 8 64
    store 8 r1 sp 112
    r1 = load 8 sp 96
    r1 = load 1 r1 0
    store 8 r1 sp 120
    r1 = load 8 sp 120
    store 8 r1 sp 128
    r1 = load 8 sp 128
    call write r1
    r1 = load 8 sp 96
    r1 = load 1 r1 0
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 144
    r1 = load 8 sp 16
    store 8 r1 sp 152
    r1 = load 8 sp 152
    r2 = load 8 sp 144
    r1 = add r1 r2 32
    store 8 r1 sp 160
    r1 = load 8 sp 160
    r1 = and r1 255 64
    store 8 r1 sp 168
    br .for.inc

  .for.inc:
    r1 = load 8 sp 32
    r1 = add r1 1 32
    store 8 r1 sp 176
    r1 = load 8 sp 168
    store 8 r1 sp 24
    r1 = load 8 sp 176
    store 8 r1 sp 40
    r1 = load 8 sp 112
    store 8 r1 sp 56
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 40
    store 8 r1 sp 32
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond

  .for.end:
    r1 = load 8 sp 16
    r2 = load 8 sp 8
    store 1 r1 r2 0
    r1 = load 8 sp 8
    r1 = load 1 r1 0
    store 8 r1 sp 184
    r1 = load 8 sp 184
    store 8 r1 sp 192
    r1 = load 8 sp 192
    call write r1
    ret 0
end main
