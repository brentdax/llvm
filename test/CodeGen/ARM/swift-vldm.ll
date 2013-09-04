; RUN: llc < %s -mcpu=swift -mtriple=armv7s-apple-ios | FileCheck %s

; vldm with registers not aligned with q registers need more micro-ops so that
; so that there usage becomes unbeneficial on swift.

; CHECK-LABEL: test_vldm
; CHECK: vldmia r{{[0-9]+}}, {d2, d3, d4}
; CHECK-NOT: vldmia r{{[0-9]+}}, {d1, d2, d3, d4}

declare fastcc void @force_register(double %d0, double %d1, double %d2, double %d3, double %d4) 

define void @test_vldm(double* %x, double * %y) {
entry:
  %addr1 = getelementptr double * %x, i32 1
  %addr2 = getelementptr double * %x, i32 2
  %addr3 = getelementptr double * %x, i32 3
  %d0 = load double * %y
  %d1 = load double * %x
  %d2 = load double * %addr1
  %d3 = load double * %addr2
  %d4 = load double * %addr3
  ; We are trying to force x[0-3] in register d1 to d4 so that we can test we
  ; don't form a "vldmia rX, {d1, d2, d3, d4}".
  ; We are relying on the calling convention and that register allocation
  ; properly coalesces registers.
  call fastcc void @force_register(double %d0, double %d1, double %d2, double %d3, double %d4)
  ret void
}