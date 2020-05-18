; ModuleID = 'test_kern.c'
source_filename = "test_kern.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.udphdr = type { i16, i16, i16, i16 }

@bpf_pass_map = dso_local global %struct.bpf_map_def { i32 2, i32 4, i32 8, i32 5, i32 0 }, section "maps", align 4
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1
@llvm.used = appending global [4 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (%struct.bpf_map_def* @bpf_pass_map to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_filter to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_parser_func to i8*)], section "llvm.metadata"

; Function Attrs: nounwind readonly uwtable
define dso_local i32 @xdp_parser_func(%struct.xdp_md* nocapture readonly) #0 section "xdp_ipv6_pass" {
  %2 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0
  %3 = load i32, i32* %2, align 4, !tbaa !2
  %4 = zext i32 %3 to i64
  %5 = inttoptr i64 %4 to %struct.ethhdr*
  %6 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %5, i64 0, i32 2
  %7 = load i16, i16* %6, align 1, !tbaa !7
  %8 = icmp eq i16 %7, 0
  %9 = select i1 %8, i32 2, i32 1
  ret i32 %9
}

; Function Attrs: norecurse nounwind readonly uwtable
define dso_local i32 @xdp_filter(%struct.xdp_md* nocapture readonly) #1 section "filter" {
  %2 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1
  %3 = load i32, i32* %2, align 4, !tbaa !10
  %4 = zext i32 %3 to i64
  %5 = inttoptr i64 %4 to i8*
  %6 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0
  %7 = load i32, i32* %6, align 4, !tbaa !2
  %8 = zext i32 %7 to i64
  %9 = inttoptr i64 %8 to i8*
  %10 = getelementptr i8, i8* %9, i64 14
  %11 = icmp ugt i8* %10, %5
  br i1 %11, label %77, label %12

12:                                               ; preds = %1
  %13 = inttoptr i64 %8 to %struct.ethhdr*
  %14 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %13, i64 0, i32 2
  %15 = load i16, i16* %14, align 1, !tbaa !7
  %16 = getelementptr i8, i8* %9, i64 2
  switch i16 %15, label %24 [
    i16 -22392, label %17
    i16 129, label %17
  ]

17:                                               ; preds = %12, %12
  %18 = getelementptr i8, i8* %9, i64 18
  %19 = icmp ugt i8* %18, %5
  br i1 %19, label %77, label %20

20:                                               ; preds = %17
  %21 = getelementptr inbounds i8, i8* %9, i64 16
  %22 = bitcast i8* %21 to i16*
  %23 = load i16, i16* %22, align 2, !tbaa !11
  br label %24

24:                                               ; preds = %20, %12
  %25 = phi i16 [ %15, %12 ], [ %23, %20 ]
  %26 = phi i64 [ 14, %12 ], [ 18, %20 ]
  switch i16 %25, label %87 [
    i16 -22392, label %79
    i16 129, label %79
  ]

27:                                               ; preds = %87
  %28 = getelementptr i8, i8* %9, i64 %89
  %29 = getelementptr i8, i8* %28, i64 20
  %30 = getelementptr inbounds i8, i8* %29, i64 8
  %31 = bitcast i8* %30 to %struct.udphdr*
  %32 = inttoptr i64 %4 to %struct.udphdr*
  %33 = icmp ugt %struct.udphdr* %31, %32
  br i1 %33, label %49, label %34

34:                                               ; preds = %27
  %35 = getelementptr inbounds i8, i8* %28, i64 9
  %36 = load i8, i8* %35, align 1, !tbaa !13
  %37 = icmp eq i8 %36, 17
  br i1 %37, label %38, label %77

38:                                               ; preds = %34
  %39 = getelementptr inbounds i8, i8* %28, i64 16
  %40 = bitcast i8* %39 to i32*
  %41 = load i32, i32* %40, align 4, !tbaa !15
  %42 = and i32 %41, 16777215
  %43 = icmp eq i32 %42, 4806
  br i1 %43, label %44, label %77

44:                                               ; preds = %38
  %45 = getelementptr inbounds i8, i8* %29, i64 2
  %46 = bitcast i8* %45 to i16*
  %47 = load i16, i16* %46, align 2, !tbaa !16
  %48 = icmp eq i16 %47, -11772
  br i1 %48, label %49, label %77

49:                                               ; preds = %27, %44
  %50 = phi i32 [ 1, %44 ], [ 2, %27 ]
  br label %77

