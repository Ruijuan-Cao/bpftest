; ModuleID = 'xdp_prog_kern.c'
source_filename = "xdp_prog_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }

@xdp_stats_map = dso_local global %struct.bpf_map_def { i32 2, i32 4, i32 16, i32 5, i32 0 }, section "maps", align 4, !dbg !0
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !23
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_stats1_func to i8*), i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @xdp_stats1_func(%struct.xdp_md* nocapture readonly) #0 section "xdp_stats1" !dbg !49 {
  %2 = alloca i32, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !63, metadata !DIExpression()), !dbg !111
  %3 = bitcast i32* %2 to i8*, !dbg !112
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #3, !dbg !112
  call void @llvm.dbg.value(metadata i32 2, metadata !74, metadata !DIExpression()), !dbg !113
  store i32 2, i32* %2, align 4, !dbg !113, !tbaa !114
  %4 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*), i8* nonnull %3) #3, !dbg !118
  call void @llvm.dbg.value(metadata i8* %4, metadata !64, metadata !DIExpression()), !dbg !119
  %5 = icmp eq i8* %4, null, !dbg !120
  br i1 %5, label %30, label %6, !dbg !122

; <label>:6:                                      ; preds = %1
  %7 = bitcast i8* %4 to i64*, !dbg !123
  %8 = atomicrmw add i64* %7, i64 1 seq_cst, !dbg !123
  %9 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !124
  %10 = load i32, i32* %9, align 4, !dbg !124, !tbaa !125
  %11 = zext i32 %10 to i64, !dbg !127
  %12 = inttoptr i64 %11 to i8*, !dbg !128
  call void @llvm.dbg.value(metadata i8* %12, metadata !75, metadata !DIExpression()), !dbg !129
  %13 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !130
  %14 = load i32, i32* %13, align 4, !dbg !130, !tbaa !131
  %15 = zext i32 %14 to i64, !dbg !132
  %16 = inttoptr i64 %15 to i8*, !dbg !133
  call void @llvm.dbg.value(metadata i8* %16, metadata !76, metadata !DIExpression()), !dbg !134
  call void @llvm.dbg.value(metadata i64 14, metadata !89, metadata !DIExpression()), !dbg !135
  %17 = getelementptr i8, i8* %16, i64 14, !dbg !136
  %18 = icmp ugt i8* %17, %12, !dbg !138
  br i1 %18, label %30, label %19, !dbg !139

; <label>:19:                                     ; preds = %6
  %20 = inttoptr i64 %15 to %struct.ethhdr*, !dbg !140
  call void @llvm.dbg.value(metadata %struct.ethhdr* %20, metadata !77, metadata !DIExpression()), !dbg !141
  %21 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %20, i64 0, i32 2, !dbg !142
  %22 = load i16, i16* %21, align 1, !dbg !142, !tbaa !143
  %23 = icmp eq i16 %22, 8, !dbg !146
  br i1 %23, label %24, label %30, !dbg !147

; <label>:24:                                     ; preds = %19
  call void @llvm.dbg.value(metadata i8* %17, metadata !91, metadata !DIExpression()), !dbg !148
  %25 = getelementptr inbounds i8, i8* %16, i64 26, !dbg !149
  %26 = bitcast i8* %25 to i32*, !dbg !149
  %27 = load i32, i32* %26, align 4, !dbg !149, !tbaa !150
  %28 = getelementptr inbounds i8, i8* %4, i64 8, !dbg !152
  %29 = bitcast i8* %28 to i32*, !dbg !152
  store i32 %27, i32* %29, align 8, !dbg !153, !tbaa !154
  br label %30, !dbg !157

