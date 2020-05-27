; ModuleID = 'af_xdp_kern.c'
source_filename = "af_xdp_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.udphdr = type { i16, i16, i16, i16 }

@xsks_map = dso_local global %struct.bpf_map_def { i32 17, i32 4, i32 4, i32 64, i32 0 }, section "maps", align 4, !dbg !0
@xdp_stats_map = dso_local global %struct.bpf_map_def { i32 2, i32 4, i32 16, i32 64, i32 0 }, section "maps", align 4, !dbg !63
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !73
@llvm.used = appending global [5 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_filter_func to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_sock_prog to i8*), i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*), i8* bitcast (%struct.bpf_map_def* @xsks_map to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @xdp_sock_prog(%struct.xdp_md* nocapture readonly) #0 section "xdp_sock" !dbg !99 {
  %2 = alloca i32, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !111, metadata !DIExpression()), !dbg !115
  %3 = bitcast i32* %2 to i8*, !dbg !116
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #3, !dbg !116
  %4 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 4, !dbg !117
  %5 = load i32, i32* %4, align 4, !dbg !117, !tbaa !118
  call void @llvm.dbg.value(metadata i32 %5, metadata !112, metadata !DIExpression()), !dbg !123
  store i32 %5, i32* %2, align 4, !dbg !123, !tbaa !124
  %6 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*), i8* nonnull %3) #3, !dbg !125
  %7 = bitcast i8* %6 to i32*, !dbg !125
  call void @llvm.dbg.value(metadata i32* %7, metadata !113, metadata !DIExpression()), !dbg !126
  %8 = icmp eq i8* %6, null, !dbg !127
  br i1 %8, label %14, label %9, !dbg !129

; <label>:9:                                      ; preds = %1
  %10 = load i32, i32* %7, align 4, !dbg !130, !tbaa !124
  %11 = add i32 %10, 1, !dbg !130
  store i32 %11, i32* %7, align 4, !dbg !130, !tbaa !124
  %12 = and i32 %10, 1, !dbg !133
  %13 = icmp eq i32 %12, 0, !dbg !133
  br i1 %13, label %14, label %20, !dbg !134

; <label>:14:                                     ; preds = %9, %1
  %15 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @xsks_map to i8*), i8* nonnull %3) #3, !dbg !135
  %16 = icmp eq i8* %15, null, !dbg !135
  br i1 %16, label %20, label %17, !dbg !137

; <label>:17:                                     ; preds = %14
  %18 = load i32, i32* %2, align 4, !dbg !138, !tbaa !124
  call void @llvm.dbg.value(metadata i32 %18, metadata !112, metadata !DIExpression()), !dbg !123
  %19 = call i32 inttoptr (i64 51 to i32 (i8*, i32, i64)*)(i8* bitcast (%struct.bpf_map_def* @xsks_map to i8*), i32 %18, i64 0) #3, !dbg !139
  br label %20, !dbg !140

; <label>:20:                                     ; preds = %14, %9, %17
  %21 = phi i32 [ %19, %17 ], [ 2, %9 ], [ 2, %14 ], !dbg !141
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #3, !dbg !142
  ret i32 %21, !dbg !142
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: nounwind
define dso_local i32 @xdp_filter_func(%struct.xdp_md* nocapture readonly) #0 section "xdp_filter" !dbg !143 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !145, metadata !DIExpression()), !dbg !239
  %4 = bitcast i32* %2 to i8*, !dbg !240
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %4) #3, !dbg !240
  %5 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 4, !dbg !241
  %6 = load i32, i32* %5, align 4, !dbg !241, !tbaa !118
  call void @llvm.dbg.value(metadata i32 %6, metadata !146, metadata !DIExpression()), !dbg !242
  store i32 %6, i32* %2, align 4, !dbg !242, !tbaa !124
  %7 = bitcast i32* %3 to i8*, !dbg !243
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %7) #3, !dbg !243
  call void @llvm.dbg.value(metadata i32 2, metadata !147, metadata !DIExpression()), !dbg !244
  store i32 2, i32* %3, align 4, !dbg !244, !tbaa !124
  %8 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*), i8* nonnull %7) #3, !dbg !245
  call void @llvm.dbg.value(metadata i8* %8, metadata !148, metadata !DIExpression()), !dbg !246
  %9 = icmp eq i8* %8, null, !dbg !247
  br i1 %9, label %108, label %10, !dbg !249

; <label>:10:                                     ; preds = %1
  %11 = getelementptr inbounds i8, i8* %8, i64 8, !dbg !250
  %12 = bitcast i8* %11 to i32*, !dbg !250
  %13 = load i32, i32* %12, align 8, !dbg !250, !tbaa !252
  %14 = icmp eq i32 %13, 0, !dbg !255
  br i1 %14, label %16, label %15, !dbg !256

; <label>:15:                                     ; preds = %10
  store i32 0, i32* %12, align 8, !dbg !257, !tbaa !252
  br label %16, !dbg !258

; <label>:16:                                     ; preds = %10, %15
  %17 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !259
  %18 = load i32, i32* %17, align 4, !dbg !259, !tbaa !260
  %19 = zext i32 %18 to i64, !dbg !261
  %20 = inttoptr i64 %19 to i8*, !dbg !262
  call void @llvm.dbg.value(metadata i8* %20, metadata !156, metadata !DIExpression()), !dbg !263
  %21 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !264
  %22 = load i32, i32* %21, align 4, !dbg !264, !tbaa !265
  %23 = zext i32 %22 to i64, !dbg !266
  %24 = inttoptr i64 %23 to i8*, !dbg !267
  call void @llvm.dbg.value(metadata i8* %24, metadata !157, metadata !DIExpression()), !dbg !268
  call void @llvm.dbg.value(metadata i64 14, metadata !170, metadata !DIExpression()), !dbg !269
  %25 = getelementptr i8, i8* %24, i64 14, !dbg !270
  %26 = icmp ugt i8* %25, %20, !dbg !272
  br i1 %26, label %27, label %30, !dbg !273

