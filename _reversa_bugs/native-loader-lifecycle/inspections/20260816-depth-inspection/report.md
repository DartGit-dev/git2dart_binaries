# Native Loader Lifecycle Depth Inspection

## Inspection metadata

```yaml
feature: native-loader-lifecycle
context: native-loader-lifecycle
date: 2026-08-16
closure_policy: package
source_commit: 680d914c8e2b87682f0b68318aee855838eb58e8
source_code_mode: read-only
neighbor_repository_read: false
bug_promotion_status: awaiting-user-confirmation
```

## Feature map

### Effective specifications

- `_reversa_sdd/native-loader-lifecycle/requirements.md`
- `_reversa_sdd/native-loader-lifecycle/design.md`
- `_reversa_sdd/native-loader-lifecycle/tasks.md`
- `_reversa_sdd/state-machines.md`
- `_reversa_sdd/flowcharts/native-loader-lifecycle.md`
- `_reversa_sdd/domain.md`, loader and lifecycle rules
- `_reversa_sdd/architecture.md`, runtime loader and platform packaging contracts

No active addenda exist. The canonical feature specifications are therefore the effective specifications.

### Code and integration surface

- `lib/src/util.dart`: lazy globals, platform target selection, dynamic loading, dependency preload, package-root resolution, native initialization
- `lib/git2dart_binaries.dart`: public export boundary
- `linux/CMakeLists.txt`, `windows/CMakeLists.txt`, Apple podspecs: runtime artifact bundling contracts
- `.github/actions/build-linux/action.yml`: Linux native producer
- `.github/workflows/build_package.yml`: artifact injection and platform tests

### Tests

- `test/windows_packaging_test.dart`: Windows manifest assertions and plain-Dart loader child process
- `test/macos_dylib_packaging_test.dart`: macOS dependency metadata, symbol lookup, and plain-Dart loader child process
- `test/opts_bindings_integration_test.dart`: indirect loader/init usage through global options

### Data and external contracts

- Lazy Dart globals: `_library`, `libgit2Opts`, `libgit2`
- Isolate-local cached package root
- Dart package-config URI and JSON entry
- OS dynamic-loader search path
- Platform artifact filenames and dependency sidecars
- Process-global native libgit2 reference count

There is no database, queue, or persistent business data in this feature.

### Existing bugs

No bug existed in this registry before this inspection.

## Evidence blockers

- `lib/src/bindings.dart` is absent.
- Windows, Linux, and macOS native artifacts are absent.
- The current Windows host cannot execute macOS, iOS, Android, or Linux loader branches.
- `F:\git2dart` was not read, and its Reversa state was not reused.

These blockers prevent current runtime replay. They do not invalidate complete static causal paths, but they prevent observations from being promoted solely on historical or hypothetical evidence.

## Findings by lens

### Spec conformity

```yaml
- finding_id: F-CONF-01
  summary: Package-root and dependency-preload failures discard the initial bare-name load failure.
  confidence: high
  evidence:
    - _reversa_sdd/native-loader-lifecycle/requirements.md:26
    - lib/src/util.dart:41-58
    - lib/src/util.dart:77-92
    - lib/src/util.dart:123-135
  suspected_severity: medium
  signals: [operational-risk, diagnostics-loss]
  classification: confirmed-static-spec-deviation
  promotion_candidate: C-NLL-02
  promoted_to: BUG-20260816-AAFR

- finding_id: F-CONF-02
  summary: The supporting flowchart still depicts import-time loading and Options-to-Init sequencing, contrary to lazy independent globals.
  confidence: high
  evidence:
    - _reversa_sdd/flowcharts/native-loader-lifecycle.md:5
    - _reversa_sdd/flowcharts/native-loader-lifecycle.md:19-20
    - lib/src/util.dart:10-12
    - _reversa_sdd/native-loader-lifecycle/design.md:12-23
  suspected_severity: low
  signals: [documentation-drift]
  classification: documentation-observation
  promotion_candidate: null
  promoted_to: null
```

### Data flow

