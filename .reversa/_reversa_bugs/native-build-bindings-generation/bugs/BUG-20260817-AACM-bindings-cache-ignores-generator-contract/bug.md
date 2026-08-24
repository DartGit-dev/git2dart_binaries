---
schema_version: 1
id: BUG-20260817-AACM
display_number: 7
title: Binding cache ignores the generator contract
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-23

origin:
  type: inspection
  external_ref: null

area: build
module: bindings-generation
feature: native-build-bindings-generation
labels:
  - cache-coherency
  - stale-generated-code
  - abi-risk

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1 static regression test"
  suspected_triggers:
    - ffigen.yaml changes without a generation-action or libgit2-version change
    - the resolved ffigen implementation changes while the native cache key remains the same

blocking: []
relationships:
  - bug: BUG-20260817-AAFK
    type: related-to
    state: proposed
    evidence: []

traceability:
  specs:
    - _reversa_sdd/native-build-bindings-generation/requirements.md#functional-requirements
    - _reversa_sdd/native-build-bindings-generation/requirements.md#non-functional-requirements
    - _reversa_sdd/native-build-bindings-generation/design.md#main-flow
  affected_code:
    - ".github/actions/generate-bindings/action.yml:13-47"
    - ".github/actions/generate-bindings/action.yml:72-113"
    - "ffigen.yaml:1-14"
    - "pubspec.yaml:19-20"
  root_cause: "The bindings-cache key omitted ffigen.yaml and pubspec.lock, so configuration and resolved-generator changes could reuse an older bindings.dart."
  reproduction_tests:
    - "test/generate_bindings_cache_test.dart: binding cache key fingerprints ffigen configuration and lockfile"
  regression_tests:
    - "flutter test -j 1 test/generate_bindings_cache_test.dart (2026-08-23: pass)"

spec_verdict: correct
change_set:
  - ".github/actions/generate-bindings/action.yml: fingerprint ffigen.yaml and pubspec.lock in restore/save keys"
  - "test/generate_bindings_cache_test.dart: require both inputs in both cache keys"

closure:
  policy: package
  satisfied: false
resolution_kind: null
---

# Binding cache ignores the generator contract

## Summary

The binding cache key and manifest identify the runner, toolchain, libgit2 version, generation action, and manifest utility, but omit `ffigen.yaml` and the resolved ffigen implementation. A matching cache can therefore copy an older `bindings.dart` and skip generation after the binding contract changes.

## Expected Behavior

Any input that can change generated Dart declarations must participate in cache identity or validation. A configuration or generator-version change must regenerate `lib/src/bindings.dart`.

## Actual Behavior

The cache key hashes only the composite action and manifest utility in addition to runner/toolchain/libgit2 values. Validation proves that cached bytes match their own manifest, not that they were produced by the current ffigen configuration and dependency. A valid cache sets `valid=true`, copies `bindings.dart`, and gates off all generation steps.

## Steps to Reproduce

1. Populate the bindings cache for the current action, toolchain, and libgit2 version.
2. Change only `ffigen.yaml` or the resolved ffigen implementation.
3. Run the generation action with the same runner/toolchain/libgit2 identity.
4. Observe that the prior cache key can match, the old file validates, and ffigen is skipped.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260817-depth-inspection/report.md`

## Suspected Area

Binding cache identity and manifest metadata in the generation composite action.

## Acceptance Criteria

1. All output-affecting binding configuration and generator inputs participate in cache identity or manifest validation.
2. A configuration-only change forces regeneration.
3. Cache-hit and cache-miss outputs are checked for the current generation contract.
4. A regression test covers configuration and generator-version invalidation.
5. The corrected package is merged and published under the package closure policy.

## Traceability

- Effective spec: NBG-RF-01 and NBG-RF-03, plus the version/content-aware cache design.
- Affected code: binding fingerprint, key, validation, and gated generation steps.
- Inspection finding: F-NBG-ERR-01 / F-NBG-DATA-01, candidate C-NBG-01.

## Resolution

Root cause is confirmed and the focused static regression test passes. The remaining requirements are a human specification verdict, a GitHub Actions cache-miss/cache-hit run, merge, and publication of a corrected package version.

## Agent Notes

- Source change approved through Gate 2 on 2026-08-23.
- `flutter test -j 1 test/generate_bindings_cache_test.dart` passed on 2026-08-23.
- Human specification verdict: correct (2026-08-23).
- See `evidence/fix-verification.md` for local evidence and the CI boundary.
- `BUG-20260816-AAH2` affects handwritten wrapper ABI widths. It is related evidence at the ABI boundary but is not a duplicate of this cache-invalidation defect.