; <label>:30:                                     ; preds = %6, %24, %19, %1
  %31 = phi i32 [ 0, %1 ], [ 2, %19 ], [ 2, %24 ], [ 2, %6 ], !dbg !158
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #3, !dbg !159
  ret i32 %31, !dbg !159
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind readnone speculatable }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!45, !46, !47}
!llvm.ident = !{!48}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "xdp_stats_map", scope: !2, file: !3, line: 21, type: !37, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.0 (Fedora 8.0.0-3.fc30)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !14, globals: !22, nameTableKind: None)
!3 = !DIFile(filename: "xdp_prog_kern.c", directory: "/root/bpftest/basic03-map-counter")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 2845, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "../headers/linux/bpf.h", directory: "/root/bpftest/basic03-map-counter")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13}
!9 = !DIEnumerator(name: "XDP_ABORTED", value: 0, isUnsigned: true)
!10 = !DIEnumerator(name: "XDP_DROP", value: 1, isUnsigned: true)
!11 = !DIEnumerator(name: "XDP_PASS", value: 2, isUnsigned: true)
!12 = !DIEnumerator(name: "XDP_TX", value: 3, isUnsigned: true)
!13 = !DIEnumerator(name: "XDP_REDIRECT", value: 4, isUnsigned: true)
!14 = !{!15, !16, !17, !19}
!15 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!16 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!17 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !18, line: 25, baseType: !19)
!18 = !DIFile(filename: "/usr/include/linux/types.h", directory: "")
!19 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !20, line: 24, baseType: !21)
!20 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!21 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!22 = !{!0, !23, !29}
!23 = !DIGlobalVariableExpression(var: !24, expr: !DIExpression())
!24 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 93, type: !25, isLocal: false, isDefinition: true)
!25 = !DICompositeType(tag: DW_TAG_array_type, baseType: !26, size: 32, elements: !27)
!26 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!27 = !{!28}
!28 = !DISubrange(count: 4)
!29 = !DIGlobalVariableExpression(var: !30, expr: !DIExpression())
!30 = distinct !DIGlobalVariable(name: "bpf_map_lookup_elem", scope: !2, file: !31, line: 33, type: !32, isLocal: true, isDefinition: true)
!31 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "")
!32 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !33, size: 64)
!33 = !DISubroutineType(types: !34)
!34 = !{!15, !15, !35}
!35 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !36, size: 64)
!36 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!37 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !38, line: 36, size: 160, elements: !39)
!38 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!39 = !{!40, !41, !42, !43, !44}
!40 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !37, file: !38, line: 37, baseType: !7, size: 32)
!41 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !37, file: !38, line: 38, baseType: !7, size: 32, offset: 32)
!42 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !37, file: !38, line: 39, baseType: !7, size: 32, offset: 64)
!43 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !37, file: !38, line: 40, baseType: !7, size: 32, offset: 96)
!44 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !37, file: !38, line: 41, baseType: !7, size: 32, offset: 128)
!45 = !{i32 2, !"Dwarf Version", i32 4}
!46 = !{i32 2, !"Debug Info Version", i32 3}
!47 = !{i32 1, !"wchar_size", i32 4}
!48 = !{!"clang version 8.0.0 (Fedora 8.0.0-3.fc30)"}
!49 = distinct !DISubprogram(name: "xdp_stats1_func", scope: !3, file: !3, line: 36, type: !50, scopeLine: 37, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !62)
!50 = !DISubroutineType(types: !51)
!51 = !{!52, !53}
!52 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!53 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !54, size: 64)
!54 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 2856, size: 160, elements: !55)
!55 = !{!56, !58, !59, !60, !61}
!56 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !54, file: !6, line: 2857, baseType: !57, size: 32)
!57 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !20, line: 27, baseType: !7)
!58 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !54, file: !6, line: 2858, baseType: !57, size: 32, offset: 32)
!59 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !54, file: !6, line: 2859, baseType: !57, size: 32, offset: 64)
!60 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !54, file: !6, line: 2861, baseType: !57, size: 32, offset: 96)
!61 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !54, file: !6, line: 2862, baseType: !57, size: 32, offset: 128)
!62 = !{!63, !64, !74, !75, !76, !77, !89, !90, !91}
!63 = !DILocalVariable(name: "ctx", arg: 1, scope: !49, file: !3, line: 36, type: !53)
!64 = !DILocalVariable(name: "rec", scope: !49, file: !3, line: 40, type: !65)
!65 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !66, size: 64)
!66 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "datarec", file: !67, line: 8, size: 128, elements: !68)
!67 = !DIFile(filename: "./common_kern_user.h", directory: "/root/bpftest/basic03-map-counter")
!68 = !{!69, !72}
!69 = !DIDerivedType(tag: DW_TAG_member, name: "rx_packets", scope: !66, file: !67, line: 9, baseType: !70, size: 64)
!70 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !20, line: 31, baseType: !71)
!71 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!72 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !66, file: !67, line: 10, baseType: !73, size: 32, offset: 64)
!73 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !18, line: 27, baseType: !57)
!74 = !DILocalVariable(name: "key", scope: !49, file: !3, line: 41, type: !57)
!75 = !DILocalVariable(name: "data_end", scope: !49, file: !3, line: 56, type: !15)
!76 = !DILocalVariable(name: "data", scope: !49, file: !3, line: 57, type: !15)
!77 = !DILocalVariable(name: "eth", scope: !49, file: !3, line: 58, type: !78)
!78 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !79, size: 64)
!79 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !80, line: 163, size: 112, elements: !81)
!80 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "")
!81 = !{!82, !87, !88}
!82 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !79, file: !80, line: 164, baseType: !83, size: 48)
!83 = !DICompositeType(tag: DW_TAG_array_type, baseType: !84, size: 48, elements: !85)
!84 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!85 = !{!86}
!86 = !DISubrange(count: 6)
!87 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !79, file: !80, line: 165, baseType: !83, size: 48, offset: 48)
!88 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !79, file: !80, line: 166, baseType: !17, size: 16, offset: 96)
!89 = !DILocalVariable(name: "nh_off", scope: !49, file: !3, line: 60, type: !70)
!90 = !DILocalVariable(name: "h_proto", scope: !49, file: !3, line: 65, type: !70)
!91 = !DILocalVariable(name: "iph", scope: !92, file: !3, line: 68, type: !94)
!92 = distinct !DILexicalBlock(scope: !93, file: !3, line: 67, column: 34)
!93 = distinct !DILexicalBlock(scope: !49, file: !3, line: 67, column: 6)
!94 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !95, size: 64)
!95 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !96, line: 86, size: 160, elements: !97)
!96 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "")
!97 = !{!98, !100, !101, !102, !103, !104, !105, !106, !107, !109, !110}
!98 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !95, file: !96, line: 88, baseType: !99, size: 4, flags: DIFlagBitField, extraData: i64 0)
!99 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !20, line: 21, baseType: !84)
!100 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !95, file: !96, line: 89, baseType: !99, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!101 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !95, file: !96, line: 96, baseType: !99, size: 8, offset: 8)
!102 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !95, file: !96, line: 97, baseType: !17, size: 16, offset: 16)
!103 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !95, file: !96, line: 98, baseType: !17, size: 16, offset: 32)
!104 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !95, file: !96, line: 99, baseType: !17, size: 16, offset: 48)
!105 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !95, file: !96, line: 100, baseType: !99, size: 8, offset: 64)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !95, file: !96, line: 101, baseType: !99, size: 8, offset: 72)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !95, file: !96, line: 102, baseType: !108, size: 16, offset: 80)
!108 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !18, line: 31, baseType: !19)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !95, file: !96, line: 103, baseType: !73, size: 32, offset: 96)
!110 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !95, file: !96, line: 104, baseType: !73, size: 32, offset: 128)
!111 = !DILocation(line: 36, column: 37, scope: !49)
!112 = !DILocation(line: 41, column: 2, scope: !49)
!113 = !DILocation(line: 41, column: 8, scope: !49)
!114 = !{!115, !115, i64 0}
!115 = !{!"int", !116, i64 0}
!116 = !{!"omnipotent char", !117, i64 0}
!117 = !{!"Simple C/C++ TBAA"}
!118 = !DILocation(line: 44, column: 8, scope: !49)
!119 = !DILocation(line: 40, column: 18, scope: !49)
!120 = !DILocation(line: 49, column: 7, scope: !121)
!121 = distinct !DILexicalBlock(scope: !49, file: !3, line: 49, column: 6)
!122 = !DILocation(line: 49, column: 6, scope: !49)
!123 = !DILocation(line: 55, column: 2, scope: !49)
!124 = !DILocation(line: 56, column: 37, scope: !49)
!125 = !{!126, !115, i64 4}
!126 = !{!"xdp_md", !115, i64 0, !115, i64 4, !115, i64 8, !115, i64 12, !115, i64 16}
!127 = !DILocation(line: 56, column: 26, scope: !49)
!128 = !DILocation(line: 56, column: 18, scope: !49)
!129 = !DILocation(line: 56, column: 7, scope: !49)
!130 = !DILocation(line: 57, column: 41, scope: !49)
!131 = !{!126, !115, i64 0}
!132 = !DILocation(line: 57, column: 30, scope: !49)
!133 = !DILocation(line: 57, column: 22, scope: !49)
!134 = !DILocation(line: 57, column: 15, scope: !49)
!135 = !DILocation(line: 60, column: 15, scope: !49)
!136 = !DILocation(line: 61, column: 18, scope: !137)
!137 = distinct !DILexicalBlock(scope: !49, file: !3, line: 61, column: 13)
!138 = !DILocation(line: 61, column: 27, scope: !137)
!139 = !DILocation(line: 61, column: 13, scope: !49)
!140 = !DILocation(line: 58, column: 30, scope: !49)
!141 = !DILocation(line: 58, column: 24, scope: !49)
!142 = !DILocation(line: 65, column: 30, scope: !49)
!143 = !{!144, !145, i64 12}
!144 = !{!"ethhdr", !116, i64 0, !116, i64 6, !145, i64 12}
!145 = !{!"short", !116, i64 0}
!146 = !DILocation(line: 67, column: 14, scope: !93)
!147 = !DILocation(line: 67, column: 6, scope: !49)
!148 = !DILocation(line: 68, column: 31, scope: !92)
!149 = !DILocation(line: 78, column: 40, scope: !92)
!150 = !{!151, !115, i64 12}
!151 = !{!"iphdr", !116, i64 0, !116, i64 0, !116, i64 1, !145, i64 2, !145, i64 4, !145, i64 6, !116, i64 8, !116, i64 9, !145, i64 10, !115, i64 12, !115, i64 16}
!152 = !DILocation(line: 78, column: 27, scope: !92)
!153 = !DILocation(line: 78, column: 33, scope: !92)
!154 = !{!155, !115, i64 8}
!155 = !{!"datarec", !156, i64 0, !115, i64 8}
!156 = !{!"long long", !116, i64 0}
!157 = !DILocation(line: 81, column: 9, scope: !92)
!158 = !DILocation(line: 0, scope: !49)
!159 = !DILocation(line: 91, column: 1, scope: !49)
