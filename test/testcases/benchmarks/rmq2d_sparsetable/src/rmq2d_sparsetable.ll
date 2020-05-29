; ModuleID = '/tmp/a.ll'
source_filename = "rmq2d_sparsetable/src/rmq2d_sparsetable.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

@_input = external global i32*, align 8
@M = external global i32, align 4
@N = external global i32, align 4
@_A = external global i32**, align 8
@M2 = external global i32, align 4
@N2 = external global i32, align 4

; Function Attrs: nounwind ssp uwtable
define i8* @malloc_upto_8(i64 %x) #0 {
entry:
  %add = add i64 %x, 7
  %div = udiv i64 %add, 8
  %mul = mul i64 %div, 8
  %call = call noalias i8* @malloc(i64 %mul) #4
  ret i8* %call
}

; Function Attrs: allocsize(0)
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind ssp uwtable
define i32 @min(i32 %x, i32 %y) #0 {
entry:
  %cmp = icmp slt i32 %x, %y
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %x, %cond.true ], [ %y, %cond.false ]
  ret i32 %cond
}

; Function Attrs: nounwind ssp uwtable
define i32 @count_leading_zeros(i32 %x) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %count.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %i.0 = phi i32 [ 31, %entry ], [ %dec, %for.inc ]
  %cmp = icmp sge i32 %i.0, 0
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %cleanup

for.body:                                         ; preds = %for.cond
  %shl = shl i32 1, %i.0
  %and = and i32 %x, %shl
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  br label %cleanup

if.end:                                           ; preds = %for.body
  %inc = add nsw i32 %count.0, 1
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %dec = add nsw i32 %i.0, -1
  br label %for.cond

cleanup:                                          ; preds = %if.then, %for.cond.cleanup
  br label %for.end

for.end:                                          ; preds = %cleanup
  ret i32 %count.0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: nounwind ssp uwtable
define i32 @floorlog2(i32 %x) #0 {
entry:
  %call = call i32 @count_leading_zeros(i32 %x)
  %sub = sub nsw i32 32, %call
  %sub1 = sub nsw i32 %sub, 1
  ret i32 %sub1
}

; Function Attrs: nounwind ssp uwtable
define i32* @input(i32 %i, i32 %j) #0 {
entry:
  %0 = load i32*, i32** @_input, align 8
  %1 = load i32, i32* @M, align 4
  %mul = mul nsw i32 %i, %1
  %add = add nsw i32 %mul, %j
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %idxprom
  ret i32* %arrayidx
}

; Function Attrs: nounwind ssp uwtable
define i32 @width(i32 %j) #0 {
entry:
  %0 = load i32, i32* @M, align 4
  %shl = shl i32 1, %j
  %sub = sub nsw i32 %0, %shl
  %add = add nsw i32 %sub, 1
  ret i32 %add
}

; Function Attrs: nounwind ssp uwtable
define i32 @height(i32 %i) #0 {
entry:
  %0 = load i32, i32* @N, align 4
  %shl = shl i32 1, %i
  %sub = sub nsw i32 %0, %shl
  %add = add nsw i32 %sub, 1
  ret i32 %add
}

; Function Attrs: nounwind ssp uwtable
define i32** @A(i32 %i, i32 %j) #0 {
entry:
  %0 = load i32**, i32*** @_A, align 8
  %1 = load i32, i32* @M2, align 4
  %add = add nsw i32 %1, 1
  %mul = mul nsw i32 %i, %add
  %add1 = add nsw i32 %mul, %j
  %idxprom = sext i32 %add1 to i64
  %arrayidx = getelementptr inbounds i32*, i32** %0, i64 %idxprom
  ret i32** %arrayidx
}

; Function Attrs: nounwind ssp uwtable
define i32 @P(i32 %i, i32 %j, i32 %ii, i32 %jj) #0 {
entry:
  %call = call i32** @A(i32 %i, i32 %j)
  %0 = load i32*, i32** %call, align 8
  %call1 = call i32 @width(i32 %j)
  %mul = mul nsw i32 %ii, %call1
  %add = add nsw i32 %mul, %jj
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %idxprom
  %1 = load i32, i32* %arrayidx, align 4
  ret i32 %1
}

