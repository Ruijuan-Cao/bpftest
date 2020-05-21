; ModuleID = 'xdp_prog_kern.c'
source_filename = "xdp_prog_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.udphdr = type { i16, i16, i16, i16 }

@xdp_stats_map = dso_local global %struct.bpf_map_def { i32 2, i32 4, i32 16, i32 5, i32 0 }, section "maps", align 4, !dbg !0
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !23
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_stats1_func to i8*), i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @xdp_stats1_func(%struct.xdp_md* nocapture readonly) #0 section "xdp_stats1" !dbg !50 {
  %2 = alloca i32, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !65, metadata !DIExpression()), !dbg !113
  %3 = bitcast i32* %2 to i8*, !dbg !114
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #3, !dbg !114
  call void @llvm.dbg.value(metadata i32 2, metadata !76, metadata !DIExpression()), !dbg !113
  store i32 2, i32* %2, align 4, !dbg !115, !tbaa !116
  %4 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @xdp_stats_map to i8*), i8* nonnull %3) #3, !dbg !120
  call void @llvm.dbg.value(metadata i8* %4, metadata !66, metadata !DIExpression()), !dbg !113
  %5 = icmp eq i8* %4, null, !dbg !121
  br i1 %5, label %44, label %6, !dbg !123

6:                                                ; preds = %1
  %7 = bitcast i8* %4 to i64*, !dbg !124
  %8 = atomicrmw add i64* %7, i64 1 seq_cst, !dbg !124
  %9 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !125
  %10 = load i32, i32* %9, align 4, !dbg !125, !tbaa !126
  %11 = zext i32 %10 to i64, !dbg !128
  %12 = inttoptr i64 %11 to i8*, !dbg !129
  call void @llvm.dbg.value(metadata i8* %12, metadata !77, metadata !DIExpression()), !dbg !113
  %13 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !130
  %14 = load i32, i32* %13, align 4, !dbg !130, !tbaa !131
  %15 = zext i32 %14 to i64, !dbg !132
  %16 = inttoptr i64 %15 to i8*, !dbg !133
  call void @llvm.dbg.value(metadata i8* %16, metadata !78, metadata !DIExpression()), !dbg !113
  call void @llvm.dbg.value(metadata i8* %16, metadata !79, metadata !DIExpression()), !dbg !113
  call void @llvm.dbg.value(metadata i64 14, metadata !91, metadata !DIExpression()), !dbg !113
  %17 = getelementptr i8, i8* %16, i64 14, !dbg !134
  %18 = icmp ugt i8* %17, %12, !dbg !136
  br i1 %18, label %44, label %19, !dbg !137

19:                                               ; preds = %6
  %20 = inttoptr i64 %15 to %struct.ethhdr*, !dbg !138
  call void @llvm.dbg.value(metadata %struct.ethhdr* %20, metadata !79, metadata !DIExpression()), !dbg !113
  %21 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %20, i64 0, i32 2, !dbg !139
  %22 = load i16, i16* %21, align 1, !dbg !139, !tbaa !140
  call void @llvm.dbg.value(metadata i16 %22, metadata !92, metadata !DIExpression()), !dbg !113
  %23 = icmp eq i16 %22, 8, !dbg !143
  br i1 %23, label %24, label %44, !dbg !144

24:                                               ; preds = %19
  call void @llvm.dbg.value(metadata i8* %17, metadata !93, metadata !DIExpression()), !dbg !145
  call void @llvm.dbg.value(metadata i8* %16, metadata !112, metadata !DIExpression(DW_OP_plus_uconst, 34, DW_OP_stack_value)), !dbg !145
  %25 = getelementptr inbounds i8, i8* %16, i64 42, !dbg !146
  %26 = bitcast i8* %25 to %struct.udphdr*, !dbg !146
  %27 = inttoptr i64 %11 to %struct.udphdr*, !dbg !148
  %28 = icmp ugt %struct.udphdr* %26, %27, !dbg !149
  br i1 %28, label %44, label %29, !dbg !150

29:                                               ; preds = %24
  %30 = getelementptr inbounds i8, i8* %16, i64 23, !dbg !151
  %31 = load i8, i8* %30, align 1, !dbg !151, !tbaa !153
  %32 = icmp eq i8 %31, 17, !dbg !155
  br i1 %32, label %33, label %44, !dbg !156

33:                                               ; preds = %29
  %34 = getelementptr inbounds i8, i8* %16, i64 36, !dbg !157
  %35 = bitcast i8* %34 to i16*, !dbg !157
  %36 = load i16, i16* %35, align 2, !dbg !157, !tbaa !158
  %37 = icmp eq i16 %36, 14640, !dbg !160
  br i1 %37, label %38, label %44, !dbg !161

