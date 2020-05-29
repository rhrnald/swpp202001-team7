
; Function matmul
start matmul 4:
  .entry:
    ; init sp!
    sp = sub sp 3808 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.cond:
    r1 = load 8 sp 0
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    br r1 .for.body .for.end425

  .for.body:
    store 8 0 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.cond1:
    r1 = load 8 sp 24
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .for.body3 .for.end422

  .for.body3:
    store 8 0 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond4

  .for.cond4:
    r1 = load 8 sp 48
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 64
    r1 = load 8 sp 64
    br r1 .for.body6 .for.end

  .for.body6:
    r1 = load 8 sp 0
    r1 = add r1 0 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = mul r1 arg1 32
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = add r1 0 32
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 104
    r1 = mul arg3 1 64
    r2 = load 8 sp 104
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 112
    r1 = load 8 sp 112
    r1 = load 8 r1 0
    store 8 r1 sp 120
    r1 = load 8 sp 0
    r1 = add r1 0 32
    store 8 r1 sp 128
    r1 = load 8 sp 128
    r1 = mul r1 arg1 32
    store 8 r1 sp 136
    r1 = load 8 sp 136
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 144
    r1 = load 8 sp 144
    r1 = add r1 1 32
    store 8 r1 sp 152
    r1 = load 8 sp 152
    store 8 r1 sp 160
    r1 = mul arg3 1 64
    r2 = load 8 sp 160
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 168
    r1 = load 8 sp 168
    r1 = load 8 r1 0
    store 8 r1 sp 176
    r1 = load 8 sp 0
    r1 = add r1 0 32
    store 8 r1 sp 184
    r1 = load 8 sp 184
    r1 = mul r1 arg1 32
    store 8 r1 sp 192
    r1 = load 8 sp 192
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 200
    r1 = load 8 sp 200
    r1 = add r1 2 32
    store 8 r1 sp 208
    r1 = load 8 sp 208
    store 8 r1 sp 216
    r1 = mul arg3 1 64
    r2 = load 8 sp 216
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 224
    r1 = load 8 sp 224
    r1 = load 8 r1 0
    store 8 r1 sp 232
    r1 = load 8 sp 0
    r1 = add r1 0 32
    store 8 r1 sp 240
    r1 = load 8 sp 240
    r1 = mul r1 arg1 32
    store 8 r1 sp 248
    r1 = load 8 sp 248
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 256
    r1 = load 8 sp 256
    r1 = add r1 3 32
    store 8 r1 sp 264
    r1 = load 8 sp 264
    store 8 r1 sp 272
    r1 = mul arg3 1 64
    r2 = load 8 sp 272
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 280
    r1 = load 8 sp 280
    r1 = load 8 r1 0
    store 8 r1 sp 288
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 296
    r1 = load 8 sp 296
    r1 = mul r1 arg1 32
    store 8 r1 sp 304
    r1 = load 8 sp 304
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 312
    r1 = load 8 sp 312
    r1 = add r1 0 32
    store 8 r1 sp 320
    r1 = load 8 sp 320
    store 8 r1 sp 328
    r1 = mul arg3 1 64
    r2 = load 8 sp 328
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 336
    r1 = load 8 sp 336
    r1 = load 8 r1 0
    store 8 r1 sp 344
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 352
    r1 = load 8 sp 352
    r1 = mul r1 arg1 32
    store 8 r1 sp 360
    r1 = load 8 sp 360
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 368
    r1 = load 8 sp 368
    r1 = add r1 1 32
    store 8 r1 sp 376
    r1 = load 8 sp 376
    store 8 r1 sp 384
    r1 = mul arg3 1 64
    r2 = load 8 sp 384
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 392
    r1 = load 8 sp 392
    r1 = load 8 r1 0
    store 8 r1 sp 400
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 408
    r1 = load 8 sp 408
    r1 = mul r1 arg1 32
    store 8 r1 sp 416
    r1 = load 8 sp 416
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 424
    r1 = load 8 sp 424
    r1 = add r1 2 32
    store 8 r1 sp 432
    r1 = load 8 sp 432
    store 8 r1 sp 440
    r1 = mul arg3 1 64
    r2 = load 8 sp 440
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 448
    r1 = load 8 sp 448
    r1 = load 8 r1 0
    store 8 r1 sp 456
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 464
    r1 = load 8 sp 464
    r1 = mul r1 arg1 32
    store 8 r1 sp 472
    r1 = load 8 sp 472
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 480
    r1 = load 8 sp 480
    r1 = add r1 3 32
    store 8 r1 sp 488
    r1 = load 8 sp 488
    store 8 r1 sp 496
    r1 = mul arg3 1 64
    r2 = load 8 sp 496
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 504
    r1 = load 8 sp 504
    r1 = load 8 r1 0
    store 8 r1 sp 512
    r1 = load 8 sp 0
    r1 = add r1 2 32
    store 8 r1 sp 520
    r1 = load 8 sp 520
    r1 = mul r1 arg1 32
    store 8 r1 sp 528
    r1 = load 8 sp 528
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 536
    r1 = load 8 sp 536
    r1 = add r1 0 32
    store 8 r1 sp 544
    r1 = load 8 sp 544
    store 8 r1 sp 552
    r1 = mul arg3 1 64
    r2 = load 8 sp 552
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 560
    r1 = load 8 sp 560
    r1 = load 8 r1 0
    store 8 r1 sp 568
    r1 = load 8 sp 0
    r1 = add r1 2 32
    store 8 r1 sp 576
    r1 = load 8 sp 576
    r1 = mul r1 arg1 32
    store 8 r1 sp 584
    r1 = load 8 sp 584
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 592
    r1 = load 8 sp 592
    r1 = add r1 1 32
    store 8 r1 sp 600
    r1 = load 8 sp 600
    store 8 r1 sp 608
    r1 = mul arg3 1 64
    r2 = load 8 sp 608
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 616
    r1 = load 8 sp 616
    r1 = load 8 r1 0
    store 8 r1 sp 624
    r1 = load 8 sp 0
    r1 = add r1 2 32
    store 8 r1 sp 632
    r1 = load 8 sp 632
    r1 = mul r1 arg1 32
    store 8 r1 sp 640
    r1 = load 8 sp 640
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 648
    r1 = load 8 sp 648
    r1 = add r1 2 32
    store 8 r1 sp 656
    r1 = load 8 sp 656
    store 8 r1 sp 664
    r1 = mul arg3 1 64
    r2 = load 8 sp 664
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 672
    r1 = load 8 sp 672
    r1 = load 8 r1 0
    store 8 r1 sp 680
    r1 = load 8 sp 0
    r1 = add r1 2 32
    store 8 r1 sp 688
    r1 = load 8 sp 688
    r1 = mul r1 arg1 32
    store 8 r1 sp 696
    r1 = load 8 sp 696
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 704
    r1 = load 8 sp 704
    r1 = add r1 3 32
    store 8 r1 sp 712
    r1 = load 8 sp 712
    store 8 r1 sp 720
    r1 = mul arg3 1 64
    r2 = load 8 sp 720
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 728
    r1 = load 8 sp 728
    r1 = load 8 r1 0
    store 8 r1 sp 736
    r1 = load 8 sp 0
    r1 = add r1 3 32
    store 8 r1 sp 744
    r1 = load 8 sp 744
    r1 = mul r1 arg1 32
    store 8 r1 sp 752
    r1 = load 8 sp 752
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 760
    r1 = load 8 sp 760
    r1 = add r1 0 32
    store 8 r1 sp 768
    r1 = load 8 sp 768
    store 8 r1 sp 776
    r1 = mul arg3 1 64
    r2 = load 8 sp 776
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 784
    r1 = load 8 sp 784
    r1 = load 8 r1 0
    store 8 r1 sp 792
    r1 = load 8 sp 0
    r1 = add r1 3 32
    store 8 r1 sp 800
    r1 = load 8 sp 800
    r1 = mul r1 arg1 32
    store 8 r1 sp 808
    r1 = load 8 sp 808
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 816
    r1 = load 8 sp 816
    r1 = add r1 1 32
    store 8 r1 sp 824
    r1 = load 8 sp 824
    store 8 r1 sp 832
    r1 = mul arg3 1 64
    r2 = load 8 sp 832
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 840
    r1 = load 8 sp 840
    r1 = load 8 r1 0
    store 8 r1 sp 848
    r1 = load 8 sp 0
    r1 = add r1 3 32
    store 8 r1 sp 856
    r1 = load 8 sp 856
    r1 = mul r1 arg1 32
    store 8 r1 sp 864
    r1 = load 8 sp 864
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 872
    r1 = load 8 sp 872
    r1 = add r1 2 32
    store 8 r1 sp 880
    r1 = load 8 sp 880
    store 8 r1 sp 888
    r1 = mul arg3 1 64
    r2 = load 8 sp 888
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 896
    r1 = load 8 sp 896
    r1 = load 8 r1 0
    store 8 r1 sp 904
    r1 = load 8 sp 0
    r1 = add r1 3 32
    store 8 r1 sp 912
    r1 = load 8 sp 912
    r1 = mul r1 arg1 32
    store 8 r1 sp 920
    r1 = load 8 sp 920
    r2 = load 8 sp 48
    r1 = add r1 r2 32
    store 8 r1 sp 928
    r1 = load 8 sp 928
    r1 = add r1 3 32
    store 8 r1 sp 936
    r1 = load 8 sp 936
    store 8 r1 sp 944
    r1 = mul arg3 1 64
    r2 = load 8 sp 944
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 952
    r1 = load 8 sp 952
    r1 = load 8 r1 0
    store 8 r1 sp 960
    r1 = load 8 sp 48
    r1 = add r1 0 32
    store 8 r1 sp 968
    r1 = load 8 sp 968
    r1 = mul r1 arg1 32
    store 8 r1 sp 976
    r1 = load 8 sp 976
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 984
    r1 = load 8 sp 984
    r1 = add r1 0 32
    store 8 r1 sp 992
    r1 = load 8 sp 992
    store 8 r1 sp 1000
    r1 = mul arg4 1 64
    r2 = load 8 sp 1000
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1008
    r1 = load 8 sp 1008
    r1 = load 8 r1 0
    store 8 r1 sp 1016
    r1 = load 8 sp 48
    r1 = add r1 0 32
    store 8 r1 sp 1024
    r1 = load 8 sp 1024
    r1 = mul r1 arg1 32
    store 8 r1 sp 1032
    r1 = load 8 sp 1032
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1040
    r1 = load 8 sp 1040
    r1 = add r1 1 32
    store 8 r1 sp 1048
    r1 = load 8 sp 1048
    store 8 r1 sp 1056
    r1 = mul arg4 1 64
    r2 = load 8 sp 1056
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1064
    r1 = load 8 sp 1064
    r1 = load 8 r1 0
    store 8 r1 sp 1072
    r1 = load 8 sp 48
    r1 = add r1 0 32
    store 8 r1 sp 1080
    r1 = load 8 sp 1080
    r1 = mul r1 arg1 32
    store 8 r1 sp 1088
    r1 = load 8 sp 1088
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1096
    r1 = load 8 sp 1096
    r1 = add r1 2 32
    store 8 r1 sp 1104
    r1 = load 8 sp 1104
    store 8 r1 sp 1112
    r1 = mul arg4 1 64
    r2 = load 8 sp 1112
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1120
    r1 = load 8 sp 1120
    r1 = load 8 r1 0
    store 8 r1 sp 1128
    r1 = load 8 sp 48
    r1 = add r1 0 32
    store 8 r1 sp 1136
    r1 = load 8 sp 1136
    r1 = mul r1 arg1 32
    store 8 r1 sp 1144
    r1 = load 8 sp 1144
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1152
    r1 = load 8 sp 1152
    r1 = add r1 3 32
    store 8 r1 sp 1160
    r1 = load 8 sp 1160
    store 8 r1 sp 1168
    r1 = mul arg4 1 64
    r2 = load 8 sp 1168
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1176
    r1 = load 8 sp 1176
    r1 = load 8 r1 0
    store 8 r1 sp 1184
    r1 = load 8 sp 48
    r1 = add r1 1 32
    store 8 r1 sp 1192
    r1 = load 8 sp 1192
    r1 = mul r1 arg1 32
    store 8 r1 sp 1200
    r1 = load 8 sp 1200
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1208
    r1 = load 8 sp 1208
    r1 = add r1 0 32
    store 8 r1 sp 1216
    r1 = load 8 sp 1216
    store 8 r1 sp 1224
    r1 = mul arg4 1 64
    r2 = load 8 sp 1224
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1232
    r1 = load 8 sp 1232
    r1 = load 8 r1 0
    store 8 r1 sp 1240
    r1 = load 8 sp 48
    r1 = add r1 1 32
    store 8 r1 sp 1248
    r1 = load 8 sp 1248
    r1 = mul r1 arg1 32
    store 8 r1 sp 1256
    r1 = load 8 sp 1256
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1264
    r1 = load 8 sp 1264
    r1 = add r1 1 32
    store 8 r1 sp 1272
    r1 = load 8 sp 1272
    store 8 r1 sp 1280
    r1 = mul arg4 1 64
    r2 = load 8 sp 1280
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1288
    r1 = load 8 sp 1288
    r1 = load 8 r1 0
    store 8 r1 sp 1296
    r1 = load 8 sp 48
    r1 = add r1 1 32
    store 8 r1 sp 1304
    r1 = load 8 sp 1304
    r1 = mul r1 arg1 32
    store 8 r1 sp 1312
    r1 = load 8 sp 1312
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1320
    r1 = load 8 sp 1320
    r1 = add r1 2 32
    store 8 r1 sp 1328
    r1 = load 8 sp 1328
    store 8 r1 sp 1336
    r1 = mul arg4 1 64
    r2 = load 8 sp 1336
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1344
    r1 = load 8 sp 1344
    r1 = load 8 r1 0
    store 8 r1 sp 1352
    r1 = load 8 sp 48
    r1 = add r1 1 32
    store 8 r1 sp 1360
    r1 = load 8 sp 1360
    r1 = mul r1 arg1 32
    store 8 r1 sp 1368
    r1 = load 8 sp 1368
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1376
    r1 = load 8 sp 1376
    r1 = add r1 3 32
    store 8 r1 sp 1384
    r1 = load 8 sp 1384
    store 8 r1 sp 1392
    r1 = mul arg4 1 64
    r2 = load 8 sp 1392
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1400
    r1 = load 8 sp 1400
    r1 = load 8 r1 0
    store 8 r1 sp 1408
    r1 = load 8 sp 48
    r1 = add r1 2 32
    store 8 r1 sp 1416
    r1 = load 8 sp 1416
    r1 = mul r1 arg1 32
    store 8 r1 sp 1424
    r1 = load 8 sp 1424
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1432
    r1 = load 8 sp 1432
    r1 = add r1 0 32
    store 8 r1 sp 1440
    r1 = load 8 sp 1440
    store 8 r1 sp 1448
    r1 = mul arg4 1 64
    r2 = load 8 sp 1448
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1456
    r1 = load 8 sp 1456
    r1 = load 8 r1 0
    store 8 r1 sp 1464
    r1 = load 8 sp 48
    r1 = add r1 2 32
    store 8 r1 sp 1472
    r1 = load 8 sp 1472
    r1 = mul r1 arg1 32
    store 8 r1 sp 1480
    r1 = load 8 sp 1480
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1488
    r1 = load 8 sp 1488
    r1 = add r1 1 32
    store 8 r1 sp 1496
    r1 = load 8 sp 1496
    store 8 r1 sp 1504
    r1 = mul arg4 1 64
    r2 = load 8 sp 1504
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1512
    r1 = load 8 sp 1512
    r1 = load 8 r1 0
    store 8 r1 sp 1520
    r1 = load 8 sp 48
    r1 = add r1 2 32
    store 8 r1 sp 1528
    r1 = load 8 sp 1528
    r1 = mul r1 arg1 32
    store 8 r1 sp 1536
    r1 = load 8 sp 1536
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1544
    r1 = load 8 sp 1544
    r1 = add r1 2 32
    store 8 r1 sp 1552
    r1 = load 8 sp 1552
    store 8 r1 sp 1560
    r1 = mul arg4 1 64
    r2 = load 8 sp 1560
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1568
    r1 = load 8 sp 1568
    r1 = load 8 r1 0
    store 8 r1 sp 1576
    r1 = load 8 sp 48
    r1 = add r1 2 32
    store 8 r1 sp 1584
    r1 = load 8 sp 1584
    r1 = mul r1 arg1 32
    store 8 r1 sp 1592
    r1 = load 8 sp 1592
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1600
    r1 = load 8 sp 1600
    r1 = add r1 3 32
    store 8 r1 sp 1608
    r1 = load 8 sp 1608
    store 8 r1 sp 1616
    r1 = mul arg4 1 64
    r2 = load 8 sp 1616
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1624
    r1 = load 8 sp 1624
    r1 = load 8 r1 0
    store 8 r1 sp 1632
    r1 = load 8 sp 48
    r1 = add r1 3 32
    store 8 r1 sp 1640
    r1 = load 8 sp 1640
    r1 = mul r1 arg1 32
    store 8 r1 sp 1648
    r1 = load 8 sp 1648
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1656
    r1 = load 8 sp 1656
    r1 = add r1 0 32
    store 8 r1 sp 1664
    r1 = load 8 sp 1664
    store 8 r1 sp 1672
    r1 = mul arg4 1 64
    r2 = load 8 sp 1672
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1680
    r1 = load 8 sp 1680
    r1 = load 8 r1 0
    store 8 r1 sp 1688
    r1 = load 8 sp 48
    r1 = add r1 3 32
    store 8 r1 sp 1696
    r1 = load 8 sp 1696
    r1 = mul r1 arg1 32
    store 8 r1 sp 1704
    r1 = load 8 sp 1704
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1712
    r1 = load 8 sp 1712
    r1 = add r1 1 32
    store 8 r1 sp 1720
    r1 = load 8 sp 1720
    store 8 r1 sp 1728
    r1 = mul arg4 1 64
    r2 = load 8 sp 1728
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1736
    r1 = load 8 sp 1736
    r1 = load 8 r1 0
    store 8 r1 sp 1744
    r1 = load 8 sp 48
    r1 = add r1 3 32
    store 8 r1 sp 1752
    r1 = load 8 sp 1752
    r1 = mul r1 arg1 32
    store 8 r1 sp 1760
    r1 = load 8 sp 1760
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1768
    r1 = load 8 sp 1768
    r1 = add r1 2 32
    store 8 r1 sp 1776
    r1 = load 8 sp 1776
    store 8 r1 sp 1784
    r1 = mul arg4 1 64
    r2 = load 8 sp 1784
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1792
    r1 = load 8 sp 1792
    r1 = load 8 r1 0
    store 8 r1 sp 1800
    r1 = load 8 sp 48
    r1 = add r1 3 32
    store 8 r1 sp 1808
    r1 = load 8 sp 1808
    r1 = mul r1 arg1 32
    store 8 r1 sp 1816
    r1 = load 8 sp 1816
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1824
    r1 = load 8 sp 1824
    r1 = add r1 3 32
    store 8 r1 sp 1832
    r1 = load 8 sp 1832
    store 8 r1 sp 1840
    r1 = mul arg4 1 64
    r2 = load 8 sp 1840
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1848
    r1 = load 8 sp 1848
    r1 = load 8 r1 0
    store 8 r1 sp 1856
    r1 = load 8 sp 120
    r2 = load 8 sp 1016
    r1 = mul r1 r2 64
    store 8 r1 sp 1864
    r1 = load 8 sp 176
    r2 = load 8 sp 1240
    r1 = mul r1 r2 64
    store 8 r1 sp 1872
    r1 = load 8 sp 1864
    r2 = load 8 sp 1872
    r1 = add r1 r2 64
    store 8 r1 sp 1880
    r1 = load 8 sp 232
    r2 = load 8 sp 1464
    r1 = mul r1 r2 64
    store 8 r1 sp 1888
    r1 = load 8 sp 1880
    r2 = load 8 sp 1888
    r1 = add r1 r2 64
    store 8 r1 sp 1896
    r1 = load 8 sp 288
    r2 = load 8 sp 1688
    r1 = mul r1 r2 64
    store 8 r1 sp 1904
    r1 = load 8 sp 1896
    r2 = load 8 sp 1904
    r1 = add r1 r2 64
    store 8 r1 sp 1912
    r1 = load 8 sp 0
    r1 = add r1 0 32
    store 8 r1 sp 1920
    r1 = load 8 sp 1920
    r1 = mul r1 arg1 32
    store 8 r1 sp 1928
    r1 = load 8 sp 1928
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 1936
    r1 = load 8 sp 1936
    r1 = add r1 0 32
    store 8 r1 sp 1944
    r1 = load 8 sp 1944
    store 8 r1 sp 1952
    r1 = mul arg2 1 64
    r2 = load 8 sp 1952
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 1960
    r1 = load 8 sp 1960
    r1 = load 8 r1 0
    store 8 r1 sp 1968
    r1 = load 8 sp 1968
    r2 = load 8 sp 1912
    r1 = add r1 r2 64
    store 8 r1 sp 1976
    r1 = load 8 sp 1976
    r2 = load 8 sp 1960
    store 8 r1 r2 0
    r1 = load 8 sp 120
    r2 = load 8 sp 1072
    r1 = mul r1 r2 64
    store 8 r1 sp 1984
    r1 = load 8 sp 176
    r2 = load 8 sp 1296
    r1 = mul r1 r2 64
    store 8 r1 sp 1992
    r1 = load 8 sp 1984
    r2 = load 8 sp 1992
    r1 = add r1 r2 64
    store 8 r1 sp 2000
    r1 = load 8 sp 232
    r2 = load 8 sp 1520
    r1 = mul r1 r2 64
    store 8 r1 sp 2008
    r1 = load 8 sp 2000
    r2 = load 8 sp 2008
    r1 = add r1 r2 64
    store 8 r1 sp 2016
    r1 = load 8 sp 288
    r2 = load 8 sp 1744
    r1 = mul r1 r2 64
    store 8 r1 sp 2024
    r1 = load 8 sp 2016
    r2 = load 8 sp 2024
    r1 = add r1 r2 64
    store 8 r1 sp 2032
    r1 = load 8 sp 0
    r1 = add r1 0 32
    store 8 r1 sp 2040
    r1 = load 8 sp 2040
    r1 = mul r1 arg1 32
    store 8 r1 sp 2048
    r1 = load 8 sp 2048
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 2056
    r1 = load 8 sp 2056
    r1 = add r1 1 32
    store 8 r1 sp 2064
    r1 = load 8 sp 2064
    store 8 r1 sp 2072
    r1 = mul arg2 1 64
    r2 = load 8 sp 2072
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 2080
    r1 = load 8 sp 2080
    r1 = load 8 r1 0
    store 8 r1 sp 2088
    r1 = load 8 sp 2088
    r2 = load 8 sp 2032
    r1 = add r1 r2 64
    store 8 r1 sp 2096
    r1 = load 8 sp 2096
    r2 = load 8 sp 2080
    store 8 r1 r2 0
    r1 = load 8 sp 120
    r2 = load 8 sp 1128
    r1 = mul r1 r2 64
    store 8 r1 sp 2104
    r1 = load 8 sp 176
    r2 = load 8 sp 1352
    r1 = mul r1 r2 64
    store 8 r1 sp 2112
    r1 = load 8 sp 2104
    r2 = load 8 sp 2112
    r1 = add r1 r2 64
    store 8 r1 sp 2120
    r1 = load 8 sp 232
    r2 = load 8 sp 1576
    r1 = mul r1 r2 64
    store 8 r1 sp 2128
    r1 = load 8 sp 2120
    r2 = load 8 sp 2128
    r1 = add r1 r2 64
    store 8 r1 sp 2136
    r1 = load 8 sp 288
    r2 = load 8 sp 1800
    r1 = mul r1 r2 64
    store 8 r1 sp 2144
    r1 = load 8 sp 2136
    r2 = load 8 sp 2144
    r1 = add r1 r2 64
    store 8 r1 sp 2152
    r1 = load 8 sp 0
    r1 = add r1 0 32
    store 8 r1 sp 2160
    r1 = load 8 sp 2160
    r1 = mul r1 arg1 32
    store 8 r1 sp 2168
    r1 = load 8 sp 2168
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 2176
    r1 = load 8 sp 2176
    r1 = add r1 2 32
    store 8 r1 sp 2184
    r1 = load 8 sp 2184
    store 8 r1 sp 2192
    r1 = mul arg2 1 64
    r2 = load 8 sp 2192
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 2200
    r1 = load 8 sp 2200
    r1 = load 8 r1 0
    store 8 r1 sp 2208
    r1 = load 8 sp 2208
    r2 = load 8 sp 2152
    r1 = add r1 r2 64
    store 8 r1 sp 2216
    r1 = load 8 sp 2216
    r2 = load 8 sp 2200
    store 8 r1 r2 0
    r1 = load 8 sp 120
    r2 = load 8 sp 1184
    r1 = mul r1 r2 64
    store 8 r1 sp 2224
    r1 = load 8 sp 176
    r2 = load 8 sp 1408
    r1 = mul r1 r2 64
    store 8 r1 sp 2232
    r1 = load 8 sp 2224
    r2 = load 8 sp 2232
    r1 = add r1 r2 64
    store 8 r1 sp 2240
    r1 = load 8 sp 232
    r2 = load 8 sp 1632
    r1 = mul r1 r2 64
    store 8 r1 sp 2248
    r1 = load 8 sp 2240
    r2 = load 8 sp 2248
    r1 = add r1 r2 64
    store 8 r1 sp 2256
    r1 = load 8 sp 288
    r2 = load 8 sp 1856
    r1 = mul r1 r2 64
    store 8 r1 sp 2264
    r1 = load 8 sp 2256
    r2 = load 8 sp 2264
    r1 = add r1 r2 64
    store 8 r1 sp 2272
    r1 = load 8 sp 0
    r1 = add r1 0 32
    store 8 r1 sp 2280
    r1 = load 8 sp 2280
    r1 = mul r1 arg1 32
    store 8 r1 sp 2288
    r1 = load 8 sp 2288
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 2296
    r1 = load 8 sp 2296
    r1 = add r1 3 32
    store 8 r1 sp 2304
    r1 = load 8 sp 2304
    store 8 r1 sp 2312
    r1 = mul arg2 1 64
    r2 = load 8 sp 2312
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 2320
    r1 = load 8 sp 2320
    r1 = load 8 r1 0
    store 8 r1 sp 2328
    r1 = load 8 sp 2328
    r2 = load 8 sp 2272
    r1 = add r1 r2 64
    store 8 r1 sp 2336
    r1 = load 8 sp 2336
    r2 = load 8 sp 2320
    store 8 r1 r2 0
    r1 = load 8 sp 344
    r2 = load 8 sp 1016
    r1 = mul r1 r2 64
    store 8 r1 sp 2344
    r1 = load 8 sp 400
    r2 = load 8 sp 1240
    r1 = mul r1 r2 64
    store 8 r1 sp 2352
    r1 = load 8 sp 2344
    r2 = load 8 sp 2352
    r1 = add r1 r2 64
    store 8 r1 sp 2360
    r1 = load 8 sp 456
    r2 = load 8 sp 1464
    r1 = mul r1 r2 64
    store 8 r1 sp 2368
    r1 = load 8 sp 2360
    r2 = load 8 sp 2368
    r1 = add r1 r2 64
    store 8 r1 sp 2376
    r1 = load 8 sp 512
    r2 = load 8 sp 1688
    r1 = mul r1 r2 64
    store 8 r1 sp 2384
    r1 = load 8 sp 2376
    r2 = load 8 sp 2384
    r1 = add r1 r2 64
    store 8 r1 sp 2392
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 2400
    r1 = load 8 sp 2400
    r1 = mul r1 arg1 32
    store 8 r1 sp 2408
    r1 = load 8 sp 2408
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 2416
    r1 = load 8 sp 2416
    r1 = add r1 0 32
    store 8 r1 sp 2424
    r1 = load 8 sp 2424
    store 8 r1 sp 2432
    r1 = mul arg2 1 64
    r2 = load 8 sp 2432
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 2440
    r1 = load 8 sp 2440
    r1 = load 8 r1 0
    store 8 r1 sp 2448
    r1 = load 8 sp 2448
    r2 = load 8 sp 2392
    r1 = add r1 r2 64
    store 8 r1 sp 2456
    r1 = load 8 sp 2456
    r2 = load 8 sp 2440
    store 8 r1 r2 0
    r1 = load 8 sp 344
    r2 = load 8 sp 1072
    r1 = mul r1 r2 64
    store 8 r1 sp 2464
    r1 = load 8 sp 400
    r2 = load 8 sp 1296
    r1 = mul r1 r2 64
    store 8 r1 sp 2472
    r1 = load 8 sp 2464
    r2 = load 8 sp 2472
    r1 = add r1 r2 64
    store 8 r1 sp 2480
    r1 = load 8 sp 456
    r2 = load 8 sp 1520
    r1 = mul r1 r2 64
    store 8 r1 sp 2488
    r1 = load 8 sp 2480
    r2 = load 8 sp 2488
    r1 = add r1 r2 64
    store 8 r1 sp 2496
    r1 = load 8 sp 512
    r2 = load 8 sp 1744
    r1 = mul r1 r2 64
    store 8 r1 sp 2504
    r1 = load 8 sp 2496
    r2 = load 8 sp 2504
    r1 = add r1 r2 64
    store 8 r1 sp 2512
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 2520
    r1 = load 8 sp 2520
    r1 = mul r1 arg1 32
    store 8 r1 sp 2528
    r1 = load 8 sp 2528
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 2536
    r1 = load 8 sp 2536
    r1 = add r1 1 32
    store 8 r1 sp 2544
    r1 = load 8 sp 2544
    store 8 r1 sp 2552
    r1 = mul arg2 1 64
    r2 = load 8 sp 2552
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 2560
    r1 = load 8 sp 2560
    r1 = load 8 r1 0
    store 8 r1 sp 2568
    r1 = load 8 sp 2568
    r2 = load 8 sp 2512
    r1 = add r1 r2 64
    store 8 r1 sp 2576
    r1 = load 8 sp 2576
    r2 = load 8 sp 2560
    store 8 r1 r2 0
    r1 = load 8 sp 344
    r2 = load 8 sp 1128
    r1 = mul r1 r2 64
    store 8 r1 sp 2584
    r1 = load 8 sp 400
    r2 = load 8 sp 1352
    r1 = mul r1 r2 64
    store 8 r1 sp 2592
    r1 = load 8 sp 2584
    r2 = load 8 sp 2592
    r1 = add r1 r2 64
    store 8 r1 sp 2600
    r1 = load 8 sp 456
    r2 = load 8 sp 1576
    r1 = mul r1 r2 64
    store 8 r1 sp 2608
    r1 = load 8 sp 2600
    r2 = load 8 sp 2608
    r1 = add r1 r2 64
    store 8 r1 sp 2616
    r1 = load 8 sp 512
    r2 = load 8 sp 1800
    r1 = mul r1 r2 64
    store 8 r1 sp 2624
    r1 = load 8 sp 2616
    r2 = load 8 sp 2624
    r1 = add r1 r2 64
    store 8 r1 sp 2632
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 2640
    r1 = load 8 sp 2640
    r1 = mul r1 arg1 32
    store 8 r1 sp 2648
    r1 = load 8 sp 2648
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 2656
    r1 = load 8 sp 2656
    r1 = add r1 2 32
    store 8 r1 sp 2664
    r1 = load 8 sp 2664
    store 8 r1 sp 2672
    r1 = mul arg2 1 64
    r2 = load 8 sp 2672
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 2680
    r1 = load 8 sp 2680
    r1 = load 8 r1 0
    store 8 r1 sp 2688
    r1 = load 8 sp 2688
    r2 = load 8 sp 2632
    r1 = add r1 r2 64
    store 8 r1 sp 2696
    r1 = load 8 sp 2696
    r2 = load 8 sp 2680
    store 8 r1 r2 0
    r1 = load 8 sp 344
    r2 = load 8 sp 1184
    r1 = mul r1 r2 64
    store 8 r1 sp 2704
    r1 = load 8 sp 400
    r2 = load 8 sp 1408
    r1 = mul r1 r2 64
    store 8 r1 sp 2712
    r1 = load 8 sp 2704
    r2 = load 8 sp 2712
    r1 = add r1 r2 64
    store 8 r1 sp 2720
    r1 = load 8 sp 456
    r2 = load 8 sp 1632
    r1 = mul r1 r2 64
    store 8 r1 sp 2728
    r1 = load 8 sp 2720
    r2 = load 8 sp 2728
    r1 = add r1 r2 64
    store 8 r1 sp 2736
    r1 = load 8 sp 512
    r2 = load 8 sp 1856
    r1 = mul r1 r2 64
    store 8 r1 sp 2744
    r1 = load 8 sp 2736
    r2 = load 8 sp 2744
    r1 = add r1 r2 64
    store 8 r1 sp 2752
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 2760
    r1 = load 8 sp 2760
    r1 = mul r1 arg1 32
    store 8 r1 sp 2768
    r1 = load 8 sp 2768
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 2776
    r1 = load 8 sp 2776
    r1 = add r1 3 32
    store 8 r1 sp 2784
    r1 = load 8 sp 2784
    store 8 r1 sp 2792
    r1 = mul arg2 1 64
    r2 = load 8 sp 2792
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 2800
    r1 = load 8 sp 2800
    r1 = load 8 r1 0
    store 8 r1 sp 2808
    r1 = load 8 sp 2808
    r2 = load 8 sp 2752
    r1 = add r1 r2 64
    store 8 r1 sp 2816
    r1 = load 8 sp 2816
    r2 = load 8 sp 2800
    store 8 r1 r2 0
    r1 = load 8 sp 568
    r2 = load 8 sp 1016
    r1 = mul r1 r2 64
    store 8 r1 sp 2824
    r1 = load 8 sp 624
    r2 = load 8 sp 1240
    r1 = mul r1 r2 64
    store 8 r1 sp 2832
    r1 = load 8 sp 2824
    r2 = load 8 sp 2832
    r1 = add r1 r2 64
    store 8 r1 sp 2840
    r1 = load 8 sp 680
    r2 = load 8 sp 1464
    r1 = mul r1 r2 64
    store 8 r1 sp 2848
    r1 = load 8 sp 2840
    r2 = load 8 sp 2848
    r1 = add r1 r2 64
    store 8 r1 sp 2856
    r1 = load 8 sp 736
    r2 = load 8 sp 1688
    r1 = mul r1 r2 64
    store 8 r1 sp 2864
    r1 = load 8 sp 2856
    r2 = load 8 sp 2864
    r1 = add r1 r2 64
    store 8 r1 sp 2872
    r1 = load 8 sp 0
    r1 = add r1 2 32
    store 8 r1 sp 2880
    r1 = load 8 sp 2880
    r1 = mul r1 arg1 32
    store 8 r1 sp 2888
    r1 = load 8 sp 2888
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 2896
    r1 = load 8 sp 2896
    r1 = add r1 0 32
    store 8 r1 sp 2904
    r1 = load 8 sp 2904
    store 8 r1 sp 2912
    r1 = mul arg2 1 64
    r2 = load 8 sp 2912
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 2920
    r1 = load 8 sp 2920
    r1 = load 8 r1 0
    store 8 r1 sp 2928
    r1 = load 8 sp 2928
    r2 = load 8 sp 2872
    r1 = add r1 r2 64
    store 8 r1 sp 2936
    r1 = load 8 sp 2936
    r2 = load 8 sp 2920
    store 8 r1 r2 0
    r1 = load 8 sp 568
    r2 = load 8 sp 1072
    r1 = mul r1 r2 64
    store 8 r1 sp 2944
    r1 = load 8 sp 624
    r2 = load 8 sp 1296
    r1 = mul r1 r2 64
    store 8 r1 sp 2952
    r1 = load 8 sp 2944
    r2 = load 8 sp 2952
    r1 = add r1 r2 64
    store 8 r1 sp 2960
    r1 = load 8 sp 680
    r2 = load 8 sp 1520
    r1 = mul r1 r2 64
    store 8 r1 sp 2968
    r1 = load 8 sp 2960
    r2 = load 8 sp 2968
    r1 = add r1 r2 64
    store 8 r1 sp 2976
    r1 = load 8 sp 736
    r2 = load 8 sp 1744
    r1 = mul r1 r2 64
    store 8 r1 sp 2984
    r1 = load 8 sp 2976
    r2 = load 8 sp 2984
    r1 = add r1 r2 64
    store 8 r1 sp 2992
    r1 = load 8 sp 0
    r1 = add r1 2 32
    store 8 r1 sp 3000
    r1 = load 8 sp 3000
    r1 = mul r1 arg1 32
    store 8 r1 sp 3008
    r1 = load 8 sp 3008
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 3016
    r1 = load 8 sp 3016
    r1 = add r1 1 32
    store 8 r1 sp 3024
    r1 = load 8 sp 3024
    store 8 r1 sp 3032
    r1 = mul arg2 1 64
    r2 = load 8 sp 3032
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 3040
    r1 = load 8 sp 3040
    r1 = load 8 r1 0
    store 8 r1 sp 3048
    r1 = load 8 sp 3048
    r2 = load 8 sp 2992
    r1 = add r1 r2 64
    store 8 r1 sp 3056
    r1 = load 8 sp 3056
    r2 = load 8 sp 3040
    store 8 r1 r2 0
    r1 = load 8 sp 568
    r2 = load 8 sp 1128
    r1 = mul r1 r2 64
    store 8 r1 sp 3064
    r1 = load 8 sp 624
    r2 = load 8 sp 1352
    r1 = mul r1 r2 64
    store 8 r1 sp 3072
    r1 = load 8 sp 3064
    r2 = load 8 sp 3072
    r1 = add r1 r2 64
    store 8 r1 sp 3080
    r1 = load 8 sp 680
    r2 = load 8 sp 1576
    r1 = mul r1 r2 64
    store 8 r1 sp 3088
    r1 = load 8 sp 3080
    r2 = load 8 sp 3088
    r1 = add r1 r2 64
    store 8 r1 sp 3096
    r1 = load 8 sp 736
    r2 = load 8 sp 1800
    r1 = mul r1 r2 64
    store 8 r1 sp 3104
    r1 = load 8 sp 3096
    r2 = load 8 sp 3104
    r1 = add r1 r2 64
    store 8 r1 sp 3112
    r1 = load 8 sp 0
    r1 = add r1 2 32
    store 8 r1 sp 3120
    r1 = load 8 sp 3120
    r1 = mul r1 arg1 32
    store 8 r1 sp 3128
    r1 = load 8 sp 3128
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 3136
    r1 = load 8 sp 3136
    r1 = add r1 2 32
    store 8 r1 sp 3144
    r1 = load 8 sp 3144
    store 8 r1 sp 3152
    r1 = mul arg2 1 64
    r2 = load 8 sp 3152
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 3160
    r1 = load 8 sp 3160
    r1 = load 8 r1 0
    store 8 r1 sp 3168
    r1 = load 8 sp 3168
    r2 = load 8 sp 3112
    r1 = add r1 r2 64
    store 8 r1 sp 3176
    r1 = load 8 sp 3176
    r2 = load 8 sp 3160
    store 8 r1 r2 0
    r1 = load 8 sp 568
    r2 = load 8 sp 1184
    r1 = mul r1 r2 64
    store 8 r1 sp 3184
    r1 = load 8 sp 624
    r2 = load 8 sp 1408
    r1 = mul r1 r2 64
    store 8 r1 sp 3192
    r1 = load 8 sp 3184
    r2 = load 8 sp 3192
    r1 = add r1 r2 64
    store 8 r1 sp 3200
    r1 = load 8 sp 680
    r2 = load 8 sp 1632
    r1 = mul r1 r2 64
    store 8 r1 sp 3208
    r1 = load 8 sp 3200
    r2 = load 8 sp 3208
    r1 = add r1 r2 64
    store 8 r1 sp 3216
    r1 = load 8 sp 736
    r2 = load 8 sp 1856
    r1 = mul r1 r2 64
    store 8 r1 sp 3224
    r1 = load 8 sp 3216
    r2 = load 8 sp 3224
    r1 = add r1 r2 64
    store 8 r1 sp 3232
    r1 = load 8 sp 0
    r1 = add r1 2 32
    store 8 r1 sp 3240
    r1 = load 8 sp 3240
    r1 = mul r1 arg1 32
    store 8 r1 sp 3248
    r1 = load 8 sp 3248
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 3256
    r1 = load 8 sp 3256
    r1 = add r1 3 32
    store 8 r1 sp 3264
    r1 = load 8 sp 3264
    store 8 r1 sp 3272
    r1 = mul arg2 1 64
    r2 = load 8 sp 3272
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 3280
    r1 = load 8 sp 3280
    r1 = load 8 r1 0
    store 8 r1 sp 3288
    r1 = load 8 sp 3288
    r2 = load 8 sp 3232
    r1 = add r1 r2 64
    store 8 r1 sp 3296
    r1 = load 8 sp 3296
    r2 = load 8 sp 3280
    store 8 r1 r2 0
    r1 = load 8 sp 792
    r2 = load 8 sp 1016
    r1 = mul r1 r2 64
    store 8 r1 sp 3304
    r1 = load 8 sp 848
    r2 = load 8 sp 1240
    r1 = mul r1 r2 64
    store 8 r1 sp 3312
    r1 = load 8 sp 3304
    r2 = load 8 sp 3312
    r1 = add r1 r2 64
    store 8 r1 sp 3320
    r1 = load 8 sp 904
    r2 = load 8 sp 1464
    r1 = mul r1 r2 64
    store 8 r1 sp 3328
    r1 = load 8 sp 3320
    r2 = load 8 sp 3328
    r1 = add r1 r2 64
    store 8 r1 sp 3336
    r1 = load 8 sp 960
    r2 = load 8 sp 1688
    r1 = mul r1 r2 64
    store 8 r1 sp 3344
    r1 = load 8 sp 3336
    r2 = load 8 sp 3344
    r1 = add r1 r2 64
    store 8 r1 sp 3352
    r1 = load 8 sp 0
    r1 = add r1 3 32
    store 8 r1 sp 3360
    r1 = load 8 sp 3360
    r1 = mul r1 arg1 32
    store 8 r1 sp 3368
    r1 = load 8 sp 3368
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 3376
    r1 = load 8 sp 3376
    r1 = add r1 0 32
    store 8 r1 sp 3384
    r1 = load 8 sp 3384
    store 8 r1 sp 3392
    r1 = mul arg2 1 64
    r2 = load 8 sp 3392
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 3400
    r1 = load 8 sp 3400
    r1 = load 8 r1 0
    store 8 r1 sp 3408
    r1 = load 8 sp 3408
    r2 = load 8 sp 3352
    r1 = add r1 r2 64
    store 8 r1 sp 3416
    r1 = load 8 sp 3416
    r2 = load 8 sp 3400
    store 8 r1 r2 0
    r1 = load 8 sp 792
    r2 = load 8 sp 1072
    r1 = mul r1 r2 64
    store 8 r1 sp 3424
    r1 = load 8 sp 848
    r2 = load 8 sp 1296
    r1 = mul r1 r2 64
    store 8 r1 sp 3432
    r1 = load 8 sp 3424
    r2 = load 8 sp 3432
    r1 = add r1 r2 64
    store 8 r1 sp 3440
    r1 = load 8 sp 904
    r2 = load 8 sp 1520
    r1 = mul r1 r2 64
    store 8 r1 sp 3448
    r1 = load 8 sp 3440
    r2 = load 8 sp 3448
    r1 = add r1 r2 64
    store 8 r1 sp 3456
    r1 = load 8 sp 960
    r2 = load 8 sp 1744
    r1 = mul r1 r2 64
    store 8 r1 sp 3464
    r1 = load 8 sp 3456
    r2 = load 8 sp 3464
    r1 = add r1 r2 64
    store 8 r1 sp 3472
    r1 = load 8 sp 0
    r1 = add r1 3 32
    store 8 r1 sp 3480
    r1 = load 8 sp 3480
    r1 = mul r1 arg1 32
    store 8 r1 sp 3488
    r1 = load 8 sp 3488
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 3496
    r1 = load 8 sp 3496
    r1 = add r1 1 32
    store 8 r1 sp 3504
    r1 = load 8 sp 3504
    store 8 r1 sp 3512
    r1 = mul arg2 1 64
    r2 = load 8 sp 3512
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 3520
    r1 = load 8 sp 3520
    r1 = load 8 r1 0
    store 8 r1 sp 3528
    r1 = load 8 sp 3528
    r2 = load 8 sp 3472
    r1 = add r1 r2 64
    store 8 r1 sp 3536
    r1 = load 8 sp 3536
    r2 = load 8 sp 3520
    store 8 r1 r2 0
    r1 = load 8 sp 792
    r2 = load 8 sp 1128
    r1 = mul r1 r2 64
    store 8 r1 sp 3544
    r1 = load 8 sp 848
    r2 = load 8 sp 1352
    r1 = mul r1 r2 64
    store 8 r1 sp 3552
    r1 = load 8 sp 3544
    r2 = load 8 sp 3552
    r1 = add r1 r2 64
    store 8 r1 sp 3560
    r1 = load 8 sp 904
    r2 = load 8 sp 1576
    r1 = mul r1 r2 64
    store 8 r1 sp 3568
    r1 = load 8 sp 3560
    r2 = load 8 sp 3568
    r1 = add r1 r2 64
    store 8 r1 sp 3576
    r1 = load 8 sp 960
    r2 = load 8 sp 1800
    r1 = mul r1 r2 64
    store 8 r1 sp 3584
    r1 = load 8 sp 3576
    r2 = load 8 sp 3584
    r1 = add r1 r2 64
    store 8 r1 sp 3592
    r1 = load 8 sp 0
    r1 = add r1 3 32
    store 8 r1 sp 3600
    r1 = load 8 sp 3600
    r1 = mul r1 arg1 32
    store 8 r1 sp 3608
    r1 = load 8 sp 3608
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 3616
    r1 = load 8 sp 3616
    r1 = add r1 2 32
    store 8 r1 sp 3624
    r1 = load 8 sp 3624
    store 8 r1 sp 3632
    r1 = mul arg2 1 64
    r2 = load 8 sp 3632
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 3640
    r1 = load 8 sp 3640
    r1 = load 8 r1 0
    store 8 r1 sp 3648
    r1 = load 8 sp 3648
    r2 = load 8 sp 3592
    r1 = add r1 r2 64
    store 8 r1 sp 3656
    r1 = load 8 sp 3656
    r2 = load 8 sp 3640
    store 8 r1 r2 0
    r1 = load 8 sp 792
    r2 = load 8 sp 1184
    r1 = mul r1 r2 64
    store 8 r1 sp 3664
    r1 = load 8 sp 848
    r2 = load 8 sp 1408
    r1 = mul r1 r2 64
    store 8 r1 sp 3672
    r1 = load 8 sp 3664
    r2 = load 8 sp 3672
    r1 = add r1 r2 64
    store 8 r1 sp 3680
    r1 = load 8 sp 904
    r2 = load 8 sp 1632
    r1 = mul r1 r2 64
    store 8 r1 sp 3688
    r1 = load 8 sp 3680
    r2 = load 8 sp 3688
    r1 = add r1 r2 64
    store 8 r1 sp 3696
    r1 = load 8 sp 960
    r2 = load 8 sp 1856
    r1 = mul r1 r2 64
    store 8 r1 sp 3704
    r1 = load 8 sp 3696
    r2 = load 8 sp 3704
    r1 = add r1 r2 64
    store 8 r1 sp 3712
    r1 = load 8 sp 0
    r1 = add r1 3 32
    store 8 r1 sp 3720
    r1 = load 8 sp 3720
    r1 = mul r1 arg1 32
    store 8 r1 sp 3728
    r1 = load 8 sp 3728
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 3736
    r1 = load 8 sp 3736
    r1 = add r1 3 32
    store 8 r1 sp 3744
    r1 = load 8 sp 3744
    store 8 r1 sp 3752
    r1 = mul arg2 1 64
    r2 = load 8 sp 3752
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 3760
    r1 = load 8 sp 3760
    r1 = load 8 r1 0
    store 8 r1 sp 3768
    r1 = load 8 sp 3768
    r2 = load 8 sp 3712
    r1 = add r1 r2 64
    store 8 r1 sp 3776
    r1 = load 8 sp 3776
    r2 = load 8 sp 3760
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 48
    r1 = add r1 4 32
    store 8 r1 sp 3784
    r1 = load 8 sp 3784
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 48
    br .for.cond4

  .for.end:
    br .for.inc420

  .for.inc420:
    r1 = load 8 sp 24
    r1 = add r1 4 32
    store 8 r1 sp 3792
    r1 = load 8 sp 3792
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.end422:
    br .for.inc423

  .for.inc423:
    r1 = load 8 sp 0
    r1 = add r1 4 32
    store 8 r1 sp 3800
    r1 = load 8 sp 3800
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.end425:
    ret 0