; <label>:27:                                     ; preds = %16
  %28 = bitcast i8* %8 to i64*, !dbg !274
  %29 = atomicrmw add i64* %28, i64 1 seq_cst, !dbg !274
  br label %108, !dbg !276

; <label>:30:                                     ; preds = %16
  %31 = inttoptr i64 %23 to %struct.ethhdr*, !dbg !277
  call void @llvm.dbg.value(metadata %struct.ethhdr* %31, metadata !158, metadata !DIExpression()), !dbg !278
  %32 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %31, i64 0, i32 2, !dbg !279
  %33 = load i16, i16* %32, align 1, !dbg !279, !tbaa !280
  call void @llvm.dbg.value(metadata i32 0, metadata !172, metadata !DIExpression()), !dbg !283
  call void @llvm.dbg.value(metadata i64 14, metadata !170, metadata !DIExpression()), !dbg !269
  %34 = getelementptr i8, i8* %24, i64 2
  call void @llvm.dbg.value(metadata i64 14, metadata !170, metadata !DIExpression()), !dbg !269
  call void @llvm.dbg.value(metadata i32 0, metadata !172, metadata !DIExpression()), !dbg !283
  switch i16 %33, label %42 [
    i16 -22392, label %35
    i16 129, label %35
  ], !dbg !284

; <label>:35:                                     ; preds = %30, %30
  call void @llvm.dbg.value(metadata i64 18, metadata !170, metadata !DIExpression()), !dbg !269
  %36 = getelementptr i8, i8* %24, i64 18, !dbg !285
  %37 = icmp ugt i8* %36, %20, !dbg !287
  br i1 %37, label %45, label %38, !dbg !288

; <label>:38:                                     ; preds = %35
  call void @llvm.dbg.value(metadata i8* %34, metadata !174, metadata !DIExpression()), !dbg !289
  %39 = getelementptr inbounds i8, i8* %24, i64 16, !dbg !290
  %40 = bitcast i8* %39 to i16*, !dbg !290
  %41 = load i16, i16* %40, align 2, !dbg !290, !tbaa !291
  call void @llvm.dbg.value(metadata i64 undef, metadata !171, metadata !DIExpression()), !dbg !293
  br label %42

; <label>:42:                                     ; preds = %38, %30
  %43 = phi i16 [ %33, %30 ], [ %41, %38 ]
  %44 = phi i64 [ 14, %30 ], [ 18, %38 ], !dbg !294
  call void @llvm.dbg.value(metadata i64 %44, metadata !170, metadata !DIExpression()), !dbg !269
  call void @llvm.dbg.value(metadata i32 1, metadata !172, metadata !DIExpression()), !dbg !283
  call void @llvm.dbg.value(metadata i64 %44, metadata !170, metadata !DIExpression()), !dbg !269
  call void @llvm.dbg.value(metadata i32 1, metadata !172, metadata !DIExpression()), !dbg !283
  switch i16 %43, label %118 [
    i16 -22392, label %110
    i16 129, label %110
  ], !dbg !284

; <label>:45:                                     ; preds = %110, %35
  %46 = bitcast i8* %8 to i64*, !dbg !295
  %47 = atomicrmw add i64* %46, i64 1 seq_cst, !dbg !295
  call void @llvm.dbg.value(metadata i64 18, metadata !170, metadata !DIExpression()), !dbg !269
  br label %108

; <label>:48:                                     ; preds = %118
  %49 = getelementptr i8, i8* %24, i64 %120, !dbg !297
  %50 = getelementptr i8, i8* %49, i64 20, !dbg !298
  call void @llvm.dbg.value(metadata i8* %50, metadata !203, metadata !DIExpression()), !dbg !299
  %51 = getelementptr inbounds i8, i8* %50, i64 8, !dbg !300
  %52 = bitcast i8* %51 to %struct.udphdr*, !dbg !300
  %53 = inttoptr i64 %19 to %struct.udphdr*, !dbg !302
  %54 = icmp ugt %struct.udphdr* %52, %53, !dbg !303
  br i1 %54, label %55, label %58, !dbg !304

; <label>:55:                                     ; preds = %48
  %56 = bitcast i8* %8 to i64*, !dbg !305
  %57 = atomicrmw add i64* %56, i64 1 seq_cst, !dbg !305
  br label %108, !dbg !307

; <label>:58:                                     ; preds = %48
  call void @llvm.dbg.value(metadata i8* %49, metadata !184, metadata !DIExpression()), !dbg !308
  %59 = getelementptr inbounds i8, i8* %49, i64 12, !dbg !309
  %60 = bitcast i8* %59 to i32*, !dbg !309
  %61 = load i32, i32* %60, align 4, !dbg !309, !tbaa !310
  %62 = call i32 @llvm.bswap.i32(i32 %61), !dbg !309
  store i32 %62, i32* %12, align 8, !dbg !312, !tbaa !252
  %63 = getelementptr inbounds i8, i8* %49, i64 9, !dbg !313
  %64 = load i8, i8* %63, align 1, !dbg !313, !tbaa !315
  %65 = icmp eq i8 %64, 17, !dbg !316
  %66 = and i32 %61, 16777215, !dbg !317
  %67 = icmp eq i32 %66, 2399415, !dbg !318
  %68 = and i1 %67, %65, !dbg !319
  br i1 %68, label %69, label %100, !dbg !319

