
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

; Function min
start min 2:
  .entry:
    ; init sp!
    sp = sub sp 24 64
    r1 = icmp slt arg1 arg2 32
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
end min

; Function min_element
start min_element 2:
  .entry:
    ; init sp!
    sp = sub sp 88 64
    store 8 arg1 sp 8
    store 8 arg1 sp 24
    r1 = load 8 sp 8
    store 8 r1 sp 0
    r1 = load 8 sp 24
    store 8 r1 sp 16
    br .while.cond

  .while.cond:
    r1 = load 8 sp 0
    r1 = icmp ne r1 arg2 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    br r1 .while.body .while.end

  .while.body:
    r1 = load 8 sp 0
    r1 = load 4 r1 0
    store 8 r1 sp 40
    r1 = load 8 sp 16
    r1 = load 4 r1 0
    store 8 r1 sp 48
    r1 = load 8 sp 40
    r2 = load 8 sp 48
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 56
    r1 = load 8 sp 16
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 64
    r1 = load 8 sp 56
    br r1 .if.then .if.end

  .if.then:
    r1 = load 8 sp 0
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 64
    br .if.end

  .if.end:
    r1 = load 8 sp 0
    r1 = add r1 4 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 8
    r1 = load 8 sp 64
    store 8 r1 sp 24
    r1 = load 8 sp 8
    store 8 r1 sp 0
    r1 = load 8 sp 24
    store 8 r1 sp 16
    br .while.cond

  .while.end:
    r1 = load 8 sp 16
    ret r1
end min_element

; Function min_at_row
start min_at_row 3:
  .entry:
    ; init sp!
    sp = sub sp 96 64
    r1 = load 8 20480 0
    store 8 r1 sp 0
    r2 = and arg1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 arg1 64
    store 8 r1 sp 8
    r1 = load 8 sp 0
    r2 = load 8 sp 8
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = load 8 r1 0
    store 8 r1 sp 24
    r2 = and arg2 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 arg2 64
    store 8 r1 sp 32
    r1 = load 8 sp 24
    r2 = load 8 sp 32
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 40
    r1 = load 8 sp 16
    r1 = load 8 r1 0
    store 8 r1 sp 48
    r2 = and arg3 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 arg3 64
    store 8 r1 sp 56
    r1 = load 8 sp 48
    r2 = load 8 sp 56
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r1 = add r1 4 64
    store 8 r1 sp 72
    r1 = load 8 sp 40
    r2 = load 8 sp 72
    r1 = call min_element r1 r2
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r1 = load 4 r1 0
    store 8 r1 sp 88
    r1 = load 8 sp 88
    ret r1
