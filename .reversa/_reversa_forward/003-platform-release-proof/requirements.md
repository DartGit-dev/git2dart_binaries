# Requirements: Platform Release Artifact Proof

> Identifier: `003-platform-release-proof`
> Date: `2026-08-24`
> Reverse-extraction directory: `.reversa/_reversa_sdd/`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP / OPEN QUESTION

## 1. Executive summary

This feature makes each expanded release package prove that its native payload is
complete and loadable for Android, iOS, Windows, macOS, and Linux. It gives release
maintainers an inspectable per-platform record of the delivered native libraries and
their compiled versions, rather than treating build declarations as release proof.
The release gate must fail when a required platform package is incomplete, a required
library cannot be resolved in that platform's loader model, or a reported compiled
version conflicts with the pinned release inputs.

## 2. Context from the legacy system

| Source | Relevant excerpt | Confidence |
|-------|------------------|-------------|
| `.reversa/_reversa_sdd/architecture.md#Architectural purpose` | CI assembles an expanded package; the tracked checkout is only source and recipes. | 🟢 |
| `.reversa/_reversa_sdd/architecture.md#Architectural invariants` | Bindings/artifacts share one pinned libgit2 version and platform names must agree with loaders and package declarations. | 🟢 |
| `.reversa/_reversa_sdd/domain.md#Packaging rules` | Declared targets have platform-specific library sets and loading contracts. | 🟢 |
| `.reversa/_reversa_sdd/domain.md#Build, test, and publication rules` | Native builds normalize names and check exports, but no current CI result or completed package was verified. | 🟢 / 🔴 |
| `.reversa/_reversa_sdd/inventory.md#Native libraries and artifacts` | The expected artifacts and pinned native source versions are declared, while expanded binaries are absent locally. | 🟢 |
| `.reversa/_reversa_sdd/code-analysis.md#Module 2: Native loader and lifecycle` | Windows preloads OpenSSL and libssh2; Linux preloads libssh2; macOS relies on self-contained linkage; iOS uses the process image. | 🟢 |
| `.reversa/_reversa_sdd/code-analysis.md#Module 7: Validation and release assembly` | Existing Windows/macOS checks are partial; Android/iOS have workflow-level integration inventory, and Linux has only CMake-path assertions. | 🟢 |

## 3. Personas and usage scenarios

| Persona | Goal | Key scenario |
|---------|----------|---------------|
| Release maintainer | Qualify a package before publication | Inspects one platform report and sees every required artifact, loader result, and compiled-version comparison. |
| CI reviewer | Diagnose a failed release gate | Opens the retained proof for the failed platform instead of inferring package contents from build declarations. |
| Package consumer | Receive a usable native package | Installs the published artifact and the platform-native loader resolves the required package payload. |

## 4. New or changed business rules

1. **BR-01:** Release qualification must be based on the assembled platform payload, not solely on source declarations, CMake/podspec/Gradle metadata, or build inputs. 🟢
   - Legacy source: `.reversa/_reversa_sdd/domain.md#Build, test, and publication rules`
   - Type: new
2. **BR-02:** Each supported platform must have an explicit expected native-library set that reflects its established loader/linkage model: Android ABI payloads, iOS XCFrameworks/process image, Windows DLLs, macOS self-contained dylib, and Linux shared libraries. 🟢
   - Legacy source: `.reversa/_reversa_sdd/domain.md#Packaging rules`
   - Type: new
3. **BR-03:** The release record must distinguish source-version inputs from versions observed in compiled native libraries; inputs alone are not compiled-version proof. 🟢
   - Legacy source: `.reversa/_reversa_sdd/inventory.md#Native libraries and artifacts`
   - Type: new
4. **BR-04:** This feature is limited to release-artifact proof. It must not change the separate OpenSSL source-parity feature or the strict Git-validation feature. 🟢
   - Legacy source: `.reversa/_reversa_sdd/architecture.md#Scope`
   - Type: new