; Function Attrs: nounwind ssp uwtable
define void @preprocess() #0 {
entry:
  %0 = load i32, i32* @N, align 4
  %call = call i32 @floorlog2(i32 %0)
  store i32 %call, i32* @N2, align 4
  %1 = load i32, i32* @M, align 4
  %call1 = call i32 @floorlog2(i32 %1)
  store i32 %call1, i32* @M2, align 4
  %2 = load i32, i32* @N2, align 4
  %add = add nsw i32 %2, 1
  %conv = sext i32 %add to i64
  %mul = mul i64 8, %conv
  %3 = load i32, i32* @M2, align 4
  %add2 = add nsw i32 %3, 1
  %conv3 = sext i32 %add2 to i64
  %mul4 = mul i64 %mul, %conv3
  %call5 = call i8* @malloc_upto_8(i64 %mul4)
  %4 = bitcast i8* %call5 to i32**
  store i32** %4, i32*** @_A, align 8
  %5 = load i32*, i32** @_input, align 8
  %call6 = call i32** @A(i32 0, i32 0)
  store i32* %5, i32** %call6, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc24, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc25, %for.inc24 ]
  %6 = load i32, i32* @N2, align 4
  %cmp = icmp sle i32 %i.0, %6
  br i1 %cmp, label %for.body, label %for.end26

for.body:                                         ; preds = %for.cond
  br label %for.cond8

for.cond8:                                        ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %7 = load i32, i32* @M2, align 4
  %cmp9 = icmp sle i32 %j.0, %7
  br i1 %cmp9, label %for.body11, label %for.end

for.body11:                                       ; preds = %for.cond8
  %cmp12 = icmp eq i32 %i.0, 0
  br i1 %cmp12, label %land.lhs.true, label %if.end

land.lhs.true:                                    ; preds = %for.body11
  %cmp14 = icmp eq i32 %j.0, 0
  br i1 %cmp14, label %if.then, label %if.end

if.then:                                          ; preds = %land.lhs.true
  br label %for.inc

if.end:                                           ; preds = %land.lhs.true, %for.body11
  %call16 = call i32 @height(i32 %i.0)
  %conv17 = sext i32 %call16 to i64
  %mul18 = mul i64 4, %conv17
  %call19 = call i32 @width(i32 %j.0)
  %conv20 = sext i32 %call19 to i64
  %mul21 = mul i64 %mul18, %conv20
  %call22 = call i8* @malloc_upto_8(i64 %mul21)
  %8 = bitcast i8* %call22 to i32*
  %call23 = call i32** @A(i32 %i.0, i32 %j.0)
  store i32* %8, i32** %call23, align 8
  br label %for.inc

for.inc:                                          ; preds = %if.end, %if.then
  %inc = add nsw i32 %j.0, 1
  br label %for.cond8

for.end:                                          ; preds = %for.cond8
  br label %for.inc24

for.inc24:                                        ; preds = %for.end
  %inc25 = add nsw i32 %i.0, 1
  br label %for.cond

for.end26:                                        ; preds = %for.cond
  br label %for.cond27

for.cond27:                                       ; preds = %for.inc110, %for.end26
  %i.1 = phi i32 [ 0, %for.end26 ], [ %inc111, %for.inc110 ]
  %9 = load i32, i32* @N2, align 4
  %cmp28 = icmp sle i32 %i.1, %9
  br i1 %cmp28, label %for.body30, label %for.end112

for.body30:                                       ; preds = %for.cond27
  br label %for.cond31

for.cond31:                                       ; preds = %for.inc107, %for.body30
  %j.1 = phi i32 [ 0, %for.body30 ], [ %inc108, %for.inc107 ]
  %10 = load i32, i32* @M2, align 4
  %cmp32 = icmp sle i32 %j.1, %10
  br i1 %cmp32, label %for.body34, label %for.end109

for.body34:                                       ; preds = %for.cond31
  %cmp35 = icmp eq i32 %i.1, 0
  br i1 %cmp35, label %land.lhs.true37, label %if.end41

land.lhs.true37:                                  ; preds = %for.body34
  %cmp38 = icmp eq i32 %j.1, 0
  br i1 %cmp38, label %if.then40, label %if.end41

if.then40:                                        ; preds = %land.lhs.true37
  br label %for.inc107

if.end41:                                         ; preds = %land.lhs.true37, %for.body34
  %call42 = call i32** @A(i32 %i.1, i32 %j.1)
  %11 = load i32*, i32** %call42, align 8
  br label %for.cond43

for.cond43:                                       ; preds = %for.inc104, %if.end41
  %ii.0 = phi i32 [ 0, %if.end41 ], [ %inc105, %for.inc104 ]
  %call44 = call i32 @height(i32 %i.1)
  %cmp45 = icmp slt i32 %ii.0, %call44
  br i1 %cmp45, label %for.body47, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond43
  br label %for.end106

for.body47:                                       ; preds = %for.cond43
  br label %for.cond48

for.cond48:                                       ; preds = %for.inc101, %for.body47
  %jj.0 = phi i32 [ 0, %for.body47 ], [ %inc102, %for.inc101 ]
  %call49 = call i32 @width(i32 %j.1)
  %cmp50 = icmp slt i32 %jj.0, %call49
  br i1 %cmp50, label %for.body53, label %for.cond.cleanup52

