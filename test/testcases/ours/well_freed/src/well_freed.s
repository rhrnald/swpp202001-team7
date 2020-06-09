
; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 240 64
    r1 = malloc 2048
    store 8 r1 sp 0
    r1 = malloc 2048
    store 8 r1 sp 8
    r1 = malloc 2048
    store 8 r1 sp 16
    r1 = call read
    store 8 r1 sp 24
    r1 = load 8 sp 24
    r1 = and r1 255 64
    store 8 r1 sp 32
    r1 = load 8 sp 32
    r2 = load 8 sp 0
    store 1 r1 r2 0
    r1 = call read
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r1 = and r1 255 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r2 = load 8 sp 8
    store 1 r1 r2 0
    r1 = call read
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r1 = and r1 255 64
    store 8 r1 sp 64
    r1 = load 8 sp 64
    r2 = load 8 sp 16
    store 1 r1 r2 0
    r1 = load 8 sp 0
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = load 1 r1 0
    store 8 r1 sp 80
    r1 = load 8 sp 80
    store 8 r1 sp 88
    r1 = load 8 sp 88
    call write r1
    r1 = load 8 sp 8
    store 8 r1 sp 96
    r1 = load 8 sp 96
    r1 = load 1 r1 0
    store 8 r1 sp 104
    r1 = load 8 sp 104
    store 8 r1 sp 112
    r1 = load 8 sp 112
    call write r1
    r1 = load 8 sp 16
    store 8 r1 sp 120
    r1 = load 8 sp 120
    r1 = load 1 r1 0
    store 8 r1 sp 128
    r1 = load 8 sp 128
    store 8 r1 sp 136
    r1 = load 8 sp 136
    call write r1
    r1 = load 8 sp 0
    free r1
    r1 = load 8 sp 8
    free r1
    r1 = load 8 sp 16
    free r1
    r1 = malloc 2048
    store 8 r1 sp 144
    r1 = malloc 2048
    store 8 r1 sp 152
    r1 = call read
    store 8 r1 sp 160
    r1 = load 8 sp 160
    r1 = and r1 255 64
    store 8 r1 sp 168
    r1 = load 8 sp 168
    r2 = load 8 sp 144
    store 1 r1 r2 0
    r1 = call read
    store 8 r1 sp 176
    r1 = load 8 sp 176
    r1 = and r1 255 64
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r2 = load 8 sp 152
    store 1 r1 r2 0
    r1 = load 8 sp 144
    store 8 r1 sp 192
    r1 = load 8 sp 192
    r1 = load 1 r1 0
    store 8 r1 sp 200
    r1 = load 8 sp 200
    store 8 r1 sp 208
    r1 = load 8 sp 208
    call write r1
    r1 = load 8 sp 152
    store 8 r1 sp 216
    r1 = load 8 sp 216
    r1 = load 1 r1 0
    store 8 r1 sp 224
    r1 = load 8 sp 224
    store 8 r1 sp 232
    r1 = load 8 sp 232
    call write r1
    r1 = load 8 sp 144
    free r1
    r1 = load 8 sp 152
    free r1
    ret 0
end main
