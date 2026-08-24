---
schema_version: 1
id: BUG-20260824-AAUE
display_number: 13
title: Mobile integration source contract uses the temporary test-app working directory
status: active
phase: delivering
severity: medium
priority: P1
created: 2026-08-24
updated: 2026-08-24

origin:
  type: ci-failure
  external_ref:
    provider: github-actions
    id: "32703598224"

area: build-release
module: ci-supply-chain
feature: validation-release-assembly
labels: [ci, mobile-integration, test-isolation]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "2/2"
  suspected_triggers:
    - "Android or iOS integration tests run from the generated mobile test application."
blocking: []
relationships:
  - bug: BUG-20260824-AAWS
    type: related-to
    state: supported
    evidence:
      - ref: evidence/reproduction.md
        observation: "The source-contract failure became visible after native artifact delivery was repaired."
traceability:
  specs:
    - .reversa/_reversa_sdd/deployment.md#deployment-gates
  affected_code:
    - test/opts_bindings_integration_test.dart
    - .github/workflows/build_package.yml
  root_cause:
    state: confirmed
    hypothesis: "A source-text assertion in the mobile integration suite reads a package-relative path that only exists in the repository checkout, not in the generated test application."
    causal_path:
      - "The workflow copies opts_bindings_integration_test.dart into a temporary mobile app."
      - "The test reads lib/src/opts_bindings.dart relative to that app."
      - "The package source lives in the dependency path, so the File read throws PathNotFoundException."
    evidence:
      - ref: evidence/reproduction.md
        observation: "Android and iOS logs both report PathNotFoundException at opts_bindings_integration_test.dart:179."
  reproduction_tests: []
  regression_tests:
    - test/opts_bindings_source_contract_test.dart
spec_verdict: null
change_set:
  - id: CHG-001
    kind: test
    artifact: test/opts_bindings_integration_test.dart
    purpose: Keep mobile integration coverage runtime-only.
    diff: fix/CHG-001.diff
  - id: CHG-002
    kind: test
    artifact: test/opts_bindings_source_contract_test.dart
    purpose: Run the source-text ABI contract from the repository test context.
    diff: fix/CHG-002.diff
closure:
  policy: package
  satisfied: false
resolution_kind: null
---

# Mobile integration source contract uses the temporary test-app working directory

## Summary

Android and iOS integration runs execute native FFI checks successfully, then fail on a repository-source assertion that cannot exist in the generated mobile test application.

## Expected Behavior

Mobile integration tests validate runtime behavior. Source contracts must run from a context that contains the package source.

## Actual Behavior

Both mobile jobs throw `PathNotFoundException` for `lib/src/opts_bindings.dart` after completing the runtime cache-option checks.

## Steps to Reproduce

1. Run the mobile jobs in GitHub Actions workflow `32703598224`.
2. Let the workflow copy `opts_bindings_integration_test.dart` into its temporary test application.
3. Observe the source-text assertion read the temporary app's missing `lib/src/opts_bindings.dart`.

## Evidence

- `evidence/reproduction.md`

## Suspected Area

Mobile test isolation in `build_package.yml` and the mixed source/runtime integration test.

## Acceptance Criteria

1. Android and iOS integration jobs run only the runtime FFI assertions.
2. The pointer-width source contract runs as a normal repository test.
3. GitHub `Build package` passes after delivery.

## Traceability

The failure blocks the platform-test deployment gate.

## Resolution

The test has been split locally. Delivery and green GitHub CI remain required by the package closure policy.

## Agent Notes

Keep the ABI source assertion. Do not replace it with a device-specific path lookup.
