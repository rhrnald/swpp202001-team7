
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

; Function initA
start initA 0:
  .entry:
    ; init sp!
    sp = sub sp 528 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .while.cond

  .while.cond:
    r1 = load 8 sp 0
    r1 = and r1 4294967295 64
    store 8 r1 sp 16
    r2 = load 8 sp 16
    r1 = shl 1 r2 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 32
    r1 = load 4 20480 0
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 48
    r1 = load 8 sp 32
    r2 = load 8 sp 48
    r1 = icmp sle r1 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .while.body .while.end

  .while.body:
    r1 = load 8 sp 0
    r1 = add r1 1 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .while.cond

  .while.end:
    r1 = load 8 sp 0
    r1 = and r1 4294967295 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 4 r1 20488 0
    r1 = load 4 20488 0
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 88
    r2 = load 8 sp 88
    r1 = mul 8 r2 64
    store 8 r1 sp 96
    r1 = load 8 sp 96
    r1 = call malloc_upto_8 r1
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 112
    r1 = load 8 sp 112
    store 8 r1 20496 0
    r1 = load 8 20504 0
    store 8 r1 sp 120
    r1 = load 8 20496 0
    store 8 r1 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 136
    r1 = load 8 sp 120
    r2 = load 8 sp 136
    store 8 r1 r2 0
    store 8 1 sp 152
    r1 = load 8 sp 152
    store 8 r1 sp 144
    br .while.cond5

  .while.cond5:
    r1 = load 8 sp 144
    r1 = and r1 4294967295 64
    store 8 r1 sp 160
    r2 = load 8 sp 160
    r1 = shl 1 r2 32
    store 8 r1 sp 168
    r1 = load 8 sp 168
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 176
    r1 = load 4 20480 0
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 192
    r1 = load 8 sp 176
    r2 = load 8 sp 192
    r1 = icmp sle r1 r2 64
    store 8 r1 sp 200
    r1 = load 8 sp 200
    br r1 .while.body12 .while.end36

  .while.body12:
    r1 = load 8 sp 144
    r1 = and r1 4294967295 64
    store 8 r1 sp 208
    r2 = load 8 sp 208
    r1 = shl 1 r2 32
    store 8 r1 sp 216
    r1 = load 4 20480 0
    store 8 r1 sp 224
    r1 = load 8 sp 224
    r2 = load 8 sp 216
    r1 = sub r1 r2 32
    store 8 r1 sp 232
    r1 = load 8 sp 232
    r1 = add r1 1 32
    store 8 r1 sp 240
    r1 = load 8 sp 240
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 248
    r2 = load 8 sp 248
    r1 = mul 4 r2 64
    store 8 r1 sp 256
    r1 = load 8 sp 256
    r1 = call malloc_upto_8 r1
    store 8 r1 sp 264
    r1 = load 8 sp 264
    store 8 r1 sp 272
    r1 = load 8 20496 0
    store 8 r1 sp 280
    r1 = load 8 sp 280
    r2 = load 8 sp 144
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 288
    r1 = load 8 sp 272
    r2 = load 8 sp 288
    store 8 r1 r2 0
    store 8 0 sp 304
    r1 = load 8 sp 304
    store 8 r1 sp 296
    br .for.cond

  .for.cond:
    r1 = load 4 20480 0
    store 8 r1 sp 312
    r1 = load 8 sp 312
    r2 = load 8 sp 216
    r1 = sub r1 r2 32
    store 8 r1 sp 320
    r1 = load 8 sp 296
    r2 = load 8 sp 320
    r1 = icmp sle r1 r2 32
    store 8 r1 sp 328
    r1 = load 8 sp 328
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = load 8 20496 0
    store 8 r1 sp 336
    r1 = load 8 sp 144
    r1 = sub r1 1 64
    store 8 r1 sp 344
    r1 = load 8 sp 336
    r2 = load 8 sp 344
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 352
    r1 = load 8 sp 352
    r1 = load 8 r1 0
    store 8 r1 sp 360
    r1 = load 8 sp 296
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 368
    r1 = load 8 sp 360
    r2 = load 8 sp 368
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 376
    r1 = load 8 sp 376
    r1 = load 4 r1 0
    store 8 r1 sp 384
    r1 = load 8 20496 0
    store 8 r1 sp 392
    r1 = load 8 sp 144
    r1 = sub r1 1 64
    store 8 r1 sp 400
    r1 = load 8 sp 392
    r2 = load 8 sp 400
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 408
    r1 = load 8 sp 408
    r1 = load 8 r1 0
    store 8 r1 sp 416
    r1 = load 8 sp 216
    r1 = sdiv r1 2 32
    store 8 r1 sp 424
    r1 = load 8 sp 296
    r2 = load 8 sp 424
    r1 = add r1 r2 32
    store 8 r1 sp 432
    r1 = load 8 sp 432
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 440
    r1 = load 8 sp 416
    r2 = load 8 sp 440
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 448
    r1 = load 8 sp 448
    r1 = load 4 r1 0
    store 8 r1 sp 456
    r1 = load 8 sp 384
    r2 = load 8 sp 456
    r1 = call min r1 r2
    store 8 r1 sp 464
    r1 = load 8 20496 0
    store 8 r1 sp 472
    r1 = load 8 sp 472
    r2 = load 8 sp 144
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 480
    r1 = load 8 sp 480
    r1 = load 8 r1 0
    store 8 r1 sp 488
    r1 = load 8 sp 296
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 496
    r1 = load 8 sp 488
    r2 = load 8 sp 496
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 504
    r1 = load 8 sp 464
    r2 = load 8 sp 504
    store 4 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 296
    r1 = add r1 1 32
    store 8 r1 sp 512
    r1 = load 8 sp 512
    store 8 r1 sp 304
    r1 = load 8 sp 304
    store 8 r1 sp 296
    br .for.cond

  .for.end:
    r1 = load 8 sp 144
    r1 = add r1 1 64
    store 8 r1 sp 520
    r1 = load 8 sp 520
    store 8 r1 sp 152
    r1 = load 8 sp 152
    store 8 r1 sp 144
    br .while.cond5

  .while.end36:
    ret 0
