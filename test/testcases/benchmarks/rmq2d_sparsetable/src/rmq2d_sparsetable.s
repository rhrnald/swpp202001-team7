
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

; Function floorlog2
start floorlog2 1:
  .entry:
    ; init sp!
    sp = sub sp 24 64
    r1 = call count_leading_zeros arg1
    store 8 r1 sp 0
    r2 = load 8 sp 0
    r1 = sub 32 r2 32
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = sub r1 1 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    ret r1
end floorlog2

; Function input
start input 2:
  .entry:
    ; init sp!
    sp = sub sp 48 64
    r1 = load 8 20480 0
    store 8 r1 sp 0
    r1 = load 4 20488 0
    store 8 r1 sp 8
    r2 = load 8 sp 8
    r1 = mul arg1 r2 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = add r1 arg2 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 32
    r1 = load 8 sp 0
    r2 = load 8 sp 32
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    ret r1
end input

; Function width
start width 1:
  .entry:
    ; init sp!
    sp = sub sp 32 64
    r1 = load 4 20488 0
    store 8 r1 sp 0
    r1 = shl 1 arg1 32
    store 8 r1 sp 8
    r1 = load 8 sp 0
    r2 = load 8 sp 8
    r1 = sub r1 r2 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = add r1 1 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    ret r1
end width

; Function height
start height 1:
  .entry:
    ; init sp!
    sp = sub sp 32 64
    r1 = load 4 20496 0
    store 8 r1 sp 0
    r1 = shl 1 arg1 32
    store 8 r1 sp 8
    r1 = load 8 sp 0
    r2 = load 8 sp 8
    r1 = sub r1 r2 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = add r1 1 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    ret r1
end height

; Function A
start A 2:
  .entry:
    ; init sp!
    sp = sub sp 56 64
    r1 = load 8 20504 0
    store 8 r1 sp 0
    r1 = load 4 20512 0
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = add r1 1 32
    store 8 r1 sp 16
    r2 = load 8 sp 16
    r1 = mul arg1 r2 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r1 = add r1 arg2 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 40
    r1 = load 8 sp 0
    r2 = load 8 sp 40
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    ret r1
end A

; Function P
start P 4:
  .entry:
    ; init sp!
    sp = sub sp 64 64
    r1 = call A arg1 arg2
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = load 8 r1 0
    store 8 r1 sp 8
    r1 = call width arg2
    store 8 r1 sp 16
    r2 = load 8 sp 16
    r1 = mul arg3 r2 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r1 = add r1 arg4 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 40
    r1 = load 8 sp 8
    r2 = load 8 sp 40
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = load 4 r1 0
    store 8 r1 sp 56
    r1 = load 8 sp 56
    ret r1
end P

