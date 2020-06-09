
; Function max
start max 2:
  .entry:
    ; init sp!
    sp = sub sp 24 64
    r1 = icmp ugt arg1 arg2 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    br r1 .cond.true .cond.false

  .cond.true:
    store 8 arg1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .cond.end

  .cond.false:
    store 8 arg2 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .cond.end

  .cond.end:
    r1 = load 8 sp 8
    ret r1
end max

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 216 64
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
    r2 = load 8 sp 0
    r1 = mul 8 r2 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = malloc r1
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 48
    store 8 0 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 56
    br .for.cond

  .for.cond:
    r1 = load 8 sp 56
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r2 = load 8 sp 0
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = call read
    store 8 r1 sp 88
    r1 = load 8 sp 56
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 96
    r1 = load 8 sp 48
    r2 = load 8 sp 96
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 104
    r1 = load 8 sp 88
    r2 = load 8 sp 104
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 56
    r1 = add r1 1 32
    store 8 r1 sp 112
    r1 = load 8 sp 112
    store 8 r1 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 56
    br .for.cond

  .for.end:
    store 8 0 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 120
    br .for.cond7

  .for.cond7:
    r1 = load 8 sp 120
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 136
    r1 = load 8 sp 136
    r2 = load 8 sp 0
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 144
    r1 = load 8 sp 144
    br r1 .for.body12 .for.cond.cleanup11

  .for.cond.cleanup11:
    br .for.end20

  .for.body12:
    r1 = load 8 sp 120
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
    r1 = load 8 sp 120
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 176
    r1 = load 8 sp 48
    r2 = load 8 sp 176
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r1 = load 8 r1 0
    store 8 r1 sp 192
    r1 = load 8 sp 168
    r2 = load 8 sp 192
    r1 = call max r1 r2
    store 8 r1 sp 200
    r1 = load 8 sp 200
    call write r1
    br .for.inc18

  .for.inc18:
    r1 = load 8 sp 120
    r1 = add r1 1 32
    store 8 r1 sp 208
    r1 = load 8 sp 208
    store 8 r1 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 120
    br .for.cond7

  .for.end20:
    ret 0
end main
