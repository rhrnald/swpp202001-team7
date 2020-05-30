
; Function countSetBits
start countSetBits 1:
  .entry:
    ; init sp!
    sp = sub sp 56 64
    r1 = icmp eq arg1 0 32
    store 8 r1 sp 0
    r1 = load 8 sp 0
    br r1 .if.then .if.else

  .if.then:
    store 8 0 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 40
    br .return

  .if.else:
    r1 = and arg1 1 32
    store 8 r1 sp 8
    r1 = ashr arg1 1 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = call countSetBits r1
    store 8 r1 sp 24
    r1 = load 8 sp 8
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 40
    br .return

  .return:
    r1 = load 8 sp 40
    ret r1
end countSetBits

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 32 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = and r1 4294967295 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = call countSetBits r1
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r2 = and r1 2147483648 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    call write r1
    ret 0
end main
