
; Function insert
start insert 2:
  .entry:
    ; init sp!
    sp = sub sp 264 64
    store 8 arg1 sp 8
    store 8 0 sp 24
    r1 = load 8 sp 8
    store 8 r1 sp 0
    r1 = load 8 sp 24
    store 8 r1 sp 16
    br .while.cond

  .while.cond:
    br .while.body

  .while.body:
    r1 = load 8 sp 0
    r1 = load 8 r1 0
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = icmp ugt r1 arg2 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .if.then .if.else

  .if.then:
    r1 = load 8 sp 0
    r1 = add r1 8 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = load 8 r1 0
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r1 = icmp eq r1 0 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    br r1 .if.then2 .if.end

  .if.then2:
    r1 = malloc 24
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 88
    r2 = load 8 sp 88
    store 8 arg2 r2 0
    r1 = load 8 sp 88
    r1 = add r1 8 64
    store 8 r1 sp 96
    r2 = load 8 sp 96
    store 8 0 r2 0
    r1 = load 8 sp 88
    r1 = add r1 16 64
    store 8 r1 sp 104
    r2 = load 8 sp 104
    store 8 0 r2 0
    r1 = load 8 sp 88
    store 8 r1 sp 112
    r1 = load 8 sp 0
    r1 = add r1 8 64
    store 8 r1 sp 120
    r1 = load 8 sp 112
    r2 = load 8 sp 120
    store 8 r1 r2 0
    r1 = load 8 sp 0
    store 8 r1 sp 224
    store 8 1 sp 240
    store 8 1 sp 256
    r1 = load 8 sp 224
    store 8 r1 sp 216
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    br .cleanup

  .if.end:
    r1 = load 8 sp 64
    store 8 r1 sp 224
    store 8 2 sp 240
    r1 = load 8 sp 16
    store 8 r1 sp 256
    r1 = load 8 sp 224
    store 8 r1 sp 216
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    br .cleanup

  .if.else:
    r1 = load 8 sp 32
    r1 = icmp ult r1 arg2 64
    store 8 r1 sp 128
    r1 = load 8 sp 128
    br r1 .if.then7 .if.else17

  .if.then7:
    r1 = load 8 sp 0
    r1 = add r1 16 64
    store 8 r1 sp 136
    r1 = load 8 sp 136
    r1 = load 8 r1 0
    store 8 r1 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 152
    r1 = load 8 sp 152
    r1 = icmp eq r1 0 64
    store 8 r1 sp 160
    r1 = load 8 sp 160
    br r1 .if.then10 .if.end16

  .if.then10:
    r1 = malloc 24
    store 8 r1 sp 168
    r1 = load 8 sp 168
    store 8 r1 sp 176
    r2 = load 8 sp 176
    store 8 arg2 r2 0
    r1 = load 8 sp 176
    r1 = add r1 8 64
    store 8 r1 sp 184
    r2 = load 8 sp 184
    store 8 0 r2 0
    r1 = load 8 sp 176
    r1 = add r1 16 64
    store 8 r1 sp 192
    r2 = load 8 sp 192
    store 8 0 r2 0
    r1 = load 8 sp 176
    store 8 r1 sp 200
    r1 = load 8 sp 0
    r1 = add r1 16 64
    store 8 r1 sp 208
    r1 = load 8 sp 200
    r2 = load 8 sp 208
    store 8 r1 r2 0
    r1 = load 8 sp 0
    store 8 r1 sp 224
    store 8 1 sp 240
    store 8 1 sp 256
    r1 = load 8 sp 224
    store 8 r1 sp 216
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    br .cleanup

  .if.end16:
    r1 = load 8 sp 152
    store 8 r1 sp 224
    store 8 2 sp 240
    r1 = load 8 sp 16
    store 8 r1 sp 256
    r1 = load 8 sp 224
    store 8 r1 sp 216
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    br .cleanup

  .if.else17:
    r1 = load 8 sp 0
    store 8 r1 sp 224
    store 8 1 sp 240
    store 8 0 sp 256
    r1 = load 8 sp 224
    store 8 r1 sp 216
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    br .cleanup

  .cleanup:
    r1 = load 8 sp 216
    store 8 r1 sp 8
    r1 = load 8 sp 248
    store 8 r1 sp 24
    r1 = load 8 sp 8
    store 8 r1 sp 0
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 232
    switch r1 2 .while.cond .cleanup19

  .cleanup19:
    r1 = load 8 sp 248
    ret r1
end insert

