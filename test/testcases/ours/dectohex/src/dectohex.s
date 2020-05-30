
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
    store 8 0 sp 24
    r1 = load 8 sp 24
    store 8 r1 sp 16
    br .for.cond

  .for.cond:
    r1 = load 8 sp 16
    r2 = load 8 sp 8
    r1 = icmp slt r1 r2 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end12

  .for.body:
    r1 = call read
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r1 = and r1 4294967295 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 64
    store 8 0 sp 80
    r1 = load 8 sp 64
    store 8 r1 sp 56
    r1 = load 8 sp 80
    store 8 r1 sp 72
    br .for.cond4

  .for.cond4:
    r1 = load 8 sp 72
    r1 = icmp slt r1 8 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    br r1 .for.body8 .for.cond.cleanup7

  .for.cond.cleanup7:
    br .for.end

  .for.body8:
    r1 = load 8 sp 56
    r1 = and r1 15 32
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 104
    r1 = load 8 sp 104
    call write r1
    r1 = load 8 sp 56
    r1 = lshr r1 4 32
    store 8 r1 sp 112
    br .for.inc

  .for.inc:
    r1 = load 8 sp 72
    r1 = add r1 1 32
    store 8 r1 sp 120
    r1 = load 8 sp 112
    store 8 r1 sp 64
    r1 = load 8 sp 120
    store 8 r1 sp 80
    r1 = load 8 sp 64
    store 8 r1 sp 56
    r1 = load 8 sp 80
    store 8 r1 sp 72
    br .for.cond4

  .for.end:
    br .for.inc10

  .for.inc10:
    r1 = load 8 sp 16
    r1 = add r1 1 32
    store 8 r1 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 24
    r1 = load 8 sp 24
    store 8 r1 sp 16
    br .for.cond

  .for.end12:
    ret 0
end main
