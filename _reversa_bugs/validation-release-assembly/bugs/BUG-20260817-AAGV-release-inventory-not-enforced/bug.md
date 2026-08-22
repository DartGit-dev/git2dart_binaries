---
schema_version: 1
id: BUG-20260817-AAGV
display_number: 9
title: Release assembly does not enforce native inventory
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17

origin:
  type: inspection
  external_ref: null

area: release
module: package-assembly
feature: validation-release-assembly
labels:
  - release-gate
  - partial-package
  - artifact-integrity

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1 static release path"
  suspected_triggers:
    - a named downloaded artifact exists but omits one or more required native files or ABIs

blocking: []
relationships:
  - bug: BUG-20260816-AAH6
    type: related-to
    state: proposed
    evidence: []
  - bug: BUG-20260817-AACM
    type: related-to
    state: proposed
    evidence: []
  - bug: BUG-20260817-AAFK
    type: related-to
    state: proposed
    evidence: []

traceability:
  specs:
    - _reversa_sdd/validation-release-assembly/requirements.md#functional-requirements
    - _reversa_sdd/validation-release-assembly/design.md#main-flow
  affected_code:
    - ".github/workflows/build_package.yml:592-675"
    - ".github/workflows/build_package.yml:686-723"
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

# Release assembly does not enforce native inventory

## Summary

The release job downloads named artifacts and then checks aggregate expanded size and pub dry-run validity, but never asserts the required per-platform filenames, ABI directories, or native manifest entries. A named but internally incomplete artifact can pass the final release boundary.

## Expected Behavior

Before dry-run or publication, release assembly must verify that every required platform artifact occupies its expected path and that every declared Android ABI and Apple slice is represented.

## Actual Behavior

Artifact download verifies only artifact names. The next gate sums whatever files are present under a hard-coded path list. `dart pub publish --dry-run` validates pub packaging metadata but does not enforce this repository's native inventory contract. No required-file, ABI-count, checksum, dependency, symbol, or manifest assertion runs in final assembly.

## Steps to Reproduce

1. Provide every named workflow artifact, but omit one required native file inside one artifact.
2. Let the release job download the named artifacts into their destination directories.
3. Keep the remaining payload below 256 MiB and pub-valid.
4. Observe that the size and dry-run gates do not test the missing native inventory entry before PR upload or push publication.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260817-depth-inspection/report.md`

## Suspected Area

Final package assembly and pre-publication validation in `publish_package`.

## Acceptance Criteria

1. Final assembly has a declarative expected inventory for every platform and architecture.
2. Any missing required file, ABI, slice, or dependency fails before dry-run and publication.
3. Validation consumes or recreates trusted checksums/manifests at the final handoff.
4. Regression tests inject partial artifacts and prove fail-closed behavior.
5. The corrected package is merged and published under the package closure policy.

## Traceability

- Effective spec: VRA-RF-02 and validation assembly main flow.
- Affected code: artifact downloads, expanded-size gate, pub dry-run, and publication step.
- Inspection finding: F-VRA-ERR-01 / F-VRA-DATA-01, candidate C-VRA-01.

## Resolution

Not started. Root cause confirmation, specification verdict, regression tests, delivery, and publication evidence remain required.

## Agent Notes

- Registration did not modify source code or tests.
- Bugs #1, #7, and #8 are upstream defects that can traverse the release boundary. They are related but not duplicates of the missing generic final-inventory gate.

