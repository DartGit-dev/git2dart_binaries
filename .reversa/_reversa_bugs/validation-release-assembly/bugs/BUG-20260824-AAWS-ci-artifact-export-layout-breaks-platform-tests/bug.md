---
schema_version: 1
id: BUG-20260824-AAWS
display_number: 12
title: CI artifact export layout leaves platform test payloads unavailable
status: active
phase: delivering
severity: high
priority: P0
created: 2026-08-24
updated: 2026-08-24

origin:
  type: ci-failure
  external_ref:
    provider: github-actions
    id: "32700476293"

area: build-release
module: ci-supply-chain
feature: validation-release-assembly
labels: [ci, artifact-layout, regression]

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "4/4"
  suspected_triggers:
    - "Platform test jobs download a native artifact whose archive root contains export/."

blocking: []
relationships:
  - bug: BUG-20260824-AAKJ
    type: related-to
    state: supported
    evidence:
      - ref: evidence/reproduction.md
        observation: "Both defects block the validation and release assembly gate."

traceability:
  specs:
    - .reversa/_reversa_sdd/deployment.md#deployment-gates
    - .reversa/_reversa_sdd/architecture.md#architectural-invariants
  affected_code:
    - .github/actions/build-android/action.yml
    - .github/actions/build-linux/action.yml
    - .github/actions/build-macos/action.yml
    - .github/actions/build-windows/action.yml
    - .github/workflows/build_package.yml
  root_cause:
    state: confirmed
    hypothesis: "A provenance sidecar outside each export directory changes the uploaded artifact's least common ancestor, preserving export/ in the archive while tests expect its contents at their destination root."
    causal_path:
      - "Build jobs upload export/** together with a sibling provenance file."
      - "The artifact archive contains export/libgit2 and export/libssh2."
      - "Test jobs download into platform roots and resolve libraries without the extra export segment."
      - "Platform tests fail before runtime validation can run."
    evidence:
      - ref: evidence/reproduction.md
        observation: "The downloaded cache-linux artifact contains export/libgit2.so and export/libssh2.so, while run_linux_tests expects linux/libssh2.so."
  reproduction_tests: []
  regression_tests:
    - test/native_cache_action_contract_test.dart

spec_verdict: null
change_set:
  - id: CHG-001
    kind: configuration
    artifact: .github/actions/build-android/action.yml, .github/actions/build-linux/action.yml, .github/actions/build-macos/action.yml, .github/actions/build-windows/action.yml, .github/workflows/build_package.yml
    purpose: Keep provenance out of test-delivery artifact archives so export contents unpack at the platform root.
    diff: fix/CHG-001.diff
  - id: CHG-002
    kind: test
    artifact: test/native_cache_action_contract_test.dart
    purpose: Prevent test-delivery uploads from adding a sibling provenance path.
    diff: fix/CHG-002.diff
change_risk:
  classification: medium
  reasons:
    - "Changes the cross-job artifact layout for every supported platform."
    - "Does not alter native compilation or package runtime contracts."
closure:
  policy: package
  satisfied: false
resolution_kind: null
---

# CI artifact export layout leaves platform test payloads unavailable

## Summary

The GitHub Actions platform build jobs succeed, but the dependent platform test jobs cannot locate their native payloads. This blocks the release gate for every change.

## Expected Behavior

The validation and release assembly gates require generated bindings and platform artifacts to be injected into each test job before desktop and mobile tests run. See `.reversa/_reversa_sdd/deployment.md#deployment-gates`.

## Actual Behavior

GitHub Actions run `32700476293` downloaded the native artifacts successfully but the archive retained an `export/` directory. Android, iOS, macOS, and Linux tests then looked for their libraries one directory too high and failed.

## Steps to Reproduce

1. Push commit `d74f0f338a8a79a6313a8359e552fd78bae1b531` to branch `1.12.2`.
2. Let the `Build package` workflow complete its platform build and download steps.
3. Observe the platform test jobs resolve platform-library paths without the archive's retained `export/` segment.

## Evidence

- `evidence/reproduction.md`
- [Push run 32700476293](https://github.com/DartGit-dev/git2dart_binaries/actions/runs/32700476293)

## Suspected Area

The native-artifact upload contract in the platform build actions and the iOS assembly job.

## Acceptance Criteria

1. Test-delivery artifacts unpack native files directly at the paths consumed by Android, iOS, Linux, macOS, and Windows tests.
2. Provenance remains available to build-time release-proof validation without changing test artifact layout.
3. Static contract coverage prevents a sibling provenance path from reintroducing `export/` nesting.
4. The GitHub `Build package` workflow is green for the corrective commit.

## Traceability

The bug violates the deployment gate that injects platform artifacts into test jobs. Root cause is confirmed by the downloaded artifact layout and the failed job paths.

## Resolution

The corrective change set is applied locally. `flutter analyze` and the focused artifact-contract regression test pass. The package closure policy requires delivery and a successful GitHub Actions run before resolution.

## Agent Notes

Do not alter native build outputs or remove provenance from the build-time release-proof flow. Limit the repair to the test-delivery artifact contract.