; Function adjust
start adjust 1:
  .entry:
    ; init sp!
    sp = sub sp 192 64
    r1 = mul arg1 1 64
    r1 = add r1 8 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = load 8 r1 0
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = icmp eq r1 0 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    br r1 .if.then .if.end

  .if.then:
    r1 = mul arg1 1 64
    r1 = add r1 16 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = load 8 r1 0
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 184
    r1 = load 8 sp 184
    store 8 r1 sp 176
    br .cleanup

  .if.end:
    r1 = load 8 sp 16
    store 8 r1 sp 64
    store 8 0 sp 80
    r1 = load 8 sp 64
    store 8 r1 sp 56
    r1 = load 8 sp 80
    store 8 r1 sp 72
    br .while.cond

  .while.cond:
    r1 = load 8 sp 56
    r1 = add r1 16 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = load 8 r1 0
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r1 = icmp ne r1 0 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    br r1 .while.body .while.end

  .while.body:
    r1 = load 8 sp 56
    r1 = add r1 16 64
    store 8 r1 sp 120
    r1 = load 8 sp 120
    r1 = load 8 r1 0
    store 8 r1 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 64
    r1 = load 8 sp 56
    store 8 r1 sp 80
    r1 = load 8 sp 64
    store 8 r1 sp 56
    r1 = load 8 sp 80
    store 8 r1 sp 72
    br .while.cond

  .while.end:
    r1 = load 8 sp 72
    r1 = icmp ne r1 0 64
    store 8 r1 sp 144
    r1 = load 8 sp 144
    br r1 .if.then6 .if.end9

  .if.then6:
    r1 = load 8 sp 56
    r1 = add r1 8 64
    store 8 r1 sp 152
    r1 = load 8 sp 152
    r1 = load 8 r1 0
    store 8 r1 sp 160
    r1 = load 8 sp 72
    r1 = add r1 16 64
    store 8 r1 sp 168
    r1 = load 8 sp 160
    r2 = load 8 sp 168
    store 8 r1 r2 0
    br .if.end9

  .if.end9:
    r1 = load 8 sp 56
    store 8 r1 sp 184
    r1 = load 8 sp 184
    store 8 r1 sp 176
    br .cleanup

  .cleanup:
    r1 = load 8 sp 176
    ret r1
end adjust

; Function remove
start remove 2:
  .entry:
    ; init sp!
    sp = sub sp 296 64
    r1 = load 8 arg1 0
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = icmp eq r1 arg2 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    br r1 .if.then .if.end

  .if.then:
    store 8 0 sp 288
    r1 = load 8 sp 288
    store 8 r1 sp 280
    br .cleanup24

  .if.end:
    store 8 arg1 sp 24
    store 8 0 sp 40
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .while.cond

  .while.cond:
    br .while.body

  .while.body:
    r1 = load 8 sp 16
    r1 = load 8 r1 0
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = icmp ugt r1 arg2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .if.then2 .if.else

  .if.then2:
    r1 = load 8 sp 16
    r1 = add r1 8 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r1 = load 8 r1 0
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r1 = icmp eq r1 0 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    br r1 .if.then4 .if.end5

  .if.then4:
    r1 = load 8 sp 16
    store 8 r1 sp 240
    store 8 1 sp 256
    store 8 0 sp 272
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    r1 = load 8 sp 272
    store 8 r1 sp 264
    br .cleanup

  .if.end5:
    r1 = load 8 sp 80
    r1 = load 8 r1 0
    store 8 r1 sp 96
    r1 = load 8 sp 96
    r1 = icmp eq r1 arg2 64
    store 8 r1 sp 104
    r1 = load 8 sp 104
    br r1 .if.then7 .if.end9

  .if.then7:
    r1 = load 8 sp 80
    r1 = call adjust r1
    store 8 r1 sp 112
    r1 = load 8 sp 112
    store 8 r1 sp 120
    r1 = load 8 sp 16
    r1 = add r1 8 64
    store 8 r1 sp 128
    r1 = load 8 sp 120
    r2 = load 8 sp 128
    store 8 r1 r2 0
    r1 = load 8 sp 80
    store 8 r1 sp 136
    r1 = load 8 sp 136
    free r1
    r1 = load 8 sp 16
    store 8 r1 sp 240
    store 8 1 sp 256
    store 8 1 sp 272
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    r1 = load 8 sp 272
    store 8 r1 sp 264
    br .cleanup

  .if.end9:
    r1 = load 8 sp 80
    store 8 r1 sp 240
    store 8 2 sp 256
    r1 = load 8 sp 32
    store 8 r1 sp 272
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    r1 = load 8 sp 272
    store 8 r1 sp 264
    br .cleanup

  .if.else:
    r1 = load 8 sp 48
    r1 = icmp ult r1 arg2 64
    store 8 r1 sp 144
    r1 = load 8 sp 144
    br r1 .if.then11 .if.end21

  .if.then11:
    r1 = load 8 sp 16
    r1 = add r1 16 64
    store 8 r1 sp 152
    r1 = load 8 sp 152
    r1 = load 8 r1 0
    store 8 r1 sp 160
    r1 = load 8 sp 160
    store 8 r1 sp 168
    r1 = load 8 sp 168
    r1 = icmp eq r1 0 64
    store 8 r1 sp 176
    r1 = load 8 sp 176
    br r1 .if.then14 .if.end15

  .if.then14:
    r1 = load 8 sp 16
    store 8 r1 sp 240
    store 8 1 sp 256
    store 8 0 sp 272
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    r1 = load 8 sp 272
    store 8 r1 sp 264
    br .cleanup

  .if.end15:
    r1 = load 8 sp 168
    r1 = load 8 r1 0
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r1 = icmp eq r1 arg2 64
    store 8 r1 sp 192
    r1 = load 8 sp 192
    br r1 .if.then17 .if.end20

  .if.then17:
    r1 = load 8 sp 168
    r1 = call adjust r1
    store 8 r1 sp 200
    r1 = load 8 sp 200
    store 8 r1 sp 208
    r1 = load 8 sp 16
    r1 = add r1 16 64
    store 8 r1 sp 216
    r1 = load 8 sp 208
    r2 = load 8 sp 216
    store 8 r1 r2 0
    r1 = load 8 sp 168
    store 8 r1 sp 224
    r1 = load 8 sp 224
    free r1
    r1 = load 8 sp 16
    store 8 r1 sp 240
    store 8 1 sp 256
    store 8 1 sp 272
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    r1 = load 8 sp 272
    store 8 r1 sp 264
    br .cleanup

  .if.end20:
    r1 = load 8 sp 168
    store 8 r1 sp 240
    store 8 2 sp 256
    r1 = load 8 sp 32
    store 8 r1 sp 272
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    r1 = load 8 sp 272
    store 8 r1 sp 264
    br .cleanup

  .if.end21:
    br .if.end22

  .if.end22:
    r1 = load 8 sp 16
    store 8 r1 sp 240
    store 8 0 sp 256
    r1 = load 8 sp 32
    store 8 r1 sp 272
    r1 = load 8 sp 240
    store 8 r1 sp 232
    r1 = load 8 sp 256
    store 8 r1 sp 248
    r1 = load 8 sp 272
    store 8 r1 sp 264
    br .cleanup

  .cleanup:
    r1 = load 8 sp 264
    store 8 r1 sp 288
    r1 = load 8 sp 288
    store 8 r1 sp 280
    r1 = load 8 sp 232
    store 8 r1 sp 24
    r1 = load 8 sp 264
    store 8 r1 sp 40
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 40
    store 8 r1 sp 32
    r1 = load 8 sp 248
    switch r1 0 .cleanup.cont 2 .while.cond .cleanup24

  .cleanup.cont:
    r1 = load 8 sp 232
    store 8 r1 sp 24
    r1 = load 8 sp 264
    store 8 r1 sp 40
    r1 = load 8 sp 24
    store 8 r1 sp 16
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .while.cond

  .cleanup24:
    r1 = load 8 sp 280
    ret r1
