# Requirements: OpenSSL source-build provenance parity

> Identifier: `002-openssl-source-parity`
> Date: `2026-08-24`
> Reverse-extraction directory: `.reversa/_reversa_sdd/`
> Confidence: ?? CONFIRMED, ?? INFERRED, ?? GAP / OPEN QUESTION

## 1. Executive summary

The release factory shall make the provenance of the OpenSSL dependency deterministic for every supported native platform. It replaces the current Windows reliance on a runner-discovered installation with the explicitly pinned OpenSSL source build used by the release configuration. If a supported platform cannot build that source, its release artifact may proceed only through a documented exception that proves the exact OpenSSL version equals the version used by every other release platform. This prevents an arbitrary runner-installed Windows version from becoming part of a publishable package. ??

## 2. Context from the legacy system

| Source | Relevant excerpt | Confidence |
|-------|------------------|-------------|
| `_reversa_sdd/architecture.md#Architectural purpose` | Native sources are produced in the supply plane and the expanded CI package is the release product. | ?? |
| `_reversa_sdd/architecture.md#Component responsibilities` | Native build/binding generation produces matching ABI and native libraries from upstream source tags and toolchains. | ?? |
| `_reversa_sdd/native-build-bindings-generation/requirements.md#Responsibilities and Rules` | The declared OpenSSL input is 3.0.15, but Windows currently discovers and fingerprints a runner-installed version; the target policy requires a pinned source build on every platform, or exact-version parity for an approved non-source path. | ?? user-confirmed policy; ?? observed Windows divergence |
| `_reversa_sdd/native-build-bindings-generation/design.md#Platform Variants` | Windows copies detected runtime DLLs rather than consuming the declared input, while the target requires source provenance or release-time parity proof. | ?? workflow evidence; ?? user-confirmed policy |
| `_reversa_sdd/code-analysis.md#Module 6: Native build and bindings generation` | Current platform pipelines fingerprint declared versions, validate manifests, and rebuild pinned upstream sources on cache miss; Windows additionally discovers/copies versioned runtime DLLs. | ?? |

## 3. Personas and usage scenarios

| Persona | Goal | Key scenario |
|---------|----------|---------------|
| Release maintainer | Produce a publishable package whose TLS dependency version and origin are controlled. | A native build starts on any supported platform and records the configured OpenSSL version rather than accepting a runner installation. |
| Package consumer | Receive compatible native artifacts with consistent crypto dependency versions. | The consumer installs a release package built for its platform without relying on an undocumented runner-specific OpenSSL version. |
| CI reviewer | Decide whether a release is eligible. | The reviewer can see source-build provenance for every platform, or the documented exception and exact-version-parity evidence. |

## 4. New or changed business rules

1. **BR-01:** Every release platform shall use the one explicitly pinned OpenSSL version declared by the release configuration. ??
   - Legacy source: `_reversa_sdd/native-build-bindings-generation/requirements.md#Responsibilities and Rules`
   - Type: changed
2. **BR-02:** A platform shall build its pinned OpenSSL version from source as the normal release path; runner discovery is not an acceptable source of dependency provenance. ?? user-confirmed policy
   - Legacy source: `_reversa_sdd/native-build-bindings-generation/design.md#Platform Variants`
   - Type: changed
3. **BR-03:** A non-source exception is permitted only when source building is infeasible for that platform and its documented release validation proves exact version equality with all other release-platform artifacts. ?? user-confirmed policy
   - Legacy source: `_reversa_sdd/native-build-bindings-generation/requirements.md#Functional Requirements`
   - Type: new
4. **BR-04:** An artifact whose OpenSSL version is arbitrary, undisclosed, mismatched, or lacks the required provenance/parity evidence is release-ineligible. ?? user-confirmed policy
   - Legacy source: `_reversa_sdd/native-build-bindings-generation/requirements.md#Functional Requirements`
   - Type: new