```yaml
- finding_id: F-DATA-01
  summary: The git_libgit2_init return value is discarded and the binding object is returned for every native result.
  confidence: high
  evidence:
    - lib/src/util.dart:71-74
    - test/windows_packaging_test.dart:45-53
    - test/macos_dylib_packaging_test.dart:72-80
  suspected_severity: high
  signals: [operational-risk, delayed-failure]
  classification: policy-lacuna-with-complete-static-path
  promotion_candidate: null
  promoted_to: null
  blocker: Expected abort-versus-continue behavior is explicitly unresolved.

- finding_id: F-DATA-02
  summary: libgit2Opts and libgit2 share a library handle but have independent lazy entry paths, so an option expression executes before initialization when evaluated first.
  confidence: high
  evidence:
    - lib/src/util.dart:10-12
    - test/opts_bindings_integration_test.dart:19-22
    - _reversa_sdd/questions.md:14-21
  suspected_severity: high
  signals: [ordering-risk, global-state]
  classification: policy-lacuna-with-reachable-path
  promotion_candidate: null
  promoted_to: null
  blocker: The required init-before-options contract is unresolved.
```

### Contracts and integrations

```yaml
- finding_id: F-CONTRACT-01
  summary: Linux exports libssh2.so as a required shared dependency but Flutter CMake omits it from bundled libraries.
  confidence: high
  evidence:
    - .github/actions/build-linux/action.yml:71-80
    - .github/actions/build-linux/action.yml:90-112
    - linux/CMakeLists.txt:41-46
    - lib/src/util.dart:77-81
    - _reversa_sdd/platform-packaging/requirements.md:8
  suspected_severity: high
  signals: [operational-risk, clean-consumer-failure, platform-contract]
  classification: confirmed-static-causal-deviation
  promotion_candidate: C-NLL-01
  promoted_to: BUG-20260816-AAH6

- finding_id: F-CONTRACT-02
  summary: A successful ambient desktop library lookup bypasses package fallback and has no local version or ABI validation.
  confidence: medium
  evidence:
    - lib/src/util.dart:34-43
    - _reversa_sdd/domain.md:33-36
  suspected_severity: medium
  signals: [abi-risk, environment-drift]
  classification: hypothesis
  promotion_candidate: null
  promoted_to: null
  blocker: No mismatched ambient library was available for replay, and app-bundled bare-name loading is intentional.

- finding_id: F-CONTRACT-03
  summary: When the Windows package directory is absent, the loader opens libssh2.dll under the already-absent directory.
  confidence: high
  evidence:
    - lib/src/util.dart:95-100
    - _reversa_sdd/native-loader-lifecycle/tasks.md:15
    - _reversa_sdd/questions.md:23-30
  suspected_severity: medium
  signals: [operational-risk, deterministic-failure]
  classification: contract-lacuna
  promotion_candidate: null
  promoted_to: null
  blocker: Bare-name retry versus explicit failure is an unresolved stakeholder decision.
```

### Error states and edge cases

```yaml
- finding_id: F-ERROR-01
  summary: Negative and exceptional loader branches lack executable regression coverage.
  confidence: high
  evidence:
    - _reversa_sdd/native-loader-lifecycle/tasks.md:14-17
    - test/windows_packaging_test.dart:29-81
    - test/macos_dylib_packaging_test.dart:52-105
  suspected_severity: medium
  signals: [regression-risk, operational-risk]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null
```

### Test coverage

