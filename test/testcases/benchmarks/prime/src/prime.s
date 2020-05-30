
; Function check_with_primes
start check_with_primes 1:
  .entry:
    ; init sp!
    sp = sub sp 176 64
    r1 = load 8 20480 0
    store 8 r1 sp 0
    r1 = load 8 sp 0
    store 8 r1 sp 16
    store 8 0 sp 32
    r1 = load 8 sp 16
    store 8 r1 sp 8
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .while.cond

  .while.cond:
    r1 = load 8 sp 8
    r1 = icmp ne r1 0 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .while.body .while.end

  .while.body:
    r1 = load 8 sp 8
    r1 = load 8 r1 0
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r2 = load 8 sp 48
    r1 = mul r1 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r1 = icmp ugt r1 arg1 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    br r1 .if.then .if.end

  .if.then:
    r1 = load 8 sp 8
    store 8 r1 sp 120
    r1 = load 8 sp 24
    store 8 r1 sp 136
    store 8 3 sp 152
    r1 = load 8 sp 120
    store 8 r1 sp 112
    r1 = load 8 sp 136
    store 8 r1 sp 128
    r1 = load 8 sp 152
    store 8 r1 sp 144
    br .cleanup

  .if.end:
    r2 = load 8 sp 48
    r1 = urem arg1 r2 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = icmp eq r1 0 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    br r1 .if.then3 .if.end4

  .if.then3:
    r1 = load 8 sp 8
    store 8 r1 sp 120
    store 8 0 sp 136
    store 8 1 sp 152
    r1 = load 8 sp 120
    store 8 r1 sp 112
    r1 = load 8 sp 136
    store 8 r1 sp 128
    r1 = load 8 sp 152
    store 8 r1 sp 144
    br .cleanup

  .if.end4:
    r1 = load 8 sp 8
    r1 = add r1 8 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = load 8 r1 0
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 120
    r1 = load 8 sp 24
    store 8 r1 sp 136
    store 8 0 sp 152
    r1 = load 8 sp 120
    store 8 r1 sp 112
    r1 = load 8 sp 136
    store 8 r1 sp 128
    r1 = load 8 sp 152
    store 8 r1 sp 144
    br .cleanup

  .cleanup:
    r1 = load 8 sp 128
    store 8 r1 sp 168
    r1 = load 8 sp 168
    store 8 r1 sp 160
    r1 = load 8 sp 144
    switch r1 0 .cleanup.cont 3 .while.end .cleanup5

  .cleanup.cont:
    r1 = load 8 sp 112
    store 8 r1 sp 16
    r1 = load 8 sp 128
    store 8 r1 sp 32
    r1 = load 8 sp 16
    store 8 r1 sp 8
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .while.cond

  .while.end:
    store 8 1 sp 168
    r1 = load 8 sp 168
    store 8 r1 sp 160
    br .cleanup5

  .cleanup5:
    r1 = load 8 sp 160
    ret r1
end check_with_primes