38:                                               ; preds = %33
  %39 = getelementptr inbounds i8, i8* %16, i64 26, !dbg !162
  %40 = bitcast i8* %39 to i32*, !dbg !162
  %41 = load i32, i32* %40, align 4, !dbg !162, !tbaa !164
  %42 = getelementptr inbounds i8, i8* %4, i64 8, !dbg !165
  %43 = bitcast i8* %42 to i32*, !dbg !165
  store i32 %41, i32* %43, align 8, !dbg !166, !tbaa !167
  br label %44, !dbg !170

44:                                               ; preds = %6, %24, %19, %29, %33, %38, %1
  %45 = phi i32 [ 0, %1 ], [ 2, %38 ], [ 2, %33 ], [ 2, %29 ], [ 2, %19 ], [ 2, %24 ], [ 2, %6 ], !dbg !113
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #3, !dbg !171
  ret i32 %45, !dbg !171
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind readnone speculatable }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!46, !47, !48}
!llvm.ident = !{!49}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "xdp_stats_map", scope: !2, file: !3, line: 21, type: !37, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1 (Fedora 9.0.1-2.fc31)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !5, globals: !22, nameTableKind: None)
!3 = !DIFile(filename: "xdp_prog_kern.c", directory: "/root/bpftest/basic03-map-counter")
!4 = !{}
!5 = !{!6, !7, !8, !10, !13}
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
!34 = !{!6, !6, !35}
!35 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !36, size: 64)
!36 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!37 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !38, line: 36, size: 160, elements: !39)
!38 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!39 = !{!40, !42, !43, !44, !45}
!40 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !37, file: !38, line: 37, baseType: !41, size: 32)
!41 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!42 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !37, file: !38, line: 38, baseType: !41, size: 32, offset: 32)
!43 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !37, file: !38, line: 39, baseType: !41, size: 32, offset: 64)
!44 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !37, file: !38, line: 40, baseType: !41, size: 32, offset: 96)
!45 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !37, file: !38, line: 41, baseType: !41, size: 32, offset: 128)
!46 = !{i32 2, !"Dwarf Version", i32 4}
!47 = !{i32 2, !"Debug Info Version", i32 3}
!48 = !{i32 1, !"wchar_size", i32 4}
!49 = !{!"clang version 9.0.1 (Fedora 9.0.1-2.fc31)"}
!50 = distinct !DISubprogram(name: "xdp_stats1_func", scope: !3, file: !3, line: 36, type: !51, scopeLine: 37, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !64)
!51 = !DISubroutineType(types: !52)
!52 = !{!53, !54}
!53 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!54 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !55, size: 64)
!55 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !56, line: 2856, size: 160, elements: !57)
!56 = !DIFile(filename: "../headers/linux/bpf.h", directory: "/root/bpftest/basic03-map-counter")
!57 = !{!58, !60, !61, !62, !63}
!58 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !55, file: !56, line: 2857, baseType: !59, size: 32)
!59 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !11, line: 27, baseType: !41)
!60 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !55, file: !56, line: 2858, baseType: !59, size: 32, offset: 32)
!61 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !55, file: !56, line: 2859, baseType: !59, size: 32, offset: 64)
!62 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !55, file: !56, line: 2861, baseType: !59, size: 32, offset: 96)
!63 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !55, file: !56, line: 2862, baseType: !59, size: 32, offset: 128)
!64 = !{!65, !66, !76, !77, !78, !79, !91, !92, !93, !112}
!65 = !DILocalVariable(name: "ctx", arg: 1, scope: !50, file: !3, line: 36, type: !54)
!66 = !DILocalVariable(name: "rec", scope: !50, file: !3, line: 40, type: !67)
!67 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !68, size: 64)
!68 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "datarec", file: !69, line: 8, size: 128, elements: !70)
!69 = !DIFile(filename: "./common_kern_user.h", directory: "/root/bpftest/basic03-map-counter")
!70 = !{!71, !74}
!71 = !DIDerivedType(tag: DW_TAG_member, name: "rx_packets", scope: !68, file: !69, line: 9, baseType: !72, size: 64)
!72 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !11, line: 31, baseType: !73)
!73 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!74 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !68, file: !69, line: 10, baseType: !75, size: 32, offset: 64)
!75 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !9, line: 27, baseType: !59)
!76 = !DILocalVariable(name: "key", scope: !50, file: !3, line: 41, type: !59)
!77 = !DILocalVariable(name: "data_end", scope: !50, file: !3, line: 56, type: !6)
!78 = !DILocalVariable(name: "data", scope: !50, file: !3, line: 57, type: !6)
!79 = !DILocalVariable(name: "eth", scope: !50, file: !3, line: 58, type: !80)
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
!91 = !DILocalVariable(name: "nh_off", scope: !50, file: !3, line: 60, type: !72)
!92 = !DILocalVariable(name: "h_proto", scope: !50, file: !3, line: 65, type: !72)
!93 = !DILocalVariable(name: "iph", scope: !94, file: !3, line: 68, type: !96)
!94 = distinct !DILexicalBlock(scope: !95, file: !3, line: 67, column: 34)
!95 = distinct !DILexicalBlock(scope: !50, file: !3, line: 67, column: 6)
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
!110 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !97, file: !98, line: 103, baseType: !75, size: 32, offset: 96)
!111 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !97, file: !98, line: 104, baseType: !75, size: 32, offset: 128)
!112 = !DILocalVariable(name: "udph", scope: !94, file: !3, line: 69, type: !13)
!113 = !DILocation(line: 0, scope: !50)
!114 = !DILocation(line: 41, column: 2, scope: !50)
!115 = !DILocation(line: 41, column: 8, scope: !50)
!116 = !{!117, !117, i64 0}
!117 = !{!"int", !118, i64 0}
!118 = !{!"omnipotent char", !119, i64 0}
!119 = !{!"Simple C/C++ TBAA"}
!120 = !DILocation(line: 44, column: 8, scope: !50)
!121 = !DILocation(line: 49, column: 7, scope: !122)
!122 = distinct !DILexicalBlock(scope: !50, file: !3, line: 49, column: 6)
!123 = !DILocation(line: 49, column: 6, scope: !50)
!124 = !DILocation(line: 55, column: 2, scope: !50)
!125 = !DILocation(line: 56, column: 37, scope: !50)
!126 = !{!127, !117, i64 4}
!127 = !{!"xdp_md", !117, i64 0, !117, i64 4, !117, i64 8, !117, i64 12, !117, i64 16}
!128 = !DILocation(line: 56, column: 26, scope: !50)
!129 = !DILocation(line: 56, column: 18, scope: !50)
!130 = !DILocation(line: 57, column: 41, scope: !50)
!131 = !{!127, !117, i64 0}
!132 = !DILocation(line: 57, column: 30, scope: !50)
!133 = !DILocation(line: 57, column: 22, scope: !50)
!134 = !DILocation(line: 61, column: 18, scope: !135)
!135 = distinct !DILexicalBlock(scope: !50, file: !3, line: 61, column: 13)
!136 = !DILocation(line: 61, column: 27, scope: !135)
!137 = !DILocation(line: 61, column: 13, scope: !50)
!138 = !DILocation(line: 58, column: 30, scope: !50)
!139 = !DILocation(line: 65, column: 30, scope: !50)
!140 = !{!141, !142, i64 12}
!141 = !{!"ethhdr", !118, i64 0, !118, i64 6, !142, i64 12}
!142 = !{!"short", !118, i64 0}
!143 = !DILocation(line: 67, column: 14, scope: !95)
!144 = !DILocation(line: 67, column: 6, scope: !50)
!145 = !DILocation(line: 0, scope: !94)
!146 = !DILocation(line: 70, column: 26, scope: !147)
!147 = distinct !DILexicalBlock(scope: !94, file: !3, line: 70, column: 21)
!148 = !DILocation(line: 70, column: 32, scope: !147)
!149 = !DILocation(line: 70, column: 30, scope: !147)
!150 = !DILocation(line: 70, column: 21, scope: !94)
!151 = !DILocation(line: 73, column: 26, scope: !152)
!152 = distinct !DILexicalBlock(scope: !94, file: !3, line: 73, column: 21)
!153 = !{!154, !118, i64 9}
!154 = !{!"iphdr", !118, i64 0, !118, i64 0, !118, i64 1, !142, i64 2, !142, i64 4, !142, i64 6, !118, i64 8, !118, i64 9, !142, i64 10, !117, i64 12, !117, i64 16}
!155 = !DILocation(line: 73, column: 35, scope: !152)
!156 = !DILocation(line: 77, column: 21, scope: !152)
!157 = !DILocation(line: 77, column: 30, scope: !152)
!158 = !{!159, !142, i64 2}
!159 = !{!"udphdr", !142, i64 0, !142, i64 2, !142, i64 4, !142, i64 6}
!160 = !DILocation(line: 77, column: 35, scope: !152)
!161 = !DILocation(line: 73, column: 21, scope: !94)
!162 = !DILocation(line: 78, column: 38, scope: !163)
!163 = distinct !DILexicalBlock(scope: !152, file: !3, line: 77, column: 52)
!164 = !{!154, !117, i64 12}
!165 = !DILocation(line: 78, column: 25, scope: !163)
!166 = !DILocation(line: 78, column: 31, scope: !163)
!167 = !{!168, !117, i64 8}
!168 = !{!"datarec", !169, i64 0, !117, i64 8}
!169 = !{!"long long", !118, i64 0}
!170 = !DILocation(line: 80, column: 17, scope: !163)
!171 = !DILocation(line: 91, column: 1, scope: !50)
