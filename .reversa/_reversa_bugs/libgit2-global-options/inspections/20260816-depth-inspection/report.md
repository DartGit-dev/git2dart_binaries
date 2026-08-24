# Depth Inspection Report: libgit2-global-options

## Inspection metadata

```yaml
feature: libgit2-global-options
context: libgit2-global-options
date: 2026-08-16
mode: read-only-diagnostic
closure_policy: package
source_modified: false
existing_feature_bugs: 0
runtime_replay: blocked
```

## Feature map

### Specifications

- `_reversa_sdd/libgit2-global-options/requirements.md`
- `_reversa_sdd/libgit2-global-options/design.md`
- `_reversa_sdd/libgit2-global-options/tasks.md`
- `_reversa_sdd/flowcharts/libgit2-global-options.md`
- `_reversa_sdd/flowcharts/libgit2-global-options-dispatch.md`
- `_reversa_sdd/architecture.md`, `_reversa_sdd/domain.md`, and `_reversa_sdd/state-machines.md`
- `_reversa_sdd/traceability/spec-impact-matrix.md`

### Code and integration boundaries

- `lib/src/opts_bindings.dart`: 33 public wrappers and 13 typed FFI signature families over one variadic `git_libgit2_opts` symbol.
- `lib/src/util.dart`: lazy `libgit2Opts` construction and the separate lazy `libgit2` initialization path.
- `lib/src/android_ssl_helper.dart`: returns a CA path but does not apply the SSL global option.
- `lib/git2dart_binaries.dart`: public export boundary.
- Generated `lib/src/bindings.dart`: absent from the tracked checkout.

### Tests

- `test/opts_bindings_integration_test.dart`: 18 of 33 public wrappers are invoked. Ten of 13 local signature families are touched.
- `integration_test/opts_bindings_integration_test.dart`: device adapter that initializes the integration binding and reuses the canonical test body; it adds no independent assertions.
- No current native test can run because generated bindings and native artifacts are absent.

### Data and ownership

- libgit2 owns process-global option values; Dart does not cache them.
- Callers own outer pointer allocations and setter inputs.
- libgit2-populated `git_buf` and `git_strarray` contents require the matching libgit2 dispose call before the outer allocation is freed or reused.
- Native integer status codes are returned directly.
- No database, queue, persistent Dart cache, or migration state participates in this feature.

### Existing bugs

No canonical bug is registered with `feature: libgit2-global-options`. The two `native-loader-lifecycle` bugs were checked and are not duplicates of this inspection's candidates.

## Evidence boundaries

- `lib/src/bindings.dart` and native artifacts are absent, so local compilation and native replay remain blocked.
- The official libgit2 v1.9.6 header was read without saving it to the repository: `https://raw.githubusercontent.com/libgit2/libgit2/v1.9.6/include/git2/common.h`.
- Header lines 270-342 and 487-494 define the current width contract used for the ABI comparison.
- Git history is auxiliary evidence only. Historical generated bindings independently contain the same type declarations, but they were not used as the sole current-release confirmation.

## Findings by lens

### Spec conformity

```yaml
- finding_id: F-LGO-CONF-01
  summary: Eleven wrappers dispatch size_t or ssize_t options through ffi.Int or Pointer<ffi.Int>.
  confidence: high
  evidence:
    - official libgit2 v1.9.6 include/git2/common.h:270-342,487-494
    - lib/src/opts_bindings.dart:29-95
    - lib/src/opts_bindings.dart:150-188
    - lib/src/opts_bindings.dart:387-405
    - lib/src/opts_bindings.dart:533-546
    - lib/src/opts_bindings.dart:599-620
    - _reversa_sdd/libgit2-global-options/requirements.md:7,15,23
  suspected_severity: critical
  signals: [abi-corruption, memory-overwrite, truncation, cross-platform]
  classification: confirmed-static-current-contract-deviation
  promotion_candidate: C-LGO-01
  promoted_to: BUG-20260816-AAH2

- finding_id: F-LGO-CONF-02
  summary: Integration tests do not restore the exact incoming process-global option state.
  confidence: high
  evidence:
    - _reversa_sdd/libgit2-global-options/requirements.md:24
    - _reversa_sdd/libgit2-global-options/tasks.md:16
    - test/opts_bindings_integration_test.dart:46-51,88-94,131-139
    - test/opts_bindings_integration_test.dart:142-163,180-200,218-237
    - test/opts_bindings_integration_test.dart:273-279,349-355
  suspected_severity: medium
  signals: [global-state-leak, order-dependence, flaky-tests]
  classification: confirmed-static-spec-deviation
  promotion_candidate: C-LGO-02
  promoted_to: BUG-20260816-AABY
```

