
; Function copy_mask
start copy_mask 5:
  .entry:
    ; init sp!
    sp = sub sp 200 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.cond:
    r1 = load 8 sp 0
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = icmp slt r1 4 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    br r1 .for.body .for.end19

  .for.body:
    store 8 0 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond2

  .for.cond2:
    r1 = load 8 sp 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = icmp slt r1 4 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .for.body6 .for.end

  .for.body6:
    r1 = load 8 sp 0
    store 8 r1 sp 64
    r2 = load 8 sp 64
    r1 = add arg2 r2 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = mul r1 arg1 32
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r1 = add r1 arg3 32
    store 8 r1 sp 88
    r1 = load 8 sp 32
    store 8 r1 sp 96
    r1 = load 8 sp 88
    r2 = load 8 sp 96
    r1 = add r1 r2 32
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 112
    r1 = mul arg4 1 64
    r2 = load 8 sp 112
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 120
    r1 = load 8 sp 120
    r1 = load 8 r1 0
    store 8 r1 sp 128
    r1 = load 8 sp 0
    store 8 r1 sp 136
    r1 = load 8 sp 136
    r1 = mul r1 4 32
    store 8 r1 sp 144
    r1 = load 8 sp 32
    store 8 r1 sp 152
    r1 = load 8 sp 144
    r2 = load 8 sp 152
    r1 = add r1 r2 32
    store 8 r1 sp 160
    r1 = load 8 sp 160
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 168
    r1 = mul arg5 1 64
    r2 = load 8 sp 168
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 176
    r1 = load 8 sp 128
    r2 = load 8 sp 176
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 32
    r1 = add r1 1 8
    store 8 r1 sp 184
    r1 = load 8 sp 184
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond2

  .for.end:
    br .for.inc17

  .for.inc17:
    r1 = load 8 sp 0
    r1 = add r1 1 8
    store 8 r1 sp 192
    r1 = load 8 sp 192
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.end19:
    ret 0
end copy_mask

; Function add_mask
start add_mask 5:
  .entry:
    ; init sp!
    sp = sub sp 216 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.cond:
    r1 = load 8 sp 0
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = icmp slt r1 4 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    br r1 .for.body .for.end20

  .for.body:
    store 8 0 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond2

  .for.cond2:
    r1 = load 8 sp 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = icmp slt r1 4 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .for.body6 .for.end

  .for.body6:
    r1 = load 8 sp 0
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r1 = mul r1 4 32
    store 8 r1 sp 72
    r1 = load 8 sp 32
    store 8 r1 sp 80
    r1 = load 8 sp 72
    r2 = load 8 sp 80
    r1 = add r1 r2 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 96
    r1 = mul arg5 1 64
    r2 = load 8 sp 96
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r1 = load 8 r1 0
    store 8 r1 sp 112
    r1 = load 8 sp 0
    store 8 r1 sp 120
    r2 = load 8 sp 120
    r1 = add arg2 r2 32
    store 8 r1 sp 128
    r1 = load 8 sp 128
    r1 = mul r1 arg1 32
    store 8 r1 sp 136
    r1 = load 8 sp 136
    r1 = add r1 arg3 32
    store 8 r1 sp 144
    r1 = load 8 sp 32
    store 8 r1 sp 152
    r1 = load 8 sp 144
    r2 = load 8 sp 152
    r1 = add r1 r2 32
    store 8 r1 sp 160
    r1 = load 8 sp 160
    store 8 r1 sp 168
    r1 = mul arg4 1 64
    r2 = load 8 sp 168
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 176
    r1 = load 8 sp 176
    r1 = load 8 r1 0
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r2 = load 8 sp 112
    r1 = add r1 r2 64
    store 8 r1 sp 192
    r1 = load 8 sp 192
    r2 = load 8 sp 176
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 32
    r1 = add r1 1 8
    store 8 r1 sp 200
    r1 = load 8 sp 200
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond2

  .for.end:
    br .for.inc18

  .for.inc18:
    r1 = load 8 sp 0
    r1 = add r1 1 8
    store 8 r1 sp 208
    r1 = load 8 sp 208
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.end20:
    ret 0
end add_mask

