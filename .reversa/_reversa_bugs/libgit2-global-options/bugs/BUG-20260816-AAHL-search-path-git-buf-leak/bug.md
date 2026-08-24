---
schema_version: 1
id: BUG-20260816-AAHL
display_number: 5
title: Search path test leaks native git_buf contents
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-16
updated: 2026-08-23

origin:
  type: inspection
  external_ref: null

area: runtime
module: dart-ffi
feature: libgit2-global-options
labels:
  - native-memory-leak
  - ownership
  - test-isolation

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1 native integration test"
  suspected_triggers:
    - Running the search-path integration test through its first and second getter calls

blocking: []

relationships:
  - bug: BUG-20260816-AABY
    type: related-to
    state: proposed
    evidence: []

traceability:
  specs:
    - _reversa_sdd/libgit2-global-options/requirements.md#responsibilities-and-rules
    - _reversa_sdd/libgit2-global-options/requirements.md#functional-requirements
    - _reversa_sdd/libgit2-global-options/design.md#alternative-flows
  affected_code:
    - "test/opts_bindings_integration_test.dart:168-200"
  root_cause: "The search-path test reset a libgit2-populated git_buf before disposing its first allocation."
  reproduction_tests:
    - "test/opts_bindings_integration_test.dart: get and set search path"
  regression_tests:
    - "flutter test -j 1 test/opts_bindings_integration_test.dart (2026-08-23: 12 passed)"

spec_verdict: null
change_set:
  - "test/opts_bindings_integration_test.dart: copy initial search path, dispose each git_buf population before reuse, and free caller-owned copies"

closure:
  policy: package
  satisfied: false
resolution_kind: null
---

# Search path test leaks native git_buf contents

## Summary

The search-path integration test overwrites the pointer, size, and reserved fields of a libgit2-populated `git_buf` before disposing its first contents. The only reference to that native allocation is lost.

## Expected Behavior

LGO-RF-04 and the ownership rule require callers to dispose libgit2-owned buffer contents with the matching libgit2 disposal function before resetting, reusing, or freeing the outer allocation.

## Actual Behavior

The first getter populates `buf`. Before the second getter, the test manually sets `ptr`, `size`, and `reserved` to zero. The later dispose therefore releases only the second population and cannot release the first allocation.

## Steps to Reproduce

1. Follow the first search-path getter at test lines 173-178.
2. Observe the manual field reset at lines 190-192 without a preceding `git_buf_dispose`.
3. Follow the second getter and the single dispose at lines 195-198.
4. Confirm that the first native pointer is no longer reachable.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260816-depth-inspection/report.md`

## Suspected Area

Native buffer ownership in the search-path integration test.

## Acceptance Criteria

1. Every successful `git_buf` population is disposed before the structure is reset or reused.
2. The outer allocation is freed after its final native contents are disposed.
3. A regression check or memory diagnostic proves that two getter calls do not orphan the first allocation.
4. The corrected package is merged and published under the package closure policy.

## Traceability

- Effective spec: ownership rule and LGO-RF-04.
- Affected code: search-path integration test.
- Inspection finding: F-LGO-DATA-01, candidate C-LGO-03.
- Proposed relation: `related-to BUG-20260816-AABY` because both are test-state hygiene defects; no common root cause is claimed.

## Resolution

Root cause is confirmed and the focused native integration suite passes. A human specification verdict was deliberately not inferred; merge and publication remain required by the package closure policy.

## Agent Notes

- Source change applied under the user's autonomous-fix instruction on 2026-08-23.
- Native integration suite passed with the bundled package DLLs on 2026-08-23.
- See `evidence/fix-verification.md` for ownership evidence.
- The relationship to the state-restoration bug is proposed and must not affect impact scoring.
