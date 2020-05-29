
; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 7408 64
    r1 = add sp 208 64
    store 8 r1 sp 0
    r1 = call read
    store 8 r1 sp 8
    r1 = load 8 sp 0
    store 8 r1 sp 16
    store 8 0 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond

  .for.cond:
    r1 = load 8 sp 24
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end8

  .for.body:
    store 8 0 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond1

  .for.cond1:
    r1 = load 8 sp 48
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    br r1 .for.body4 .for.cond.cleanup3

  .for.cond.cleanup3:
    br .for.end

  .for.body4:
    r1 = load 8 sp 24
    r2 = load 8 sp 48
    r1 = add r1 r2 64
    store 8 r1 sp 72
    r1 = load 8 sp 0
    r2 = load 8 sp 48
    r2 = mul r2 240 64
    r1 = add r1 r2 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r2 = load 8 sp 24
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 88
    r1 = load 8 sp 72
    r2 = load 8 sp 88
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 48
    r1 = add r1 1 64
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond1

  .for.end:
    br .for.inc6

  .for.inc6:
    r1 = load 8 sp 24
    r1 = add r1 1 64
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond

  .for.end8:
    store 8 0 sp 120
    r1 = load 8 sp 120
    store 8 r1 sp 112
    br .for.cond10

  .for.cond10:
    r1 = load 8 sp 112
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 128
    r1 = load 8 sp 128
    br r1 .for.body13 .for.cond.cleanup12

  .for.cond.cleanup12:
    br .for.end26

  .for.body13:
    store 8 0 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 136
    br .for.cond15

  .for.cond15:
    r1 = load 8 sp 136
    r2 = load 8 sp 8
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 152
    r1 = load 8 sp 152
    br r1 .for.body18 .for.cond.cleanup17

  .for.cond.cleanup17:
    br .for.end23

  .for.body18:
    r1 = load 8 sp 0
    r2 = load 8 sp 112
    r2 = mul r2 240 64
    r1 = add r1 r2 64
    store 8 r1 sp 160
    r1 = load 8 sp 160
    r2 = load 8 sp 136
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 168
    r1 = load 8 sp 168
    r1 = load 8 r1 0
    store 8 r1 sp 176
    r1 = load 8 sp 176
    call write r1
    br .for.inc21

  .for.inc21:
    r1 = load 8 sp 136
    r1 = add r1 1 64
    store 8 r1 sp 184
    r1 = load 8 sp 184
    store 8 r1 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 136
    br .for.cond15

  .for.end23:
    br .for.inc24

  .for.inc24:
    r1 = load 8 sp 112
    r1 = add r1 1 64
    store 8 r1 sp 192
    r1 = load 8 sp 192
    store 8 r1 sp 120
    r1 = load 8 sp 120
    store 8 r1 sp 112
    br .for.cond10

  .for.end26:
    r1 = load 8 sp 0
    store 8 r1 sp 200
    ret 0
end main