; Function preprocess
start preprocess 0:
  .entry:
    ; init sp!
    sp = sub sp 896 64
    r1 = load 4 20496 0
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = call floorlog2 r1
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 4 r1 20520 0
    r1 = load 4 20488 0
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = call floorlog2 r1
    store 8 r1 sp 24
    r1 = load 8 sp 24
    store 4 r1 20512 0
    r1 = load 4 20520 0
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = add r1 1 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 48
    r2 = load 8 sp 48
    r1 = mul 8 r2 64
    store 8 r1 sp 56
    r1 = load 4 20512 0
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r1 = add r1 1 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 80
    r1 = load 8 sp 56
    r2 = load 8 sp 80
    r1 = mul r1 r2 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = call malloc_upto_8 r1
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 20504 0
    r1 = load 8 20480 0
    store 8 r1 sp 112
    r1 = call A 0 0
    store 8 r1 sp 120
    r1 = load 8 sp 112
    r2 = load 8 sp 120
    store 8 r1 r2 0
    store 8 0 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 128
    br .for.cond

  .for.cond:
    r1 = load 4 20520 0
    store 8 r1 sp 144
    r1 = load 8 sp 128
    r2 = load 8 sp 144
    r1 = icmp sle r1 r2 32
    store 8 r1 sp 152
    r1 = load 8 sp 152
    br r1 .for.body .for.end26

  .for.body:
    store 8 0 sp 168
    r1 = load 8 sp 168
    store 8 r1 sp 160
    br .for.cond8

  .for.cond8:
    r1 = load 4 20512 0
    store 8 r1 sp 176
    r1 = load 8 sp 160
    r2 = load 8 sp 176
    r1 = icmp sle r1 r2 32
    store 8 r1 sp 184
    r1 = load 8 sp 184
    br r1 .for.body11 .for.end

  .for.body11:
    r1 = load 8 sp 128
    r1 = icmp eq r1 0 32
    store 8 r1 sp 192
    r1 = load 8 sp 192
    br r1 .land.lhs.true .if.end

  .land.lhs.true:
    r1 = load 8 sp 160
    r1 = icmp eq r1 0 32
    store 8 r1 sp 200
    r1 = load 8 sp 200
    br r1 .if.then .if.end

  .if.then:
    br .for.inc

  .if.end:
    r1 = load 8 sp 128
    r1 = call height r1
    store 8 r1 sp 208
    r1 = load 8 sp 208
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 216
    r2 = load 8 sp 216
    r1 = mul 4 r2 64
    store 8 r1 sp 224
    r1 = load 8 sp 160
    r1 = call width r1
    store 8 r1 sp 232
    r1 = load 8 sp 232
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 240
    r1 = load 8 sp 224
    r2 = load 8 sp 240
    r1 = mul r1 r2 64
    store 8 r1 sp 248
    r1 = load 8 sp 248
    r1 = call malloc_upto_8 r1
    store 8 r1 sp 256
    r1 = load 8 sp 256
    store 8 r1 sp 264
    r1 = load 8 sp 128
    r2 = load 8 sp 160
    r1 = call A r1 r2
    store 8 r1 sp 272
    r1 = load 8 sp 264
    r2 = load 8 sp 272
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 160
    r1 = add r1 1 32
    store 8 r1 sp 280
    r1 = load 8 sp 280
    store 8 r1 sp 168
    r1 = load 8 sp 168
    store 8 r1 sp 160
    br .for.cond8

  .for.end:
    br .for.inc24

  .for.inc24:
    r1 = load 8 sp 128
    r1 = add r1 1 32
    store 8 r1 sp 288
    r1 = load 8 sp 288
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 128
    br .for.cond

  .for.end26:
    store 8 0 sp 304
    r1 = load 8 sp 304
    store 8 r1 sp 296
    br .for.cond27

  .for.cond27:
    r1 = load 4 20520 0
    store 8 r1 sp 312
    r1 = load 8 sp 296
    r2 = load 8 sp 312
    r1 = icmp sle r1 r2 32
    store 8 r1 sp 320
    r1 = load 8 sp 320
    br r1 .for.body30 .for.end112

  .for.body30:
    store 8 0 sp 336
    r1 = load 8 sp 336
    store 8 r1 sp 328
    br .for.cond31

  .for.cond31:
    r1 = load 4 20512 0
    store 8 r1 sp 344
    r1 = load 8 sp 328
    r2 = load 8 sp 344
    r1 = icmp sle r1 r2 32
    store 8 r1 sp 352
    r1 = load 8 sp 352
    br r1 .for.body34 .for.end109

  .for.body34:
    r1 = load 8 sp 296
    r1 = icmp eq r1 0 32
    store 8 r1 sp 360
    r1 = load 8 sp 360
    br r1 .land.lhs.true37 .if.end41

  .land.lhs.true37:
    r1 = load 8 sp 328
    r1 = icmp eq r1 0 32
    store 8 r1 sp 368
    r1 = load 8 sp 368
    br r1 .if.then40 .if.end41

  .if.then40:
    br .for.inc107

  .if.end41:
    r1 = load 8 sp 296
    r2 = load 8 sp 328
    r1 = call A r1 r2
    store 8 r1 sp 376
    r1 = load 8 sp 376
    r1 = load 8 r1 0
    store 8 r1 sp 384
    store 8 0 sp 400
    r1 = load 8 sp 400
    store 8 r1 sp 392
    br .for.cond43

  .for.cond43:
    r1 = load 8 sp 296
    r1 = call height r1
    store 8 r1 sp 408
    r1 = load 8 sp 392
    r2 = load 8 sp 408
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 416
    r1 = load 8 sp 416
    br r1 .for.body47 .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end106

  .for.body47:
    store 8 0 sp 432
    r1 = load 8 sp 432
    store 8 r1 sp 424
    br .for.cond48

  .for.cond48:
    r1 = load 8 sp 328
    r1 = call width r1
    store 8 r1 sp 440
    r1 = load 8 sp 424
    r2 = load 8 sp 440
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 448
    r1 = load 8 sp 448
    br r1 .for.body53 .for.cond.cleanup52

  .for.cond.cleanup52:
    br .for.end103

  .for.body53:
    r1 = load 8 sp 328
    r1 = icmp ne r1 0 32
    store 8 r1 sp 456
    r1 = load 8 sp 456
    br r1 .if.then56 .if.else

  .if.then56:
    r1 = load 8 sp 328
    r1 = sub r1 1 32
    store 8 r1 sp 464
    r1 = load 8 sp 296
    r2 = load 8 sp 464
    r1 = call A r1 r2
    store 8 r1 sp 472
    r1 = load 8 sp 472
    r1 = load 8 r1 0
    store 8 r1 sp 480
    r1 = load 8 sp 328
    r1 = sub r1 1 32
    store 8 r1 sp 488
    r1 = load 8 sp 488
    r1 = call width r1
    store 8 r1 sp 496
    r1 = load 8 sp 392
    r2 = load 8 sp 496
    r1 = mul r1 r2 32
    store 8 r1 sp 504
    r1 = load 8 sp 504
    r2 = load 8 sp 424
    r1 = add r1 r2 32
    store 8 r1 sp 512
    r1 = load 8 sp 512
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 520
    r1 = load 8 sp 480
    r2 = load 8 sp 520
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 528
    r1 = load 8 sp 528
    r1 = load 4 r1 0
    store 8 r1 sp 536
    r1 = load 8 sp 392
    r2 = load 8 sp 496
    r1 = mul r1 r2 32
    store 8 r1 sp 544
    r1 = load 8 sp 544
    r2 = load 8 sp 424
    r1 = add r1 r2 32
    store 8 r1 sp 552
    r1 = load 8 sp 328
    r1 = sub r1 1 32
    store 8 r1 sp 560
    r2 = load 8 sp 560
    r1 = shl 1 r2 32
    store 8 r1 sp 568
    r1 = load 8 sp 552
    r2 = load 8 sp 568
    r1 = add r1 r2 32
    store 8 r1 sp 576
    r1 = load 8 sp 576
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 584
    r1 = load 8 sp 480
    r2 = load 8 sp 584
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 592
    r1 = load 8 sp 592
    r1 = load 4 r1 0
    store 8 r1 sp 600
    r1 = load 8 sp 536
    r2 = load 8 sp 600
    r1 = call min r1 r2
    store 8 r1 sp 608
    r1 = load 8 sp 328
    r1 = call width r1
    store 8 r1 sp 616
    r1 = load 8 sp 392
    r2 = load 8 sp 616
    r1 = mul r1 r2 32
    store 8 r1 sp 624
    r1 = load 8 sp 624
    r2 = load 8 sp 424
    r1 = add r1 r2 32
    store 8 r1 sp 632
    r1 = load 8 sp 632
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 640
    r1 = load 8 sp 384
    r2 = load 8 sp 640
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 648
    r1 = load 8 sp 608
    r2 = load 8 sp 648
    store 4 r1 r2 0
    br .if.end100

  .if.else:
    r1 = load 8 sp 296
    r1 = sub r1 1 32
    store 8 r1 sp 656
    r1 = load 8 sp 656
    r2 = load 8 sp 328
    r1 = call A r1 r2
    store 8 r1 sp 664
    r1 = load 8 sp 664
    r1 = load 8 r1 0
    store 8 r1 sp 672
    r1 = load 8 sp 296
    r1 = sub r1 1 32
    store 8 r1 sp 680
    r1 = load 8 sp 680
    r1 = call height r1
    store 8 r1 sp 688
    r1 = load 8 sp 328
    r1 = call width r1
    store 8 r1 sp 696
    r1 = load 8 sp 392
    r2 = load 8 sp 696
    r1 = mul r1 r2 32
    store 8 r1 sp 704
    r1 = load 8 sp 704
    r2 = load 8 sp 424
    r1 = add r1 r2 32
    store 8 r1 sp 712
    r1 = load 8 sp 712
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 720
    r1 = load 8 sp 672
    r2 = load 8 sp 720
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 728
    r1 = load 8 sp 728
    r1 = load 4 r1 0
    store 8 r1 sp 736
    r1 = load 8 sp 296
    r1 = sub r1 1 32
    store 8 r1 sp 744
    r2 = load 8 sp 744
    r1 = shl 1 r2 32
    store 8 r1 sp 752
    r1 = load 8 sp 392
    r2 = load 8 sp 752
    r1 = add r1 r2 32
    store 8 r1 sp 760
    r1 = load 8 sp 328
    r1 = call width r1
    store 8 r1 sp 768
    r1 = load 8 sp 760
    r2 = load 8 sp 768
    r1 = mul r1 r2 32
    store 8 r1 sp 776
    r1 = load 8 sp 776
    r2 = load 8 sp 424
    r1 = add r1 r2 32
    store 8 r1 sp 784
    r1 = load 8 sp 784
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 792
    r1 = load 8 sp 672
    r2 = load 8 sp 792
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 800
    r1 = load 8 sp 800
    r1 = load 4 r1 0
    store 8 r1 sp 808
    r1 = load 8 sp 736
    r2 = load 8 sp 808
    r1 = call min r1 r2
    store 8 r1 sp 816
    r1 = load 8 sp 328
    r1 = call width r1
    store 8 r1 sp 824
    r1 = load 8 sp 392
    r2 = load 8 sp 824
    r1 = mul r1 r2 32
    store 8 r1 sp 832
    r1 = load 8 sp 832
    r2 = load 8 sp 424
    r1 = add r1 r2 32
    store 8 r1 sp 840
    r1 = load 8 sp 840
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 848
    r1 = load 8 sp 384
    r2 = load 8 sp 848
    r2 = mul r2 4 64
    r1 = add r1 r2 64
    store 8 r1 sp 856
    r1 = load 8 sp 816
    r2 = load 8 sp 856
    store 4 r1 r2 0
    br .if.end100

  .if.end100:
    br .for.inc101

  .for.inc101:
    r1 = load 8 sp 424
    r1 = add r1 1 32
    store 8 r1 sp 864
    r1 = load 8 sp 864
    store 8 r1 sp 432
    r1 = load 8 sp 432
    store 8 r1 sp 424
    br .for.cond48

  .for.end103:
    br .for.inc104

  .for.inc104:
    r1 = load 8 sp 392
    r1 = add r1 1 32
    store 8 r1 sp 872
    r1 = load 8 sp 872
    store 8 r1 sp 400
    r1 = load 8 sp 400
    store 8 r1 sp 392
    br .for.cond43

  .for.end106:
    br .for.inc107

  .for.inc107:
    r1 = load 8 sp 328
    r1 = add r1 1 32
    store 8 r1 sp 880
    r1 = load 8 sp 880
    store 8 r1 sp 336
    r1 = load 8 sp 336
    store 8 r1 sp 328
    br .for.cond31

  .for.end109:
    br .for.inc110

  .for.inc110:
    r1 = load 8 sp 296
    r1 = add r1 1 32
    store 8 r1 sp 888
    r1 = load 8 sp 888
    store 8 r1 sp 304
    r1 = load 8 sp 304
    store 8 r1 sp 296
    br .for.cond27

  .for.end112:
    ret 0
