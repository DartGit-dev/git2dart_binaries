# Reversa Depth Inspection Confidence Report

## Scope and method

The seven feature folders were inspected with six read-only diagnostic lenses: specification conformity, test coverage, data flow, contracts and integrations, error states, and concurrency and consistency. Source code and tests were not changed. `F:\git2dart` was not read, so all consumer-side links remain explicitly external or inferred.

The core Reviewer score of **80.5%** remains the canonical SDD marker-count score. This report does not invent a new numeric score from non-equivalent depth findings. It records qualitative confidence changes and canonical defects discovered after that report.

## Canonical defect summary

| # | ID | Severity | Feature | Confirmed defect |
|---:|---|---|---|---|
| 1 | `BUG-20260816-AAH6` | High | native-loader-lifecycle / platform-packaging | Linux Flutter bundle omits required `libssh2.so` sidecar |
| 2 | `BUG-20260816-AAFR` | Medium | native-loader-lifecycle | Desktop fallback loses the initial native loader failure |
| 3 | `BUG-20260816-AAH2` | Critical | libgit2-global-options | Eleven global-option wrappers use incorrect ABI widths |
| 4 | `BUG-20260816-AABY` | Medium | libgit2-global-options | Option tests fail to restore exact process-global state |
| 5 | `BUG-20260816-AAHL` | Medium | libgit2-global-options | Search-path test leaks the first native `git_buf` contents |
| 6 | `BUG-20260817-AADQ` | Low | android-tls-bootstrap | Temporary-directory failures bypass helper diagnostics |
| 7 | `BUG-20260817-AACM` | High | native-build-bindings-generation | Binding cache ignores the ffigen generator contract |
| 8 | `BUG-20260817-AAFK` | High | native-build-bindings-generation | Mobile native caches ignore target build inputs |
| 9 | `BUG-20260817-AAGV` | High | validation-release-assembly | Final release assembly does not enforce native inventory |
| 10 | `BUG-20260817-AAKR` | Medium | dart-ffi-facade | Public error constructor accepts invalid native pointers |

Severity distribution: one Critical, four High, four Medium, and one Low. All records are open and triaging under package closure policy. None is marked fixed from static analysis alone.

## Confidence changes by feature

### Native loader lifecycle

- Increased: exact platform selection, package-root fallback, cache, lazy-library, and initialization flows are statically traced.
- Decreased: Linux clean-consumer packaging and fallback diagnostic retention are confirmed defects.
- Remains red: init-result policy, init-before-options ordering, shutdown ownership, Windows missing-directory policy, and native runtime replay.

### libgit2 global options

- Increased: all 33 public wrapper names, 13 signature families, ownership paths, and current official libgit2 1.9.6 width contracts were mapped.
- Decreased materially: 11 wrappers have a confirmed pointer-width ABI defect; test restoration and `git_buf` ownership assertions are contradicted by code.
- Remains red: generated binding artifact, complete discriminator comparison, failing-status replay, and concurrency ownership.

### Android TLS bootstrap

- Increased: the two CA copies are identical in this snapshot, and the asset key, flushed write, retry state, and native setter boundary are traced.
- Decreased: directory-resolution diagnostics have a confirmed bypass; no local helper test exists.
- Remains red: byte-view occurrence, concurrent first-call policy, cached-file revalidation, native application, status handling, pointer ownership, and Android HTTPS.

### Platform packaging

- Increased: producer-to-injection and manifest/name recipes are traced for all five platforms; current CA copies match.
- No new defect beyond exact dedupe of Linux bug #1.
- Remains red: current native inventory, assembled desktop consumer applications, non-x86_64 Android runtime, iOS device runtime, architecture policy, Apple version policy, signing, and notarization.

### Native build and bindings generation

- Increased: manifest metadata, exact file-set, SHA-256, size, cache naming, symbol checks, version alignment, and collision avoidance are confirmed statically.
- Decreased materially: binding and mobile cache identities omit output-affecting inputs, creating confirmed stale-output paths.
- Remains red: current generated/native artifacts, current workflow caches, post-upload provenance, immutable upstream identity, SBOM, signatures, and attestations.

### Validation and release assembly

- Increased: required job DAG and PR non-publication are structurally fail-closed for configured events.
- Decreased: the claimed final per-platform inventory gate is absent.
- Remains red: current CI/payload/publication evidence, branch eligibility, duplicate-publication policy, credential/protection state, exact archive-size equivalence, and external consumer compatibility.

### Dart FFI facade

- Increased: barrel exports, null string/error paths, SHA-1 predicate, and borrowed-memory non-freeing behavior are traced.
- Decreased: internal-only error construction is publicly exposed and can bypass pointer guards; no direct facade boundary tests exist.
- Remains red: validator semantics, borrowed error lifetime/snapshot expectation, thread attribution, current generated ABI, and external consumer compatibility.

## Genuine unresolved decisions

The ten decisions in `_reversa_sdd/questions.md` remain unresolved and must not be inferred:

1. Full versus lightweight ref/object validation.
2. Initialization ordering and shutdown ownership.
3. Windows missing-package fallback policy.
4. Authoritative complete global-options ABI evidence.
5. Android TLS consumer sequence and first-call serialization.
6. Apple/pub version synchronization.
7. Windows OpenSSL provenance policy.
8. Cross-repository compatibility matrix and gate ownership.
9. Authoritative current release evidence and branch eligibility.
10. Publication and supply-chain controls.

Depth inspection did not convert any of these stakeholder choices into assumed requirements.

## Residual evidence blockers

- `lib/src/bindings.dart` and all current native artifact roots are absent from the tracked checkout.
- No authoritative current workflow run, restored cache, expanded release package, or pub.dev publication result was inspected.
- The host cannot execute macOS/iOS/Android target behavior, and no physical-device or multi-ABI evidence is local.
- No clean desktop consumer application, Android HTTPS scenario, native failure injector, or deterministic facade error fixture is available.
- External GitHub protections, token scopes, publisher internals, signing/notarization, and upstream provenance controls are outside repository evidence.
- `F:\git2dart` was intentionally not read; the two-repository product boundary remains an inferred integration contract except where this repository documents it.

## Final disposition

Depth inspection is complete for all seven features. Confirmed causal deviations were promoted only after canonical deduplication. Conditional risks, coverage gaps, policy choices, and external-state questions remain observations or lacunae. The original SDD confidence report remains unchanged and should be read together with this diagnostic report and the ten canonical BUG records.

