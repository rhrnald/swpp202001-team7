
; Function gcd
start gcd 2:
  .entry:
    ; init sp!
    sp = sub sp 96 64
    r1 = icmp eq arg1 0 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    br r1 .if.then .if.end

  .if.then:
    store 8 arg2 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 80
    br .return

  .if.end:
    r1 = icmp eq arg2 0 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    br r1 .if.then2 .if.end3

  .if.then2:
    store 8 arg1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 80
    br .return

  .if.end3:
    r1 = icmp ugt arg1 arg2 64
    store 8 r1 sp 16
    r1 = load 8 sp 16
    br r1 .if.then5 .if.else

  .if.then5:
    r1 = urem arg1 arg2 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    store 8 r1 sp 48
    store 8 arg2 sp 64
    r1 = load 8 sp 48
    store 8 r1 sp 40
    r1 = load 8 sp 64
    store 8 r1 sp 56
    br .if.end7

  .if.else:
    r1 = urem arg2 arg1 64
    store 8 r1 sp 32
    store 8 arg1 sp 48
    r1 = load 8 sp 32
    store 8 r1 sp 64
    r1 = load 8 sp 48
    store 8 r1 sp 40
    r1 = load 8 sp 64
    store 8 r1 sp 56
    br .if.end7

  .if.end7:
    r1 = load 8 sp 40
    r2 = load 8 sp 56
    r1 = call gcd r1 r2
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 80
    br .return

  .return:
    r1 = load 8 sp 80
    ret r1
end gcd

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 24 64
    r1 = call read
    store 8 r1 sp 0
    r1 = call read
    store 8 r1 sp 8
    r1 = load 8 sp 0
    r2 = load 8 sp 8
    r1 = call gcd r1 r2
    store 8 r1 sp 16
    r1 = load 8 sp 16
    call write r1
    ret 0
end main
