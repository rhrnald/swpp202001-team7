
; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 136 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = add r1 1 64
    store 8 r1 sp 8
    r2 = load 8 sp 8
    r1 = mul 8 r2 64
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = malloc r1
    store 8 r1 sp 24
    r1 = load 8 sp 24
    store 8 r1 sp 32
    store 8 1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 40
    br .for.cond

  .for.cond:
    r1 = load 8 sp 40
    r2 = load 8 sp 0
    r1 = icmp ule r1 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = call read
    store 8 r1 sp 64
    r1 = load 8 sp 32
    r2 = load 8 sp 40
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 72
    r1 = load 8 sp 64
    r2 = load 8 sp 72
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 40
    r1 = add r1 1 64
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 40
    br .for.cond

  .for.end:
    r1 = load 8 sp 0
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 88
    br .for.cond4

  .for.cond4:
    r1 = load 8 sp 88
    r1 = icmp ugt r1 0 64
    store 8 r1 sp 104
    r1 = load 8 sp 104
    br r1 .for.body7 .for.cond.cleanup6

  .for.cond.cleanup6:
    br .for.end10

  .for.body7:
    r1 = load 8 sp 32
    r2 = load 8 sp 88
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    r1 = load 8 r1 0
    store 8 r1 sp 120
    r1 = load 8 sp 120
    call write r1
    br .for.inc9

  .for.inc9:
    r1 = load 8 sp 88
    r1 = add r1 18446744073709551615 64
    store 8 r1 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 88
    br .for.cond4

  .for.end10:
    ret 0
end main