end initA

; Function count_leading_zeros
start count_leading_zeros 1:
  .entry:
    ; init sp!
    sp = sub sp 80 64
    store 8 0 sp 8
    store 8 31 sp 24
    r1 = load 8 sp 8
    store 8 r1 sp 0
    r1 = load 8 sp 24
    store 8 r1 sp 16
    br .for.cond

  .for.cond:
    r1 = load 8 sp 16
    r1 = icmp sge r1 0 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .cleanup

  .for.body:
    r2 = load 8 sp 16
    r1 = shl 1 r2 32
    store 8 r1 sp 40
    r2 = load 8 sp 40
    r1 = and arg1 r2 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = icmp ne r1 0 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .if.then .if.end

  .if.then:
    br .cleanup

  .if.end:
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 64
    br .for.inc

  .for.inc:
    r1 = load 8 sp 16
    r1 = add r1 4294967295 32
    store 8 r1 sp 72
    r1 = load 8 sp 64
    store 8 r1 sp 8
    r1 = load 8 sp 72
    store 8 r1 sp 24
    r1 = load 8 sp 8
    store 8 r1 sp 0
    r1 = load 8 sp 24
    store 8 r1 sp 16
    br .for.cond

  .cleanup:
    br .for.end

  .for.end:
    r1 = load 8 sp 0
    ret r1
