# Depth Inspection Report: android-tls-bootstrap

## Inspection metadata

```yaml
feature: android-tls-bootstrap
context: android-tls-bootstrap
date: 2026-08-17
mode: read-only-diagnostic
closure_policy: package
source_modified: false
existing_feature_bugs: 0
runtime_replay: blocked
```

## Feature map

### Specifications

- `_reversa_sdd/android-tls-bootstrap/requirements.md`
- `_reversa_sdd/android-tls-bootstrap/design.md`
- `_reversa_sdd/android-tls-bootstrap/tasks.md`
- `_reversa_sdd/flowcharts/android-tls-bootstrap.md`
- `_reversa_sdd/flowcharts/android-tls-bootstrap-initialize.md`
- `_reversa_sdd/adrs/003-make-android-tls-bootstrap-explicit-and-ordered.md`
- `_reversa_sdd/domain.md` and `_reversa_sdd/state-machines.md`

### Code and integration boundaries

- `lib/src/android_ssl_helper.dart`: asynchronous asset extraction, flushed temp-file write, cached path, and retry state.
- `pubspec.yaml:61-62`: Flutter package asset declaration.
- `assets/certs/cacert.pem`: Flutter package asset selected by the helper.
- `android/src/main/assets/certs/cacert.pem`: Android-source duplicate; no helper read site uses this copy.
- `lib/src/opts_bindings.dart:241-249`: native certificate-location setter boundary.
- `lib/src/util.dart`: separate lazy libgit2 initialization boundary.

### Tests

- No test or integration test references `AndroidSSLHelper`.
- No local test verifies extraction bytes, sequential cache behavior, retry, concurrency, duplicate asset identity, native option application, or Android HTTPS.

### Data and state

- `_initialized: bool` and `_certPath: String?` are isolate-local static state.
- `rootBundle.load` supplies a `ByteData` view.
- The helper writes `<temporary>/cacert.pem` directly and caches only its path.
- The native setter and consumer own later path conversion, status handling, and TLS use.
- No database, queue, or persisted state is involved.

### Existing bugs

No canonical bug has `feature: android-tls-bootstrap`. The five existing bugs were checked and do not duplicate the Android TLS findings.

## Verified asset snapshot

| Copy | Bytes | SHA-256 | PEM BEGIN/END pairs |
|---|---:|---|---:|
| `assets/certs/cacert.pem` | 234415 | `9C0683BC1DB52A9C21BE6D592D283DBF8632DC242BE47522EB7201D882BD1CEB` | 148/148 |
| `android/src/main/assets/certs/cacert.pem` | 234415 | `9C0683BC1DB52A9C21BE6D592D283DBF8632DC242BE47522EB7201D882BD1CEB` | 148/148 |

The copies are byte-identical in this snapshot. No repository check prevents future drift.

## Findings by lens

### Spec conformity

```yaml
- finding_id: F-ATB-CONF-01
  summary: Temporary-directory lookup failures bypass the helper diagnostic catch.
  confidence: high
  evidence:
    - lib/src/android_ssl_helper.dart:74
    - lib/src/android_ssl_helper.dart:77
    - lib/src/android_ssl_helper.dart:90-92
    - _reversa_sdd/android-tls-bootstrap/design.md:15
  suspected_severity: low
  signals: [diagnostics-loss, operational-risk]
  classification: confirmed-static-spec-deviation
  promotion_candidate: C-ATB-01
  promoted_to: BUG-20260817-AADQ

- finding_id: F-ATB-CONF-02
  summary: Exact-byte extraction is conditional on the returned ByteData spanning its complete backing buffer.
  confidence: medium
  evidence:
    - lib/src/android_ssl_helper.dart:79-84
    - _reversa_sdd/android-tls-bootstrap/requirements.md:15
    - Dart TypedData and Flutter AssetBundle API contracts
  suspected_severity: medium
  signals: [integrity-risk, byte-range]
  classification: integrity-hypothesis
  promotion_candidate: null
  promoted_to: null
  blocker: No local evidence shows rootBundle returning a nonzero-offset or shorter view for this asset.
```

### Data flow