; Function mask_mul
start mask_mul 3:
  .entry:
    ; init sp!
    sp = sub sp 312 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.cond:
    r1 = load 8 sp 0
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = icmp slt r1 4 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    br r1 .for.body .for.end33

  .for.body:
    store 8 0 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond2

  .for.cond2:
    r1 = load 8 sp 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = icmp slt r1 4 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .for.body6 .for.end30

  .for.body6:
    store 8 0 sp 72
    store 8 0 sp 88
    r1 = load 8 sp 72
    store 8 r1 sp 64
    r1 = load 8 sp 88
    store 8 r1 sp 80
    br .for.cond7

  .for.cond7:
    r1 = load 8 sp 64
    store 8 r1 sp 96
    r1 = load 8 sp 96
    r1 = icmp slt r1 4 32
    store 8 r1 sp 104
    r1 = load 8 sp 104
    br r1 .for.body11 .for.end

  .for.body11:
    r1 = load 8 sp 0
    store 8 r1 sp 112
    r1 = load 8 sp 112
    r1 = mul r1 4 32
    store 8 r1 sp 120
    r1 = load 8 sp 64
    store 8 r1 sp 128
    r1 = load 8 sp 120
    r2 = load 8 sp 128
    r1 = add r1 r2 32
    store 8 r1 sp 136
    r1 = load 8 sp 136
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 144
    r1 = mul arg2 1 64
    r2 = load 8 sp 144
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 152
    r1 = load 8 sp 152
    r1 = load 8 r1 0
    store 8 r1 sp 160
    r1 = load 8 sp 64
    store 8 r1 sp 168
    r1 = load 8 sp 168
    r1 = mul r1 4 32
    store 8 r1 sp 176
    r1 = load 8 sp 32
    store 8 r1 sp 184
    r1 = load 8 sp 176
    r2 = load 8 sp 184
    r1 = add r1 r2 32
    store 8 r1 sp 192
    r1 = load 8 sp 192
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 200
    r1 = mul arg3 1 64
    r2 = load 8 sp 200
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 208
    r1 = load 8 sp 208
    r1 = load 8 r1 0
    store 8 r1 sp 216
    r1 = load 8 sp 160
    r2 = load 8 sp 216
    r1 = mul r1 r2 64
    store 8 r1 sp 224
    r1 = load 8 sp 80
    r2 = load 8 sp 224
    r1 = add r1 r2 64
    store 8 r1 sp 232
    br .for.inc

  .for.inc:
    r1 = load 8 sp 64
    r1 = add r1 1 8
    store 8 r1 sp 240
    r1 = load 8 sp 240
    store 8 r1 sp 72
    r1 = load 8 sp 232
    store 8 r1 sp 88
    r1 = load 8 sp 72
    store 8 r1 sp 64
    r1 = load 8 sp 88
    store 8 r1 sp 80
    br .for.cond7

  .for.end:
    r1 = load 8 sp 0
    store 8 r1 sp 248
    r1 = load 8 sp 248
    r1 = mul r1 4 32
    store 8 r1 sp 256
    r1 = load 8 sp 32
    store 8 r1 sp 264
    r1 = load 8 sp 256
    r2 = load 8 sp 264
    r1 = add r1 r2 32
    store 8 r1 sp 272
    r1 = load 8 sp 272
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 280
    r1 = mul arg1 1 64
    r2 = load 8 sp 280
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 288
    r1 = load 8 sp 80
    r2 = load 8 sp 288
    store 8 r1 r2 0
    br .for.inc28

  .for.inc28:
    r1 = load 8 sp 32
    r1 = add r1 1 8
    store 8 r1 sp 296
    r1 = load 8 sp 296
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond2

  .for.end30:
    br .for.inc31

  .for.inc31:
    r1 = load 8 sp 0
    r1 = add r1 1 8
    store 8 r1 sp 304
    r1 = load 8 sp 304
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.end33:
    ret 0
end mask_mul

