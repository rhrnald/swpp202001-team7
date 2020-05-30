
; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 80 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    store 8 r1 sp 16
    store 8 18446744073709551615 sp 32
    r1 = load 8 sp 16
    store 8 r1 sp 8
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .while.cond

  .while.cond:
    r2 = load 8 sp 8
    r1 = sub 0 r2 64
    store 8 r1 sp 40
    r1 = load 8 sp 8
    r2 = load 8 sp 40
    r1 = icmp ne r1 r2 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    br r1 .while.body .while.end

  .while.body:
    r1 = load 8 sp 8
    r2 = load 8 sp 24
    r1 = and r1 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r2 = load 8 sp 56
    r1 = add r1 r2 64
    store 8 r1 sp 64
    r1 = load 8 sp 24
    r1 = lshr r1 1 64
    store 8 r1 sp 72
    r1 = load 8 sp 64
    store 8 r1 sp 16
    r1 = load 8 sp 72
    store 8 r1 sp 32
    r1 = load 8 sp 16
    store 8 r1 sp 8
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .while.cond

  .while.end:
    r1 = load 8 sp 24
    call write r1
    ret 0
end main