## 5. Functional requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|----|-----------|------------|--------------------|-------------|
| FR-01 | Create a per-platform proof from the final expanded package for Android, iOS, Windows, macOS, and Linux. | Must | A release candidate emits one independently identifiable result per supported platform and no result is derived only from source declarations. | 🟢 |
| FR-02 | Verify the complete intended native package set for each platform according to the existing platform packaging contract. | Must | The proof enumerates required artifacts and reports present/missing/unexpected status; missing required artifacts fail qualification. Android covers x86_64, arm64-v8a, x86, and armeabi-v7a. | 🟢 |
| FR-03 | Exercise every required external-library loading/linkage path using the platform's actual model. | Must | Windows proves libgit2.dll, libssh2.dll, and matching OpenSSL DLL loading; macOS proves self-containment and loader reachability; Linux proves libgit2.so plus package-local libssh2.so reachability; Android proves app-loader resolution of its complete ABI payload; iOS proves process-image/XCFramework symbol availability. A failure is terminal for that platform. | 🟢 |
| FR-04 | Record compiled native-library version proof and compare it against intended release inputs for libgit2, libssh2, and OpenSSL wherever that dependency is delivered or linked for the platform. | Must | Each applicable platform record contains the observed compiled version, intended version, comparison result, and the evidence source; an absent, unreadable, or mismatched required version fails qualification. | 🟢 |
| FR-05 | Retain human-readable and machine-readable evidence that identifies the release candidate, platform, artifact paths/names, loader/linkage results, compiled-version observations, and failures. | Must | A failed or successful candidate leaves a platform-scoped report available to the release reviewer before publication decision. | 🟡 |
| FR-06 | Make publication and PR release-artifact handoff depend on all required platform proofs. | Must | The release flow does not publish, and a PR candidate is not presented as qualified, when any required platform proof is missing or failing. | 🟢 |
| FR-07 | Preserve the existing source-only distinction. | Should | Local source-only runs report that compiled package proof is unavailable rather than claiming package or runtime success when generated artifacts are absent. | 🟢 |

## 6. Non-functional requirements

| Type | Requirement | Evidence or rationale | Confidence |
|------|-----------|----------------------------|-------------|
| Reliability | Qualification fails closed for missing payload elements, failed loading, unreadable compiled versions, or absent proof. | Existing loader errors rethrow and release gates are authoritative. `.reversa/_reversa_sdd/code-analysis.md#Module 2: Native loader and lifecycle` | 🟢 |
| Observability | Reports must separate declared input versions from observed compiled versions and identify the platform/ABI or architecture evaluated. | Existing workflow fingerprints inputs, but does not prove compiled versions per platform. `.reversa/_reversa_sdd/domain.md#Logs and monitored events` | 🟢 |
| Portability | Assertions must respect different platform contracts instead of applying a Windows DLL rule to static iOS/macOS linkage. | Platform packaging and loader modes are explicitly different. `.reversa/_reversa_sdd/domain.md#Packaging rules` | 🟢 |
| Security | Proof output must not expose publication secrets, private tokens, or unrelated host paths. | Release delivery uses CI/publisher credentials; proof needs only artifact and verification facts. | 🟡 |
| Scope control | No source-parity remediation, Git-behavior validation, consumer-repository modification, or production runtime behavior change belongs to this feature. | Explicit feature boundary. | 🟢 |

## 7. Acceptance criteria