### Data flow

```yaml
- finding_id: F-LGO-DATA-01
  summary: Search-path test discards the first libgit2-owned git_buf contents before disposal.
  confidence: high
  evidence:
    - _reversa_sdd/libgit2-global-options/requirements.md:9,18
    - _reversa_sdd/libgit2-global-options/design.md:15
    - test/opts_bindings_integration_test.dart:168-178
    - test/opts_bindings_integration_test.dart:190-198
  suspected_severity: medium
  signals: [native-memory-leak, ownership]
  classification: confirmed-static-ownership-deviation
  promotion_candidate: C-LGO-03
  promoted_to: BUG-20260816-AAHL

- finding_id: F-LGO-DATA-02
  summary: Negative extension length is accepted as a Dart int and crosses an unsigned ffi.Size boundary without a local guard.
  confidence: medium
  evidence:
    - lib/src/opts_bindings.dart:521-529
    - lib/src/opts_bindings.dart:645-657
    - test/opts_bindings_integration_test.dart:359-373
  suspected_severity: high
  signals: [out-of-bounds-read, crash-risk, signed-unsigned-conversion]
  classification: conditional-unsafe-path
  promotion_candidate: null
  promoted_to: null
  blocker: Exact Dart FFI conversion outcome and native behavior are not replayable without artifacts; the effective spec does not require this guard explicitly.
```

### Contracts and integrations

```yaml
- finding_id: F-LGO-CONTRACT-01
  summary: libgit2Opts can be called before the separate lazy libgit2 initializer is read.
  confidence: high-for-path
  evidence:
    - lib/src/util.dart:10-12
    - test/opts_bindings_integration_test.dart:19-22
    - _reversa_sdd/libgit2-global-options/tasks.md:4-5
    - _reversa_sdd/questions.md:14-21
  suspected_severity: high
  signals: [lifecycle-risk, integration-order]
  classification: explicit-policy-lacuna
  promotion_candidate: null
  promoted_to: null

- finding_id: F-LGO-CONTRACT-02
  summary: SSL option application and Android HTTPS readiness remain outside this repository.
  confidence: high
  evidence:
    - lib/src/opts_bindings.dart:241-249
    - lib/src/android_ssl_helper.dart:26-58
    - _reversa_sdd/android-tls-bootstrap/requirements.md:7,10,18
  suspected_severity: high
  signals: [android-https, external-consumer-boundary]
  classification: known-cross-repository-gap
  promotion_candidate: null
  promoted_to: null
```

### Error states and edge cases

```yaml
- finding_id: F-LGO-ERR-01
  summary: Null output pointers and pointer-length consistency cases are forwarded without local checks and have no tests.
  confidence: high-for-path
  evidence:
    - lib/src/opts_bindings.dart:29-33,180-188,241-249,502-529
    - _reversa_sdd/libgit2-global-options/requirements.md:29-35
  suspected_severity: high
  signals: [native-crash-risk, invalid-memory-access]
  classification: validation-responsibility-gap
  promotion_candidate: null
  promoted_to: null
  reason: The effective spec does not assign these checks to the Dart wrapper, and no native deviation was observed.

- finding_id: F-LGO-ERR-02
  summary: Most integer, enum, boolean, and upper-bound inputs have no Dart-side validation.
  confidence: high
  evidence:
    - lib/src/opts_bindings.dart:108-155,199-203
    - lib/src/opts_bindings.dart:287-405,445-489
    - _reversa_sdd/libgit2-global-options/design.md:27
  suspected_severity: medium
  signals: [invalid-enum, truncation, policy-risk]
  classification: documented-validation-gap
  promotion_candidate: null
  promoted_to: null
  reason: Only the negative pack-object-size guard is a locally settled wrapper requirement.
```

