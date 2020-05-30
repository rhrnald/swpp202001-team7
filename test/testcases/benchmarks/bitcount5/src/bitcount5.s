
; Function countSetBitsRec
start countSetBitsRec 1:
  .entry:
    ; init sp!
    sp = sub sp 96 64
    r1 = icmp eq 0 arg1 32
    store 8 r1 sp 0
    r1 = load 8 sp 0
    br r1 .if.then .if.end

  .if.then:
    store 8 20480 sp 8
    r1 = load 8 sp 8
    r1 = load 4 r1 0
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 80
    br .cleanup

  .if.end:
    r1 = and arg1 15 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 32
    r2 = load 8 sp 32
    r2 = mul r2 4 64
    r1 = add 20480 r2 64
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r1 = load 4 r1 0
    store 8 r1 sp 48
    r1 = lshr arg1 4 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r1 = call countSetBitsRec r1
    store 8 r1 sp 64
    r1 = load 8 sp 48
    r2 = load 8 sp 64
    r1 = add r1 r2 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 80
    br .cleanup

  .cleanup:
    r1 = load 8 sp 80
    ret r1
end countSetBitsRec

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 160 64
    r1 = malloc 64
    store 8 20480 sp 0
    r2 = load 8 sp 0
    store 4 0 r2 0
    store 8 20484 sp 8
    r2 = load 8 sp 8
    store 4 1 r2 0
    store 8 20488 sp 16
    r2 = load 8 sp 16
    store 4 1 r2 0
    store 8 20492 sp 24
    r2 = load 8 sp 24
    store 4 2 r2 0
    store 8 20496 sp 32
    r2 = load 8 sp 32
    store 4 1 r2 0
    store 8 20500 sp 40
    r2 = load 8 sp 40
    store 4 2 r2 0
    store 8 20504 sp 48
    r2 = load 8 sp 48
    store 4 2 r2 0
    store 8 20508 sp 56
    r2 = load 8 sp 56
    store 4 3 r2 0
    store 8 20512 sp 64
    r2 = load 8 sp 64
    store 4 1 r2 0
    store 8 20516 sp 72
    r2 = load 8 sp 72
    store 4 2 r2 0
    store 8 20520 sp 80
    r2 = load 8 sp 80
    store 4 2 r2 0
    store 8 20524 sp 88
    r2 = load 8 sp 88
    store 4 3 r2 0
    store 8 20528 sp 96
    r2 = load 8 sp 96
    store 4 2 r2 0
    store 8 20532 sp 104
    r2 = load 8 sp 104
    store 4 3 r2 0
    store 8 20536 sp 112
    r2 = load 8 sp 112
    store 4 3 r2 0
    store 8 20540 sp 120
    r2 = load 8 sp 120
    store 4 4 r2 0
    r1 = call read
    store 8 r1 sp 128
    r1 = load 8 sp 128
    r1 = and r1 4294967295 64
    store 8 r1 sp 136
    r1 = load 8 sp 136
    r1 = call countSetBitsRec r1
    store 8 r1 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 152
    r1 = load 8 sp 152
    call write r1
    ret 0
end main