; <label>:69:                                     ; preds = %58
  %70 = getelementptr inbounds i8, i8* %50, i64 2, !dbg !320
  %71 = bitcast i8* %70 to i16*, !dbg !320
  %72 = load i16, i16* %71, align 2, !dbg !320, !tbaa !321
  %73 = icmp eq i16 %72, 14640, !dbg !323
  br i1 %73, label %74, label %100, !dbg !324

; <label>:74:                                     ; preds = %69
  %75 = bitcast i8* %8 to i64*, !dbg !325
  store i64 11, i64* %75, align 8, !dbg !327, !tbaa !328
  br label %108, !dbg !329

; <label>:76:                                     ; preds = %118
  %77 = getelementptr i8, i8* %24, i64 %120, !dbg !330
  call void @llvm.dbg.value(metadata i8* %77, metadata !204, metadata !DIExpression()), !dbg !331
  %78 = getelementptr i8, i8* %77, i64 40, !dbg !332
  call void @llvm.dbg.value(metadata i8* %78, metadata !238, metadata !DIExpression()), !dbg !333
  %79 = getelementptr inbounds i8, i8* %78, i64 8, !dbg !334
  %80 = bitcast i8* %79 to %struct.udphdr*, !dbg !334
  %81 = inttoptr i64 %19 to %struct.udphdr*, !dbg !336
  %82 = icmp ugt %struct.udphdr* %80, %81, !dbg !337
  br i1 %82, label %108, label %83, !dbg !338

; <label>:83:                                     ; preds = %76
  %84 = getelementptr inbounds i8, i8* %77, i64 6, !dbg !339
  %85 = load i8, i8* %84, align 2, !dbg !339, !tbaa !341
  %86 = icmp eq i8 %85, 17, !dbg !344
  br i1 %86, label %87, label %100, !dbg !345

; <label>:87:                                     ; preds = %83
  %88 = getelementptr inbounds i8, i8* %77, i64 24, !dbg !346
  %89 = load i8, i8* %88, align 4, !dbg !347, !tbaa !348
  %90 = icmp eq i8 %89, -3, !dbg !349
  br i1 %90, label %91, label %100, !dbg !350

; <label>:91:                                     ; preds = %87
  %92 = getelementptr inbounds i8, i8* %88, i64 1, !dbg !351
  %93 = load i8, i8* %92, align 1, !dbg !351, !tbaa !348
  %94 = icmp eq i8 %93, 0, !dbg !352
  br i1 %94, label %95, label %100, !dbg !353

; <label>:95:                                     ; preds = %91
  %96 = getelementptr inbounds i8, i8* %78, i64 2, !dbg !354
  %97 = bitcast i8* %96 to i16*, !dbg !354
  %98 = load i16, i16* %97, align 2, !dbg !354, !tbaa !321
  %99 = icmp eq i16 %98, 14640, !dbg !355
  br i1 %99, label %108, label %100, !dbg !356

; <label>:100:                                    ; preds = %58, %69, %95, %91, %87, %83, %118
  %101 = bitcast i8* %8 to i64*, !dbg !357
  %102 = atomicrmw add i64* %101, i64 1 seq_cst, !dbg !357
  %103 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @xsks_map to i8*), i8* nonnull %4) #3, !dbg !358
  %104 = icmp eq i8* %103, null, !dbg !358
  br i1 %104, label %108, label %105, !dbg !360

; <label>:105:                                    ; preds = %100
  %106 = load i32, i32* %2, align 4, !dbg !361, !tbaa !124
  call void @llvm.dbg.value(metadata i32 %106, metadata !146, metadata !DIExpression()), !dbg !242
  %107 = call i32 inttoptr (i64 51 to i32 (i8*, i32, i64)*)(i8* bitcast (%struct.bpf_map_def* @xsks_map to i8*), i32 %106, i64 0) #3, !dbg !362
  br label %108, !dbg !363

; <label>:108:                                    ; preds = %95, %76, %55, %74, %45, %27, %100, %105, %1
  %109 = phi i32 [ 0, %1 ], [ 2, %27 ], [ %107, %105 ], [ 2, %45 ], [ 2, %100 ], [ 2, %55 ], [ 1, %74 ], [ 1, %95 ], [ 2, %76 ], !dbg !294
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %7) #3, !dbg !364
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %4) #3, !dbg !364
  ret i32 %109, !dbg !364

; <label>:110:                                    ; preds = %42, %42
  %111 = add nuw nsw i64 %44, 4, !dbg !365
  call void @llvm.dbg.value(metadata i64 %111, metadata !170, metadata !DIExpression()), !dbg !269
  %112 = getelementptr i8, i8* %24, i64 %111, !dbg !285
  %113 = icmp ugt i8* %112, %20, !dbg !287
  br i1 %113, label %45, label %114, !dbg !288

; <label>:114:                                    ; preds = %110
  call void @llvm.dbg.value(metadata i8* %34, metadata !174, metadata !DIExpression()), !dbg !289
  %115 = getelementptr inbounds i8, i8* %34, i64 %44, !dbg !290
  %116 = bitcast i8* %115 to i16*, !dbg !290
  %117 = load i16, i16* %116, align 2, !dbg !290, !tbaa !291
  call void @llvm.dbg.value(metadata i64 undef, metadata !171, metadata !DIExpression()), !dbg !293
  br label %118

; <label>:118:                                    ; preds = %114, %42
  %119 = phi i16 [ %43, %42 ], [ %117, %114 ]
  %120 = phi i64 [ %44, %42 ], [ %111, %114 ], !dbg !294
  call void @llvm.dbg.value(metadata i64 %120, metadata !170, metadata !DIExpression()), !dbg !269
  call void @llvm.dbg.value(metadata i32 2, metadata !172, metadata !DIExpression()), !dbg !283
  call void @llvm.dbg.value(metadata i64 %120, metadata !170, metadata !DIExpression()), !dbg !269
  call void @llvm.dbg.value(metadata i64 %120, metadata !170, metadata !DIExpression()), !dbg !269
  call void @llvm.dbg.value(metadata i64 18, metadata !170, metadata !DIExpression()), !dbg !269
  switch i16 %119, label %100 [
    i16 8, label %48
    i16 -8826, label %76
  ], !dbg !366
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