```yaml
- finding_id: F-ATB-DATA-01
  summary: The helper converts ByteData through buffer.asUint8List without preserving offsetInBytes and lengthInBytes.
  confidence: medium
  evidence:
    - lib/src/android_ssl_helper.dart:79-84
    - https://api.dart.dev/dart-typed_data/ByteBuffer/asUint8List.html
    - https://api.flutter.dev/flutter/services/AssetBundle/load.html
  suspected_severity: high
  signals: [tls-risk, extra-bytes, data-integrity]
  classification: integrity-hypothesis
  promotion_candidate: null
  promoted_to: null
  note: API semantics are confirmed; occurrence with the production asset view is not.

- finding_id: F-ATB-DATA-02
  summary: Cached success stores only a path and does not validate file existence or contents on later calls.
  confidence: high-for-path
  evidence:
    - lib/src/android_ssl_helper.dart:38-39,68-75,86-87
    - _reversa_sdd/android-tls-bootstrap/design.md:24,29
  suspected_severity: high
  signals: [stale-cache, tls-outage]
  classification: lifecycle-policy-gap
  promotion_candidate: null
  promoted_to: null
  reason: Revalidation after temporary-directory cleanup is not an effective requirement.

- finding_id: F-ATB-DATA-03
  summary: Both tracked CA copies are currently byte-identical and structurally balanced.
  confidence: high
  evidence:
    - repository SHA-256 and certificate-marker counts
  suspected_severity: low
  signals: []
  classification: negative-assurance
  promotion_candidate: null
  promoted_to: null
```

### Contracts and integrations

```yaml
- finding_id: F-ATB-CONTRACT-01
  summary: Certificate application, native status handling, and successful Android HTTPS remain outside this checkout.
  confidence: high
  evidence:
    - lib/src/android_ssl_helper.dart:14-36,43-58
    - lib/src/opts_bindings.dart:241-249
    - _reversa_sdd/android-tls-bootstrap/requirements.md:7,10,18
    - _reversa_sdd/android-tls-bootstrap/tasks.md:11,16
  suspected_severity: high
  signals: [android-https, lifecycle-order, external-consumer-boundary]
  classification: explicit-cross-repository-lacuna
  promotion_candidate: null
  promoted_to: null

- finding_id: F-ATB-CONTRACT-02
  summary: Asset declaration and the package-qualified runtime key agree.
  confidence: high
  evidence:
    - pubspec.yaml:61-62
    - lib/src/android_ssl_helper.dart:79-81
  suspected_severity: low
  signals: []
  classification: verified-conformity
  promotion_candidate: null
  promoted_to: null
```

### Error states and edge cases

```yaml
- finding_id: F-ATB-ERR-01
  summary: A failed direct write may leave a partial final-path file, while cached success remains unset and a later call retries.
  confidence: medium
  evidence:
    - lib/src/android_ssl_helper.dart:75,84,86-92
  suspected_severity: medium
  signals: [partial-file, retry-interference]
  classification: conditional-error-path
  promotion_candidate: null
  promoted_to: null
  blocker: Partial-file persistence depends on filesystem failure timing and has no injected test.

- finding_id: F-ATB-ERR-02
  summary: Failures inside asset load or file write leave cached success unset and remain retryable.
  confidence: high
  evidence:
    - lib/src/android_ssl_helper.dart:77-93
  suspected_severity: low
  signals: []
  classification: verified-conformity
  promotion_candidate: null
  promoted_to: null
```

### Test coverage

```yaml
- finding_id: F-ATB-TEST-01
  summary: No local test exercises AndroidSSLHelper, so all three feature test tasks remain unproved.
  confidence: high
  evidence:
    - repository test inventory
    - _reversa_sdd/android-tls-bootstrap/tasks.md:13-16
  suspected_severity: high
  signals: [tls-risk, false-confidence]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-ATB-TEST-02
  summary: Byte-for-byte extraction and ByteData subview handling have no test.
  confidence: high
  evidence:
    - _reversa_sdd/android-tls-bootstrap/requirements.md:15
    - lib/src/android_ssl_helper.dart:79-84
  suspected_severity: high
  signals: [data-integrity, tls-risk]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-ATB-TEST-03
  summary: Retry is not tested for directory, asset, write, or partial-file failures.
  confidence: high
  evidence:
    - lib/src/android_ssl_helper.dart:73-93
    - _reversa_sdd/android-tls-bootstrap/tasks.md:15
  suspected_severity: medium
  signals: [operational-risk]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-ATB-TEST-04
  summary: Sequential idempotence, cache invalidation, and concurrent first calls have no test.
  confidence: high
  evidence:
    - lib/src/android_ssl_helper.dart:68-75
    - _reversa_sdd/android-tls-bootstrap/requirements.md:16,25
  suspected_severity: high
  signals: [stale-cache, concurrency-risk]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-ATB-TEST-05
  summary: No test prevents the two CA copies from drifting.
  confidence: high
  evidence:
    - repository asset snapshot
  suspected_severity: medium
  signals: [supply-drift, tls-risk]
  classification: packaging-integrity-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-ATB-TEST-06
  summary: No local test proves init, extraction, native setter success, and Android HTTPS as one flow.
  confidence: high
  evidence:
    - _reversa_sdd/android-tls-bootstrap/requirements.md:18
    - _reversa_sdd/android-tls-bootstrap/tasks.md:16
    - _reversa_sdd/gaps.md:6
  suspected_severity: high
  signals: [android-https, operational-risk]
  classification: explicit-integration-evidence-gap
  promotion_candidate: null
  promoted_to: null
```

