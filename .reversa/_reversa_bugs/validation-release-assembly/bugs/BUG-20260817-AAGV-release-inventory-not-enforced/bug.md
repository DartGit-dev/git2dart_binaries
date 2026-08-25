---
schema_version: 1
id: BUG-20260817-AAGV
display_number: 9
title: Release assembly does not enforce native inventory
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-25

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
  rate: "1/1 release-inventory regression test"
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
    - _reversa_sdd/validation-release-assembly/requirements.md#2026-08-25-re-extraction-contract
    - _reversa_sdd/addenda/003-platform-release-proof.md#regras-sob-vigilancia
  affected_code:
    - ".github/workflows/build_package.yml:592-675"
    - ".github/workflows/build_package.yml:686-723"
  root_cause:
    state: confirmed
    hypothesis: "The aggregate proof validator checks only record shape, status, safe present paths, and scope membership; it never establishes semantic proof completeness or binds proof hashes to the downloaded release payload."
    causal_path:
      - ".github/scripts/platform_release_proof.py: validate accepts empty inventory expected/present/missing/unexpected collections, an empty versions map, and null attestation."
      - ".github/workflows/build_package.yml:721-722 calls validate without the assembled payload root, so no proof digest can be compared with downloaded artifact bytes."
      - "A record with status=passed can therefore satisfy the aggregate gate while proving neither required payload contents nor byte identity."
    evidence:
      - ref: evidence/reproduction.md
        observation: "The current aggregate CLI accepted all eight scopes built from empty inventory and versions fields with null attestation."
      - ref: evidence/semantic-regression-20260825.md
        observation: "W002 identified the same semantic and proof-to-payload identity gap."
    code_refs:
      - file: .github/scripts/platform_release_proof.py
        symbol: validate
        commit: b372be1cc2a50e8d13a0ecaa5b4e61780ce92f17
      - file: .github/workflows/build_package.yml
        symbol: "publish_package / Qualify same-run platform proofs before release eligibility"
        commit: b372be1cc2a50e8d13a0ecaa5b4e61780ce92f17
  reproduction_tests:
    - "test/platform_release_proof_test.dart: empty-inventory aggregate input fails closed"
    - "test/platform_release_proof_test.dart: empty-versions aggregate input fails closed"
    - "test/platform_release_proof_test.dart: null-attestation aggregate input fails closed"
  regression_tests:
    - "test/platform_release_proof_test.dart: complete payload-backed proof set passes the aggregate CLI"
    - "test/platform_release_proof_test.dart: arbitrary-attestation aggregate input fails closed"
    - "test/platform_release_proof_test.dart: incomplete-apple-attestation aggregate input fails closed"
    - "test/platform_release_proof_test.dart: payload-byte-mismatch aggregate input fails closed"
    - "test/platform_release_proof_test.dart: producer proof with silent successful linkage round-trips"
    - "test/platform_release_proof_workflow_facts_test.dart: same-run platform proof artifacts are upstream of eligibility"

spec_verdict: spec-correta
change_risk:
  classification: high
  reasons:
    - "The change is on the final package-publication boundary; an overly strict or incorrect mapping can stop all release candidates."
    - "The contract spans producer proof records, downloaded artifacts, and the publish workflow, but is reversible and has no data migration."
change_set:
  - id: CHG-001
    kind: test
    artifact: test/platform_release_proof_test.dart
    purpose: "Reproduce empty semantic proof acceptance and protect complete payload-backed proof validation."
    diff: fix/CHG-001-tests-proposed.diff
  - id: CHG-002
    kind: code
    artifact: .github/scripts/platform_release_proof.py
    purpose: "Fail closed on incomplete proof semantics and bind each inventory digest to final payload bytes."
    diff: fix/CHG-002.diff
  - id: CHG-003
    kind: configuration
    artifact: .github/workflows/build_package.yml
    purpose: "Pass the assembled workspace to aggregate proof validation before later release gates."
    diff: fix/CHG-003.diff
  - id: CHG-004
    kind: test
    artifact: test/platform_release_proof_test.dart
    purpose: "Prove producer-to-validator silent-linkage compatibility and reject arbitrary, incomplete, or payload-unbound attestation."
    diff: fix/CHG-004-tests-proposed.diff
  - id: CHG-005
    kind: code
    artifact: .github/scripts/platform_release_proof.py
    purpose: "Require a platform-specific attestation contract, bind emitted digests to the corresponding final payload segment, and make successful silent linkage probes valid producer evidence."
    diff: fix/CHG-005.diff

closure:
  policy: package
  satisfied: false
resolution_kind: fixed
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
- `evidence/semantic-regression-20260825.md`
- `evidence/reproduction.md`
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

- Corrective Gate 1 (approved and applied): test/platform_release_proof_test.dart adds producer-to-validator linkage and required-attestation regression cases; recorded in evidence/corrective-gate-1-red.md.
- Corrective Gate 2 (approved and applied): .github/scripts/platform_release_proof.py now enforces the attestation contract and payload-segment digest binding; recorded in evidence/corrective-gate-2-green.md.
- Mandatory independent review: approved; recorded in evidence/independent-review-corrective.md. The review leaves hosted assembly, merge, publication, package closure, and human spec verdict unresolved.

- Effective spec: VRA-RF-02 and validation assembly main flow.
- Affected code: artifact downloads, expanded-size gate, pub dry-run, and publication step.
- Inspection finding: F-VRA-ERR-01 / F-VRA-DATA-01, candidate C-VRA-01.

## Resolution

Root cause is confirmed by deterministic local reproduction and static workflow inspection. The corrective Gate 1 tests demonstrated the reviewer findings in red; corrective Gate 2 applied the approved validator-only update and reached targeted green evidence on 2026-08-25. The fresh mandatory independent high-risk review approved the correction. The user selected spec_verdict: spec-correta. The fix is therefore delivered locally, but this package-policy bug remains active/delivering with closure unsatisfied.

### Remaining package-delivery evidence

1. A hosted GitHub Actions release-assembly run must execute the amended publish_package path and show the aggregate platform-proof gate passing before downstream release eligibility.
2. The reviewed change set must be merged into its delivery branch.
3. The resulting package version must be published, with evidence that the released package contains the validated native payload and provenance.

No spec addendum or DONE.md was created because package closure is not yet satisfied.

## Agent Notes

- Source change applied under the user's autonomous-fix instruction on 2026-08-23.
- See `evidence/fix-verification.md` for inventory scope and CI boundary.
- Bugs #1, #7, and #8 are upstream defects that can traverse the release boundary. They are related but not duplicates of the missing generic final-inventory gate.
- On 2026-08-25 the user chose to append semantic-regression occurrence `003-platform-release-proof/W002` to this unlocked bug instead of creating a separate bug. The occurrence adds evidence about empty versions, null attestation, and the missing proof-hash-to-payload-byte join. The user classified it as `high / P1`, matching the existing aggregate fields.
