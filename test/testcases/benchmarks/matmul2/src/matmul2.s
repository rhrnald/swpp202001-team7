
; Function matmul
start matmul 4:
  .entry:
    ; init sp!
    sp = sub sp 232 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.cond:
    r1 = load 8 sp 0
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    br r1 .for.body .for.end22

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
    br r1 .for.body3 .for.end19

  .for.body3:
    store 8 0 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond4

  .for.cond4:
    r1 = load 8 sp 48
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 64
    r1 = load 8 sp 64
    br r1 .for.body6 .for.end

  .for.body6:
    r1 = load 8 sp 0
    r1 = mul r1 arg1 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 88
    r1 = mul arg3 1 64
    r2 = load 8 sp 88
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 96
    r1 = load 8 sp 96
    r1 = load 8 r1 0
    store 8 r1 sp 104
    r1 = load 8 sp 48
    r1 = mul r1 arg1 32
    store 8 r1 sp 112
    r1 = load 8 sp 112
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 120
    r1 = load 8 sp 120
    store 8 r1 sp 128
    r1 = mul arg4 1 64
    r2 = load 8 sp 128
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 136
    r1 = load 8 sp 136
    r1 = load 8 r1 0
    store 8 r1 sp 144
    r1 = load 8 sp 104
    r2 = load 8 sp 144
    r1 = mul r1 r2 64
    store 8 r1 sp 152
    r1 = load 8 sp 0
    r1 = mul r1 arg1 32
    store 8 r1 sp 160
    r1 = load 8 sp 160
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 168
    r1 = load 8 sp 168
    store 8 r1 sp 176
    r1 = mul arg2 1 64
    r2 = load 8 sp 176
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r1 = load 8 r1 0
    store 8 r1 sp 192
    r1 = load 8 sp 192
    r2 = load 8 sp 152
    r1 = add r1 r2 64
    store 8 r1 sp 200
    r1 = load 8 sp 200
    r2 = load 8 sp 184
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 48
    r1 = add r1 1 32
    store 8 r1 sp 208
    r1 = load 8 sp 208
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond4

  .for.end:
    br .for.inc17

  .for.inc17:
    r1 = load 8 sp 24
    r1 = add r1 1 32
    store 8 r1 sp 216
    r1 = load 8 sp 216
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.end19:
    br .for.inc20

  .for.inc20:
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 224
    r1 = load 8 sp 224
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.end22:
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
    sp = sub sp 136 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = and r1 4294967295 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = mul r1 r2 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r1 = mul r1 8 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = malloc r1
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 48
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = mul r1 r2 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r1 = mul r1 8 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = malloc r1
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 88
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = mul r1 r2 32
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r1 = mul r1 8 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    r1 = malloc r1
    store 8 r1 sp 120
    r1 = load 8 sp 120
    store 8 r1 sp 128
    r1 = load 8 sp 8
    r2 = load 8 sp 48
    call read_mat r1 r2
    r1 = load 8 sp 8
    r2 = load 8 sp 88
    call read_mat r1 r2
    r1 = load 8 sp 8
    r2 = load 8 sp 128
    r3 = load 8 sp 48
    r4 = load 8 sp 88
    call matmul r1 r2 r3 r4
    r1 = load 8 sp 8
    r2 = load 8 sp 128
    call print_mat r1 r2
    ret 0
end main