### Concurrency and consistency

```yaml
- finding_id: F-ATB-CONC-01
  summary: Concurrent first calls can overlap writes to the same final path because no in-flight Future or lock is shared.
  confidence: high-for-overlap
  evidence:
    - lib/src/android_ssl_helper.dart:38-39,68-89
    - _reversa_sdd/android-tls-bootstrap/requirements.md:25
    - _reversa_sdd/android-tls-bootstrap/design.md:16,28
  suspected_severity: high
  signals: [intermittency, duplicate-write, partial-read]
  classification: concurrency-gap
  promotion_candidate: null
  promoted_to: null
  blocker: Actual corruption is not observed and serialization policy remains unresolved.

- finding_id: F-ATB-CONC-02
  summary: Isolate-local static coordination may target the same application temp path from multiple isolates.
  confidence: medium
  evidence:
    - lib/src/android_ssl_helper.dart:38-39,74-75
  suspected_severity: high
  signals: [cross-isolate-race, stale-state]
  classification: concurrency-hypothesis
  promotion_candidate: null
  promoted_to: null
  blocker: No multi-isolate Android harness or verified per-isolate path-provider behavior.

- finding_id: F-ATB-CONC-03
  summary: A late failing same-isolate call does not erase a prior successful cached state.
  confidence: high
  evidence:
    - lib/src/android_ssl_helper.dart:86-92
  suspected_severity: low
  signals: []
  classification: negative-assurance
  promotion_candidate: null
  promoted_to: null
```

## Conditional security and configuration lens

```yaml
- finding_id: F-ATB-SEC-01
  summary: The tracked CA bundle is older than the current published Mozilla extract, and no freshness policy or update automation is defined.
  confidence: high-for-age-and-difference
  evidence:
    - tracked bundle header: Mozilla data date 2025-11-04, 148 certificates
    - https://curl.se/docs/caextract.html: current data date 2026-07-16, 119 certificates
    - repository history: both tracked copies introduced in commit 40c398d and never updated
  suspected_severity: high
  signals: [trust-store-drift, security-policy-gap, supply-chain]
  classification: freshness-policy-gap
  promotion_candidate: null
  promoted_to: null
  reason: The effective specification defines no allowed age, provenance refresh cadence, or root-removal policy; removed-root impact was not independently established.
```

## Consolidated result

| Classification | Count |
|---|---:|
| Confirmed static bug candidates | 1 |
| Integrity or error hypotheses | 3 |
| Coverage and integration gaps | 6 |
| Lifecycle or concurrency gaps | 3 |
| Security/configuration policy gaps | 1 |
| Verified conformity or negative-assurance groups | 4 |
| **Total consolidated findings and assurance groups** | **18** |

## Bug promotion candidate

| Candidate | Severity | Finding | Gate status |
|---|---|---|---|
| `C-ATB-01` | Low | Temporary-directory failures bypass the promised helper stderr diagnostic | Registered as `BUG-20260817-AADQ` |

The user authorized automatic registration of all confirmed candidates after deduplication. Cross-context deduplication found no matching bug, and `C-ATB-01` was registered as a new canonical record. No hypothesis or lacuna was promoted.

## Confidence impact

- Current snapshot confidence increases for asset identity, package-key alignment, flushed-success ordering, and retry state after asset/write errors.
- Extraction behavior remains unproved dynamically because the feature has zero local tests.
- Byte-range integrity, concurrent first calls, cached-file survival, and consumer-side native application remain yellow or red.
- Trust-store freshness is now a verified policy gap, not a claim of a specific compromised root.
- The completed core Reversa score of 80.5% was not rewritten.

## Clusters

1. **Extraction observability:** the only confirmed deviation is the uncaught directory-resolution diagnostic path.
2. **Integrity and lifecycle:** ByteData view semantics, direct final-path writes, cached-path survival, and concurrent calls lack runtime proof or settled policy.
3. **TLS readiness:** extraction, native application, status handling, and HTTPS proof remain split across a cross-repository boundary.

## Not covered

- No Android helper, device, native setter, HTTPS, failure-injection, or multi-isolate harness was available.
- `F:\git2dart` was not read; consumer behavior remains explicitly unverified.
- No source, test, staged, or global-setting change was made.
