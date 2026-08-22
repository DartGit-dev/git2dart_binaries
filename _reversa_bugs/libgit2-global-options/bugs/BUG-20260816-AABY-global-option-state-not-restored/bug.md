---
schema_version: 1
id: BUG-20260816-AABY
display_number: 4
title: Global option tests fail to restore process state
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
module: dart-ffi
feature: libgit2-global-options
labels:
  - test-isolation
  - global-state
  - order-dependence

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1 static inspection"
  suspected_triggers:
    - Successful search-path or user-agent test
    - Assertion failure after a global option mutation
    - Incoming caching state different from the assumed default

blocking: []

relationships: []

traceability:
  specs:
    - _reversa_sdd/libgit2-global-options/requirements.md#non-functional-requirements
    - _reversa_sdd/libgit2-global-options/tasks.md#test-tasks
  affected_code:
    - "test/opts_bindings_integration_test.dart:15-163"
    - "test/opts_bindings_integration_test.dart:166-237"
    - "test/opts_bindings_integration_test.dart:241-355"
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

# Global option tests fail to restore process state

## Summary

The integration suite mutates process-global libgit2 options without reliably restoring the exact incoming values. Some tests never restore, one restores an assumed default, and most restoration statements are skipped when an assertion fails after mutation.

## Expected Behavior

The Testability NFR and LGO-TT-03 require every mutable global option to be restored in teardown after each test.

## Actual Behavior

Search path and user agent are never restored. Caching is unconditionally reset to 1 without reading its incoming value. Most other tests restore only at the end of the successful body rather than in teardown or finally. Only the pack maximum object size test uses `addTearDown`.

## Steps to Reproduce

1. Inspect every test that calls a global option setter.
2. Trace whether the exact initial value is captured.
3. Trace both the success path and an assertion-failure path after mutation.
4. Observe missing restoration, assumed defaults, and cleanup statements that are bypassed on failure.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260816-depth-inspection/report.md`

## Suspected Area

Test lifecycle and cleanup ownership for mutable process-global libgit2 state.

## Acceptance Criteria

1. Every mutated option captures its exact incoming value when a getter exists.
2. Restoration runs from teardown or finally even when an assertion fails.
3. Tests do not assume the incoming global state.
4. A regression test proves isolation across reordered tests and injected failures.
5. The corrected package is merged and published under the package closure policy.

## Traceability

- Effective spec: Testability NFR and LGO-TT-03.
- Affected code: global-option integration tests.
- Inspection finding: F-LGO-CONF-02 and merged state-hygiene findings, candidate C-LGO-02.

## Resolution

Not started. Root cause confirmation, specification verdict, regression tests, delivery, and publication evidence remain required.

## Agent Notes

- Registration did not modify tests or source code.
- This record merges all manifestations of the same exact-state restoration defect.
- Do not treat process exit as compliance with per-test restoration requirements.