```gherkin
Scenario: A complete candidate is qualified on every platform
  Given an expanded release candidate with generated bindings and native artifacts
  When release qualification runs for Android, iOS, Windows, macOS, and Linux
  Then it retains one platform-scoped proof containing inventory, loader/linkage, and compiled-version results
  And publication eligibility is granted only if every required proof passes

Scenario: A Windows candidate lacks a required OpenSSL runtime DLL
  Given a Windows release payload without a DLL required by the loader contract
  When platform proof evaluates the package
  Then the Windows proof identifies the missing DLL
  And the candidate is not qualified or published

Scenario: A Linux candidate has only CMake declarations but no loadable package dependency
  Given a Linux payload whose CMake declaration exists but whose required package-local dependency cannot be loaded
  When platform proof evaluates the assembled package
  Then the Linux proof fails on loader reachability
  And declaration-only evidence is not accepted as success

Scenario: Source-only checkout has no expanded artifacts
  Given a checkout without generated bindings or native release binaries
  When a local proof-oriented check is requested
  Then it reports unavailable package proof
  And it does not claim runtime or publication qualification
```

## 8. MoSCoW priority

| Item | MoSCoW | Rationale |
|------|--------|---------------|
| FR-01 through FR-04 | Must | They establish the requested platform payload, loading, and compiled-version evidence. |
| FR-05 | Must | Release reviewers need inspectable evidence, not a pass/fail assertion only. |
| FR-06 | Must | Evidence must be a release gate to protect publication. |
| FR-07 | Should | It keeps source-only diagnostics truthful without expanding runtime scope. |
| Security NFR | Should | Verification must not broaden secret exposure. |

## 9. Clarifications

### Session 2026-08-24

- **Q:** Which CI-visible evidence mechanism is authoritative for observing
  compiled versions of statically linked dependencies in iOS and macOS release
  artifacts, where a separately loadable dependency file may not exist?
  **R:** Use a reproducible build-time attestation emitted beside each final
  platform artifact. It must record the intended tagged inputs (libgit2,
  libssh2, OpenSSL), toolchain/SDK identity, every relevant archive/XCFramework
  slice path, and SHA-256 hashes of those inputs and emitted artifacts. It must
  also record version evidence extracted from available compiled metadata (for
  example archive/object strings, exported symbols, or other format-specific
  inspection) and a comparison result. For static iOS/macOS linkage, this is
  artifact identity and build provenance evidence, not a claim that a runtime
  loader can report a separately loadable dependency version. If a required
  version cannot be read from the final static artifact, the record is
  `unavailable`/not proven and qualification fails closed; source tags and
  workflow inputs alone never satisfy FR-04. The repository fact supporting
  this boundary is that iOS packages `libgit2.a`, `libssh2.a`, and OpenSSL
  archives into XCFrameworks, while macOS checks self-contained linkage with
  `nm` and `otool`; no existing runtime version API was established here.

- **Q:** Which retained artifact/report location and retention policy should be
  the release-review source of truth for the machine-readable and
  human-readable proofs?
  **R:** Store both reports as CI run-scoped workflow artifacts, partitioned by
  release candidate and platform/ABI (machine-readable JSON plus a concise
  human-readable text/Markdown report). The final gate consumes these artifacts
  from the same run and blocks publication if any required report is absent or
  failing. Retain them for the run's review window and the configured CI
  artifact retention period; use a longer explicit retention for release/tag
  runs than ephemeral PR runs, with the exact duration treated as repository CI
  policy rather than embedded in source or package payload. Do not write proof
  reports into the source checkout, published package, Git metadata, or logs
  that may contain secrets; sanitize paths to artifact-relative names. Existing
  workflow evidence supports this location model: it already uploads CI
  artifacts and uses `retention-days: 1` for intermediate platform outputs and
  `retention-days: 7` for PR release packages. The remaining operational
  uncertainty is the organization-specific duration for release/tag runs; it
  does not change the authoritative location or fail-closed gate semantics.

## 10. Gaps

- 🟡 Release/tag retention duration remains an operational CI-policy choice;
  this feature requires it to be explicitly configured and documented before
  implementation, but does not assume a repository-specific number.

## 11. Change history

| Date | Change | Author |
|------|-----------|-------|
| 2026-08-24 | Initial version generated by `/reversa-requirements` | reversa |