end matmul

; Function read_mat
start read_mat 2:
  .entry:
    ; init sp!
    sp = sub sp 104 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.cond:
    r1 = load 8 sp 0
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    br r1 .for.body .for.end6

  .for.body:
    store 8 0 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.cond1:
    r1 = load 8 sp 24
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .for.body3 .for.end

  .for.body3:
    r1 = call read
    store 8 r1 sp 48
    r1 = load 8 sp 0
    r1 = mul r1 arg1 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 64
    r1 = load 8 sp 64
    store 8 r1 sp 72
    r1 = mul arg2 1 64
    r2 = load 8 sp 72
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 80
    r1 = load 8 sp 48
    r2 = load 8 sp 80
    store 8 r1 r2 0
    br .for.inc

  .for.inc:
    r1 = load 8 sp 24
    r1 = add r1 1 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.end:
    br .for.inc4

  .for.inc4:
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.end6:
    ret 0
end read_mat

; Function print_mat
start print_mat 2:
  .entry:
    ; init sp!
    sp = sub sp 104 64
    store 8 0 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.cond:
    r1 = load 8 sp 0
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    br r1 .for.body .for.end6

  .for.body:
    store 8 0 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.cond1:
    r1 = load 8 sp 24
    r1 = icmp ult r1 arg1 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    br r1 .for.body3 .for.end

  .for.body3:
    r1 = load 8 sp 0
    r1 = mul r1 arg1 32
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r2 = load 8 sp 24
    r1 = add r1 r2 32
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 64
    r1 = mul arg2 1 64
    r2 = load 8 sp 64
    r2 = mul r2 8 64
    r1 = add r1 r2 64
    store 8 r1 sp 72
    r1 = load 8 sp 72
    r1 = load 8 r1 0
    store 8 r1 sp 80
    r1 = load 8 sp 80
    call write r1
    br .for.inc

  .for.inc:
    r1 = load 8 sp 24
    r1 = add r1 1 32
    store 8 r1 sp 88
    r1 = load 8 sp 88
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 24
    br .for.cond1

  .for.end:
    br .for.inc4

  .for.inc4:
    r1 = load 8 sp 0
    r1 = add r1 1 32
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 8
    r1 = load 8 sp 8
    store 8 r1 sp 0
    br .for.cond

  .for.end6:
    ret 0
