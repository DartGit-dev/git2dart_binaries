# Actions: Platform Release Artifact Proof

> Identifier: `003-platform-release-proof`
> Date: `2026-08-24`
> Roadmap: `.reversa/_reversa_forward/003-platform-release-proof/roadmap.md`

## Summary

| Metric | Value |
|---------|-------|
| Total actions | 11 |
| Parallelizable (`[//]`) | 1 |
| Longest dependency chain | 8 |

## Phase 1, Preparation

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|------------|--------|
| T001 | Create the versioned platform-proof helper contract: expected platform/ABI inventory matrix, artifact-relative path validation, allow-listed report fields, stable failure codes, and fail-closed schema validation. | - | - | `.github/scripts/platform_release_proof.py` | ?? | `[X]` |

## Phase 2, Tests

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|------------|--------|
| T002 | Add helper fixtures and tests for normalized records, SHA-256 inventory states, absolute-path/secret-like field rejection, and `unavailable` as non-qualifying when proof is required. | T001 | - | `test/platform_release_proof_test.dart` | ?? | `[X]` |
| T003 | Add workflow-contract tests for independently named Android-ABI and desktop/Apple proof artifacts, same-run proof retrieval, and ordering before dry-run/publish eligibility. | - | `[//]` | `test/platform_release_proof_workflow_test.dart` | ?? | `[X]` |
| T004 | Add negative fixtures for missing payload members, loader/linkage failure, unknown schema, unreadable/mismatched compiled version, and source-only unavailable output. | T002 | - | `test/platform_release_proof_test.dart` | ?? | `[X]` |

## Phase 3, Core

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|------------|--------|
| T005 | Implement final-payload probes for the Android ABI, Windows, Linux, and macOS contracts: expected/present/unexpected inventory, digest/size, actual loader or linkage result, and intended-versus-observed dependency evidence. | T001, T002 | - | `.github/scripts/platform_release_proof.py` | ?? | `[X]` |
| T006 | Implement iOS/macOS static-linkage attestations from final XCFramework/archive slices, including input and emitted SHA-256 values, toolchain/SDK identity, readable compiled metadata, and terminal failure for unavailable or mismatched evidence. | T005 | - | `.github/scripts/platform_release_proof.py` | ?? | `[X]` |
| T007 | Render sanitized, schema-versioned `proof.json` and concise `proof.md` records, including candidate/run identity, human diagnostics, and explicit source-only `unavailable` diagnostics that cannot qualify a release. | T006 | - | `.github/scripts/platform_release_proof.py` | ?? | `[X]` |

## Phase 4, Integration

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|------------|--------|
| T008 | Invoke the proof helper after each assembled platform/ABI export, upload paired run-scoped reports under independently named artifacts, and configure the approved bounded release/tag-proof retention separately from the existing short-lived intermediate artifacts. | T005, T007, T003 | - | `.github/workflows/build_package.yml` | ?? / ?? | `[X]` |
| T009 | Extend `publish_package` to download every expected proof from the same workflow run, reject unknown schema, missing, invalid, failing, or required-unavailable records, and place the aggregate gate before existing size, dry-run, PR handoff, and publication transitions. | T008, T004 | - | `.github/workflows/build_package.yml` | ?? | `[X]` |
| T010 | Update workflow-contract coverage to assert the complete proof producer matrix, bounded retention configuration, and fail-closed publish gate without asserting OpenSSL source-parity or Git-history behavior. | T008, T009 | - | `test/platform_release_proof_workflow_test.dart` | ?? / ?? | `[X]` |

## Phase 5, Polish

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|------------|--------|
| T011 | Add reviewer-facing report assertions for concise sanitized diagnostics and JSON/Markdown parity, covering pass, failure, and source-only unavailable candidates without leaking checkout paths, Git metadata, or publication inputs. | T004, T007 | - | `test/platform_release_proof_test.dart` | ?? | `[X]` |

## Execution notes

- The bounded release/tag proof-retention value is an approved CI-policy input; do not invent a repository-specific number during implementation.
- Scope boundary: do not modify `002-openssl-source-parity`, OpenSSL source provenance policy, strict Git validation, consumer repositories, package payload contents, or runtime behavior.

## Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-24 | Initial version generated by `/reversa-to-do` | reversa |