end preprocess

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 520 64
    r1 = malloc 8
    r1 = malloc 8
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
    store 4 r1 20496 0
    r1 = call read
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = and r1 4294967295 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    store 4 r1 20488 0
    r1 = load 4 20496 0
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 40
    r2 = load 8 sp 40
    r1 = mul 4 r2 64
    store 8 r1 sp 48
    r1 = load 4 20488 0
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 64
    r1 = load 8 sp 48
    r2 = load 8 sp 64
    r1 = mul r1 r2 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = call malloc_upto_8 r1
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 20480 0
    store 8 0 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 96
    br .for.cond

  .for.cond:
    r1 = load 4 20496 0
    store 8 r1 sp 112
    r1 = load 8 sp 96
    r2 = load 8 sp 112
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 120
    r1 = load 8 sp 120
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end18

  .for.body:
    store 8 0 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 128
    br .for.cond8

  .for.cond8:
    r1 = load 4 20488 0
    store 8 r1 sp 144
    r1 = load 8 sp 128
    r2 = load 8 sp 144
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 152
    r1 = load 8 sp 152
    br r1 .for.body12 .for.cond.cleanup11

  .for.cond.cleanup11:
    br .for.end

  .for.body12:
    r1 = call read
    store 8 r1 sp 160
    r1 = load 8 sp 160
    r1 = and r1 4294967295 64
    store 8 r1 sp 168
    r1 = load 8 sp 96
    r2 = load 8 sp 128
    r1 = call input r1 r2
    store 8 r1 sp 176
    r1 = load 8 sp 168
    r2 = load 8 sp 176
    store 4 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 128
    r1 = add r1 1 32
    store 8 r1 sp 184
    r1 = load 8 sp 184
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 128
    br .for.cond8

  .for.end:
    br .for.inc16

  .for.inc16:
    r1 = load 8 sp 96
    r1 = add r1 1 32
    store 8 r1 sp 192
    r1 = load 8 sp 192
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 96
    br .for.cond

  .for.end18:
    call preprocess
    r1 = call read
    store 8 r1 sp 200
    r1 = load 8 sp 200
    r1 = and r1 4294967295 64
    store 8 r1 sp 208
    r1 = load 8 sp 208
    store 8 r1 sp 224
    r1 = load 8 sp 224
    store 8 r1 sp 216
    br .while.cond

  .while.cond:
    r1 = load 8 sp 216
    r1 = add r1 4294967295 32
    store 8 r1 sp 232
    r1 = load 8 sp 216
    r1 = icmp ne r1 0 32
    store 8 r1 sp 240
    r1 = load 8 sp 240
    br r1 .while.body .while.end

  .while.body:
    r1 = call read
    store 8 r1 sp 248
    r1 = load 8 sp 248
    r1 = and r1 4294967295 64
    store 8 r1 sp 256
    r1 = call read
    store 8 r1 sp 264
    r1 = load 8 sp 264
    r1 = and r1 4294967295 64
    store 8 r1 sp 272
    r1 = call read
    store 8 r1 sp 280
    r1 = load 8 sp 280
    r1 = and r1 4294967295 64
    store 8 r1 sp 288
    r1 = call read
    store 8 r1 sp 296
    r1 = load 8 sp 296
    r1 = and r1 4294967295 64
    store 8 r1 sp 304
    r1 = load 8 sp 272
    r2 = load 8 sp 256
    r1 = sub r1 r2 32
    store 8 r1 sp 312
    r1 = load 8 sp 312
    r1 = add r1 1 32
    store 8 r1 sp 320
    r1 = load 8 sp 320
    r1 = call floorlog2 r1
    store 8 r1 sp 328
    r1 = load 8 sp 304
    r2 = load 8 sp 288
    r1 = sub r1 r2 32
    store 8 r1 sp 336
    r1 = load 8 sp 336
    r1 = add r1 1 32
    store 8 r1 sp 344
    r1 = load 8 sp 344
    r1 = call floorlog2 r1
    store 8 r1 sp 352
    r1 = load 8 sp 328
    r2 = load 8 sp 352
    r3 = load 8 sp 256
    r4 = load 8 sp 288
    r1 = call P r1 r2 r3 r4
    store 8 r1 sp 360
    r1 = load 8 sp 272
    r1 = add r1 1 32
    store 8 r1 sp 368
    r2 = load 8 sp 328
    r1 = shl 1 r2 32
    store 8 r1 sp 376
    r1 = load 8 sp 368
    r2 = load 8 sp 376
    r1 = sub r1 r2 32
    store 8 r1 sp 384
    r1 = load 8 sp 328
    r2 = load 8 sp 352
    r3 = load 8 sp 384
    r4 = load 8 sp 288
    r1 = call P r1 r2 r3 r4
    store 8 r1 sp 392
    r1 = load 8 sp 304
    r1 = add r1 1 32
    store 8 r1 sp 400
    r2 = load 8 sp 352
    r1 = shl 1 r2 32
    store 8 r1 sp 408
    r1 = load 8 sp 400
    r2 = load 8 sp 408
    r1 = sub r1 r2 32
    store 8 r1 sp 416
    r1 = load 8 sp 328
    r2 = load 8 sp 352
    r3 = load 8 sp 256
    r4 = load 8 sp 416
    r1 = call P r1 r2 r3 r4
    store 8 r1 sp 424
    r1 = load 8 sp 272
    r1 = add r1 1 32
    store 8 r1 sp 432
    r2 = load 8 sp 328
    r1 = shl 1 r2 32
    store 8 r1 sp 440
    r1 = load 8 sp 432
    r2 = load 8 sp 440
    r1 = sub r1 r2 32
    store 8 r1 sp 448
    r1 = load 8 sp 304
    r1 = add r1 1 32
    store 8 r1 sp 456
    r2 = load 8 sp 352
    r1 = shl 1 r2 32
    store 8 r1 sp 464
    r1 = load 8 sp 456
    r2 = load 8 sp 464
    r1 = sub r1 r2 32
    store 8 r1 sp 472
    r1 = load 8 sp 328
    r2 = load 8 sp 352
    r3 = load 8 sp 448
    r4 = load 8 sp 472
    r1 = call P r1 r2 r3 r4
    store 8 r1 sp 480
    r1 = load 8 sp 360
    r2 = load 8 sp 392
    r1 = call min r1 r2
    store 8 r1 sp 488
    r1 = load 8 sp 424
    r2 = load 8 sp 480
    r1 = call min r1 r2
    store 8 r1 sp 496
    r1 = load 8 sp 488
    r2 = load 8 sp 496
    r1 = call min r1 r2
    store 8 r1 sp 504
    r1 = load 8 sp 504
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 512
    r1 = load 8 sp 512
    call write r1
    r1 = load 8 sp 232
    store 8 r1 sp 224
    r1 = load 8 sp 224
    store 8 r1 sp 216
    br .while.cond

  .while.end:
    ret 0
end main
