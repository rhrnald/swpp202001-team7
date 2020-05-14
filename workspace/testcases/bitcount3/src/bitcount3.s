
; Function countSetBits
start countSetBits 1:
  .entry:
    ; init sp!
    sp = sub sp 64 64
    store 8 arg1 sp 8
    store 8 0 sp 24
    r1 = load 8 sp 8
    store 8 r1 sp 0
    r1 = load 8 sp 24
    store 8 r1 sp 16
    br .while.cond

  .while.cond:
    r1 = load 8 sp 0
    r1 = icmp ne r1 0 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    br r1 .while.body .while.end

  .while.body:
    r1 = load 8 sp 0
    r1 = sub r1 1 32
    store 8 r1 sp 40
    r1 = load 8 sp 0
    r2 = load 8 sp 40
    r1 = and r1 r2 32
    store 8 r1 sp 48
    r1 = load 8 sp 16
    r1 = add r1 1 32
    store 8 r1 sp 56
    r1 = load 8 sp 48
    store 8 r1 sp 8
    r1 = load 8 sp 56
    store 8 r1 sp 24
    r1 = load 8 sp 8
    store 8 r1 sp 0
    r1 = load 8 sp 24
    store 8 r1 sp 16
    br .while.cond

  .while.end:
    r1 = load 8 sp 16
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
    store 8 r1 sp 24
    r1 = load 8 sp 24
    call write r1
    ret 0
end main