; Function Attrs: nounwind readnone speculatable
declare i32 @llvm.bswap.i32(i32) #2

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind readnone speculatable }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!95, !96, !97}
!llvm.ident = !{!98}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "xsks_map", scope: !2, file: !3, line: 36, type: !65, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.0 (Fedora 8.0.0-3.fc30)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !43, globals: !62, nameTableKind: None)
!3 = !DIFile(filename: "af_xdp_kern.c", directory: "/root/bpftest/advanced03-AF_XDP")
!4 = !{!5, !14}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 2845, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "../headers/linux/bpf.h", directory: "/root/bpftest/advanced03-AF_XDP")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13}
!9 = !DIEnumerator(name: "XDP_ABORTED", value: 0, isUnsigned: true)
!10 = !DIEnumerator(name: "XDP_DROP", value: 1, isUnsigned: true)
!11 = !DIEnumerator(name: "XDP_PASS", value: 2, isUnsigned: true)
!12 = !DIEnumerator(name: "XDP_TX", value: 3, isUnsigned: true)
!13 = !DIEnumerator(name: "XDP_REDIRECT", value: 4, isUnsigned: true)
!14 = !DICompositeType(tag: DW_TAG_enumeration_type, file: !15, line: 28, baseType: !7, size: 32, elements: !16)
!15 = !DIFile(filename: "/usr/include/linux/in.h", directory: "")
!16 = !{!17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42}
!17 = !DIEnumerator(name: "IPPROTO_IP", value: 0, isUnsigned: true)
!18 = !DIEnumerator(name: "IPPROTO_ICMP", value: 1, isUnsigned: true)
!19 = !DIEnumerator(name: "IPPROTO_IGMP", value: 2, isUnsigned: true)
!20 = !DIEnumerator(name: "IPPROTO_IPIP", value: 4, isUnsigned: true)
!21 = !DIEnumerator(name: "IPPROTO_TCP", value: 6, isUnsigned: true)
!22 = !DIEnumerator(name: "IPPROTO_EGP", value: 8, isUnsigned: true)
!23 = !DIEnumerator(name: "IPPROTO_PUP", value: 12, isUnsigned: true)
!24 = !DIEnumerator(name: "IPPROTO_UDP", value: 17, isUnsigned: true)
!25 = !DIEnumerator(name: "IPPROTO_IDP", value: 22, isUnsigned: true)
!26 = !DIEnumerator(name: "IPPROTO_TP", value: 29, isUnsigned: true)
!27 = !DIEnumerator(name: "IPPROTO_DCCP", value: 33, isUnsigned: true)
!28 = !DIEnumerator(name: "IPPROTO_IPV6", value: 41, isUnsigned: true)
!29 = !DIEnumerator(name: "IPPROTO_RSVP", value: 46, isUnsigned: true)
!30 = !DIEnumerator(name: "IPPROTO_GRE", value: 47, isUnsigned: true)
!31 = !DIEnumerator(name: "IPPROTO_ESP", value: 50, isUnsigned: true)
!32 = !DIEnumerator(name: "IPPROTO_AH", value: 51, isUnsigned: true)
!33 = !DIEnumerator(name: "IPPROTO_MTP", value: 92, isUnsigned: true)
!34 = !DIEnumerator(name: "IPPROTO_BEETPH", value: 94, isUnsigned: true)
!35 = !DIEnumerator(name: "IPPROTO_ENCAP", value: 98, isUnsigned: true)
!36 = !DIEnumerator(name: "IPPROTO_PIM", value: 103, isUnsigned: true)
!37 = !DIEnumerator(name: "IPPROTO_COMP", value: 108, isUnsigned: true)
!38 = !DIEnumerator(name: "IPPROTO_SCTP", value: 132, isUnsigned: true)
!39 = !DIEnumerator(name: "IPPROTO_UDPLITE", value: 136, isUnsigned: true)
!40 = !DIEnumerator(name: "IPPROTO_MPLS", value: 137, isUnsigned: true)
!41 = !DIEnumerator(name: "IPPROTO_RAW", value: 255, isUnsigned: true)
!42 = !DIEnumerator(name: "IPPROTO_MAX", value: 256, isUnsigned: true)
!43 = !{!44, !45, !46, !48, !51, !60, !61}
!44 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!45 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!46 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !47, line: 25, baseType: !48)
!47 = !DIFile(filename: "/usr/include/linux/types.h", directory: "")
!48 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !49, line: 24, baseType: !50)
!49 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!50 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!51 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !52, size: 64)
!52 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "udphdr", file: !53, line: 23, size: 64, elements: !54)
!53 = !DIFile(filename: "/usr/include/linux/udp.h", directory: "")
!54 = !{!55, !56, !57, !58}
!55 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !52, file: !53, line: 24, baseType: !46, size: 16)
!56 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !52, file: !53, line: 25, baseType: !46, size: 16, offset: 16)
!57 = !DIDerivedType(tag: DW_TAG_member, name: "len", scope: !52, file: !53, line: 26, baseType: !46, size: 16, offset: 32)
!58 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !52, file: !53, line: 27, baseType: !59, size: 16, offset: 48)
!59 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !47, line: 31, baseType: !48)
!60 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !47, line: 27, baseType: !61)
!61 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !49, line: 27, baseType: !7)
!62 = !{!0, !63, !73, !79, !87}
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression())
!64 = distinct !DIGlobalVariable(name: "xdp_stats_map", scope: !2, file: !3, line: 43, type: !65, isLocal: false, isDefinition: true)
!65 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !66, line: 36, size: 160, elements: !67)
!66 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!67 = !{!68, !69, !70, !71, !72}
!68 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !65, file: !66, line: 37, baseType: !7, size: 32)
!69 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !65, file: !66, line: 38, baseType: !7, size: 32, offset: 32)
!70 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !65, file: !66, line: 39, baseType: !7, size: 32, offset: 64)
!71 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !65, file: !66, line: 40, baseType: !7, size: 32, offset: 96)
!72 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !65, file: !66, line: 41, baseType: !7, size: 32, offset: 128)
!73 = !DIGlobalVariableExpression(var: !74, expr: !DIExpression())
!74 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 178, type: !75, isLocal: false, isDefinition: true)
!75 = !DICompositeType(tag: DW_TAG_array_type, baseType: !76, size: 32, elements: !77)
!76 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!77 = !{!78}
!78 = !DISubrange(count: 4)
!79 = !DIGlobalVariableExpression(var: !80, expr: !DIExpression())
!80 = distinct !DIGlobalVariable(name: "bpf_map_lookup_elem", scope: !2, file: !81, line: 33, type: !82, isLocal: true, isDefinition: true)
!81 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "")
!82 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !83, size: 64)
!83 = !DISubroutineType(types: !84)
!84 = !{!44, !44, !85}
!85 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !86, size: 64)
!86 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!87 = !DIGlobalVariableExpression(var: !88, expr: !DIExpression())
!88 = distinct !DIGlobalVariable(name: "bpf_redirect_map", scope: !2, file: !81, line: 1252, type: !89, isLocal: true, isDefinition: true)
!89 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !90, size: 64)
!90 = !DISubroutineType(types: !91)
!91 = !{!92, !44, !61, !93}
!92 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!93 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !49, line: 31, baseType: !94)
!94 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!95 = !{i32 2, !"Dwarf Version", i32 4}
!96 = !{i32 2, !"Debug Info Version", i32 3}
!97 = !{i32 1, !"wchar_size", i32 4}
!98 = !{!"clang version 8.0.0 (Fedora 8.0.0-3.fc30)"}
!99 = distinct !DISubprogram(name: "xdp_sock_prog", scope: !3, file: !3, line: 53, type: !100, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !110)
!100 = !DISubroutineType(types: !101)
!101 = !{!92, !102}
!102 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 64)
!103 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 2856, size: 160, elements: !104)
!104 = !{!105, !106, !107, !108, !109}
!105 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !103, file: !6, line: 2857, baseType: !61, size: 32)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !103, file: !6, line: 2858, baseType: !61, size: 32, offset: 32)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !103, file: !6, line: 2859, baseType: !61, size: 32, offset: 64)
!108 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !103, file: !6, line: 2861, baseType: !61, size: 32, offset: 96)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !103, file: !6, line: 2862, baseType: !61, size: 32, offset: 128)
!110 = !{!111, !112, !113}
!111 = !DILocalVariable(name: "ctx", arg: 1, scope: !99, file: !3, line: 53, type: !102)
!112 = !DILocalVariable(name: "index", scope: !99, file: !3, line: 55, type: !92)
!113 = !DILocalVariable(name: "pkt_count", scope: !99, file: !3, line: 56, type: !114)
!114 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !61, size: 64)
!115 = !DILocation(line: 53, column: 34, scope: !99)
!116 = !DILocation(line: 55, column: 5, scope: !99)
!117 = !DILocation(line: 55, column: 22, scope: !99)
!118 = !{!119, !120, i64 16}
!119 = !{!"xdp_md", !120, i64 0, !120, i64 4, !120, i64 8, !120, i64 12, !120, i64 16}
!120 = !{!"int", !121, i64 0}
!121 = !{!"omnipotent char", !122, i64 0}
!122 = !{!"Simple C/C++ TBAA"}
!123 = !DILocation(line: 55, column: 9, scope: !99)
!124 = !{!120, !120, i64 0}
!125 = !DILocation(line: 58, column: 17, scope: !99)
!126 = !DILocation(line: 56, column: 12, scope: !99)
!127 = !DILocation(line: 59, column: 9, scope: !128)
!128 = distinct !DILexicalBlock(scope: !99, file: !3, line: 59, column: 9)
!129 = !DILocation(line: 59, column: 9, scope: !99)
!130 = !DILocation(line: 62, column: 25, scope: !131)
!131 = distinct !DILexicalBlock(scope: !132, file: !3, line: 62, column: 13)
!132 = distinct !DILexicalBlock(scope: !128, file: !3, line: 59, column: 20)
!133 = !DILocation(line: 62, column: 28, scope: !131)
!134 = !DILocation(line: 62, column: 13, scope: !132)
!135 = !DILocation(line: 68, column: 9, scope: !136)
!136 = distinct !DILexicalBlock(scope: !99, file: !3, line: 68, column: 9)
!137 = !DILocation(line: 68, column: 9, scope: !99)
!138 = !DILocation(line: 69, column: 44, scope: !136)
!139 = !DILocation(line: 69, column: 16, scope: !136)
!140 = !DILocation(line: 69, column: 9, scope: !136)
!141 = !DILocation(line: 0, scope: !99)
!142 = !DILocation(line: 72, column: 1, scope: !99)
!143 = distinct !DISubprogram(name: "xdp_filter_func", scope: !3, file: !3, line: 80, type: !100, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !144)
!144 = !{!145, !146, !147, !148, !156, !157, !158, !170, !171, !172, !174, !184, !203, !204, !238}
!145 = !DILocalVariable(name: "ctx", arg: 1, scope: !143, file: !3, line: 80, type: !102)
!146 = !DILocalVariable(name: "index", scope: !143, file: !3, line: 83, type: !92)
!147 = !DILocalVariable(name: "key", scope: !143, file: !3, line: 84, type: !92)
!148 = !DILocalVariable(name: "rec", scope: !143, file: !3, line: 85, type: !149)
!149 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !150, size: 64)
!150 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "datarec", file: !151, line: 2, size: 128, elements: !152)
!151 = !DIFile(filename: "./common_defs.h", directory: "/root/bpftest/advanced03-AF_XDP")
!152 = !{!153, !154, !155}
!153 = !DIDerivedType(tag: DW_TAG_member, name: "rx_packets", scope: !150, file: !151, line: 3, baseType: !93, size: 64)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !150, file: !151, line: 4, baseType: !61, size: 32, offset: 64)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !150, file: !151, line: 5, baseType: !61, size: 32, offset: 96)
!156 = !DILocalVariable(name: "data_end", scope: !143, file: !3, line: 94, type: !44)
!157 = !DILocalVariable(name: "data", scope: !143, file: !3, line: 95, type: !44)
!158 = !DILocalVariable(name: "eth", scope: !143, file: !3, line: 96, type: !159)
!159 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !160, size: 64)
!160 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !161, line: 163, size: 112, elements: !162)
!161 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "")
!162 = !{!163, !168, !169}
!163 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !160, file: !161, line: 164, baseType: !164, size: 48)
!164 = !DICompositeType(tag: DW_TAG_array_type, baseType: !165, size: 48, elements: !166)
!165 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!166 = !{!167}
!167 = !DISubrange(count: 6)
!168 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !160, file: !161, line: 165, baseType: !164, size: 48, offset: 48)
!169 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !160, file: !161, line: 166, baseType: !46, size: 16, offset: 96)
!170 = !DILocalVariable(name: "addr_off", scope: !143, file: !3, line: 99, type: !93)
!171 = !DILocalVariable(name: "h_proto", scope: !143, file: !3, line: 105, type: !93)
!172 = !DILocalVariable(name: "i", scope: !173, file: !3, line: 108, type: !92)
!173 = distinct !DILexicalBlock(scope: !143, file: !3, line: 108, column: 5)
!174 = !DILocalVariable(name: "vhdr", scope: !175, file: !3, line: 110, type: !179)
!175 = distinct !DILexicalBlock(scope: !176, file: !3, line: 109, column: 77)
!176 = distinct !DILexicalBlock(scope: !177, file: !3, line: 109, column: 13)
!177 = distinct !DILexicalBlock(scope: !178, file: !3, line: 108, column: 31)
!178 = distinct !DILexicalBlock(scope: !173, file: !3, line: 108, column: 5)
!179 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !180, size: 64)
!180 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "vlan_hdr", file: !3, line: 74, size: 32, elements: !181)
!181 = !{!182, !183}
!182 = !DIDerivedType(tag: DW_TAG_member, name: "h_vlan_TCI", scope: !180, file: !3, line: 75, baseType: !46, size: 16)
!183 = !DIDerivedType(tag: DW_TAG_member, name: "h_vlan_encapsulated_proto", scope: !180, file: !3, line: 76, baseType: !46, size: 16, offset: 16)
!184 = !DILocalVariable(name: "iph", scope: !185, file: !3, line: 122, type: !187)
!185 = distinct !DILexicalBlock(scope: !186, file: !3, line: 121, column: 36)
!186 = distinct !DILexicalBlock(scope: !143, file: !3, line: 121, column: 9)
!187 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !188, size: 64)
!188 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !189, line: 86, size: 160, elements: !190)
!189 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "")
!190 = !{!191, !193, !194, !195, !196, !197, !198, !199, !200, !201, !202}
!191 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !188, file: !189, line: 88, baseType: !192, size: 4, flags: DIFlagBitField, extraData: i64 0)
!192 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !49, line: 21, baseType: !165)
!193 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !188, file: !189, line: 89, baseType: !192, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!194 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !188, file: !189, line: 96, baseType: !192, size: 8, offset: 8)
!195 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !188, file: !189, line: 97, baseType: !46, size: 16, offset: 16)
!196 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !188, file: !189, line: 98, baseType: !46, size: 16, offset: 32)
!197 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !188, file: !189, line: 99, baseType: !46, size: 16, offset: 48)
!198 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !188, file: !189, line: 100, baseType: !192, size: 8, offset: 64)
!199 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !188, file: !189, line: 101, baseType: !192, size: 8, offset: 72)
!200 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !188, file: !189, line: 102, baseType: !59, size: 16, offset: 80)
!201 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !188, file: !189, line: 103, baseType: !60, size: 32, offset: 96)
!202 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !188, file: !189, line: 104, baseType: !60, size: 32, offset: 128)
!203 = !DILocalVariable(name: "udph", scope: !185, file: !3, line: 123, type: !51)
!204 = !DILocalVariable(name: "ipv6h", scope: !205, file: !3, line: 140, type: !207)
!205 = distinct !DILexicalBlock(scope: !206, file: !3, line: 139, column: 43)
!206 = distinct !DILexicalBlock(scope: !186, file: !3, line: 139, column: 14)
!207 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !208, size: 64)
!208 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ipv6hdr", file: !209, line: 116, size: 320, elements: !210)
!209 = !DIFile(filename: "/usr/include/linux/ipv6.h", directory: "")
!210 = !{!211, !212, !213, !217, !218, !219, !220, !237}
!211 = !DIDerivedType(tag: DW_TAG_member, name: "priority", scope: !208, file: !209, line: 118, baseType: !192, size: 4, flags: DIFlagBitField, extraData: i64 0)
!212 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !208, file: !209, line: 119, baseType: !192, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!213 = !DIDerivedType(tag: DW_TAG_member, name: "flow_lbl", scope: !208, file: !209, line: 126, baseType: !214, size: 24, offset: 8)
!214 = !DICompositeType(tag: DW_TAG_array_type, baseType: !192, size: 24, elements: !215)
!215 = !{!216}
!216 = !DISubrange(count: 3)
!217 = !DIDerivedType(tag: DW_TAG_member, name: "payload_len", scope: !208, file: !209, line: 128, baseType: !46, size: 16, offset: 32)
!218 = !DIDerivedType(tag: DW_TAG_member, name: "nexthdr", scope: !208, file: !209, line: 129, baseType: !192, size: 8, offset: 48)
!219 = !DIDerivedType(tag: DW_TAG_member, name: "hop_limit", scope: !208, file: !209, line: 130, baseType: !192, size: 8, offset: 56)
!220 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !208, file: !209, line: 132, baseType: !221, size: 128, offset: 64)
!221 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in6_addr", file: !222, line: 33, size: 128, elements: !223)
!222 = !DIFile(filename: "/usr/include/linux/in6.h", directory: "")
!223 = !{!224}
!224 = !DIDerivedType(tag: DW_TAG_member, name: "in6_u", scope: !221, file: !222, line: 40, baseType: !225, size: 128)
!225 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !221, file: !222, line: 34, size: 128, elements: !226)
!226 = !{!227, !231, !235}
!227 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr8", scope: !225, file: !222, line: 35, baseType: !228, size: 128)
!228 = !DICompositeType(tag: DW_TAG_array_type, baseType: !192, size: 128, elements: !229)
!229 = !{!230}
!230 = !DISubrange(count: 16)
!231 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr16", scope: !225, file: !222, line: 37, baseType: !232, size: 128)
!232 = !DICompositeType(tag: DW_TAG_array_type, baseType: !46, size: 128, elements: !233)
!233 = !{!234}
!234 = !DISubrange(count: 8)
!235 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr32", scope: !225, file: !222, line: 38, baseType: !236, size: 128)
!236 = !DICompositeType(tag: DW_TAG_array_type, baseType: !60, size: 128, elements: !77)
!237 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !208, file: !209, line: 133, baseType: !221, size: 128, offset: 192)
!238 = !DILocalVariable(name: "udph", scope: !205, file: !3, line: 141, type: !51)
!239 = !DILocation(line: 80, column: 36, scope: !143)
!240 = !DILocation(line: 83, column: 5, scope: !143)
!241 = !DILocation(line: 83, column: 22, scope: !143)
!242 = !DILocation(line: 83, column: 9, scope: !143)
!243 = !DILocation(line: 84, column: 5, scope: !143)
!244 = !DILocation(line: 84, column: 9, scope: !143)
!245 = !DILocation(line: 85, column: 27, scope: !143)
!246 = !DILocation(line: 85, column: 21, scope: !143)
!247 = !DILocation(line: 87, column: 10, scope: !248)
!248 = distinct !DILexicalBlock(scope: !143, file: !3, line: 87, column: 9)
!249 = !DILocation(line: 87, column: 9, scope: !143)
!250 = !DILocation(line: 90, column: 14, scope: !251)
!251 = distinct !DILexicalBlock(scope: !143, file: !3, line: 90, column: 9)
!252 = !{!253, !120, i64 8}
!253 = !{!"datarec", !254, i64 0, !120, i64 8, !120, i64 12}
!254 = !{!"long long", !121, i64 0}
!255 = !DILocation(line: 90, column: 20, scope: !251)
!256 = !DILocation(line: 90, column: 9, scope: !143)
!257 = !DILocation(line: 91, column: 20, scope: !251)
!258 = !DILocation(line: 91, column: 9, scope: !251)
!259 = !DILocation(line: 94, column: 41, scope: !143)
!260 = !{!119, !120, i64 4}
!261 = !DILocation(line: 94, column: 30, scope: !143)
!262 = !DILocation(line: 94, column: 22, scope: !143)
!263 = !DILocation(line: 94, column: 11, scope: !143)
!264 = !DILocation(line: 95, column: 37, scope: !143)
!265 = !{!119, !120, i64 0}
!266 = !DILocation(line: 95, column: 26, scope: !143)
!267 = !DILocation(line: 95, column: 18, scope: !143)
!268 = !DILocation(line: 95, column: 11, scope: !143)
!269 = !DILocation(line: 99, column: 11, scope: !143)
!270 = !DILocation(line: 100, column: 14, scope: !271)
!271 = distinct !DILexicalBlock(scope: !143, file: !3, line: 100, column: 9)
!272 = !DILocation(line: 100, column: 25, scope: !271)
!273 = !DILocation(line: 100, column: 9, scope: !143)
!274 = !DILocation(line: 101, column: 9, scope: !275)
!275 = distinct !DILexicalBlock(scope: !271, file: !3, line: 100, column: 36)
!276 = !DILocation(line: 102, column: 9, scope: !275)
!277 = !DILocation(line: 96, column: 26, scope: !143)
!278 = !DILocation(line: 96, column: 20, scope: !143)
!279 = !DILocation(line: 105, column: 26, scope: !143)
!280 = !{!281, !282, i64 12}
!281 = !{!"ethhdr", !121, i64 0, !121, i64 6, !282, i64 12}
!282 = !{!"short", !121, i64 0}
!283 = !DILocation(line: 108, column: 13, scope: !173)
!284 = !DILocation(line: 109, column: 43, scope: !176)
!285 = !DILocation(line: 112, column: 22, scope: !286)
!286 = distinct !DILexicalBlock(scope: !175, file: !3, line: 112, column: 17)
!287 = !DILocation(line: 112, column: 33, scope: !286)
!288 = !DILocation(line: 112, column: 17, scope: !175)
!289 = !DILocation(line: 110, column: 30, scope: !175)
!290 = !DILocation(line: 116, column: 29, scope: !175)
!291 = !{!292, !282, i64 2}
!292 = !{!"vlan_hdr", !282, i64 0, !282, i64 2}
!293 = !DILocation(line: 105, column: 11, scope: !143)
!294 = !DILocation(line: 0, scope: !143)
!295 = !DILocation(line: 113, column: 17, scope: !296)
!296 = distinct !DILexicalBlock(scope: !286, file: !3, line: 112, column: 44)
!297 = !DILocation(line: 122, column: 34, scope: !185)
!298 = !DILocation(line: 123, column: 47, scope: !185)
!299 = !DILocation(line: 123, column: 24, scope: !185)
!300 = !DILocation(line: 124, column: 18, scope: !301)
!301 = distinct !DILexicalBlock(scope: !185, file: !3, line: 124, column: 13)
!302 = !DILocation(line: 124, column: 24, scope: !301)
!303 = !DILocation(line: 124, column: 22, scope: !301)
!304 = !DILocation(line: 124, column: 13, scope: !185)
!305 = !DILocation(line: 125, column: 13, scope: !306)
!306 = distinct !DILexicalBlock(scope: !301, file: !3, line: 124, column: 50)
!307 = !DILocation(line: 126, column: 13, scope: !306)
!308 = !DILocation(line: 122, column: 23, scope: !185)
!309 = !DILocation(line: 128, column: 22, scope: !185)
!310 = !{!311, !120, i64 12}
!311 = !{!"iphdr", !121, i64 0, !121, i64 0, !121, i64 1, !282, i64 2, !282, i64 4, !282, i64 6, !121, i64 8, !121, i64 9, !282, i64 10, !120, i64 12, !120, i64 16}
!312 = !DILocation(line: 128, column: 20, scope: !185)
!313 = !DILocation(line: 131, column: 18, scope: !314)
!314 = distinct !DILexicalBlock(scope: !185, file: !3, line: 131, column: 13)
!315 = !{!311, !121, i64 9}
!316 = !DILocation(line: 131, column: 27, scope: !314)
!317 = !DILocation(line: 133, column: 35, scope: !314)
!318 = !DILocation(line: 133, column: 49, scope: !314)
!319 = !DILocation(line: 133, column: 13, scope: !314)
!320 = !DILocation(line: 134, column: 22, scope: !314)
!321 = !{!322, !282, i64 2}
!322 = !{!"udphdr", !282, i64 0, !282, i64 2, !282, i64 4, !282, i64 6}
!323 = !DILocation(line: 134, column: 27, scope: !314)
!324 = !DILocation(line: 131, column: 13, scope: !185)
!325 = !DILocation(line: 135, column: 19, scope: !326)
!326 = distinct !DILexicalBlock(scope: !314, file: !3, line: 134, column: 44)
!327 = !DILocation(line: 135, column: 30, scope: !326)
!328 = !{!253, !254, i64 0}
!329 = !DILocation(line: 136, column: 7, scope: !326)
!330 = !DILocation(line: 140, column: 39, scope: !205)
!331 = !DILocation(line: 140, column: 26, scope: !205)
!332 = !DILocation(line: 141, column: 48, scope: !205)
!333 = !DILocation(line: 141, column: 25, scope: !205)
!334 = !DILocation(line: 142, column: 18, scope: !335)
!335 = distinct !DILexicalBlock(scope: !205, file: !3, line: 142, column: 13)
!336 = !DILocation(line: 142, column: 24, scope: !335)
!337 = !DILocation(line: 142, column: 22, scope: !335)
!338 = !DILocation(line: 142, column: 13, scope: !205)
!339 = !DILocation(line: 145, column: 20, scope: !340)
!340 = distinct !DILexicalBlock(scope: !205, file: !3, line: 145, column: 13)
!341 = !{!342, !121, i64 6}
!342 = !{!"ipv6hdr", !121, i64 0, !121, i64 0, !121, i64 1, !282, i64 4, !121, i64 6, !121, i64 7, !343, i64 8, !343, i64 24}
!343 = !{!"in6_addr", !121, i64 0}
!344 = !DILocation(line: 145, column: 28, scope: !340)
!345 = !DILocation(line: 146, column: 13, scope: !340)
!346 = !DILocation(line: 146, column: 23, scope: !340)
!347 = !DILocation(line: 146, column: 16, scope: !340)
!348 = !{!121, !121, i64 0}
!349 = !DILocation(line: 146, column: 40, scope: !340)
!350 = !DILocation(line: 147, column: 13, scope: !340)
!351 = !DILocation(line: 147, column: 16, scope: !340)
!352 = !DILocation(line: 147, column: 40, scope: !340)
!353 = !DILocation(line: 148, column: 13, scope: !340)
!354 = !DILocation(line: 148, column: 22, scope: !340)
!355 = !DILocation(line: 148, column: 27, scope: !340)
!356 = !DILocation(line: 145, column: 13, scope: !205)
!357 = !DILocation(line: 154, column: 5, scope: !143)
!358 = !DILocation(line: 171, column: 9, scope: !359)
!359 = distinct !DILexicalBlock(scope: !143, file: !3, line: 171, column: 9)
!360 = !DILocation(line: 171, column: 9, scope: !143)
!361 = !DILocation(line: 172, column: 44, scope: !359)
!362 = !DILocation(line: 172, column: 16, scope: !359)
!363 = !DILocation(line: 172, column: 9, scope: !359)
!364 = !DILocation(line: 176, column: 1, scope: !143)
!365 = !DILocation(line: 111, column: 22, scope: !175)
!366 = !DILocation(line: 121, column: 9, scope: !143)
