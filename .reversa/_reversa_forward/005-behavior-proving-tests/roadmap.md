# Roadmap: Behavior-proving package validation

> Identifier: `005-behavior-proving-tests`  
> Date: `2026-08-25`  
> Requirements: `.reversa/_reversa_forward/005-behavior-proving-tests/requirements.md`  
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP

## 1. Resumo da abordagem

Replace every source-string assertion that serves FR-01 through FR-08 with a layered executable-evidence suite; none remains an acceptance mechanism for those requirements. Keep unit-level fixtures deterministic and host-independent; put process isolation around loader and consumer proofs; make CI assemble and consume the same-run expanded package. The change adds test seams only where direct observation is otherwise impossible: Android TLS dependencies and a narrowly scoped loader probe entrypoint. Artifact utilities remain Python CLIs and are exercised through their public command lines. Workflow policy is parsed into a graph/fact model and lifecycle architecture is queried through Dart analyzer AST/element facts. `analyzer` is a direct, exactly pinned `dev_dependency`; absence or incompatible resolution is a fail-closed test error, never a skip. The release gate stays fail-closed: unavailable native prerequisites are reported separately from a passing proof.

## 2. Applied principles

| Principle | How the feature relates | Status |
|-----------|-------------------------|--------|
| No project-local principles file exists | No additional local principle can be evaluated; requirements and effective addenda remain binding inputs. | follows |
| Fail-closed release eligibility | Negative fixtures, unavailable prerequisites, and proof validation retain non-success outcomes. | follows |
| CI-owned generated bindings | Consumer/bundle proof receives `bindings.dart` only from the producing workflow run; no tracked or checkout fallback is accepted. | follows |
| Main-only credential-bearing publication | Parsed graph assertions distinguish universally reachable validation from publication reachable only on exact `push` to `refs/heads/main`. | follows |

## 3. Technical decisions

| ID | Decision | Rationale | Rejected alternatives | Confidence |
|----|----------|-----------|-----------------------|------------|
| D-01 | Add a native ABI probe fixture with a `size_t` echo/observation path and submit a value above `0xffffffff` through `Libgit2Opts`; run it only on a declared 64-bit native payload. | Dart FFI type spelling and source text cannot prove width preservation. | Inspecting `ffi.Size` declarations; lowering the value into 32-bit range. | 🟢 |
| D-02 | Run desktop fallback-success and missing-library failure cases in fresh Dart subprocesses with explicit package config/root fixtures. | `libgit2Runtime` and dynamic-library loading are isolate/process global enough that in-process cases can leak loaded-library state. | Mutating test-process environment; checking diagnostic source strings. | 🟢 |
| D-03 | Test `native_cache_manifest.py` and `platform_release_proof.py` by generating one valid fixture and one independent fixture per failure family, asserting exit status plus stable diagnostic category/schema. | Both tools already expose public CLIs and fail-closed result contracts. | Importing private Python functions; only testing malformed JSON. | 🟢 |
| D-04 | Add a disposable package-bundle assembly followed by a clean minimal consumer subprocess, with CI injecting same-run generated binding and native payload before assembly. | The shipped product is the expanded package, not the checkout. | Running from repository root; resolving a globally cached package. | 🟢 |
| D-05 | Extract Android TLS file/asset/directory operations behind an internal injectable dependency bundle; retain the static public `AndroidSSLHelper.initialize()` facade. | This observes success, cached reuse, failed write/load, and retry without device-only global APIs. | Source assertions; exposing a new public API. | 🟡 |
| D-06 | Parse the workflow into an explicit job/step dependency and condition fact model; query lifecycle-boundary facts through a direct, exact-pinned Dart `analyzer` dev dependency. Analyzer absence or version incompatibility fails the validation. | Structural policy must survive formatting, comments, and literal rearrangement, while AST API drift must not silently weaken the gate. | YAML substring searches; regex-only production-source scans; optional/transitive analyzer resolution. | 🟢 user-confirmed requirement; 🟡 exact compatible analyzer version pending implementation-time SDK resolution |

## 4. Premissas

No unresolved `[DÚVIDA]` markers were accepted from `requirements.md`.

## 5. Delta arquitetural

