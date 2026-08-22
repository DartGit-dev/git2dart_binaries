---
schema_version: 1
id: BUG-20260816-AAH2
display_number: 3
title: Global option wrappers use incorrect ABI widths
status: open
phase: triaging
severity: critical
priority: P0
created: 2026-08-16
updated: 2026-08-16

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
  root_cause: null
  reproduction_tests: []
  regression_tests: []

spec_verdict: null
change_set: []

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

Not started. Root cause confirmation, specification verdict, regression tests, delivery, and publication evidence remain required.

## Agent Notes

- Registration did not modify source code.
- Critical/P0 reflects a statically confirmed native memory overwrite path on 64-bit output calls.
- The upstream header was read directly and was not copied into the repository.
