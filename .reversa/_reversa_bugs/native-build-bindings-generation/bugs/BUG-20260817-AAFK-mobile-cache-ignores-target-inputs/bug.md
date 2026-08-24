---
schema_version: 1
id: BUG-20260817-AAFK
display_number: 8
title: Mobile native caches ignore target build inputs
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
module: native-build
feature: native-build-bindings-generation
labels:
  - cache-coherency
  - binary-compatibility
  - mobile

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1 static regression test"
  suspected_triggers:
    - Android android_api_level changes with the same ABI and native versions
    - iOS ios_deployment_target changes with the same SDK, architecture, and native versions
    - iOS openssl_target changes with the same SDK, architecture, and native versions

blocking: []
relationships: []

traceability:
  specs:
    - _reversa_sdd/native-build-bindings-generation/requirements.md#functional-requirements
    - _reversa_sdd/native-build-bindings-generation/requirements.md#non-functional-requirements
    - _reversa_sdd/native-build-bindings-generation/design.md#main-flow
  affected_code:
    - ".github/actions/build-android/action.yml:16-17"
    - ".github/actions/build-android/action.yml:43-47"
    - ".github/actions/build-android/action.yml:123-149"
    - ".github/actions/build-android/action.yml:172-235"
    - ".github/actions/build-ios/action.yml:19-28"
    - ".github/actions/build-ios/action.yml:32-64"
    - ".github/actions/build-ios/action.yml:99-190"
    - ".github/actions/build-ios/action.yml:243-258"
  root_cause: "Android android_api_level and iOS ios_deployment_target/openssl_target affected build flags but were omitted from toolchain fingerprints used by cache keys and manifest validation."
  reproduction_tests:
    - "test/mobile_cache_fingerprint_test.dart: mobile cache fingerprints include output-affecting target inputs"
  regression_tests:
    - "flutter test -j 1 test/mobile_cache_fingerprint_test.dart (2026-08-23: pass)"

spec_verdict: correct
change_set:
  - ".github/actions/build-android/action.yml: include android_api_level in toolchain fingerprint"
  - ".github/actions/build-ios/action.yml: include ios_deployment_target and openssl_target in toolchain fingerprint"
  - "test/mobile_cache_fingerprint_test.dart: assert all output-affecting target inputs"

closure:
  policy: package
  satisfied: false
resolution_kind: null
---

# Mobile native caches ignore target build inputs

## Summary

Android and iOS cache identity omits declared inputs that directly alter compiler, linker, deployment, or OpenSSL configuration. Different target configurations can therefore validate and reuse the same cached binary output.

## Expected Behavior

Every output-affecting platform input must participate in the cache key and validated manifest metadata. Changing a minimum OS/API target or OpenSSL target must rebuild the affected native slice.

## Actual Behavior

Android uses `android_api_level` in OpenSSL and CMake flags, but the fingerprint, cache key, and manifest omit it. iOS uses `ios_deployment_target` and `openssl_target` in its build environment and flags, but its fingerprint, cache key, and manifest omit both. Matching library versions, SDK/ABI, and toolchain values are sufficient to accept bytes built for the previous target configuration.

## Steps to Reproduce

1. Populate an Android or iOS native cache with the default target inputs.
2. Change only one omitted target input while preserving ABI/SDK, native versions, and toolchain identity.
3. Run the same composite action.
4. Observe that the old key can match and manifest validation cannot distinguish the new requested target from the cached target.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260817-depth-inspection/report.md`

## Suspected Area

Android and iOS native cache fingerprints, keys, and manifest metadata.

## Acceptance Criteria

1. Android API level participates in cache identity and validation.
2. iOS deployment target and OpenSSL target participate in cache identity and validation.
3. Changing any target input forces a rebuild for the affected ABI or slice.
4. Regression tests cover cross-configuration cache isolation.
5. The corrected package is merged and published under the package closure policy.

## Traceability

- Effective spec: NBG-RF-02 and NBG-RF-03, plus version/content-aware cache identity.
- Affected code: Android and iOS fingerprints, keys, manifests, and build flags.
- Inspection finding: F-NBG-CON-01 plus the Android API-level trace, candidate C-NBG-02.

## Resolution

Root cause is confirmed and the focused static regression test passes. The remaining requirements are a human specification verdict, hosted Android/iOS cache-miss/cache-hit evidence, merge, and publication of a corrected package version.

## Agent Notes

- Source change approved through Gate 2 on 2026-08-23.
- `flutter test -j 1 test/mobile_cache_fingerprint_test.dart` passed on 2026-08-23.
- Human specification verdict: correct (2026-08-23).
- See `evidence/fix-verification.md` for local evidence and CI boundary.
- Android and iOS are grouped because the same cache-identity defect omits output-affecting action inputs on both mobile builders.
