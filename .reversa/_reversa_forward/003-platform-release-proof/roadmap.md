# Roadmap: Platform Release Artifact Proof

> Identifier: `003-platform-release-proof`
> Date: `2026-08-24`
> Requirements: `.reversa/_reversa_forward/003-platform-release-proof/requirements.md`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP

## 1. Approach summary

Extend the existing `Build package` supply path with a fail-closed, final-payload
qualification stage. Each platform or Android ABI produces a normalized proof record
from its assembled export; the publish job consumes only those run-scoped records
before the existing dry-run/publication transition. The record contains inventory,
loader/linkage outcome, observed compiled-version evidence, intended build inputs,
and artifact digests. Static Apple dependencies use reproducible build-time
attestations beside final artifacts, never source tags alone as version proof.

This is a CI/release-evidence delta only. It neither changes the separate OpenSSL
source-parity policy nor adds strict Git-validation behavior.

## 2. Applied principles

`.reversa/principles.md` is absent, so no project principle can be evaluated or
rewritten by this plan. The extracted architectural invariants remain binding.

| Principle / invariant | How the feature relates | Status |
|---|---|---|
| Bindings and native artifacts use one pinned libgit2 version (`architecture.md#Architectural invariants`) | Compares observed compiled evidence with the workflow's intended release inputs. | follows |
| Artifact names match loader and package declarations (`architecture.md#Architectural invariants`) | Inventory and loader checks use the existing platform-specific contract. | follows |
| Publication follows required platform tests, size gate, and dry-run (`architecture.md#Architectural invariants`) | Adds platform-proof completeness as another predecessor of publication. | follows |
| Source checkout is not an expanded distribution (`domain.md#Packaging rules`) | Source-only execution reports unavailable proof rather than passing. | follows |

## 3. Technical decisions

| ID | Decision | Rationale | Rejected alternatives | Confidence |
|---|---|---|---|---|
| D-01 | Produce one CI artifact per platform, and per Android ABI, containing `proof.json` and `proof.md`. | `Build package` already exchanges native artifacts through GitHub Actions; partitioning makes a failure diagnosable and gateable. | One aggregate report; build declarations as proof; repository-tracked reports. | 🟢 |
| D-02 | Define a normalized proof schema with run/candidate identity, platform/ABI, artifact-relative paths, SHA-256, expected/present/unexpected inventory, linkage result, intended versions, observed version evidence, and terminal status. | FR-01–05 require reviewable human and machine records, while NFR security forbids host paths or secrets. | Logs only; source-version fields only; absolute paths. | 🟢 |
| D-03 | Verify final package payloads against each established loader/linkage model. | Platform contracts differ: Android has four ABI payloads, iOS uses process-image/XCFramework symbols, macOS self-contained dylib linkage, Linux package-local `libssh2.so`, and Windows runtime DLL preloading. | One Windows-style DLL check for every platform; metadata-only checks. | 🟢 |
| D-04 | For static iOS/macOS dependencies, emit a reproducible build-time attestation beside each final archive/XCFramework slice. It records intended tagged inputs, toolchain/SDK identity, relevant input and emitted-artifact SHA-256 values, readable compiled metadata, and comparison outcome. | Those platforms do not necessarily expose separately loadable dependency files; the clarification requires artifact identity/provenance without pretending a runtime version API exists. | Claim source tags prove compiled versions; require a nonexistent runtime dependency file. | 🟢 |
| D-05 | Treat absent, unreadable, mismatched, or unavailable required compiled-version evidence as a terminal platform-proof failure. | FR-04 and Reliability NFR explicitly require fail-closed qualification. | Warning-only result; successful source-tag comparison. | 🟢 |
| D-06 | Keep proof reports run-scoped workflow artifacts outside checkout, published payload, Git metadata, secret-bearing logs, and absolute host paths. Keep intermediate build artifacts at their current short retention; configure/document a longer bounded retention for release/tag proofs than PR proofs. | Clarification resolves location and policy boundary; repository already retains intermediate outputs for 1 day and PR release package for 7 days. | Commit reports; package reports; an unbounded retention promise; encode an unapproved fixed release duration in source. | 🟢 / 🟡 |
| D-07 | Make `publish_package` download and validate every expected proof in the same workflow run before `dart pub publish --dry-run` handoff/publish eligibility. | It preserves the extracted release state machine's downstream-publication invariant. | Publish after tests only; validate proofs in a later unrelated run. | 🟢 |
| D-08 | Keep OpenSSL source provenance and strict Git validation out of this feature. | They have separate active/specified work and would conflate proof consumption with dependency-origin or repository-history policy. | Modify source-parity implementation; introduce Git-history gates. | 🟢 |