end count_leading_zeros

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 424 64
    r1 = malloc 8
    r1 = malloc 8
    r1 = malloc 8
    r1 = malloc 8
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = and r1 4294967295 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 4 r1 20480 0
    r1 = load 4 20480 0
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 24
    r2 = load 8 sp 24
    r1 = mul 4 r2 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = call malloc_upto_8 r1
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 20504 0
    store 8 0 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 56
    br .for.cond

  .for.cond:
    r1 = load 4 20480 0
    store 8 r1 sp 72
    r1 = load 8 sp 56
    r2 = load 8 sp 72
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 80
    r1 = load 8 sp 80
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = call read
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = and r1 4294967295 64
    store 8 r1 sp 96
    r1 = load 8 20504 0
    store 8 r1 sp 104
    r1 = load 8 sp 56
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 112
    r1 = load 8 sp 104
    r2 = load 8 sp 112
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 120
    r1 = load 8 sp 96
    r2 = load 8 sp 120
    store 4 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 56
    r1 = add r1 1 32
    store 8 r1 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 56
    br .for.cond

  .for.end:
    call initA
    r1 = call read
    store 8 r1 sp 136
    r1 = load 8 sp 136
    r1 = and r1 4294967295 64
    store 8 r1 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 160
    r1 = load 8 sp 160
    store 8 r1 sp 152
    br .while.cond

  .while.cond:
    r1 = load 8 sp 152
    r1 = add r1 4294967295 32
    store 8 r1 sp 168
    r1 = load 8 sp 152
    r1 = icmp ne r1 0 32
    store 8 r1 sp 176
    r1 = load 8 sp 176
    br r1 .while.body .while.end

  .while.body:
    r1 = call read
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r1 = and r1 4294967295 64
    store 8 r1 sp 192
    r1 = call read
    store 8 r1 sp 200
    r1 = load 8 sp 200
    r1 = and r1 4294967295 64
    store 8 r1 sp 208
    r1 = load 8 sp 208
    r2 = load 8 sp 192
    r1 = sub r1 r2 32
    store 8 r1 sp 216
    r1 = load 8 sp 216
    r1 = add r1 1 32
    store 8 r1 sp 224
    r1 = load 8 sp 224
    r1 = call count_leading_zeros r1
    store 8 r1 sp 232
    r2 = load 8 sp 232
    r1 = sub 32 r2 32
    store 8 r1 sp 240
    r1 = load 8 20496 0
    store 8 r1 sp 248
    r1 = load 8 sp 240
    r1 = sub r1 1 32
    store 8 r1 sp 256
    r1 = load 8 sp 256
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 264
    r1 = load 8 sp 248
    r2 = load 8 sp 264
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 272
    r1 = load 8 sp 272
    r1 = load 8 r1 0
    store 8 r1 sp 280
    r1 = load 8 sp 192
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 288
    r1 = load 8 sp 280
    r2 = load 8 sp 288
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 296
    r1 = load 8 sp 296
    r1 = load 4 r1 0
    store 8 r1 sp 304
    r1 = load 8 20496 0
    store 8 r1 sp 312
    r1 = load 8 sp 240
    r1 = sub r1 1 32
    store 8 r1 sp 320
    r1 = load 8 sp 320
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 328
    r1 = load 8 sp 312
    r2 = load 8 sp 328
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 336
    r1 = load 8 sp 336
    r1 = load 8 r1 0
    store 8 r1 sp 344
    r1 = load 8 sp 240
    r1 = sub r1 1 32
    store 8 r1 sp 352
    r2 = load 8 sp 352
    r1 = shl 1 r2 32
    store 8 r1 sp 360
    r1 = load 8 sp 208
    r2 = load 8 sp 360
    r1 = sub r1 r2 32
    store 8 r1 sp 368
    r1 = load 8 sp 368
    r1 = add r1 1 32
    store 8 r1 sp 376
    r1 = load 8 sp 376
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 384
    r1 = load 8 sp 344
    r2 = load 8 sp 384
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 392
    r1 = load 8 sp 392
    r1 = load 4 r1 0
    store 8 r1 sp 400
    r1 = load 8 sp 304
    r2 = load 8 sp 400
    r1 = call min r1 r2
    store 8 r1 sp 408
    r1 = load 8 sp 408
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 416
    r1 = load 8 sp 416
    call write r1
    r1 = load 8 sp 168
    store 8 r1 sp 160
    r1 = load 8 sp 160
    store 8 r1 sp 152
    br .while.cond

  .while.end:
    ret 0
end main
