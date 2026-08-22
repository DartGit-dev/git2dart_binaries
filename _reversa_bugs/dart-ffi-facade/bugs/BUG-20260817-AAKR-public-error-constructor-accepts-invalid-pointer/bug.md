---
schema_version: 1
id: BUG-20260817-AAKR
display_number: 10
title: Public error constructor accepts invalid native pointers
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-17

origin:
  type: inspection
  external_ref: null

area: runtime
module: dart-ffi
feature: dart-ffi-facade
labels:
  - unsafe-public-api
  - native-pointer
  - null-dereference

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1 static dereference path"
  suspected_triggers:
    - constructing LibGit2Error with nullptr or an invalid Pointer<git_error> and reading a getter

blocking: []
relationships: []

traceability:
  specs:
    - _reversa_sdd/dart-ffi-facade/requirements.md#functional-requirements
    - _reversa_sdd/dart-ffi-facade/design.md#interface
  affected_code:
    - "lib/src/error.dart:12-24"
    - "lib/src/extensions.dart:90-97"
    - "lib/git2dart_binaries.dart:4-9"
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

# Public error constructor accepts invalid native pointers

## Summary

`LibGit2Error` documents its native-pointer constructor as internal-only, but the constructor is public and the class is exported through the package barrel. Callers can construct it with `nullptr` or any arbitrary `Pointer<git_error>`; `message` and `errorClass` then dereference that pointer without validation.

## Expected Behavior

The public nullable error path should expose only a native pointer returned and checked by `getLastError()`, or otherwise reject invalid pointers before dereference. An internal-only constructor should not be part of the public API.

## Actual Behavior

The constructor has no private identifier or guard. The public barrel exports the class, and both getters immediately access `_errorPointer.ref`. The `getLastError()` factory path rejects `nullptr`, but direct public construction bypasses that guard.

## Steps to Reproduce

1. Import `package:git2dart_binaries/git2dart_binaries.dart`.
2. Construct `LibGit2Error(nullptr)` or provide another invalid native pointer.
3. Read `message`, `errorClass`, or `toString()`.
4. Follow the unconditional native dereference in `error.dart`.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260817-depth-inspection/report.md`

## Suspected Area

Visibility and validation of the native error wrapper constructor.

## Acceptance Criteria

1. The internal native-pointer constructor is not publicly callable, or it validates its pointer contract before dereference.
2. Public callers obtain nullable errors through a guarded API.
3. Tests cover `nullptr`, a populated error, and attempted direct invalid construction according to the chosen API shape.
4. Borrowed-memory ownership remains explicit and no wrapper frees native-owned error storage.
5. The corrected package is merged and published under the package closure policy.

## Traceability

- Effective spec: nullable last-error representation and the facade interface.
- Affected code: `LibGit2Error`, `getLastError()`, and the public barrel.
- Inspection finding: F-DFF-ERR-01, candidate C-DFF-01.

## Resolution

Not started. Root cause confirmation, specification verdict, regression tests, delivery, and publication evidence remain required.

## Agent Notes

- Registration did not modify source code or tests.
- Exact runtime symptom was not replayed because generated bindings and native artifacts are absent. The public bypass and unconditional dereference are statically confirmed.

