
; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 688 64
    r1 = add sp 288 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    store 8 r1 sp 8
    r1 = malloc 400
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 24
    r1 = call read
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = icmp sgt r1 50 64
    store 8 r1 sp 40
    r1 = load 8 sp 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    r1 = load 8 sp 40
    br r1 .if.then .if.end

  .if.then:
    store 8 50 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .if.end

  .if.end:
    store 8 0 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 64
    br .for.cond

  .for.cond:
    r1 = load 8 sp 64
    r2 = load 8 sp 48
    r1 = icmp slt r1 r2 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = load 8 sp 0
    r2 = load 8 sp 64
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 88
    r1 = load 8 sp 64
    r2 = load 8 sp 88
    store 8 r1 r2 0
    r2 = load 8 sp 64
    r1 = sub 49 r2 64
    store 8 r1 sp 96
    r1 = load 8 sp 24
    r2 = load 8 sp 64
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 104
    r1 = load 8 sp 96
    r2 = load 8 sp 104
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 64
    r1 = add r1 1 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 64
    br .for.cond

  .for.end:
    store 8 0 sp 128
    store 8 0 sp 144
    r1 = load 8 sp 128
    store 8 r1 sp 120
    r1 = load 8 sp 144
    store 8 r1 sp 136
    br .for.cond5

  .for.cond5:
    r1 = load 8 sp 136
    r2 = load 8 sp 48
    r1 = icmp slt r1 r2 64
    store 8 r1 sp 152
    r1 = load 8 sp 152
    br r1 .for.body8 .for.cond.cleanup7

  .for.cond.cleanup7:
    br .for.end20

  .for.body8:
    r1 = load 8 sp 0
    r2 = load 8 sp 136
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 160
    r1 = load 8 sp 160
    r1 = load 8 r1 0
    store 8 r1 sp 168
    r1 = load 8 sp 120
    r2 = load 8 sp 168
    r1 = add r1 r2 64
    store 8 r1 sp 176
    r1 = load 8 sp 24
    r2 = load 8 sp 136
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r1 = load 8 r1 0
    store 8 r1 sp 192
    r1 = load 8 sp 176
    r2 = load 8 sp 192
    r1 = add r1 r2 64
    store 8 r1 sp 200
    r2 = load 8 sp 136
    r1 = sub 49 r2 64
    store 8 r1 sp 208
    r1 = load 8 sp 0
    r2 = load 8 sp 208
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 216
    r1 = load 8 sp 216
    r1 = load 8 r1 0
    store 8 r1 sp 224
    r1 = load 8 sp 200
    r2 = load 8 sp 224
    r1 = add r1 r2 64
    store 8 r1 sp 232
    r2 = load 8 sp 136
    r1 = sub 49 r2 64
    store 8 r1 sp 240
    r1 = load 8 sp 24
    r2 = load 8 sp 240
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 248
    r1 = load 8 sp 248
    r1 = load 8 r1 0
    store 8 r1 sp 256
    r1 = load 8 sp 232
    r2 = load 8 sp 256
    r1 = add r1 r2 64
    store 8 r1 sp 264
    br .for.inc18

  .for.inc18:
    r1 = load 8 sp 136
    r1 = add r1 1 64
    store 8 r1 sp 272
    r1 = load 8 sp 264
    store 8 r1 sp 128
    r1 = load 8 sp 272
    store 8 r1 sp 144
    r1 = load 8 sp 128
    store 8 r1 sp 120
    r1 = load 8 sp 144
    store 8 r1 sp 136
    br .for.cond5

  .for.end20:
    r1 = load 8 sp 120
    call write r1
    r1 = load 8 sp 0
    store 8 r1 sp 280
    ret 0
end main
