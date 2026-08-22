---
schema_version: 1
id: BUG-20260816-AAFR
display_number: 2
title: Desktop fallback loses the initial native loader failure
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-16
updated: 2026-08-16

origin:
  type: inspection
  external_ref: null

area: runtime
module: native-runtime
feature: native-loader-lifecycle
labels:
  - diagnostics-loss
  - operational-risk

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1 static inspection"
  suspected_triggers:
    - Bare-name desktop load failure followed by package-root resolution failure
    - Bare-name desktop load failure followed by dependency preload failure

blocking: []

relationships:
  - bug: BUG-20260816-AAH6
    type: related-to
    state: proposed
    evidence: []

traceability:
  specs:
    - _reversa_sdd/native-loader-lifecycle/requirements.md#non-functional-requirements
    - _reversa_sdd/native-loader-lifecycle/design.md#main-flow
  affected_code:
    - "lib/src/util.dart:41-65"
    - "lib/src/util.dart:77-92"
    - "lib/src/util.dart:123-135"
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

# Desktop fallback loses the initial native loader failure

## Summary

Desktop loading records the initial bare-name failure only inside the final package-path open handler. If package-root resolution or dependency preload fails first, control never reaches that handler and the diagnostic output omits the original native loader failure.

## Expected Behavior

The effective Native Loader and Lifecycle Diagnostics NFR requires loader failures to retain both the name attempt and the package-path attempt. The fallback flow must preserve enough context to diagnose the complete attempt chain.

## Actual Behavior

After the bare-name failure, `_packageRoot()` and `_loadPlatformDependencies()` execute outside the inner fallback `try` block. A failure in either operation bypasses the only diagnostic that prints `firstError` together with the package fallback path. Dependency preload prints only its own error, and package-root failure surfaces as a generic `StateError`.

## Steps to Reproduce

1. On a desktop platform, make the initial bare-name `DynamicLibrary.open` fail.
2. Make package-root resolution fail, or make package-local dependency preload fail.
3. Observe the resulting error path in `lib/src/util.dart:41-65`.
4. Confirm that the diagnostic containing the initial failure at lines 58-63 is not reached.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260816-depth-inspection/report.md`

## Suspected Area

Desktop loader error aggregation across bare-name lookup, package-root resolution, dependency preload, and the final package-path open.

## Acceptance Criteria

1. Every exhausted desktop fallback path retains the initial bare-name failure and the failing fallback stage.
2. Package-root and dependency-preload failures produce actionable diagnostics without hiding the original loader error.
3. Regression tests cover root-resolution failure and dependency-preload failure after a bare-name failure.
4. Under the package closure policy, the corrected version is merged and published before this record can be resolved as fixed.

## Traceability

- Specs: Native Loader and Lifecycle Diagnostics NFR and desktop fallback main flow.
- Affected code: `_openLibrary`, `_loadPlatformDependencies`, and `_resolvePackageRoot` in `lib/src/util.dart`.
- Inspection finding: F-CONF-01, candidate C-NLL-02.
- Proposed relation: `related-to BUG-20260816-AAH6` because both affect the Linux package fallback chain; this is a hypothesis, not a causal claim.

## Resolution

Not started. Root cause confirmation, specification verdict, regression tests, delivery evidence, and publication evidence remain required.

## Agent Notes

- Source code was read only during registration.
- Severity is Medium and priority is P2 because the defect impairs diagnosis rather than directly proving data loss or a runtime crash.
- The proposed relation must not influence automated priority or impact scoring until evidence supports it.
