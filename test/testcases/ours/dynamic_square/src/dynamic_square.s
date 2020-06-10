
; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 224 64
    r1 = call read
    store 8 r1 sp 0
    r2 = load 8 sp 0
    r1 = mul 8 r2 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = malloc r1
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 24
    store 8 0 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond

  .for.cond:
    r1 = load 8 sp 32
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r2 = load 8 sp 0
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = call read
    store 8 r1 sp 64
    r1 = load 8 sp 32
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 72
    r1 = load 8 sp 24
    r2 = load 8 sp 72
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 80
    r1 = load 8 sp 64
    r2 = load 8 sp 80
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 32
    r1 = add r1 1 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond

  .for.end:
    r1 = load 8 sp 0
    r1 = sub r1 1 64
    store 8 r1 sp 96
    r1 = load 8 sp 96
    r1 = and r1 4294967295 64
    store 8 r1 sp 104
    store 8 0 sp 120
    r1 = load 8 sp 104
    store 8 r1 sp 136
    r1 = load 8 sp 120
    store 8 r1 sp 112
    r1 = load 8 sp 136
    store 8 r1 sp 128
    br .for.cond6

  .for.cond6:
    r1 = load 8 sp 128
    r1 = icmp sge r1 0 32
    store 8 r1 sp 144
    r1 = load 8 sp 144
    br r1 .for.body10 .for.cond.cleanup9

  .for.cond.cleanup9:
    br .for.end17

  .for.body10:
    r1 = load 8 sp 128
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 152
    r1 = load 8 sp 24
    r2 = load 8 sp 152
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 160
    r1 = load 8 sp 160
    r1 = load 8 r1 0
    store 8 r1 sp 168
    r1 = load 8 sp 128
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 176
    r1 = load 8 sp 24
    r2 = load 8 sp 176
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r1 = load 8 r1 0
    store 8 r1 sp 192
    r1 = load 8 sp 168
    r2 = load 8 sp 192
    r1 = mul r1 r2 64
    store 8 r1 sp 200
    r1 = load 8 sp 112
    r2 = load 8 sp 200
    r1 = add r1 r2 64
    store 8 r1 sp 208
    br .for.inc16

  .for.inc16:
    r1 = load 8 sp 128
    r1 = add r1 4294967295 32
    store 8 r1 sp 216
    r1 = load 8 sp 208
    store 8 r1 sp 120
    r1 = load 8 sp 216
    store 8 r1 sp 136
    r1 = load 8 sp 120
    store 8 r1 sp 112
    r1 = load 8 sp 136
    store 8 r1 sp 128
    br .for.cond6

  .for.end17:
    r1 = load 8 sp 112
    call write r1
    ret 0
end main