### Test coverage

```yaml
- finding_id: F-LGO-TEST-01
  summary: Fifteen of 33 wrappers are never invoked, including all three risky multi-argument signature families.
  confidence: high
  evidence:
    - lib/src/opts_bindings.dart:78-95,150-155,211-249
    - lib/src/opts_bindings.dart:287-375,445-465,521-529
    - test/opts_bindings_integration_test.dart:14-375
    - _reversa_sdd/libgit2-global-options/tasks.md:15,22
  suspected_severity: high
  signals: [abi-risk, operational-risk]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-LGO-TEST-02
  summary: Search-path and user-agent tests claim round trips but assert only status, not returned values.
  confidence: high
  evidence:
    - test/opts_bindings_integration_test.dart:180-200
    - test/opts_bindings_integration_test.dart:218-237
  suspected_severity: medium
  signals: [false-confidence, weak-oracle]
  classification: test-proof-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-LGO-TEST-03
  summary: Status passthrough is exercised only for success and no negative native status is compared unchanged.
  confidence: high
  evidence:
    - test/opts_bindings_integration_test.dart:14-373
    - _reversa_sdd/libgit2-global-options/requirements.md:16
  suspected_severity: medium
  signals: [uncovered-error-contract]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-LGO-TEST-04
  summary: The negative pack-size test observes RangeError but cannot prove absence of native dispatch dynamically.
  confidence: high
  evidence:
    - lib/src/opts_bindings.dart:425-433
    - test/opts_bindings_integration_test.dart:310-314
  suspected_severity: low
  signals: [incomplete-acceptance-proof]
  classification: test-proof-gap
  promotion_candidate: null
  promoted_to: null
  note: Static control flow does prove that the guard precedes dispatch.

- finding_id: F-LGO-TEST-05
  summary: The device adapter reruns the canonical test body and adds no device-specific assertion.
  confidence: high
  evidence:
    - integration_test/opts_bindings_integration_test.dart:1-7
  suspected_severity: low
  signals: [non-independent-evidence]
  classification: duplicate-test-surface
  promotion_candidate: null
  promoted_to: null
```

### Concurrency and consistency

```yaml
- finding_id: F-LGO-CONC-01
  summary: Process-global mutations have no serialization, ownership, or conflict detection across consumers or isolates.
  confidence: high-for-mechanism
  evidence:
    - _reversa_sdd/libgit2-global-options/design.md:20,29
    - _reversa_sdd/libgit2-global-options/tasks.md:22
    - lib/src/opts_bindings.dart:10-657
  suspected_severity: high
  signals: [lost-update, cross-consumer-interference, intermittency]
  classification: explicit-concurrency-policy-lacuna
  promotion_candidate: null
  promoted_to: null

- finding_id: F-LGO-CONC-02
  summary: Read-mutate-restore test sequences can overwrite a concurrent consumer's later value.
  confidence: medium
  evidence:
    - test/opts_bindings_integration_test.dart:20-48
    - test/opts_bindings_integration_test.dart:105-133
  suspected_severity: medium
  signals: [stale-restore, lost-update, intermittency]
  classification: concurrency-hypothesis
  promotion_candidate: null
  promoted_to: null
  blocker: No concurrent consumer or isolate harness and no settled concurrency policy.
```

## Verified conformities

- Exactly 33 unique public option wrappers contain 33 discriminator references.
- Wrapper methods return the FFI status without reinterpretation.
- The negative pack maximum object size guard precedes `ffi.Size` dispatch.
- The extension getter disposes libgit2-owned `git_strarray` contents before freeing the outer allocation.

