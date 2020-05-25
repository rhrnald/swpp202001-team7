
; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 8456 64
    r1 = add sp 456 64
    store 8 r1 sp 0
    r1 = call read
    store 8 r1 sp 8
    r1 = call read
    store 8 r1 sp 16
    r1 = load 8 sp 0
    store 8 r1 sp 24
    store 8 0 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond

  .for.cond:
    r1 = load 8 sp 32
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end8

  .for.body:
    store 8 0 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 56
    br .for.cond2

  .for.cond2:
    r1 = load 8 sp 56
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    br r1 .for.body5 .for.cond.cleanup4

  .for.cond.cleanup4:
    br .for.end

  .for.body5:
    br .for.inc

  .for.inc:
    r1 = load 8 sp 56
    r1 = add r1 1 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 56
    br .for.cond2

  .for.end:
    br .for.inc6

  .for.inc6:
    r1 = load 8 sp 32
    r1 = add r1 1 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond

  .for.end8:
    store 8 0 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 96
    br .for.cond10

  .for.cond10:
    r1 = load 8 sp 96
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    br r1 .for.body13 .for.cond.cleanup12

  .for.cond.cleanup12:
    br .for.end34

  .for.body13:
    store 8 0 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 120
    br .for.cond15

  .for.cond15:
    r1 = load 8 sp 120
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 136
    r1 = load 8 sp 136
    br r1 .for.body18 .for.cond.cleanup17

  .for.cond.cleanup17:
    br .for.end31

  .for.body18:
    store 8 0 sp 152
    r1 = load 8 sp 152
    store 8 r1 sp 144
    br .for.cond19

  .for.cond19:
    r1 = load 8 sp 144
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 160
    r1 = load 8 sp 160
    br r1 .for.body22 .for.cond.cleanup21

  .for.cond.cleanup21:
    br .for.end28

  .for.body22:
    r1 = load 8 sp 96
    r2 = load 8 sp 120
    r1 = mul r1 r2 64
    store 8 r1 sp 168
    r1 = load 8 sp 168
    r2 = load 8 sp 144
    r1 = add r1 r2 64
    store 8 r1 sp 176
    r1 = load 8 sp 0
    r2 = load 8 sp 144
    r2 = mul r2 800 64
    r1 = add r1 r2 64
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r2 = load 8 sp 96
    r2 = mul r2 80 64
    r1 = add r1 r2 64
    store 8 r1 sp 192
    r1 = load 8 sp 192
    r2 = load 8 sp 120
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 200
    r1 = load 8 sp 176
    r2 = load 8 sp 200
    store 8 r1 r2 0
    br .for.inc26

  .for.inc26:
    r1 = load 8 sp 144
    r1 = add r1 1 64
    store 8 r1 sp 208
    r1 = load 8 sp 208
    store 8 r1 sp 152
    r1 = load 8 sp 152
    store 8 r1 sp 144
    br .for.cond19

  .for.end28:
    br .for.inc29

  .for.inc29:
    r1 = load 8 sp 120
    r1 = add r1 1 64
    store 8 r1 sp 216
    r1 = load 8 sp 216
    store 8 r1 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 120
    br .for.cond15

  .for.end31:
    br .for.inc32

  .for.inc32:
    r1 = load 8 sp 96
    r1 = add r1 1 64
    store 8 r1 sp 224
    r1 = load 8 sp 224
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 96
    br .for.cond10

  .for.end34:
    store 8 0 sp 240
    store 8 0 sp 256
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    br .for.cond36

  .for.cond36:
    r1 = load 8 sp 248
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 264
    r1 = load 8 sp 264
    br r1 .for.body39 .for.cond.cleanup38

  .for.cond.cleanup38:
    br .for.end64

  .for.body39:
    r1 = load 8 sp 232
    store 8 r1 sp 280
    store 8 0 sp 296
    r1 = load 8 sp 280
    store 8 r1 sp 272
    r1 = load 8 sp 296
    store 8 r1 sp 288
    br .for.cond41

  .for.cond41:
    r1 = load 8 sp 288
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 304
    r1 = load 8 sp 304
    br r1 .for.body44 .for.cond.cleanup43

  .for.cond.cleanup43:
    br .for.end61

  .for.body44:
    r1 = load 8 sp 272
    store 8 r1 sp 320
    store 8 0 sp 336
    r1 = load 8 sp 320
    store 8 r1 sp 312
    r1 = load 8 sp 336
    store 8 r1 sp 328
    br .for.cond46

  .for.cond46:
    r1 = load 8 sp 328
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 344
    r1 = load 8 sp 344
    br r1 .for.body49 .for.cond.cleanup48

  .for.cond.cleanup48:
    br .for.end58

  .for.body49:
    r1 = load 8 sp 16
    r2 = load 8 sp 8
    r1 = icmp ne r1 r2 64
    store 8 r1 sp 352
    r1 = load 8 sp 312
    store 8 r1 sp 416
    r1 = load 8 sp 416
    store 8 r1 sp 408
    r1 = load 8 sp 352
    br r1 .if.then .if.end

  .if.then:
    r1 = load 8 sp 0
    r2 = load 8 sp 288
    r2 = mul r2 800 64
    r1 = add r1 r2 64
    store 8 r1 sp 360
    r1 = load 8 sp 360
    r2 = load 8 sp 328
    r2 = mul r2 80 64
    r1 = add r1 r2 64
    store 8 r1 sp 368
    r1 = load 8 sp 368
    r2 = load 8 sp 248
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 376
    r1 = load 8 sp 376
    r1 = load 8 r1 0
    store 8 r1 sp 384
    r2 = load 8 sp 384
    r1 = add 2 r2 64
    store 8 r1 sp 392
    r1 = load 8 sp 312
    r2 = load 8 sp 392
    r1 = add r1 r2 64
    store 8 r1 sp 400
    r1 = load 8 sp 400
    store 8 r1 sp 416
    r1 = load 8 sp 416
    store 8 r1 sp 408
    br .if.end

  .if.end:
    br .for.inc56

  .for.inc56:
    r1 = load 8 sp 328
    r1 = add r1 1 64
    store 8 r1 sp 424
    r1 = load 8 sp 408
    store 8 r1 sp 320
    r1 = load 8 sp 424
    store 8 r1 sp 336
    r1 = load 8 sp 320
    store 8 r1 sp 312
    r1 = load 8 sp 336
    store 8 r1 sp 328
    br .for.cond46

  .for.end58:
    br .for.inc59

  .for.inc59:
    r1 = load 8 sp 288
    r1 = add r1 1 64
    store 8 r1 sp 432
    r1 = load 8 sp 312
    store 8 r1 sp 280
    r1 = load 8 sp 432
    store 8 r1 sp 296
    r1 = load 8 sp 280
    store 8 r1 sp 272
    r1 = load 8 sp 296
    store 8 r1 sp 288
    br .for.cond41

  .for.end61:
    br .for.inc62

  .for.inc62:
    r1 = load 8 sp 248
    r1 = add r1 1 64
    store 8 r1 sp 440
    r1 = load 8 sp 272
    store 8 r1 sp 240
    r1 = load 8 sp 440
    store 8 r1 sp 256
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    br .for.cond36

  .for.end64:
    r1 = load 8 sp 232
    call write r1
    r1 = load 8 sp 0
    store 8 r1 sp 448
    ret 0
end main