for.cond.cleanup52:                               ; preds = %for.cond48
  br label %for.end103

for.body53:                                       ; preds = %for.cond48
  %cmp54 = icmp ne i32 %j.1, 0
  br i1 %cmp54, label %if.then56, label %if.else

if.then56:                                        ; preds = %for.body53
  %sub = sub nsw i32 %j.1, 1
  %call57 = call i32** @A(i32 %i.1, i32 %sub)
  %12 = load i32*, i32** %call57, align 8
  %sub58 = sub nsw i32 %j.1, 1
  %call59 = call i32 @width(i32 %sub58)
  %mul60 = mul nsw i32 %ii.0, %call59
  %add61 = add nsw i32 %mul60, %jj.0
  %idxprom = sext i32 %add61 to i64
  %arrayidx = getelementptr inbounds i32, i32* %12, i64 %idxprom
  %13 = load i32, i32* %arrayidx, align 4
  %mul62 = mul nsw i32 %ii.0, %call59
  %add63 = add nsw i32 %mul62, %jj.0
  %sub64 = sub nsw i32 %j.1, 1
  %shl = shl i32 1, %sub64
  %add65 = add nsw i32 %add63, %shl
  %idxprom66 = sext i32 %add65 to i64
  %arrayidx67 = getelementptr inbounds i32, i32* %12, i64 %idxprom66
  %14 = load i32, i32* %arrayidx67, align 4
  %call68 = call i32 @min(i32 %13, i32 %14)
  %call69 = call i32 @width(i32 %j.1)
  %mul70 = mul nsw i32 %ii.0, %call69
  %add71 = add nsw i32 %mul70, %jj.0
  %idxprom72 = sext i32 %add71 to i64
  %arrayidx73 = getelementptr inbounds i32, i32* %11, i64 %idxprom72
  store i32 %call68, i32* %arrayidx73, align 4
  br label %if.end100

if.else:                                          ; preds = %for.body53
  %sub75 = sub nsw i32 %i.1, 1
  %call76 = call i32** @A(i32 %sub75, i32 %j.1)
  %15 = load i32*, i32** %call76, align 8
  %sub77 = sub nsw i32 %i.1, 1
  %call78 = call i32 @height(i32 %sub77)
  %call80 = call i32 @width(i32 %j.1)
  %mul81 = mul nsw i32 %ii.0, %call80
  %add82 = add nsw i32 %mul81, %jj.0
  %idxprom83 = sext i32 %add82 to i64
  %arrayidx84 = getelementptr inbounds i32, i32* %15, i64 %idxprom83
  %16 = load i32, i32* %arrayidx84, align 4
  %sub86 = sub nsw i32 %i.1, 1
  %shl87 = shl i32 1, %sub86
  %add88 = add nsw i32 %ii.0, %shl87
  %call89 = call i32 @width(i32 %j.1)
  %mul90 = mul nsw i32 %add88, %call89
  %add91 = add nsw i32 %mul90, %jj.0
  %idxprom92 = sext i32 %add91 to i64
  %arrayidx93 = getelementptr inbounds i32, i32* %15, i64 %idxprom92
  %17 = load i32, i32* %arrayidx93, align 4
  %call94 = call i32 @min(i32 %16, i32 %17)
  %call95 = call i32 @width(i32 %j.1)
  %mul96 = mul nsw i32 %ii.0, %call95
  %add97 = add nsw i32 %mul96, %jj.0
  %idxprom98 = sext i32 %add97 to i64
  %arrayidx99 = getelementptr inbounds i32, i32* %11, i64 %idxprom98
  store i32 %call94, i32* %arrayidx99, align 4
  br label %if.end100

if.end100:                                        ; preds = %if.else, %if.then56
  br label %for.inc101

for.inc101:                                       ; preds = %if.end100
  %inc102 = add nsw i32 %jj.0, 1
  br label %for.cond48

for.end103:                                       ; preds = %for.cond.cleanup52
  br label %for.inc104

for.inc104:                                       ; preds = %for.end103
  %inc105 = add nsw i32 %ii.0, 1
  br label %for.cond43

for.end106:                                       ; preds = %for.cond.cleanup
  br label %for.inc107

for.inc107:                                       ; preds = %for.end106, %if.then40
  %inc108 = add nsw i32 %j.1, 1
  br label %for.cond31

for.end109:                                       ; preds = %for.cond31
  br label %for.inc110

for.inc110:                                       ; preds = %for.end109
  %inc111 = add nsw i32 %i.1, 1
  br label %for.cond27