; Function matmul
start matmul 4:
  .entry:
    ; init sp!
    sp = sub sp 552 64
    r1 = add sp 168 64
    store 8 r1 sp 0
    r1 = add sp 296 64
    store 8 r1 sp 8
    r1 = add sp 424 64
    store 8 r1 sp 16
    store 8 0 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond

  .for.cond:
    r1 = load 8 sp 24
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .for.body .for.end17

  .for.body:
    store 8 0 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond1

  .for.cond1:
    r1 = load 8 sp 48
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 64
    r1 = load 8 sp 64
    br r1 .for.body3 .for.end14

  .for.body3:
    store 8 0 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 72
    br .for.cond4

  .for.cond4:
    r1 = load 8 sp 72
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    br r1 .for.body6 .for.end

  .for.body6:
    r1 = load 8 sp 8
    store 8 r1 sp 96
    r2 = load 8 sp 24
    r3 = load 8 sp 72
    r5 = load 8 sp 96
    call copy_mask arg1 r2 r3 arg3 r5
    r1 = load 8 sp 16
    store 8 r1 sp 104
    r2 = load 8 sp 72
    r3 = load 8 sp 48
    r5 = load 8 sp 104
    call copy_mask arg1 r2 r3 arg4 r5
    r1 = load 8 sp 0
    store 8 r1 sp 112
    r1 = load 8 sp 8
    store 8 r1 sp 120
    r1 = load 8 sp 16
    store 8 r1 sp 128
    r1 = load 8 sp 112
    r2 = load 8 sp 120
    r3 = load 8 sp 128
    call mask_mul r1 r2 r3
    r1 = load 8 sp 0
    store 8 r1 sp 136
    r2 = load 8 sp 24
    r3 = load 8 sp 48
    r5 = load 8 sp 136
    call add_mask arg1 r2 r3 arg2 r5
    br .for.inc

  .for.inc:
    r1 = load 8 sp 72
    r1 = add r1 4 32
    store 8 r1 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 72
    br .for.cond4

  .for.end:
    br .for.inc12

  .for.inc12:
    r1 = load 8 sp 48
    r1 = add r1 4 32
    store 8 r1 sp 152
    r1 = load 8 sp 152
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond1

  .for.end14:
    br .for.inc15

  .for.inc15:
    r1 = load 8 sp 24
    r1 = add r1 4 32
    store 8 r1 sp 160
    r1 = load 8 sp 160
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond

  .for.end17:
    ret 0
end matmul

; Function read_mat
start read_mat 2:
  .entry:
    ; init sp!
    sp = sub sp 104 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.cond:
    r1 = load 8 sp 0
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    br r1 .for.body .for.end6

  .for.body:
    store 8 0 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.cond1:
    r1 = load 8 sp 24
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .for.body3 .for.end

  .for.body3:
    r1 = call read
    store 8 r1 sp 48
    r1 = load 8 sp 0
    r1 = mul r1 arg1 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 72
    r1 = mul arg2 1 64
    r2 = load 8 sp 72
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 80
    r1 = load 8 sp 48
    r2 = load 8 sp 80
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 24
    r1 = add r1 1 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.end:
    br .for.inc4

  .for.inc4:
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.end6:
    ret 0
end read_mat

; Function print_mat
start print_mat 2:
  .entry:
    ; init sp!
    sp = sub sp 104 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.cond:
    r1 = load 8 sp 0
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    br r1 .for.body .for.end6

  .for.body:
    store 8 0 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.cond1:
    r1 = load 8 sp 24
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .for.body3 .for.end

  .for.body3:
    r1 = load 8 sp 0
    r1 = mul r1 arg1 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 64
    r1 = mul arg2 1 64
    r2 = load 8 sp 64
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = load 8 r1 0
    store 8 r1 sp 80
    r1 = load 8 sp 80
    call write r1
    br .for.inc

  .for.inc:
    r1 = load 8 sp 24
    r1 = add r1 1 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.end:
    br .for.inc4

  .for.inc4:
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.end6:
    ret 0
end print_mat

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 152 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = and r1 4294967295 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = urem r1 4 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = icmp ne r1 0 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    br r1 .if.then .if.end

  .if.then:
    br .cleanup

  .if.end:
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = mul r1 r2 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r1 = mul r1 8 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = malloc r1
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 64
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = mul r1 r2 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r1 = mul r1 8 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = malloc r1
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 104
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = mul r1 r2 32
    store 8 r1 sp 112
    r1 = load 8 sp 112
    store 8 r1 sp 120
    r1 = load 8 sp 120
    r1 = mul r1 8 64
    store 8 r1 sp 128
    r1 = load 8 sp 128
    r1 = malloc r1
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 144
    r1 = load 8 sp 8
    r2 = load 8 sp 64
    call read_mat r1 r2
    r1 = load 8 sp 8
    r2 = load 8 sp 104
    call read_mat r1 r2
    r1 = load 8 sp 8
    r2 = load 8 sp 144
    r3 = load 8 sp 64
    r4 = load 8 sp 104
    call matmul r1 r2 r3 r4
    r1 = load 8 sp 8
    r2 = load 8 sp 144
    call print_mat r1 r2
    br .cleanup

  .cleanup:
    ret 0
end main
