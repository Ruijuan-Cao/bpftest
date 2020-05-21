; ModuleID = 'xdp_prog_kern.c'
source_filename = "xdp_prog_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.udphdr = type { i16, i16, i16, i16 }

@xdp_stats_map = dso_local global %struct.bpf_map_def { i32 2, i32 4, i32 16, i32 5, i32 0 }, section "maps", align 4, !dbg !0
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !26
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_stats1_func to i8*), i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @xdp_stats1_func(%struct.xdp_md* nocapture readonly) #0 section "xdp_stats1" !dbg !52 {
  %2 = alloca i32, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !66, metadata !DIExpression()), !dbg !113
  %3 = bitcast i32* %2 to i8*, !dbg !114
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #3, !dbg !114
  call void @llvm.dbg.value(metadata i32 2, metadata !76, metadata !DIExpression()), !dbg !113
  store i32 2, i32* %2, align 4, !dbg !115, !tbaa !116
  %4 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*), i8* nonnull %3) #3, !dbg !120
  call void @llvm.dbg.value(metadata i8* %4, metadata !67, metadata !DIExpression()), !dbg !113
  %5 = icmp eq i8* %4, null, !dbg !121
  br i1 %5, label %48, label %6, !dbg !123

6:                                                ; preds = %1
  %7 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !124
  %8 = load i32, i32* %7, align 4, !dbg !124, !tbaa !125
  %9 = zext i32 %8 to i64, !dbg !127
  %10 = inttoptr i64 %9 to i8*, !dbg !128
  call void @llvm.dbg.value(metadata i8* %10, metadata !77, metadata !DIExpression()), !dbg !113
  %11 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !129
  %12 = load i32, i32* %11, align 4, !dbg !129, !tbaa !130
  %13 = zext i32 %12 to i64, !dbg !131
  %14 = inttoptr i64 %13 to i8*, !dbg !132
  call void @llvm.dbg.value(metadata i8* %14, metadata !78, metadata !DIExpression()), !dbg !113
  call void @llvm.dbg.value(metadata i8* %14, metadata !79, metadata !DIExpression()), !dbg !113
  call void @llvm.dbg.value(metadata i64 14, metadata !91, metadata !DIExpression()), !dbg !113
  %15 = getelementptr i8, i8* %14, i64 14, !dbg !133
  %16 = icmp ugt i8* %15, %10, !dbg !135
  br i1 %16, label %48, label %17, !dbg !136

17:                                               ; preds = %6
  %18 = inttoptr i64 %13 to %struct.ethhdr*, !dbg !137
  call void @llvm.dbg.value(metadata %struct.ethhdr* %18, metadata !79, metadata !DIExpression()), !dbg !113
  %19 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %18, i64 0, i32 2, !dbg !138
  %20 = load i16, i16* %19, align 1, !dbg !138, !tbaa !139
  call void @llvm.dbg.value(metadata i16 %20, metadata !92, metadata !DIExpression()), !dbg !113
  %21 = icmp eq i16 %20, 8, !dbg !142
  br i1 %21, label %22, label %48, !dbg !143

22:                                               ; preds = %17
  call void @llvm.dbg.value(metadata i8* %15, metadata !93, metadata !DIExpression()), !dbg !144
  call void @llvm.dbg.value(metadata i8* %14, metadata !112, metadata !DIExpression(DW_OP_plus_uconst, 34, DW_OP_stack_value)), !dbg !144
  %23 = getelementptr inbounds i8, i8* %14, i64 42, !dbg !145
  %24 = bitcast i8* %23 to %struct.udphdr*, !dbg !145
  %25 = inttoptr i64 %9 to %struct.udphdr*, !dbg !147
  %26 = icmp ugt %struct.udphdr* %24, %25, !dbg !148
  br i1 %26, label %48, label %27, !dbg !149

27:                                               ; preds = %22
  %28 = getelementptr inbounds i8, i8* %14, i64 23, !dbg !150
  %29 = load i8, i8* %28, align 1, !dbg !150, !tbaa !152
  %30 = icmp eq i8 %29, 17, !dbg !154
  br i1 %30, label %31, label %48, !dbg !155

31:                                               ; preds = %27
  %32 = getelementptr inbounds i8, i8* %14, i64 26, !dbg !156
  %33 = bitcast i8* %32 to i32*, !dbg !156
  %34 = load i32, i32* %33, align 4, !dbg !156, !tbaa !159
  %35 = call i32 @llvm.bswap.i32(i32 %34), !dbg !156
  %36 = and i32 %35, -256, !dbg !160
  %37 = icmp eq i32 %36, -1062673664, !dbg !161
  br i1 %37, label %38, label %48, !dbg !162