## ABI mismatch detail

The official v1.9.6 header requires pointer-width types for these 11 wrappers:

| Wrapper group | Upstream type | Current Dart FFI type | Risk on 64-bit |
|---|---|---|---|
| get/set mwindow size | `size_t*` / `size_t` | `Pointer<Int>` / `Int` | 8-byte output into 4-byte allocation; argument width mismatch |
| get/set mapped limit | `size_t*` / `size_t` | `Pointer<Int>` / `Int` | same |
| get/set file limit | `size_t*` / `size_t` | `Pointer<Int>` / `Int` | same |
| set cache object limit | `size_t` for size | `Int` | truncation and variadic width mismatch |
| set cache max size | `ssize_t` | `Int` | truncation and variadic width mismatch |
| get cached memory | `ssize_t*`, `ssize_t*` | `Pointer<Int>`, `Pointer<Int>` | two pointer-width outputs target 4-byte allocations in tests |
| get/set pack max objects | `size_t*` / `size_t` | `Pointer<Int>` / `Int` | output overwrite and argument width mismatch |

This is a current contract deviation, not an inference from method names. The exact pinned v1.9.6 upstream header was compared to the current wrapper declarations.

## Consolidated result

| Classification | Count |
|---|---:|
| Confirmed static bug candidates | 3 |
| Conditional unsafe paths | 1 |
| Coverage or test-proof gaps | 5 |
| Policy or integration lacunae | 3 |
| Validation responsibility gaps | 2 |
| Concurrency hypotheses | 1 |
| Verified conformity groups | 1 |
| **Total consolidated findings and assurance groups** | **16** |

## Bug promotion candidates

| Candidate | Severity | Finding | Gate status |
|---|---|---|---|
| `C-LGO-01` | Critical | Eleven size_t/ssize_t wrappers use 32-bit ffi.Int at the variadic ABI boundary | Registered as `BUG-20260816-AAH2` |
| `C-LGO-02` | Medium | Tests fail to restore exact process-global option values and fail to restore on error paths | Registered as `BUG-20260816-AABY` |
| `C-LGO-03` | Medium | Search-path test orphans the first native git_buf allocation before disposal | Registered as `BUG-20260816-AAHL` |

The user authorized all confirmed candidates after cross-context deduplication. All three candidates were registered as separate canonical records. No duplicate or regression relation applies.

## Confidence impact

- Current wrapper ABI confidence decreases materially: the former red proof gap is now a confirmed mismatch for 11 wrappers against the exact pinned upstream header.
- Test-isolation confidence decreases because the explicit restoration rule is contradicted on successful and failing paths.
- Status passthrough, negative pack-size guard ordering, wrapper count, and extension getter disposal remain confirmed.
- Runtime outcome confidence remains blocked by absent generated bindings and native artifacts.
- The completed core Reversa score of 80.5% was not rewritten by this maintenance inspection.

## Clusters

1. **ABI width cluster:** 11 wrappers and their tests share 32-bit declarations for pointer-width upstream types. This is the highest-impact structural defect.
2. **Test state hygiene cluster:** missing exact restoration, non-teardown restoration, assumed defaults, and a leaked native buffer make test order and failure paths unsafe.
3. **Evidence cluster:** incomplete wrapper coverage and success-only status checks previously allowed the ABI mismatch to remain unproved.

## Not covered

- No native runtime replay, crash reproduction, or analyzer run was possible without generated bindings and artifacts.
- No consumer repository was read; Android TLS application and cross-consumer concurrency remain explicitly external or unresolved.
- Security authorization and secrets lenses were not activated because this feature has no authentication or secret-storage boundary. The native memory-safety issue is fully represented by the ABI lens.
- Performance and migration lenses were not activated because there is no relevant loop-over-I/O, database, migration, or persistent configuration surface.
- Observability was inspected through status/error contracts; no separate logging defect was promoted.
