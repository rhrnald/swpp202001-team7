
; Function get_inputs
start get_inputs 1:
  .entry:
    ; init sp!
    sp = sub sp 96 64
    r1 = icmp eq arg1 0 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    br r1 .if.then .if.end

  .if.then:
    store 8 0 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 80
    br .return

  .if.end:
    r1 = mul arg1 8 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = malloc r1
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 24
    store 8 0 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond

  .for.cond:
    r1 = load 8 sp 32
    r1 = icmp ult r1 arg1 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = call read
    store 8 r1 sp 56
    r1 = load 8 sp 24
    r2 = load 8 sp 32
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 64
    r1 = load 8 sp 56
    r2 = load 8 sp 64
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 32
    r1 = add r1 1 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 40
    r1 = load 8 sp 40
    store 8 r1 sp 32
    br .for.cond

  .for.end:
    r1 = load 8 sp 24
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 80
    br .return

  .return:
    r1 = load 8 sp 80
    ret r1
end get_inputs

; Function sort
start sort 2:
  .entry:
    ; init sp!
    sp = sub sp 152 64
    r1 = icmp eq arg1 0 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    br r1 .if.then .if.end

  .if.then:
    br .for.end15

  .if.end:
    store 8 0 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .for.cond

  .for.cond:
    r1 = load 8 sp 8
    r1 = icmp ult r1 arg1 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end15

  .for.body:
    r1 = sub arg1 1 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 40
    br .for.cond2

  .for.cond2:
    r1 = load 8 sp 40
    r2 = load 8 sp 8
    r1 = icmp ugt r1 r2 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    br r1 .for.body5 .for.cond.cleanup4

  .for.cond.cleanup4:
    br .for.end

  .for.body5:
    r1 = mul arg2 1 64
    r2 = load 8 sp 40
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r1 = load 8 r1 0
    store 8 r1 sp 72
    r1 = load 8 sp 40
    r1 = sub r1 1 64
    store 8 r1 sp 80
    r1 = mul arg2 1 64
    r2 = load 8 sp 80
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = load 8 r1 0
    store 8 r1 sp 96
    r1 = load 8 sp 72
    r2 = load 8 sp 96
    r1 = icmp ult r1 r2 64
    store 8 r1 sp 104
    r1 = load 8 sp 104
    br r1 .if.then9 .if.end13

  .if.then9:
    r1 = mul arg2 1 64
    r2 = load 8 sp 40
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 112
    r1 = load 8 sp 96
    r2 = load 8 sp 112
    store 8 r1 r2 0
    r1 = load 8 sp 40
    r1 = sub r1 1 64
    store 8 r1 sp 120
    r1 = mul arg2 1 64
    r2 = load 8 sp 120
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 128
    r1 = load 8 sp 72
    r2 = load 8 sp 128
    store 8 r1 r2 0
    br .if.end13

  .if.end13:
    br .for.inc

  .for.inc:
    r1 = load 8 sp 40
    r1 = add r1 18446744073709551615 64
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 40
    br .for.cond2

  .for.end:
    br .for.inc14

  .for.inc14:
    r1 = load 8 sp 8
    r1 = add r1 1 64
    store 8 r1 sp 144
    r1 = load 8 sp 144
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .for.cond

  .for.end15:
    ret 0
end sort

; Function put_inputs
start put_inputs 2:
  .entry:
    ; init sp!
    sp = sub sp 56 64
    r1 = icmp eq arg1 0 64
    store 8 r1 sp 0
    r1 = load 8 sp 0
    br r1 .if.then .if.end

  .if.then:
    br .for.end

  .if.end:
    store 8 0 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .for.cond

  .for.cond:
    r1 = load 8 sp 8
    r1 = icmp ult r1 arg1 64
    store 8 r1 sp 24
    r1 = load 8 sp 24
    br r1 .for.body .for.cond.cleanup

  .for.cond.cleanup:
    br .for.end

  .for.body:
    r1 = mul arg2 1 64
    r2 = load 8 sp 8
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = load 8 r1 0
    store 8 r1 sp 40
    r1 = load 8 sp 40
    call write r1
    br .for.inc

  .for.inc:
    r1 = load 8 sp 8
    r1 = add r1 1 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    store 8 r1 sp 16
    r1 = load 8 sp 16
    store 8 r1 sp 8
    br .for.cond

  .for.end:
    ret 0
end put_inputs

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 24 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = icmp eq r1 0 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    br r1 .if.then .if.end

  .if.then:
    br .cleanup

  .if.end:
    r1 = load 8 sp 0
    r1 = call get_inputs r1
    store 8 r1 sp 16
    r1 = load 8 sp 0
    r2 = load 8 sp 16
    call sort r1 r2
    r1 = load 8 sp 0
    r2 = load 8 sp 16
    call put_inputs r1 r2
    br .cleanup

  .cleanup:
    ret 0
end main
