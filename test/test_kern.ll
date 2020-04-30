; ModuleID = 'test_kern.c'
source_filename = "test_kern.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.vlan_hdr = type { i16, i16 }

@bpf_pass_map = dso_local global %struct.bpf_map_def { i32 2, i32 4, i32 8, i32 5, i32 0 }, section "maps", align 4
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (%struct.bpf_map_def* @bpf_pass_map to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_parser_func to i8*)], section "llvm.metadata"

; Function Attrs: nounwind readonly uwtable
define dso_local i32 @xdp_parser_func(%struct.xdp_md* nocapture readonly) #0 section "xdp_ipv6_pass" {
  %2 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0
  %3 = load i32, i32* %2, align 4, !tbaa !2
  %4 = zext i32 %3 to i64
  %5 = inttoptr i64 %4 to i8*
  %6 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1
  %7 = load i32, i32* %6, align 4, !tbaa !7
  %8 = zext i32 %7 to i64
  %9 = inttoptr i64 %8 to i8*
  %10 = getelementptr i8, i8* %5, i64 1
  %11 = icmp ugt i8* %10, %9
  br i1 %11, label %53, label %12

; <label>:12:                                     ; preds = %1
  %13 = getelementptr inbounds i8, i8* %5, i64 12
  %14 = bitcast i8* %13 to i16*
  %15 = load i16, i16* %14, align 1, !tbaa !8
  %16 = inttoptr i64 %8 to %struct.vlan_hdr*
  switch i16 %15, label %49 [
    i16 -22392, label %17
    i16 129, label %17
  ]

; <label>:17:                                     ; preds = %12, %12
  %18 = getelementptr inbounds i8, i8* %5, i64 18
  %19 = bitcast i8* %18 to %struct.vlan_hdr*
  %20 = icmp ugt %struct.vlan_hdr* %19, %16
  br i1 %20, label %49, label %21

; <label>:21:                                     ; preds = %17
  %22 = getelementptr inbounds i8, i8* %5, i64 16
  %23 = bitcast i8* %22 to i16*
  %24 = load i16, i16* %23, align 1, !tbaa !8
  switch i16 %24, label %49 [
    i16 -22392, label %25
    i16 129, label %25
  ]

; <label>:25:                                     ; preds = %21, %21
  %26 = getelementptr inbounds i8, i8* %5, i64 22
  %27 = bitcast i8* %26 to %struct.vlan_hdr*
  %28 = icmp ugt %struct.vlan_hdr* %27, %16
  br i1 %28, label %49, label %29

; <label>:29:                                     ; preds = %25
  %30 = getelementptr inbounds i8, i8* %5, i64 20
  %31 = bitcast i8* %30 to i16*
  %32 = load i16, i16* %31, align 1, !tbaa !8
  switch i16 %32, label %49 [
    i16 -22392, label %33
    i16 129, label %33
  ]

; <label>:33:                                     ; preds = %29, %29
  %34 = getelementptr inbounds i8, i8* %5, i64 26
  %35 = bitcast i8* %34 to %struct.vlan_hdr*
  %36 = icmp ugt %struct.vlan_hdr* %35, %16
  br i1 %36, label %49, label %37

; <label>:37:                                     ; preds = %33
  %38 = getelementptr inbounds i8, i8* %5, i64 24
  %39 = bitcast i8* %38 to i16*
  %40 = load i16, i16* %39, align 1, !tbaa !8
  switch i16 %40, label %49 [
    i16 -22392, label %41
    i16 129, label %41
  ]

; <label>:41:                                     ; preds = %37, %37
  %42 = getelementptr inbounds i8, i8* %5, i64 30
  %43 = bitcast i8* %42 to %struct.vlan_hdr*
  %44 = icmp ugt %struct.vlan_hdr* %43, %16
  br i1 %44, label %49, label %45

; <label>:45:                                     ; preds = %41
  %46 = getelementptr inbounds i8, i8* %5, i64 28
  %47 = bitcast i8* %46 to i16*
  %48 = load i16, i16* %47, align 1, !tbaa !8
  br label %49

; <label>:49:                                     ; preds = %12, %17, %21, %25, %29, %33, %37, %41, %45
  %50 = phi i16 [ %15, %12 ], [ %15, %17 ], [ %24, %21 ], [ %24, %25 ], [ %32, %29 ], [ %32, %33 ], [ %40, %37 ], [ %40, %41 ], [ %48, %45 ]
  %51 = icmp eq i16 %50, 8
  %52 = select i1 %51, i32 2, i32 1
  ret i32 %52

; <label>:53:                                     ; preds = %1
  ret i32 1
}

attributes #0 = { nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 8.0.0 (Fedora 8.0.0-1.fc30)"}
!2 = !{!3, !4, i64 0}
!3 = !{!"xdp_md", !4, i64 0, !4, i64 4, !4, i64 8, !4, i64 12, !4, i64 16}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = !{!3, !4, i64 4}
!8 = !{!9, !9, i64 0}
!9 = !{!"short", !5, i64 0}