## 4. Assumptions

No unresolved `[DUVIDA]` markers were accepted.

Operational decision before implementation: choose and document the exact bounded
release/tag proof-retention duration, subject to the repository/organization Actions
limit. This is an explicit CI policy value, not a package or source payload field.

## 5. Architectural delta

| Component | Legacy source file | Change type | Summary |
|---|---|---|---|
| Supply plane / GitHub Actions | `_reversa_sdd/architecture.md#Supply path` | rule-changed | Native-build exports gain proof production and the release job gains proof aggregation/gating. |
| Platform packaging | `_reversa_sdd/code-analysis.md#Module 5: Platform packaging` | rule-changed | Expected artifact inventories and actual loader/linkage assertions are made executable per platform/ABI. |
| Native build and bindings generation | `_reversa_sdd/code-analysis.md#Module 6: Native build and bindings generation` | rule-changed | Build outputs gain hashes and, for static Apple linkage, provenance/version attestations of final slices. |
| Validation and release assembly | `_reversa_sdd/code-analysis.md#Module 7: Validation and release assembly` | rule-changed | The release DAG blocks PR qualification/publishing on missing or failing proofs. |
| Release qualification state | `_reversa_sdd/state-machines.md#4. Release qualification` | rule-changed | Add `PlatformProof` after assembly and before size/dry-run/publish; any required failure transitions to `Failed`. |

## 6. Data-model delta

- Change summary: no persistent application data changes. CI gains an ephemeral,
  schema-versioned proof record and Apple static-linkage attestation records.
- Full details: `.reversa/_reversa_forward/003-platform-release-proof/data-delta.md`

## 7. External-contract delta

No HTTP, queue, gRPC, or GraphQL contract changes are in scope. GitHub Actions
workflow artifacts are an internal CI evidence boundary, so `interfaces/` is omitted.

## 8. Migration plan

1. Define the proof schema, artifact-relative path sanitization, and platform/ABI
   expectation matrix without changing dependency-source provenance.
2. Add proof production to each existing native-build/package assembly path, including
   static iOS/macOS attestations and their fail-closed readable-version rule.
3. Upload per-scope JSON and Markdown proofs as run-scoped artifacts; preserve the
   current 1-day intermediate policy and apply the approved bounded release/tag policy.
4. Make `publish_package` fetch, validate, summarize, and require every expected
   proof before release-package handoff or publication eligibility.
5. Exercise complete and failure candidates plus source-only unavailable behavior;
   verify reports contain no secrets, checkout writes, Git metadata, or host paths.

## 9. Risks and mitigations

| Risk | Impact | Probability | Mitigation |
|---|---|---|---|
| Static archive/XCFramework metadata lacks a readable required version. | high | medium | Record `unavailable`, fail that platform, and improve the build-time evidence extractor; do not substitute source tags. |
| A check validates an export/build declaration instead of the final payload. | high | medium | Run inventory/hash/linkage probes only after assembly from artifact-relative final paths. |
| Cross-platform tools yield inconsistent report shapes. | medium | medium | Version one normalized schema and test fixtures per platform/ABI. |
| Proof report leaks host paths or credentials. | high | low | Permit only sanitized relative paths and an explicit allow-list of fields; never dump environment or publish-action inputs. |
| Release/tag retention is unspecified. | medium | high | Block completion until an owner selects and documents a bounded policy consistent with Actions limits. |
| Scope expands into source-parity or strict Git validation. | high | medium | Keep those checks absent from action list and review the diff against D-08. |

## 10. Definition of done

- [ ] Each Android ABI and each desktop/Apple platform emits independently named
  JSON and Markdown proof from its final package payload.
- [ ] Every required artifact is inventoried, SHA-256 recorded, and validated by
  its actual loader/linkage model.
- [ ] Every applicable dependency has intended-versus-observed compiled evidence;
  static iOS/macOS evidence includes required attestation fields and fails closed
  if a required version is unreadable.
- [ ] The same-run release gate rejects an absent, invalid, or failing required proof
  before PR qualification/publish handoff or publication.
- [ ] Reports are platform/ABI partitioned, run-scoped, human + JSON, sanitized, and
  retained under explicit intermediate and release/tag policy.
- [ ] Source-only execution truthfully reports unavailable package proof.
- [ ] No OpenSSL source-parity or strict Git-validation behavior is changed.

## 11. Change history

| Date | Change | Author |
|---|---|---|
| 2026-08-24 | Initial version generated by `/reversa-plan` | reversa |
