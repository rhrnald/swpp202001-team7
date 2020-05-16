
; Function sum_of
start sum_of 4:
  .entry:
    ; init sp!
    sp = sub sp 64 64
    r2 = and arg1 128 64
    r2 = sub 0 r2 64
    r1 = or r2 arg1 64
    store 8 r1 sp 0
    r2 = and arg2 128 64
    r2 = sub 0 r2 64
    r1 = or r2 arg2 64
    store 8 r1 sp 8
    r1 = load 8 sp 0
    r2 = load 8 sp 8
    r1 = add r1 r2 32
    store 8 r1 sp 16
    r2 = and arg3 128 64
    r2 = sub 0 r2 64
    r1 = or r2 arg3 64
    store 8 r1 sp 24
    r1 = load 8 sp 16
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 32
    r2 = and arg4 128 64
    r2 = sub 0 r2 64
    r1 = or r2 arg4 64
    store 8 r1 sp 40
    r1 = load 8 sp 32
    r2 = load 8 sp 40
    r1 = add r1 r2 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = and r1 255 64
    store 8 r1 sp 56
    r1 = load 8 sp 56
    ret r1
end sum_of

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 88 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = and r1 255 64
    store 8 r1 sp 8
    r1 = call read
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = and r1 255 64
    store 8 r1 sp 24
    r1 = call read
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r1 = and r1 255 64
    store 8 r1 sp 40
    r1 = call read
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = and r1 255 64
    store 8 r1 sp 56
    r1 = load 8 sp 8
    r2 = load 8 sp 24
    r3 = load 8 sp 40
    r4 = load 8 sp 56
    r1 = call sum_of r1 r2 r3 r4
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r2 = and r1 128 64
    r2 = sub 0 r2 64
    r1 = or r2 r1 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 80
    r1 = load 8 sp 80
    call write r1
    ret 0
end main
