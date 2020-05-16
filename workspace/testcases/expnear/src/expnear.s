
; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 96 64
    r1 = call read
    store 8 r1 sp 0
    store 8 1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .while.cond

  .while.cond:
    r1 = load 8 sp 8
    r2 = load 8 sp 0
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    store 8 r1 sp 32
    r2 = load 8 sp 8
    r1 = sub 0 r2 64
    store 8 r1 sp 40
    r2 = load 8 sp 0
    r1 = sub 0 r2 64
    store 8 r1 sp 48
    r1 = load 8 sp 40
    r2 = load 8 sp 48
    r1 = icmp ugt r1 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 64
    r1 = load 8 sp 32
    r2 = load 8 sp 64
    r1 = and r1 r2 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = icmp ne r1 0 32
    store 8 r1 sp 80
    r1 = load 8 sp 80
    br r1 .while.body .while.end

  .while.body:
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = add r1 r2 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .while.cond

  .while.end:
    r1 = load 8 sp 8
    call write r1
    ret 0
end main