end min_at_row

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 448 64
    r1 = malloc 8
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = and r1 4294967295 64
    store 8 r1 sp 8
    r1 = call read
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = and r1 4294967295 64
    store 8 r1 sp 24
    r1 = load 8 sp 8
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 32
    r2 = load 8 sp 32
    r1 = mul 8 r2 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r1 = call malloc_upto_8 r1
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 20480 0
    store 8 0 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 64
    br .for.cond

  .for.cond:
    r1 = load 8 sp 64
    r2 = load 8 sp 8
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 80
    r1 = load 8 sp 80
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end22

  .for.body:
    r1 = load 8 sp 24
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 88
    r2 = load 8 sp 88
    r1 = mul 4 r2 64
    store 8 r1 sp 96
    r1 = load 8 sp 96
    r1 = call malloc_upto_8 r1
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 112
    r1 = load 8 20480 0
    store 8 r1 sp 120
    r1 = load 8 sp 64
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 128
    r1 = load 8 sp 120
    r2 = load 8 sp 128
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 136
    r1 = load 8 sp 112
    r2 = load 8 sp 136
    store 8 r1 r2 0
    store 8 0 sp 152
    r1 = load 8 sp 152
    store 8 r1 sp 144
    br .for.cond9

  .for.cond9:
    r1 = load 8 sp 144
    r2 = load 8 sp 24
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 160
    r1 = load 8 sp 160
    br r1 .for.body13 .for.cond.cleanup12

  .for.cond.cleanup12:
    br .for.end

  .for.body13:
    r1 = call read
    store 8 r1 sp 168
    r1 = load 8 sp 168
    r1 = and r1 4294967295 64
    store 8 r1 sp 176
    r1 = load 8 20480 0
    store 8 r1 sp 184
    r1 = load 8 sp 64
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 192
    r1 = load 8 sp 184
    r2 = load 8 sp 192
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 200
    r1 = load 8 sp 200
    r1 = load 8 r1 0
    store 8 r1 sp 208
    r1 = load 8 sp 144
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 216
    r1 = load 8 sp 208
    r2 = load 8 sp 216
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 224
    r1 = load 8 sp 176
    r2 = load 8 sp 224
    store 4 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 144
    r1 = add r1 1 32
    store 8 r1 sp 232
    r1 = load 8 sp 232
    store 8 r1 sp 152
    r1 = load 8 sp 152
    store 8 r1 sp 144
    br .for.cond9

  .for.end:
    br .for.inc20

  .for.inc20:
    r1 = load 8 sp 64
    r1 = add r1 1 32
    store 8 r1 sp 240
    r1 = load 8 sp 240
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 64
    br .for.cond

  .for.end22:
    r1 = call read
    store 8 r1 sp 248
    r1 = load 8 sp 248
    r1 = and r1 4294967295 64
    store 8 r1 sp 256
    r1 = load 8 sp 256
    store 8 r1 sp 272
    r1 = load 8 sp 272
    store 8 r1 sp 264
    br .while.cond

  .while.cond:
    r1 = load 8 sp 264
    r1 = add r1 4294967295 32
    store 8 r1 sp 280
    r1 = load 8 sp 264
    r1 = icmp ne r1 0 32
    store 8 r1 sp 288
    r1 = load 8 sp 288
    br r1 .while.body .while.end

  .while.body:
    r1 = call read
    store 8 r1 sp 296
    r1 = load 8 sp 296
    r1 = and r1 4294967295 64
    store 8 r1 sp 304
    r1 = call read
    store 8 r1 sp 312
    r1 = load 8 sp 312
    r1 = and r1 4294967295 64
    store 8 r1 sp 320
    r1 = call read
    store 8 r1 sp 328
    r1 = load 8 sp 328
    r1 = and r1 4294967295 64
    store 8 r1 sp 336
    r1 = call read
    store 8 r1 sp 344
    r1 = load 8 sp 344
    r1 = and r1 4294967295 64
    store 8 r1 sp 352
    r1 = load 8 sp 304
    r2 = load 8 sp 336
    r3 = load 8 sp 352
    r1 = call min_at_row r1 r2 r3
    store 8 r1 sp 360
    r1 = load 8 sp 304
    r1 = add r1 1 32
    store 8 r1 sp 368
    r1 = load 8 sp 360
    store 8 r1 sp 384
    r1 = load 8 sp 368
    store 8 r1 sp 400
    r1 = load 8 sp 384
    store 8 r1 sp 376
    r1 = load 8 sp 400
    store 8 r1 sp 392
    br .for.cond35

  .for.cond35:
    r1 = load 8 sp 392
    r2 = load 8 sp 320
    r1 = icmp sle r1 r2 32
    store 8 r1 sp 408
    r1 = load 8 sp 408
    br r1 .for.body39 .for.cond.cleanup38

  .for.cond.cleanup38:
    br .for.end44

  .for.body39:
    r1 = load 8 sp 392
    r2 = load 8 sp 336
    r3 = load 8 sp 352
    r1 = call min_at_row r1 r2 r3
    store 8 r1 sp 416
    r1 = load 8 sp 376
    r2 = load 8 sp 416
    r1 = call min r1 r2
    store 8 r1 sp 424
    br .for.inc42

  .for.inc42:
    r1 = load 8 sp 392
    r1 = add r1 1 32
    store 8 r1 sp 432
    r1 = load 8 sp 424
    store 8 r1 sp 384
    r1 = load 8 sp 432
    store 8 r1 sp 400
    r1 = load 8 sp 384
    store 8 r1 sp 376
    r1 = load 8 sp 400
    store 8 r1 sp 392
    br .for.cond35

  .for.end44:
    r1 = load 8 sp 376
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 440
    r1 = load 8 sp 440
    call write r1
    r1 = load 8 sp 280
    store 8 r1 sp 272
    r1 = load 8 sp 272
    store 8 r1 sp 264
    br .while.cond

  .while.end:
    ret 0
end main