for.end112:                                       ; preds = %for.cond27
  ret void
}

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i32
  store i32 %conv, i32* @N, align 4
  %call1 = call i64 (...) @read()
  %conv2 = trunc i64 %call1 to i32
  store i32 %conv2, i32* @M, align 4
  %0 = load i32, i32* @N, align 4
  %conv3 = sext i32 %0 to i64
  %mul = mul i64 4, %conv3
  %1 = load i32, i32* @M, align 4
  %conv4 = sext i32 %1 to i64
  %mul5 = mul i64 %mul, %conv4
  %call6 = call i8* @malloc_upto_8(i64 %mul5)
  %2 = bitcast i8* %call6 to i32*
  store i32* %2, i32** @_input, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc16, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc17, %for.inc16 ]
  %3 = load i32, i32* @N, align 4
  %cmp = icmp slt i32 %i.0, %3
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end18

for.body:                                         ; preds = %for.cond
  br label %for.cond8

for.cond8:                                        ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %4 = load i32, i32* @M, align 4
  %cmp9 = icmp slt i32 %j.0, %4
  br i1 %cmp9, label %for.body12, label %for.cond.cleanup11

for.cond.cleanup11:                               ; preds = %for.cond8
  br label %for.end

for.body12:                                       ; preds = %for.cond8
  %call13 = call i64 (...) @read()
  %conv14 = trunc i64 %call13 to i32
  %call15 = call i32* @input(i32 %i.0, i32 %j.0)
  store i32 %conv14, i32* %call15, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body12
  %inc = add nsw i32 %j.0, 1
  br label %for.cond8

for.end:                                          ; preds = %for.cond.cleanup11
  br label %for.inc16

for.inc16:                                        ; preds = %for.end
  %inc17 = add nsw i32 %i.0, 1
  br label %for.cond

for.end18:                                        ; preds = %for.cond.cleanup
  call void @preprocess()
  %call19 = call i64 (...) @read()
  %conv20 = trunc i64 %call19 to i32
  br label %while.cond

while.cond:                                       ; preds = %while.body, %for.end18
  %Q.0 = phi i32 [ %conv20, %for.end18 ], [ %dec, %while.body ]
  %dec = add nsw i32 %Q.0, -1
  %tobool = icmp ne i32 %Q.0, 0
  br i1 %tobool, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %call21 = call i64 (...) @read()
  %conv22 = trunc i64 %call21 to i32
  %call23 = call i64 (...) @read()
  %conv24 = trunc i64 %call23 to i32
  %call25 = call i64 (...) @read()
  %conv26 = trunc i64 %call25 to i32
  %call27 = call i64 (...) @read()
  %conv28 = trunc i64 %call27 to i32
  %sub = sub nsw i32 %conv24, %conv22
  %add = add nsw i32 %sub, 1
  %call29 = call i32 @floorlog2(i32 %add)
  %sub30 = sub nsw i32 %conv28, %conv26
  %add31 = add nsw i32 %sub30, 1
  %call32 = call i32 @floorlog2(i32 %add31)
  %call33 = call i32 @P(i32 %call29, i32 %call32, i32 %conv22, i32 %conv26)
  %add34 = add nsw i32 %conv24, 1
  %shl = shl i32 1, %call29
  %sub35 = sub nsw i32 %add34, %shl
  %call36 = call i32 @P(i32 %call29, i32 %call32, i32 %sub35, i32 %conv26)
  %add37 = add nsw i32 %conv28, 1
  %shl38 = shl i32 1, %call32
  %sub39 = sub nsw i32 %add37, %shl38
  %call40 = call i32 @P(i32 %call29, i32 %call32, i32 %conv22, i32 %sub39)
  %add41 = add nsw i32 %conv24, 1
  %shl42 = shl i32 1, %call29
  %sub43 = sub nsw i32 %add41, %shl42
  %add44 = add nsw i32 %conv28, 1
  %shl45 = shl i32 1, %call32
  %sub46 = sub nsw i32 %add44, %shl45
  %call47 = call i32 @P(i32 %call29, i32 %call32, i32 %sub43, i32 %sub46)
  %call48 = call i32 @min(i32 %call33, i32 %call36)
  %call49 = call i32 @min(i32 %call40, i32 %call47)
  %call50 = call i32 @min(i32 %call48, i32 %call49)
  %conv51 = sext i32 %call50 to i64
  call void @write(i64 %conv51)
  br label %while.cond

while.end:                                        ; preds = %while.cond
  ret i32 0
}

declare i64 @read(...) #3

declare void @write(i64) #3

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { allocsize(0) "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { allocsize(0) }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 10, i32 15]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 10.0.0 (git@github.com:llvm/llvm-project.git d32170dbd5b0d54436537b6b75beaf44324e0c28)"}