| Component | Legacy source file | Change type | Summary |
|-----------|--------------------|-------------|---------|
| Global-options wrapper | `.reversa/_reversa_sdd/code-analysis.md#Module 3: libgit2 global options` | rule-changed | Add runtime ABI-width evidence for selected `ffi.Size` option path without changing public options. |
| Native loader/lifecycle | `.reversa/_reversa_sdd/code-analysis.md#Module 2: Native loader and lifecycle` | rule-changed | Add isolated process probes for bare-name failure, package fallback success, and terminal diagnostics; Android retains no fallback. |
| Android TLS bootstrap | `.reversa/_reversa_sdd/code-analysis.md#Module 4: Android TLS bootstrap` | rule-changed | Add internal test seam to prove cache-after-success and retry-after-failure state transitions. |
| Validation/release assembly | `.reversa/_reversa_sdd/code-analysis.md#Module 7: Validation and release assembly` | rule-changed | Replace all FR-01–FR-08 source-string assertions with fixture CLI execution, package-consumer bundle evidence, mandatory analyzer AST facts, and parsed workflow graph evidence. |
| CI-owned generated bindings | `.reversa/_reversa_sdd/addenda/005-ci-owned-generated-bindings.md#Acceptance Contract` | changed-contract | Bundle and consumer validation accept only same-run downloaded `bindings.dart`. |
| Platform-proof helper | `.reversa/_reversa_sdd/addenda/003-platform-release-proof.md#Resumo da entrega` | changed-contract | Extend executable invalid-input coverage while preserving same-run proof as an eligibility prerequisite. |

## 6. Delta no modelo de dados

- Change summary: No persistent domain model or migration. Add disposable test-fixture descriptors: expected metadata, payload tree, corruption kind, expected exit class, proof scope, and evidence class.
- Full details: `.reversa/_reversa_forward/005-behavior-proving-tests/data-delta.md`

## 7. Delta de contratos externos

| Contract | Type | Detail file |
|----------|------|-------------|
| Expanded package consumer bundle | Dart package / filesystem artifact / subprocess | `.reversa/_reversa_forward/005-behavior-proving-tests/interfaces/package-consumer-bundle.md` |

## 8. Migration plan

1. Inventory every existing source-string assertion mapped to FR-01–FR-08 and assign it a replacement executable/AST/parser/CLI proof before deleting the assertion.
2. Add the direct exact-pinned `analyzer` dev dependency and make incompatible/unavailable analyzer resolution a failing prerequisite for AST validation; preserve all public exports and loader behavior.
3. Introduce fixture builders and test-only seams, then replace the inventoried assertions with executable unit, subprocess, CLI, analyzer-AST, and parsed-workflow tests.
4. Add CI assembly/consumer proof after same-run binding and payload download, before publish dry-run/publication eligibility.
5. Run focused host checks; CI supplies authoritative native/platform/package evidence where checkout prerequisites are absent.

## 9. Risks and mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Native payload absent locally makes ABI/loader proof appear green by skip | high | medium | Require an explicit unavailable result locally; inject same-run payload in CI and fail CI if declared inputs are missing. |
| Loader test accidentally resolves checkout/system libraries | high | medium | Use fresh subprocesses, disposable package roots, sanitized environment, and assert resolved bundle identity. |
| Global libgit2 settings leak across tests | medium | medium | Isolate mutation process; capture/restore values where API permits; serialize probe tests. |
| Android seam alters public behavior | medium | low | Keep the public static method as a delegating facade; inject only internal dependencies. |
| Workflow parser incompletely models GitHub expressions | medium | medium | Limit assertions to documented event/ref/needs/step-if facts; fail closed on unsupported conditions. |
| Analyzer API/version drift disables AST coverage | high | medium | Pin `analyzer` directly in `dev_dependencies`, check its resolved compatibility at test start, and fail non-zero on absence/incompatibility. |
| A source-string assertion is removed before an equivalent proof exists | high | medium | Maintain an FR-01–FR-08 replacement inventory with one executable/AST/parser case per retired assertion. |
| Fixture diagnostics leak temp absolute paths | medium | low | Assert sanitized categories and inspect generated proof/diagnostics for root omission. |

## 10. Definition of done

- [ ] ABI probe proves exact >32-bit `size_t` preservation on a supported 64-bit injected payload, otherwise reports unavailable.
- [ ] Fresh subprocesses prove desktop fallback success and terminal error semantics; Android no-fallback remains explicit.
- [ ] Cache-manifest and platform-proof valid/corrupt fixture matrices assert fail-closed command results.
- [ ] CI assembles a disposable expanded bundle from same-run artifacts and a clean consumer resolves that bundle only.
- [ ] Android TLS tests prove success, cache reuse, failure, and retry through injected dependencies.
- [ ] Every source-string assertion mapped to FR-01–FR-08 is removed or converted and is traceable to an equivalent executable, analyzer-AST, CLI, subprocess, or parsed-workflow proof.
- [ ] `analyzer` is a direct exact-pinned `dev_dependency`; missing or incompatible analyzer resolution fails the AST validation non-zero.
- [ ] External consumer fixture uses only public imports; analyzer AST and parsed workflow tests enforce the selected structural rules.
- [ ] All actions in `actions.md` marked `[X]`.
- [ ] `cross-check.md` (if executed) has no CRITICAL or HIGH findings.
- [ ] `regression-watch.md` generated.

## 11. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-25 | Initial version generated by `/reversa-plan` | reversa |