38:                                               ; preds = %31
  %39 = getelementptr inbounds i8, i8* %14, i64 36, !dbg !163
  %40 = bitcast i8* %39 to i16*, !dbg !163
  %41 = load i16, i16* %40, align 2, !dbg !163, !tbaa !164
  %42 = icmp eq i16 %41, 14640, !dbg !166
  br i1 %42, label %43, label %48, !dbg !167

43:                                               ; preds = %38
  %44 = getelementptr inbounds i8, i8* %4, i64 8, !dbg !168
  %45 = bitcast i8* %44 to i32*, !dbg !168
  store i32 %35, i32* %45, align 8, !dbg !170, !tbaa !171
  %46 = bitcast i8* %4 to i64*, !dbg !174
  %47 = atomicrmw add i64* %46, i64 1 seq_cst, !dbg !174
  br label %48, !dbg !175

48:                                               ; preds = %6, %22, %17, %27, %43, %38, %31, %1
  %49 = phi i32 [ 0, %1 ], [ 2, %31 ], [ 2, %38 ], [ 2, %43 ], [ 2, %27 ], [ 2, %17 ], [ 2, %22 ], [ 2, %6 ], !dbg !113
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #3, !dbg !176
  ret i32 %49, !dbg !176
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

; Function Attrs: nounwind readnone speculatable
declare i32 @llvm.bswap.i32(i32) #2

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind readnone speculatable }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!48, !49, !50}
!llvm.ident = !{!51}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "xdp_stats_map", scope: !2, file: !3, line: 21, type: !40, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1 (Fedora 9.0.1-2.fc31)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !5, globals: !25, nameTableKind: None)
!3 = !DIFile(filename: "xdp_prog_kern.c", directory: "/root/bpftest/basic03-map-counter")
!4 = !{}
!5 = !{!6, !7, !8, !10, !13, !22, !23}
!6 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!7 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!8 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !9, line: 25, baseType: !10)
!9 = !DIFile(filename: "/usr/include/linux/types.h", directory: "")
!10 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !11, line: 24, baseType: !12)
!11 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!12 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!13 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !14, size: 64)
!14 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "udphdr", file: !15, line: 23, size: 64, elements: !16)
!15 = !DIFile(filename: "/usr/include/linux/udp.h", directory: "")
!16 = !{!17, !18, !19, !20}
!17 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !14, file: !15, line: 24, baseType: !8, size: 16)
!18 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !14, file: !15, line: 25, baseType: !8, size: 16, offset: 16)
!19 = !DIDerivedType(tag: DW_TAG_member, name: "len", scope: !14, file: !15, line: 26, baseType: !8, size: 16, offset: 32)
!20 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !14, file: !15, line: 27, baseType: !21, size: 16, offset: 48)
!21 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !9, line: 31, baseType: !10)
!22 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !9, line: 27, baseType: !23)
!23 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !11, line: 27, baseType: !24)
!24 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!25 = !{!0, !26, !32}
!26 = !DIGlobalVariableExpression(var: !27, expr: !DIExpression())
!27 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 99, type: !28, isLocal: false, isDefinition: true)
!28 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 32, elements: !30)
!29 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!30 = !{!31}
!31 = !DISubrange(count: 4)
!32 = !DIGlobalVariableExpression(var: !33, expr: !DIExpression())
!33 = distinct !DIGlobalVariable(name: "bpf_map_lookup_elem", scope: !2, file: !34, line: 33, type: !35, isLocal: true, isDefinition: true)
!34 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "")
!35 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !36, size: 64)
!36 = !DISubroutineType(types: !37)
!37 = !{!6, !6, !38}
!38 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !39, size: 64)
!39 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!40 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !41, line: 36, size: 160, elements: !42)
!41 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!42 = !{!43, !44, !45, !46, !47}
!43 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !40, file: !41, line: 37, baseType: !24, size: 32)
!44 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !40, file: !41, line: 38, baseType: !24, size: 32, offset: 32)
!45 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !40, file: !41, line: 39, baseType: !24, size: 32, offset: 64)
!46 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !40, file: !41, line: 40, baseType: !24, size: 32, offset: 96)
!47 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !40, file: !41, line: 41, baseType: !24, size: 32, offset: 128)
!48 = !{i32 2, !"Dwarf Version", i32 4}
!49 = !{i32 2, !"Debug Info Version", i32 3}
!50 = !{i32 1, !"wchar_size", i32 4}
!51 = !{!"clang version 9.0.1 (Fedora 9.0.1-2.fc31)"}
!52 = distinct !DISubprogram(name: "xdp_stats1_func", scope: !3, file: !3, line: 36, type: !53, scopeLine: 37, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !65)
!53 = !DISubroutineType(types: !54)
!54 = !{!55, !56}
!55 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!56 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !57, size: 64)
!57 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !58, line: 2856, size: 160, elements: !59)
!58 = !DIFile(filename: "../headers/linux/bpf.h", directory: "/root/bpftest/basic03-map-counter")
!59 = !{!60, !61, !62, !63, !64}
!60 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !57, file: !58, line: 2857, baseType: !23, size: 32)
!61 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !57, file: !58, line: 2858, baseType: !23, size: 32, offset: 32)
!62 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !57, file: !58, line: 2859, baseType: !23, size: 32, offset: 64)
!63 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !57, file: !58, line: 2861, baseType: !23, size: 32, offset: 96)
!64 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !57, file: !58, line: 2862, baseType: !23, size: 32, offset: 128)
!65 = !{!66, !67, !76, !77, !78, !79, !91, !92, !93, !112}
!66 = !DILocalVariable(name: "ctx", arg: 1, scope: !52, file: !3, line: 36, type: !56)
!67 = !DILocalVariable(name: "rec", scope: !52, file: !3, line: 40, type: !68)
!68 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !69, size: 64)
!69 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "datarec", file: !70, line: 8, size: 128, elements: !71)
!70 = !DIFile(filename: "./common_kern_user.h", directory: "/root/bpftest/basic03-map-counter")
!71 = !{!72, !75}
!72 = !DIDerivedType(tag: DW_TAG_member, name: "rx_packets", scope: !69, file: !70, line: 9, baseType: !73, size: 64)
!73 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !11, line: 31, baseType: !74)
!74 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!75 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !69, file: !70, line: 10, baseType: !23, size: 32, offset: 64)
!76 = !DILocalVariable(name: "key", scope: !52, file: !3, line: 41, type: !23)
!77 = !DILocalVariable(name: "data_end", scope: !52, file: !3, line: 56, type: !6)
!78 = !DILocalVariable(name: "data", scope: !52, file: !3, line: 57, type: !6)
!79 = !DILocalVariable(name: "eth", scope: !52, file: !3, line: 58, type: !80)
!80 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !81, size: 64)
!81 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !82, line: 163, size: 112, elements: !83)
!82 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "")
!83 = !{!84, !89, !90}
!84 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !81, file: !82, line: 164, baseType: !85, size: 48)
!85 = !DICompositeType(tag: DW_TAG_array_type, baseType: !86, size: 48, elements: !87)
!86 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!87 = !{!88}
!88 = !DISubrange(count: 6)
!89 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !81, file: !82, line: 165, baseType: !85, size: 48, offset: 48)
!90 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !81, file: !82, line: 166, baseType: !8, size: 16, offset: 96)
!91 = !DILocalVariable(name: "nh_off", scope: !52, file: !3, line: 60, type: !73)
!92 = !DILocalVariable(name: "h_proto", scope: !52, file: !3, line: 65, type: !73)
!93 = !DILocalVariable(name: "iph", scope: !94, file: !3, line: 68, type: !96)
!94 = distinct !DILexicalBlock(scope: !95, file: !3, line: 67, column: 34)
!95 = distinct !DILexicalBlock(scope: !52, file: !3, line: 67, column: 6)
!96 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !97, size: 64)
!97 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !98, line: 86, size: 160, elements: !99)
!98 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "")
!99 = !{!100, !102, !103, !104, !105, !106, !107, !108, !109, !110, !111}
!100 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !97, file: !98, line: 88, baseType: !101, size: 4, flags: DIFlagBitField, extraData: i64 0)
!101 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !11, line: 21, baseType: !86)
!102 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !97, file: !98, line: 89, baseType: !101, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!103 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !97, file: !98, line: 96, baseType: !101, size: 8, offset: 8)
!104 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !97, file: !98, line: 97, baseType: !8, size: 16, offset: 16)
!105 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !97, file: !98, line: 98, baseType: !8, size: 16, offset: 32)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !97, file: !98, line: 99, baseType: !8, size: 16, offset: 48)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !97, file: !98, line: 100, baseType: !101, size: 8, offset: 64)
!108 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !97, file: !98, line: 101, baseType: !101, size: 8, offset: 72)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !97, file: !98, line: 102, baseType: !21, size: 16, offset: 80)
!110 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !97, file: !98, line: 103, baseType: !22, size: 32, offset: 96)
!111 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !97, file: !98, line: 104, baseType: !22, size: 32, offset: 128)
!112 = !DILocalVariable(name: "udph", scope: !94, file: !3, line: 70, type: !13)
!113 = !DILocation(line: 0, scope: !52)
!114 = !DILocation(line: 41, column: 2, scope: !52)
!115 = !DILocation(line: 41, column: 8, scope: !52)
!116 = !{!117, !117, i64 0}
!117 = !{!"int", !118, i64 0}
!118 = !{!"omnipotent char", !119, i64 0}
!119 = !{!"Simple C/C++ TBAA"}
!120 = !DILocation(line: 44, column: 8, scope: !52)
!121 = !DILocation(line: 49, column: 7, scope: !122)
!122 = distinct !DILexicalBlock(scope: !52, file: !3, line: 49, column: 6)
!123 = !DILocation(line: 49, column: 6, scope: !52)
!124 = !DILocation(line: 56, column: 37, scope: !52)
!125 = !{!126, !117, i64 4}
!126 = !{!"xdp_md", !117, i64 0, !117, i64 4, !117, i64 8, !117, i64 12, !117, i64 16}
!127 = !DILocation(line: 56, column: 26, scope: !52)
!128 = !DILocation(line: 56, column: 18, scope: !52)
!129 = !DILocation(line: 57, column: 41, scope: !52)
!130 = !{!126, !117, i64 0}
!131 = !DILocation(line: 57, column: 30, scope: !52)
!132 = !DILocation(line: 57, column: 22, scope: !52)
!133 = !DILocation(line: 61, column: 18, scope: !134)
!134 = distinct !DILexicalBlock(scope: !52, file: !3, line: 61, column: 13)
!135 = !DILocation(line: 61, column: 27, scope: !134)
!136 = !DILocation(line: 61, column: 13, scope: !52)
!137 = !DILocation(line: 58, column: 30, scope: !52)
!138 = !DILocation(line: 65, column: 30, scope: !52)
!139 = !{!140, !141, i64 12}
!140 = !{!"ethhdr", !118, i64 0, !118, i64 6, !141, i64 12}
!141 = !{!"short", !118, i64 0}
!142 = !DILocation(line: 67, column: 14, scope: !95)
!143 = !DILocation(line: 67, column: 6, scope: !52)
!144 = !DILocation(line: 0, scope: !94)
!145 = !DILocation(line: 71, column: 26, scope: !146)
!146 = distinct !DILexicalBlock(scope: !94, file: !3, line: 71, column: 21)
!147 = !DILocation(line: 71, column: 32, scope: !146)
!148 = !DILocation(line: 71, column: 30, scope: !146)
!149 = !DILocation(line: 71, column: 21, scope: !94)
!150 = !DILocation(line: 74, column: 26, scope: !151)
!151 = distinct !DILexicalBlock(scope: !94, file: !3, line: 74, column: 21)
!152 = !{!153, !118, i64 9}
!153 = !{!"iphdr", !118, i64 0, !118, i64 0, !118, i64 1, !141, i64 2, !141, i64 4, !141, i64 6, !118, i64 8, !118, i64 9, !141, i64 10, !117, i64 12, !117, i64 16}
!154 = !DILocation(line: 74, column: 35, scope: !151)
!155 = !DILocation(line: 74, column: 21, scope: !94)
!156 = !DILocation(line: 76, column: 7, scope: !157)
!157 = distinct !DILexicalBlock(scope: !158, file: !3, line: 76, column: 6)
!158 = distinct !DILexicalBlock(scope: !151, file: !3, line: 75, column: 2)
!159 = !{!153, !117, i64 12}
!160 = !DILocation(line: 76, column: 25, scope: !157)
!161 = !DILocation(line: 76, column: 39, scope: !157)
!162 = !DILocation(line: 76, column: 53, scope: !157)
!163 = !DILocation(line: 76, column: 62, scope: !157)
!164 = !{!165, !141, i64 2}
!165 = !{!"udphdr", !141, i64 0, !141, i64 2, !141, i64 4, !141, i64 6}
!166 = !DILocation(line: 76, column: 67, scope: !157)
!167 = !DILocation(line: 76, column: 6, scope: !158)
!168 = !DILocation(line: 78, column: 9, scope: !169)
!169 = distinct !DILexicalBlock(scope: !157, file: !3, line: 77, column: 10)
!170 = !DILocation(line: 78, column: 15, scope: !169)
!171 = !{!172, !117, i64 8}
!172 = !{!"datarec", !173, i64 0, !117, i64 8}
!173 = !{!"long long", !118, i64 0}
!174 = !DILocation(line: 79, column: 5, scope: !169)
!175 = !DILocation(line: 80, column: 2, scope: !169)
!176 = !DILocation(line: 97, column: 1, scope: !52)