end remove

; Function traverse
start traverse 1:
  .entry:
    ; init sp!
    sp = sub sp 64 64
    r1 = icmp eq arg1 0 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    br r1 .if.then .if.end

  .if.then:
    br .return

  .if.end:
    r1 = load 8 arg1 0
    store 8 r1 sp 8
    r1 = mul arg1 1 64
    r1 = add r1 8 64
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = load 8 r1 0
    store 8 r1 sp 24
    r1 = load 8 sp 24
    store 8 r1 sp 32
    r1 = mul arg1 1 64
    r1 = add r1 16 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r1 = load 8 r1 0
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 56
    r1 = load 8 sp 32
    call traverse r1
    r1 = load 8 sp 8
    call write r1
    r1 = load 8 sp 56
    call traverse r1
    br .return

  .return:
    ret 0
end traverse

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 120 64
    r1 = malloc 24
    store 8 r1 sp 0
    r1 = load 8 sp 0
    store 8 r1 sp 8
    r1 = call read
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r2 = load 8 sp 8
    store 8 r1 r2 0
    r1 = load 8 sp 8
    r1 = add r1 8 64
    store 8 r1 sp 24
    r2 = load 8 sp 24
    store 8 0 r2 0
    r1 = load 8 sp 8
    r1 = add r1 16 64
    store 8 r1 sp 32
    r2 = load 8 sp 32
    store 8 0 r2 0
    r1 = call read
    store 8 r1 sp 40
    store 8 0 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond

  .for.cond:
    r1 = load 8 sp 48
    r2 = load 8 sp 40
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = call read
    store 8 r1 sp 72
    r1 = call read
    store 8 r1 sp 80
    r1 = load 8 sp 72
    r1 = icmp eq r1 0 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    br r1 .if.then .if.else

  .if.then:
    r1 = load 8 sp 8
    r2 = load 8 sp 80
    r1 = call insert r1 r2
    store 8 r1 sp 96
    br .if.end

  .if.else:
    r1 = load 8 sp 8
    r2 = load 8 sp 80
    r1 = call remove r1 r2
    store 8 r1 sp 104
    br .if.end

  .if.end:
    br .for.inc

  .for.inc:
    r1 = load 8 sp 48
    r1 = add r1 1 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond

  .for.end:
    r1 = load 8 sp 8
    call traverse r1
    ret 0
end main
