; ModuleID = 'test_kern.c'
source_filename = "test_kern.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }

@bpf_pass_map = dso_local global %struct.bpf_map_def { i32 2, i32 4, i32 8, i32 5, i32 0 }, section "maps", align 4
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (%struct.bpf_map_def* @bpf_pass_map to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_pass_func to i8*)], section "llvm.metadata"

; Function Attrs: nounwind uwtable
define dso_local i32 @xdp_pass_func(%struct.xdp_md* nocapture readnone) #0 section "xdp_pass" {
  %2 = alloca i32, align 4
  %3 = bitcast i32* %2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #2
  store i32 2, i32* %2, align 4, !tbaa !2
  %4 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @bpf_pass_map to i8*), i8* nonnull %3) #2
  %5 = icmp eq i8* %4, null
  br i1 %5, label %9, label %6

6:                                                ; preds = %1
  %7 = bitcast i8* %4 to i64*
  %8 = atomicrmw add i64* %7, i64 1 seq_cst
  br label %9

9:                                                ; preds = %1, %6
  %10 = phi i32 [ 2, %6 ], [ 0, %1 ]
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #2
  ret i32 %10
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.1 (Fedora 9.0.1-2.fc31)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