51:                                               ; preds = %87
  %52 = getelementptr i8, i8* %9, i64 %89
  %53 = getelementptr i8, i8* %52, i64 40
  %54 = getelementptr inbounds i8, i8* %53, i64 8
  %55 = bitcast i8* %54 to %struct.udphdr*
  %56 = inttoptr i64 %4 to %struct.udphdr*
  %57 = icmp ugt %struct.udphdr* %55, %56
  br i1 %57, label %75, label %58

58:                                               ; preds = %51
  %59 = getelementptr inbounds i8, i8* %52, i64 6
  %60 = load i8, i8* %59, align 2, !tbaa !18
  %61 = icmp eq i8 %60, 17
  br i1 %61, label %62, label %77

62:                                               ; preds = %58
  %63 = getelementptr inbounds i8, i8* %52, i64 24
  %64 = load i8, i8* %63, align 4, !tbaa !21
  %65 = icmp eq i8 %64, -3
  br i1 %65, label %66, label %77

66:                                               ; preds = %62
  %67 = getelementptr inbounds i8, i8* %63, i64 1
  %68 = load i8, i8* %67, align 1, !tbaa !21
  %69 = icmp eq i8 %68, 0
  br i1 %69, label %70, label %77

70:                                               ; preds = %66
  %71 = getelementptr inbounds i8, i8* %53, i64 2
  %72 = bitcast i8* %71 to i16*
  %73 = load i16, i16* %72, align 2, !tbaa !16
  %74 = icmp eq i16 %73, -11772
  br i1 %74, label %75, label %77

75:                                               ; preds = %51, %70
  %76 = phi i32 [ 1, %70 ], [ 2, %51 ]
  br label %77

77:                                               ; preds = %17, %79, %87, %34, %38, %44, %58, %62, %66, %70, %75, %49, %1
  %78 = phi i32 [ 2, %1 ], [ %50, %49 ], [ %76, %75 ], [ 2, %70 ], [ 2, %66 ], [ 2, %62 ], [ 2, %58 ], [ 2, %44 ], [ 2, %38 ], [ 2, %34 ], [ 2, %87 ], [ 2, %79 ], [ 2, %17 ]
  ret i32 %78

79:                                               ; preds = %24, %24
  %80 = add nuw nsw i64 %26, 4
  %81 = getelementptr i8, i8* %9, i64 %80
  %82 = icmp ugt i8* %81, %5
  br i1 %82, label %77, label %83

83:                                               ; preds = %79
  %84 = getelementptr inbounds i8, i8* %16, i64 %26
  %85 = bitcast i8* %84 to i16*
  %86 = load i16, i16* %85, align 2, !tbaa !11
  br label %87

87:                                               ; preds = %83, %24
  %88 = phi i16 [ %25, %24 ], [ %86, %83 ]
  %89 = phi i64 [ %26, %24 ], [ %80, %83 ]
  switch i16 %88, label %77 [
    i16 8, label %27
    i16 -8826, label %51
  ]
}

attributes #0 = { nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { norecurse nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (Fedora 9.0.1-2.fc31)"}
!2 = !{!3, !4, i64 0}
!3 = !{!"xdp_md", !4, i64 0, !4, i64 4, !4, i64 8, !4, i64 12, !4, i64 16}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = !{!8, !9, i64 12}
!8 = !{!"ethhdr", !5, i64 0, !5, i64 6, !9, i64 12}
!9 = !{!"short", !5, i64 0}
!10 = !{!3, !4, i64 4}
!11 = !{!12, !9, i64 2}
!12 = !{!"vlan_hdr", !9, i64 0, !9, i64 2}
!13 = !{!14, !5, i64 9}
!14 = !{!"iphdr", !5, i64 0, !5, i64 0, !5, i64 1, !9, i64 2, !9, i64 4, !9, i64 6, !5, i64 8, !5, i64 9, !9, i64 10, !4, i64 12, !4, i64 16}
!15 = !{!14, !4, i64 16}
!16 = !{!17, !9, i64 2}
!17 = !{!"udphdr", !9, i64 0, !9, i64 2, !9, i64 4, !9, i64 6}
!18 = !{!19, !5, i64 6}
!19 = !{!"ipv6hdr", !5, i64 0, !5, i64 0, !5, i64 1, !9, i64 4, !5, i64 6, !5, i64 7, !20, i64 8, !20, i64 24}
!20 = !{!"in6_addr", !5, i64 0}
!21 = !{!5, !5, i64 0}
