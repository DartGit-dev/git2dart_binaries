---
schema_version: 1
id: BUG-20260824-AAKJ
display_number: 11
title: Analyzer lint diagnostics block validation
status: active
phase: delivering
severity: medium
priority: P1
created: 2026-08-24
updated: 2026-08-24

origin:
  type: manual-report
  external_ref: null

area: build-release
module: ci-supply-chain
feature: validation-release-assembly
labels: []

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1"
  suspected_triggers: []

blocking: []
relationships: []

traceability:
  specs:
    - .reversa/_reversa_sdd/validation-release-assembly/requirements.md#Responsibilities-and-Rules
  affected_code:
    - test/opts_bindings_integration_test.dart
    - test/workflow_trigger_policy_test.dart
  root_cause:
    state: confirmed
    hypothesis: Test source directives and a newline assertion literal violate active analyzer rules.
    causal_path:
      - test source violates analyzer rule
      - flutter analyze returns exit code 1
      - validation gate is blocked
    evidence:
      - ref: evidence/reproduction.md
        observation: The analyzer reports exactly two diagnostics and exits with code 1.
    code_refs:
      - file: test/opts_bindings_integration_test.dart
        symbol: import directives
        commit: b9a2c3e1da53129ba14547849aa2abd6dbd4f7b3
      - file: test/workflow_trigger_policy_test.dart
        symbol: workflow publication assertion
        commit: b9a2c3e1da53129ba14547849aa2abd6dbd4f7b3
  reproduction_tests:
    - flutter analyze before the correction
  regression_tests:
    - flutter analyze after the correction

spec_verdict: spec-correta

change_risk:
  classification: low
  reasons:
    - Two test-only source edits
    - No public API, data, dependency, or runtime behavior change
    - Fully reversible

change_set:
  - id: CHG-001
    kind: test
    artifact: test/opts_bindings_integration_test.dart
    purpose: Order Dart import directives alphabetically.
    diff: fix/CHG-001.diff
  - id: CHG-002
    kind: test
    artifact: test/workflow_trigger_policy_test.dart
    purpose: Represent expected workflow newlines and interpolation literally.
    diff: fix/CHG-002.diff

closure:
  policy: package
  satisfied: false
resolution_kind: fixed
---

# Analyzer lint diagnostics block validation

## Summary

The validation command fails because two test-source lint diagnostics make `flutter analyze` exit with code 1.

## Expected Behavior

The validation and release assembly specification requires build and test gates to succeed before package assembly and publication. The test sources must pass the repository's active analyzer rules.

## Actual Behavior

`flutter analyze` reports `directives_ordering` and `use_raw_strings`, then exits with code 1.

## Steps to Reproduce

1. Check out commit `b9a2c3e1da53129ba14547849aa2abd6dbd4f7b3`.
2. Run `flutter analyze`.
3. Observe the two diagnostics and exit code 1.

## Evidence

- [Reproduction capsule](evidence/reproduction.md)

## Suspected Area

The affected files are test sources. The cause is confirmed from the analyzer diagnostics and the corresponding source text.

## Acceptance Criteria

1. Import directives follow the active ordering rule.
2. The workflow assertion represents the newline without the flagged escape.
3. `flutter analyze` exits with code 0.

## Traceability

- Spec: `.reversa/_reversa_sdd/validation-release-assembly/requirements.md#Responsibilities-and-Rules`
- Affected code: `test/opts_bindings_integration_test.dart` and `test/workflow_trigger_policy_test.dart`
- Reproduction and regression check: `flutter analyze`

## Resolution

The correction has been applied and locally verified. `flutter analyze` now
exits with code 0. Both affected test files pass when the integration test is
given its local packaged native-library root.

| Change | Type | Purpose |
| --- | --- | --- |
| CHG-001 | test | Alphabetize the Dart imports. |
| CHG-002 | test | Use literals that satisfy the analyzer without changing the asserted workflow text. |

The effective specification is correct because it already requires validation
gates to succeed. The source test code diverged from that requirement, so no
spec addendum is needed. The user continued with this recommended verdict.

The package closure policy still requires a merge and publication, neither of
which was requested or performed. The bug therefore remains active in
`delivering` and has no `DONE.md` lock.

Validation evidence:

- `flutter analyze`: passed, exit code 0.
- `flutter test -j 1 test/workflow_trigger_policy_test.dart`: passed, 2 tests.
- `flutter test -j 1 test/opts_bindings_integration_test.dart`: passed, 12 tests
  with `GIT2DART_BINARIES_PACKAGE_ROOT` set to the locally cached package.

## Agent Notes

- No duplicate was found among the ten existing bug records.
- The user explicitly requested registration and correction in one task.
- Do not alter release behavior, dependencies, or production code.
