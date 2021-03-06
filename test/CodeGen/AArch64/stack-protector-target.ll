; Test target-specific stack cookie location.
; RUN: llc -mtriple=aarch64-linux-android < %s -o - | FileCheck --check-prefix=ANDROID-AARCH64 %s
; RUN: llc -mtriple=aarch64-fuchsia < %s -o - | FileCheck --check-prefixes=FUCHSIA-AARCH64-COMMON,FUCHSIA-AARCH64-USER %s
; RUN: llc -mtriple=aarch64-fuchsia -code-model=kernel < %s -o - | FileCheck --check-prefixes=FUCHSIA-AARCH64-COMMON,FUCHSIA-AARCH64-KERNEL %s

define void @_Z1fv() sspreq {
entry:
  %x = alloca i32, align 4
  %0 = bitcast i32* %x to i8*
  call void @_Z7CapturePi(i32* nonnull %x)
  ret void
}

declare void @_Z7CapturePi(i32*)

; ANDROID-AARCH64: mrs [[A:.*]], TPIDR_EL0
; ANDROID-AARCH64: ldr [[B:.*]], {{\[}}[[A]], #40]
; ANDROID-AARCH64: str [[B]], [sp,
; ANDROID-AARCH64: ldr [[C:.*]], {{\[}}[[A]], #40]
; ANDROID-AARCH64: ldr [[D:.*]], [sp,
; ANDROID-AARCH64: cmp [[C]], [[D]]

; FUCHSIA-AARCH64-USER: mrs [[A:.*]], TPIDR_EL0
; FUCHSIA-AARCH64-KERNEL: mrs [[A:.*]], TPIDR_EL1
; FUCHSIA-AARCH64-COMMON: ldur [[B:.*]], {{\[}}[[A]], #-16]
; FUCHSIA-AARCH64-COMMON: str [[B]], [sp,
; FUCHSIA-AARCH64-COMMON: ldur [[C:.*]], {{\[}}[[A]], #-16]
; FUCHSIA-AARCH64-COMMON: ldr [[D:.*]], [sp,
; FUCHSIA-AARCH64-COMMON: cmp [[C]], [[D]]