## 5. Functional requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|----|-----------|------------|--------------------|-------------|
| FR-01 | Define one explicit OpenSSL version input that is consumed by every supported platform native build. | Must | Each platform build records the same configured OpenSSL version in its build evidence and native artifact metadata. | ?? |
| FR-02 | Build the configured OpenSSL version from source for Windows and every other supported platform in the normal release path. | Must | No normal platform build selects, fingerprints, or copies a runner-discovered OpenSSL installation as its dependency source. | ?? user-confirmed policy |
| FR-03 | Make Windows consume the same explicit source-build provenance policy as the other platforms. | Must | A Windows artifact is produced from the configured source version and its packaged OpenSSL runtime files correspond to that build. | ?? user-confirmed policy |
| FR-04 | Preserve version/provenance identity in cache and artifact validation. | Must | A cached or uploaded native artifact is rejected when its recorded OpenSSL version or provenance does not match the configured release policy. | ?? |
| FR-05 | Support a constrained non-source fallback only when source building is infeasible. | Should | The exception documents the affected platform and infeasibility, and release validation proves its exact OpenSSL version equals every source-built platform artifact before release eligibility. | ?? user-confirmed policy |
| FR-06 | Block release eligibility for arbitrary runner-installed, mismatched, or unproven OpenSSL versions. | Must | A build or release validation reports a failure before publication when normal source provenance is absent and the fallback proof is incomplete or unequal. | ?? user-confirmed policy |

## 6. Non-functional requirements

| Type | Requirement | Evidence or rationale | Confidence |
|------|-----------|----------------------------|-------------|
| Reproducibility | The selected OpenSSL version and provenance shall be deterministic inputs to cache/artifact identity, not runner environment state. | `_reversa_sdd/code-analysis.md#Module 6: Native build and bindings generation` | ?? |
| Supply chain | Native TLS dependency sources shall be attributable to the configured version for all platforms. | `_reversa_sdd/native-build-bindings-generation/requirements.md#Cross-platform dependency parity` | ?? user-confirmed policy |
| Compatibility | Platform packaging shall continue to contain the OpenSSL runtime files required by the existing loader/package contracts. | `_reversa_sdd/code-analysis.md#Module 6: Native build and bindings generation` | ?? |
| Observability | Build/release evidence shall state the configured version, provenance path, and fallback parity verdict for each platform. | `_reversa_sdd/native-build-bindings-generation/design.md#Decisions, State, Observability` | ?? |
| Release safety | This feature shall not add strict Git validation requirements; that concern is explicitly out of scope for this feature. | User-provided scope boundary | ?? |

## 7. Acceptance criteria

```gherkin
Scenario: Source-built pinned dependency on every platform
  Given a release build is configured with one explicit OpenSSL version
  When each supported platform native build runs on its normal path
  Then every platform uses a source build of that exact version
  And every native artifact records matching version and provenance evidence

Scenario: Windows no longer accepts runner discovery
  Given a Windows runner has a different OpenSSL installation available
  When the Windows native build runs
  Then the runner installation is not selected as the dependency source
  And the packaged Windows runtime files derive from the configured source build

Scenario: Source build is infeasible on one platform
  Given a documented source-build infeasibility for one supported platform
  When release validation evaluates that platform's non-source artifact
  Then it proves the exact OpenSSL version equals every other release-platform artifact
  And release eligibility continues only when the proof succeeds

Scenario: Version or provenance mismatch
  Given a native cache or artifact has an arbitrary, mismatched, or unproven OpenSSL version
  When build or release validation evaluates it
  Then the artifact is rejected
  And publication eligibility is blocked
```

## 8. MoSCoW priority

| Item | MoSCoW | Rationale |
|------|--------|---------------|
| FR-01 | Must | A single explicit version is the basis for parity. |
| FR-02 | Must | Source provenance is the requested normal policy for every platform. |
| FR-03 | Must | Windows is the identified noncompliant path. |
| FR-04 | Must | Cached artifacts must not reintroduce divergent provenance. |
| FR-05 | Should | It preserves release continuity only under strict documented equivalence. |
| FR-06 | Must | Unproven dependency versions cannot be published. |
| Reproducibility NFR | Must | Runner state must not determine release dependency identity. |

## 9. Clarifications

> No clarification session has been recorded yet. Run `/reversa-clarify` when an `[OPEN QUESTION]` remains.

## 10. Gaps

- No open questions. The policy specifies the normal source-build path and the permitted exact-version-parity fallback. ??

## 11. Change history

| Date | Change | Author |
|------|-----------|-------|
| 2026-08-24 | Initial version generated by `/reversa-requirements` | reversa |
