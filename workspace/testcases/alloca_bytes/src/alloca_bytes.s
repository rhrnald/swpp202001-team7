
; Function __alloca_bytes__
start __alloca_bytes__ 1:
  .entry:
    ; init sp!
    sp = sub sp 8 64
    r1 = malloc arg1
    store 8 r1 sp 0
    r1 = load 8 sp 0
    ret r1
end __alloca_bytes__

; Function heavy_func
start heavy_func 16:
  .entry:
    ; init sp!
    sp = sub sp 120 64
    r1 = add arg1 arg2 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = add r1 arg3 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = add r1 arg4 64
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = add r1 arg5 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r1 = add r1 arg6 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = add r1 arg7 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r1 = add r1 arg8 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = add r1 arg9 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r1 = add r1 arg10 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r1 = add r1 arg11 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = add r1 arg12 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r1 = add r1 arg13 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = add r1 arg14 64
    store 8 r1 sp 96
    r1 = load 8 sp 96
    r1 = add r1 arg15 64
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r1 = add r1 arg16 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    call write r1
    ret 0
end heavy_func

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 440 64
    r1 = call __alloca_bytes__ 8
    store 8 r1 sp 0
    r1 = call read
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 24
    store 8 0 sp 40
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond

  .for.cond:
    r1 = load 8 sp 32
    r1 = icmp slt r1 8 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = load 8 sp 16
    r1 = and r1 255 64
    store 8 r1 sp 56
    r1 = load 8 sp 32
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 64
    r1 = load 8 sp 0
    r2 = load 8 sp 64
    r1 = add r1 r2 64
    store 8 r1 sp 72
    r1 = load 8 sp 56
    r2 = load 8 sp 72
    store 1 r1 r2 0
    r1 = load 8 sp 16
    r1 = lshr r1 8 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r1 = mul r1 18446744073709551615 64
    store 8 r1 sp 88
    br .for.inc

  .for.inc:
    r1 = load 8 sp 32
    r1 = add r1 1 32
    store 8 r1 sp 96
    r1 = load 8 sp 88
    store 8 r1 sp 24
    r1 = load 8 sp 96
    store 8 r1 sp 40
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond

  .for.end:
    store 8 0 sp 112
    store 8 0 sp 128
    r1 = load 8 sp 112
    store 8 r1 sp 104
    r1 = load 8 sp 128
    store 8 r1 sp 120
    br .for.cond3

  .for.cond3:
    r1 = load 8 sp 120
    r1 = icmp slt r1 8 32
    store 8 r1 sp 136
    r1 = load 8 sp 136
    br r1 .for.body7 .for.cond.cleanup6

  .for.cond.cleanup6:
    br .for.end13

  .for.body7:
    r1 = load 8 sp 120
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 144
    r1 = load 8 sp 0
    r2 = load 8 sp 144
    r1 = add r1 r2 64
    store 8 r1 sp 152
    r1 = load 8 sp 152
    r1 = load 1 r1 0
    store 8 r1 sp 160
    r1 = load 8 sp 160
    store 8 r1 sp 168
    r1 = load 8 sp 104
    r2 = load 8 sp 168
    r1 = add r1 r2 64
    store 8 r1 sp 176
    br .for.inc11

  .for.inc11:
    r1 = load 8 sp 120
    r1 = add r1 1 32
    store 8 r1 sp 184
    r1 = load 8 sp 176
    store 8 r1 sp 112
    r1 = load 8 sp 184
    store 8 r1 sp 128
    r1 = load 8 sp 112
    store 8 r1 sp 104
    r1 = load 8 sp 128
    store 8 r1 sp 120
    br .for.cond3

  .for.end13:
    r1 = load 8 sp 104
    call write r1
    r1 = call read
    store 8 r1 sp 192
    r1 = call read
    store 8 r1 sp 200
    r1 = call read
    store 8 r1 sp 208
    r1 = call read
    store 8 r1 sp 216
    r1 = call read
    store 8 r1 sp 224
    r1 = call read
    store 8 r1 sp 232
    r1 = call read
    store 8 r1 sp 240
    r1 = call read
    store 8 r1 sp 248
    r1 = call read
    store 8 r1 sp 256
    r1 = call read
    store 8 r1 sp 264
    r1 = call read
    store 8 r1 sp 272
    r1 = call read
    store 8 r1 sp 280
    r1 = call read
    store 8 r1 sp 288
    r1 = call read
    store 8 r1 sp 296
    r1 = call read
    store 8 r1 sp 304
    r1 = call read
    store 8 r1 sp 312
    r1 = load 8 sp 192
    r2 = load 8 sp 200
    r3 = load 8 sp 208
    r4 = load 8 sp 216
    r5 = load 8 sp 224
    r6 = load 8 sp 232
    r7 = load 8 sp 240
    r8 = load 8 sp 248
    r9 = load 8 sp 256
    r10 = load 8 sp 264
    r11 = load 8 sp 272
    r12 = load 8 sp 280
    r13 = load 8 sp 288
    r14 = load 8 sp 296
    r15 = load 8 sp 304
    r16 = load 8 sp 312
    call heavy_func r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16
    r1 = call read
    store 8 r1 sp 320
    r1 = call read
    store 8 r1 sp 328
    r1 = call read
    store 8 r1 sp 336
    r1 = call read
    store 8 r1 sp 344
    r1 = call read
    store 8 r1 sp 352
    r1 = call read
    store 8 r1 sp 360
    r1 = call read
    store 8 r1 sp 368
    r1 = call read
    store 8 r1 sp 376
    r1 = call read
    store 8 r1 sp 384
    r1 = call read
    store 8 r1 sp 392
    r1 = call read
    store 8 r1 sp 400
    r1 = call read
    store 8 r1 sp 408
    r1 = call read
    store 8 r1 sp 416
    r1 = call read
    store 8 r1 sp 424
    r1 = call read
    store 8 r1 sp 432
    r1 = load 8 sp 320
    r2 = load 8 sp 328
    r3 = load 8 sp 336
    r4 = load 8 sp 344
    r5 = load 8 sp 352
    r6 = load 8 sp 360
    r7 = load 8 sp 368
    r9 = load 8 sp 376
    r10 = load 8 sp 384
    r11 = load 8 sp 392
    r12 = load 8 sp 400
    r13 = load 8 sp 408
    r14 = load 8 sp 416
    r15 = load 8 sp 424
    r16 = load 8 sp 432
    call heavy_func r1 r2 r3 r4 r5 r6 r7 0 r9 r10 r11 r12 r13 r14 r15 r16
    ret 0
end main