end print_mat

; Function main
start main 0:
  .entry:
    ; init sp!
    sp = sub sp 152 64
    r1 = call read
    store 8 r1 sp 0
    r1 = load 8 sp 0
    r1 = and r1 4294967295 64
    store 8 r1 sp 8
    r1 = load 8 sp 8
    r1 = urem r1 4 32
    store 8 r1 sp 16
    r1 = load 8 sp 16
    r1 = icmp ne r1 0 32
    store 8 r1 sp 24
    r1 = load 8 sp 24
    br r1 .if.then .if.end

  .if.then:
    br .cleanup

  .if.end:
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = mul r1 r2 32
    store 8 r1 sp 32
    r1 = load 8 sp 32
    store 8 r1 sp 40
    r1 = load 8 sp 40
    r1 = mul r1 8 64
    store 8 r1 sp 48
    r1 = load 8 sp 48
    r1 = malloc r1
    store 8 r1 sp 56
    r1 = load 8 sp 56
    store 8 r1 sp 64
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = mul r1 r2 32
    store 8 r1 sp 72
    r1 = load 8 sp 72
    store 8 r1 sp 80
    r1 = load 8 sp 80
    r1 = mul r1 8 64
    store 8 r1 sp 88
    r1 = load 8 sp 88
    r1 = malloc r1
    store 8 r1 sp 96
    r1 = load 8 sp 96
    store 8 r1 sp 104
    r1 = load 8 sp 8
    r2 = load 8 sp 8
    r1 = mul r1 r2 32
    store 8 r1 sp 112
    r1 = load 8 sp 112
    store 8 r1 sp 120
    r1 = load 8 sp 120
    r1 = mul r1 8 64
    store 8 r1 sp 128
    r1 = load 8 sp 128
    r1 = malloc r1
    store 8 r1 sp 136
    r1 = load 8 sp 136
    store 8 r1 sp 144
    r1 = load 8 sp 8
    r2 = load 8 sp 64
    call read_mat r1 r2
    r1 = load 8 sp 8
    r2 = load 8 sp 104
    call read_mat r1 r2
    r1 = load 8 sp 8
    r2 = load 8 sp 144
    r3 = load 8 sp 64
    r4 = load 8 sp 104
    call matmul r1 r2 r3 r4
    r1 = load 8 sp 8
    r2 = load 8 sp 144
    call print_mat r1 r2
    br .cleanup

  .cleanup:
    ret 0
end main