; Function add_primes
start add_primes 1:
  .entry:
    ; init sp!
    sp = sub sp 232 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .while.cond

  .while.cond:
    r1 = load 8 20488 0
    store 8 r1 sp 16
    r1 = load 8 20488 0
    store 8 r1 sp 24
    r1 = load 8 sp 16
    r2 = load 8 sp 24
    r1 = mul r1 r2 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = icmp ult r1 arg1 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .while.body .while.end

  .while.body:
    r1 = load 8 20488 0
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = add r1 1 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 20488 0
    r1 = load 8 20488 0
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r1 = call check_with_primes r1
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = icmp ne r1 0 64
    store 8 r1 sp 80
    r1 = load 8 sp 0
    store 8 r1 sp 208
    r1 = load 8 sp 208
    store 8 r1 sp 200
    r1 = load 8 sp 80
    br r1 .if.then .if.end5

  .if.then:
    r1 = malloc 16
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 96
    r1 = load 8 20488 0
    store 8 r1 sp 104
    r1 = load 8 sp 104
    r2 = load 8 sp 96
    store 8 r1 r2 0
    r1 = load 8 sp 96
    r1 = add r1 8 64
    store 8 r1 sp 112
    r2 = load 8 sp 112
    store 8 0 r2 0
    r1 = load 8 sp 96
    store 8 r1 sp 120
    r1 = load 8 20496 0
    store 8 r1 sp 128
    r1 = load 8 sp 128
    r1 = add r1 8 64
    store 8 r1 sp 136
    r1 = load 8 sp 120
    r2 = load 8 sp 136
    store 8 r1 r2 0
    r1 = load 8 sp 96
    store 8 r1 20496 0
    r1 = load 8 20488 0
    store 8 r1 sp 144
    r2 = load 8 sp 144
    r1 = urem arg1 r2 64
    store 8 r1 sp 152
    r1 = load 8 sp 152
    r1 = icmp eq r1 0 64
    store 8 r1 sp 160
    r1 = load 8 sp 160
    br r1 .if.then4 .if.end

  .if.then4:
    store 8 0 sp 176
    store 8 1 sp 192
    r1 = load 8 sp 176
    store 8 r1 sp 168
    r1 = load 8 sp 192
    store 8 r1 sp 184
    br .cleanup

  .if.end:
    r1 = load 8 sp 0
    store 8 r1 sp 176
    store 8 0 sp 192
    r1 = load 8 sp 176
    store 8 r1 sp 168
    r1 = load 8 sp 192
    store 8 r1 sp 184
    br .cleanup

  .cleanup:
    r1 = load 8 sp 168
    store 8 r1 sp 224
    r1 = load 8 sp 224
    store 8 r1 sp 216
    r1 = load 8 sp 184
    switch r1 0 .cleanup.cont 1 .return .unreachable

  .cleanup.cont:
    r1 = load 8 sp 168
    store 8 r1 sp 208
    r1 = load 8 sp 208
    store 8 r1 sp 200
    br .if.end5

  .if.end5:
    r1 = load 8 sp 200
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .while.cond

  .while.end:
    store 8 1 sp 224
    r1 = load 8 sp 224
    store 8 r1 sp 216
    br .return

  .return:
    r1 = load 8 sp 216
    ret r1

  .unreachable:
    ret 0
end add_primes

; Function is_prime
start is_prime 1:
  .entry:
    ; init sp!
    sp = sub sp 40 64
    r1 = call check_with_primes arg1
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = icmp eq r1 0 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    br r1 .if.then .if.end

  .if.then:
    store 8 0 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .return

  .if.end:
    r1 = call add_primes arg1
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .return

  .return:
    r1 = load 8 sp 24
    ret r1
end is_prime

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 88 64
    r1 = malloc 8
    r1 = malloc 8
    r1 = malloc 8
    r1 = malloc 16
    store 8 r1 sp 0
    r1 = load 8 sp 0
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 20480 0
    r1 = load 8 20480 0
    store 8 r1 sp 16
    r2 = load 8 sp 16
    store 8 2 r2 0
    r1 = load 8 20480 0
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r1 = add r1 8 64
    store 8 r1 sp 32
    r2 = load 8 sp 32
    store 8 0 r2 0
    r1 = load 8 20480 0
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 20496 0
    store 8 2 20488 0
    br .while.body

  .while.body:
    r1 = call read
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = icmp eq r1 0 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .if.then .if.end

  .if.then:
    store 8 3 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 72
    br .cleanup

  .if.end:
    r1 = load 8 sp 48
    r1 = call is_prime r1
    store 8 r1 sp 64
    r1 = load 8 sp 64
    call write r1
    store 8 0 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 72
    br .cleanup

  .cleanup:
    r1 = load 8 sp 72
    switch r1 0 .cleanup.cont 3 .while.end .unreachable

  .cleanup.cont:
    br .while.body

  .while.end:
    ret 0

  .unreachable:
    ret 0
end main