```yaml
- finding_id: F-TEST-01
  summary: Named package-root tests do not force JSON, environment, or VM-argument fallback branches.
  confidence: high
  evidence:
    - test/windows_packaging_test.dart:58-61
    - test/macos_dylib_packaging_test.dart:85-88
    - lib/src/util.dart:123-198
  suspected_severity: medium
  signals: [operational-risk]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-TEST-02
  summary: Loader success tests run with the repository working directory and do not assert which loader branch succeeded.
  confidence: high
  evidence:
    - test/windows_packaging_test.dart:58-72
    - test/macos_dylib_packaging_test.dart:85-99
    - _reversa_sdd/native-loader-lifecycle/tasks.md:14
  suspected_severity: medium
  signals: [test-proof-weakness]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null

- finding_id: F-TEST-03
  summary: Direct coverage is absent for Android, iOS, Linux, unsupported platform, malformed or missing config, missing Windows directory, and init failure paths.
  confidence: high
  evidence:
    - _reversa_sdd/native-loader-lifecycle/requirements.md:16-26
    - _reversa_sdd/native-loader-lifecycle/tasks.md:14-17
  suspected_severity: medium
  signals: [regression-risk]
  classification: coverage-gap
  promotion_candidate: null
  promoted_to: null
```

### Concurrency and consistency

```yaml
- finding_id: F-CONCURRENCY-01
  summary: No production component owns shutdown or balances init across consumers and isolates.
  confidence: high
  evidence:
    - lib/src/util.dart:71-74
    - test/windows_packaging_test.dart:45-53
    - test/macos_dylib_packaging_test.dart:72-80
    - test/opts_bindings_integration_test.dart:9-12
  suspected_severity: high
  signals: [reference-count-drift, shutdown-race]
  classification: lifecycle-policy-lacuna
  promotion_candidate: null
  promoted_to: null

- finding_id: F-CONCURRENCY-02
  summary: Separate isolates can evaluate loader and init globals independently, but no multi-isolate lifecycle harness exists.
  confidence: medium
  evidence:
    - lib/src/util.dart:10-14
    - _reversa_sdd/state-machines.md:112
  suspected_severity: medium
  signals: [intermittency, duplicate-initialization, global-state]
  classification: hypothesis
  promotion_candidate: null
  promoted_to: null

- finding_id: F-CONCURRENCY-03
  summary: No same-isolate race was found in package-root caching because resolution and IO are synchronous.
  confidence: high
  evidence:
    - lib/src/util.dart:69
    - lib/src/util.dart:123-199
  suspected_severity: low
  signals: []
  classification: negative-assurance
  promotion_candidate: null
  promoted_to: null
```

## Consolidated result

| Classification | Count |
|---|---:|
| Confirmed static bug candidates | 2 |
| Documentation observations | 1 |
| Coverage gaps | 4 |
| Policy or contract lacunae | 4 |
| Hypotheses | 2 |
| Negative assurance | 1 |
| **Total consolidated findings** | **14** |

## Bug promotion candidates

| Candidate | Severity | Finding | Gate status |
|---|---|---|---|
| `C-NLL-01` | High | Linux required `libssh2.so` is omitted from Flutter bundled libraries | Registered as `BUG-20260816-AAH6` |
| `C-NLL-02` | Medium | Fallback root or preload failures discard the first loader error | Registered as `BUG-20260816-AAFR` |

The user selected both confirmed candidates. Required cross-context deduplication found no existing canonical bugs, so both were registered as new records. No `duplicate-of` or `regression-of` relation applies.

## Confidence impact

- The global Reversa confidence score remains 80.5% because this maintenance skill does not rewrite completed SDD confidence markers.
- Two generic risks are now refined into high-confidence static causal deviations and are eligible for bug registration.
- Lifecycle ordering, failed-init policy, shutdown ownership, Windows missing-directory policy, and multi-isolate behavior remain red gaps.
- Current runtime confidence did not increase because generated bindings and native artifacts are unavailable.

## Clusters

The strongest cluster is the desktop fallback and packaging boundary. It combines artifact sidecar completeness, package-root reachability, dependency preload, diagnostic retention, and test proof. Historical loader fixes indicate this boundary is change-prone, but history was used only as an auxiliary signal.

## Not covered

- No runtime loader replay or symbol inspection was possible.
- No consumer lifecycle in `F:\git2dart` was inspected.
- Security and authorization lenses were not activated because this feature has no auth or secret-handling path.
- Performance was not activated because no repeated remote IO or computational hot path was found.
- Configuration and observability signals were incorporated into the contract/error findings rather than run as separate bug-producing lenses.
