---
schema_version: 1
id: BUG-20260816-AAH6
display_number: 1
title: Linux Flutter bundle omits required libssh2 sidecar
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-16
updated: 2026-08-16

origin:
  type: inspection
  external_ref: null

area: packaging
module: platform-integration
feature: native-loader-lifecycle
labels:
  - platform-contract
  - operational-risk

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1 static inspection"
  suspected_triggers:
    - Linux Flutter application assembled from the package artifacts

blocking:
  - kind: external
    reason: Native artifacts are absent, so clean-consumer runtime reproduction is not currently available.
    since: 2026-08-16

relationships: []

traceability:
  specs:
    - _reversa_sdd/platform-packaging/requirements.md#responsibilities-and-rules
    - _reversa_sdd/platform-packaging/requirements.md#functional-requirements
    - _reversa_sdd/platform-packaging/design.md#artifact-model
  affected_code:
    - "linux/CMakeLists.txt:41-46"
    - ".github/actions/build-linux/action.yml:71-80"
    - ".github/actions/build-linux/action.yml:90-117"
    - "lib/src/util.dart:77-81"
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

# Linux Flutter bundle omits required libssh2 sidecar

## Summary

The Linux native build produces `libssh2.so` as a shared dependency of `libgit2.so`, but the Linux Flutter CMake manifest declares only `libgit2.so` as a bundled library. A clean consumer application can therefore lack the sidecar required by the package contract.

## Expected Behavior

The effective platform packaging specification requires Linux packages to deliver both `libgit2.so` and the package-local `libssh2.so`. PPK-RF-02 requires every platform's required native artifacts to be carried into the assembled application.

## Actual Behavior

The Linux build action exports both libraries and explicitly links libgit2 against the exported shared libssh2. `linux/CMakeLists.txt` lists only `libgit2.so` in `git2dart_binaries_bundled_libraries`, so Flutter assembly has no declaration that carries `libssh2.so` into the consumer application.

## Steps to Reproduce

1. Inspect the Linux build action and confirm that it exports `libssh2.so` and links libgit2 to that shared file.
2. Inspect `git2dart_binaries_bundled_libraries` in `linux/CMakeLists.txt`.
3. Observe that only `libgit2.so` is declared for bundling.
4. Runtime reproduction in a clean consumer remains blocked until native artifacts are available.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260816-depth-inspection/report.md`

## Suspected Area

Linux Flutter packaging integration, specifically the boundary between the exported native artifact set and the CMake bundled-library declaration.

## Acceptance Criteria

1. A clean Linux Flutter consumer bundle contains both `libgit2.so` and the required `libssh2.so` sidecar.
2. The assembled application resolves the native dependency chain without relying on an ambient system libssh2.
3. A regression test or package inspection proves that the declared Linux bundle contains the complete artifact set.
4. Under the package closure policy, the corrected version is merged and published before this record can be resolved as fixed.

## Traceability

- Specs: platform packaging responsibilities, PPK-RF-02, and the Linux artifact model.
- Affected code: Linux CMake bundling, Linux native build/export action, and Linux dependency preload.
- Inspection finding: F-CONTRACT-01, candidate C-NLL-01.

## Resolution

Not started. Root cause confirmation, specification verdict, regression tests, delivery evidence, and publication evidence remain required.

## Agent Notes

- Source code was read only during registration.
- Severity is High and priority is P1 because a clean Linux consumer may fail to load the native dependency chain.
- Do not mark fixed from a local manifest edit alone. The package closure policy requires merge and a corrected published version.
