---
schema_version: 1
id: BUG-20260816-AAH2
display_number: 3
title: Global option wrappers use incorrect ABI widths
status: active
phase: delivering
severity: critical
priority: P0
created: 2026-08-16
updated: 2026-08-23

origin:
  type: inspection
  external_ref: null

area: runtime
module: dart-ffi
feature: libgit2-global-options
labels:
  - abi-corruption
  - memory-safety
  - cross-platform

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "11/11 inspected wrappers"
  suspected_triggers:
    - Calling affected global options on a 64-bit native target

blocking:
  - kind: external
    reason: Generated bindings and native artifacts are absent, so runtime crash or corruption replay is not currently available.
    since: 2026-08-16

relationships: []

traceability:
  specs:
    - _reversa_sdd/libgit2-global-options/requirements.md#responsibilities-and-rules
    - _reversa_sdd/libgit2-global-options/requirements.md#functional-requirements
    - _reversa_sdd/libgit2-global-options/requirements.md#non-functional-requirements
  affected_code:
    - "lib/src/opts_bindings.dart:29-95"
    - "lib/src/opts_bindings.dart:150-188"
    - "lib/src/opts_bindings.dart:387-405"
    - "lib/src/opts_bindings.dart:533-546"
    - "lib/src/opts_bindings.dart:599-620"
  root_cause:
    state: confirmed
    hypothesis: "The specialised variadic wrapper encoded size_t and ssize_t option arguments as 32-bit ffi.Int values."
    causal_path:
      - "A size_t or ssize_t option selects an ffi.Int-based variadic signature family."
      - "On 64-bit targets, a getter writes a pointer-width native value through a 32-bit Dart allocation, or a setter receives a width-mismatched argument."
    evidence:
      - ref: "evidence/inspection-evidence.md"
        observation: "The pinned libgit2 1.9.6 header and every affected wrapper were compared directly."
      - ref: "fix/CHG-001-tests-proposed.diff"
        observation: "Pointer-width test allocations fail to compile against the previous Pointer<Int> public API."
    code_refs:
      - file: "lib/src/opts_bindings.dart"
        symbol: "Libgit2Opts"
        commit: null
  reproduction_tests:
    - "test/opts_bindings_integration_test.dart: pointer-width allocation compilation before CHG-002"
  regression_tests:
    - "test/opts_bindings_integration_test.dart: mwindow, cache, and pack pointer-width integration paths"

spec_verdict: spec-correta
change_set:
  - id: CHG-001
    kind: test
    artifact: test/opts_bindings_integration_test.dart
    purpose: "Exercise affected option families with matching pointer-width test allocations."
    diff: fix/CHG-001-tests-proposed.diff
  - id: CHG-002
    kind: code
    artifact: lib/src/opts_bindings.dart
    purpose: "Align every affected variadic option signature with libgit2 1.9.6 size_t or ssize_t ABI widths."
    diff: fix/CHG-002-code-proposed.diff

change_risk:
  classification: média
  reasons:
    - "Public output-pointer parameter types change to their exact native-width forms."
    - "The corrected values cross a variadic native ABI boundary."

closure:
  policy: package
  satisfied: false
resolution_kind: null
---

# Global option wrappers use incorrect ABI widths

## Summary

Eleven global-option wrappers use 32-bit `ffi.Int` or `Pointer<ffi.Int>` where the exact pinned libgit2 1.9.6 header requires pointer-width `size_t`, `size_t*`, `ssize_t`, or `ssize_t*` arguments.

## Expected Behavior

LGO-RF-01 and the ABI correctness NFR require every discriminator to use the exact native signature from the pinned libgit2 1.9.6 header.

## Actual Behavior

The affected mwindow, cache, and pack wrappers dispatch pointer-width native values through 32-bit FFI declarations. On 64-bit targets, output calls can write 8 bytes through pointers allocated for 4-byte integers. Setter calls also use the wrong variadic argument width and can truncate or misread values.

## Steps to Reproduce

1. Read `include/git2/common.h` from official tag `v1.9.6`.
2. Compare header lines 270-342 and 487-494 with the current FFI declarations.
3. Observe 11 wrappers whose `size_t` or `ssize_t` contract is represented as `ffi.Int`.
4. Runtime replay remains blocked until generated bindings and native artifacts are available.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260816-depth-inspection/report.md`

## Suspected Area

Variadic FFI signature-family declarations and the 11 wrappers that reuse the 32-bit integer families.

## Acceptance Criteria

1. Every affected wrapper uses the exact signed or unsigned pointer-width ABI type required by libgit2 1.9.6.
2. Output tests allocate the matching pointer-width native type.
3. Native regression tests cover all affected getter and setter families on a 64-bit target.
4. The corrected package is merged and published under the package closure policy.

## Traceability

- Effective spec: LGO-RF-01 and ABI correctness NFR.
- Affected code: `lib/src/opts_bindings.dart` wrappers and private signature families.
- Inspection finding: F-LGO-CONF-01, candidate C-LGO-01.

## Resolution

The root cause is confirmed statically. CHG-001 reproduced the old mismatch as
compile-time `Pointer<Size>` / `Pointer<IntPtr>` versus `Pointer<Int>` errors.
CHG-002 corrected the public wrappers and their variadic signature families.

Validation after CHG-002:

- `dart format` completed for the two changed Dart files.
- The focused test now compiles and reaches runtime loading; the previous ABI
  type errors are absent.
- The source-only checkout cannot load `windows/libssh2.dll` (error 126).
  The focused native suite was then run through the installed matching 1.12.1
  package bundle and passed all 13 tests; see `evidence/reproduction.md`.
- Targeted static analysis reported no errors, but retained pre-existing lint
  findings in the wrapper file (one unused import and naming/order diagnostics).

The specification verdict and native 64-bit green run are complete. Package
delivery and publication evidence remain pending; therefore the package closure
policy is not satisfied and this bug is not resolved.

Specification verdict: `spec-correta`, approved by the user on 2026-08-23.
The effective specification already required the exact pinned-header ABI; no
addendum is needed.

## Agent Notes

- Registration did not modify source code.
- Critical/P0 reflects a statically confirmed native memory overwrite path on 64-bit output calls.
- The upstream header was read directly and was not copied into the repository.
