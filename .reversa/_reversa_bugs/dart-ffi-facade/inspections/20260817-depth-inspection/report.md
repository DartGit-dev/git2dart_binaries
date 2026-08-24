# Depth Inspection Report: dart-ffi-facade

## Inspection metadata

```yaml
feature: dart-ffi-facade
context: dart-ffi-facade
date: 2026-08-17
mode: read-only-diagnostic
closure_policy: package
source_modified: false
existing_feature_bugs: 0
runtime_replay: blocked
```

## Feature map

- Public barrel: `lib/git2dart_binaries.dart` exports six generated and handwritten surfaces.
- Helpers: `lib/src/extensions.dart` supplies SHA-1, ref-name, object-type, C-string, and last-error conversions.
- Error wrapper: `lib/src/error.dart` stores a borrowed `Pointer<git_error>`.
- Generated ABI: `lib/src/bindings.dart` is required but absent in the tracked checkout.
- Tests: no public-barrel-only consumer test and no direct validator, string, or error-wrapper boundary test.

## Findings by lens

### Spec conformity

- The barrel statically exports all six declared surfaces.
- Null native strings map to `''`, and the intended `getLastError()` path maps a null error pointer to `null`.
- Object-type and ref-name comments describe stricter validity than the implementation enforces. Their intended finite/full-Git semantics are explicit red decisions and were not promoted.
- The constructor documented as internal-only is public and bypasses the null guard. Registered as bug #10.

### Data flow

- Consumer imports flow through the barrel to generated bindings and handwritten modules.
- `git_error_last()` returns a borrowed pointer; `LibGit2Error` stores it and lazily dereferences message/class.
- The wrapper does not free native-owned memory, consistent with the ownership rule.
- Full generated ABI flow remains blocked by the absent binding artifact and is additionally bounded by bugs #3 and #7.

### Contracts and integrations

- The public arbitrary-pointer constructor conflicts with its internal-use declaration. Registered as bug #10.
- Borrowed error lifetime is not stabilized into a Dart snapshot, but no intended snapshot contract or stale-read replay exists.
- External `git2dart` consumer compatibility remains outside this repository and was not inferred.

### Error states and edge cases

- Direct `LibGit2Error(nullptr)` or another invalid pointer reaches unconditional getter dereference. Registered as bug #10.
- Unknown native error-class conversion remains unverified because current generated enum declarations are absent.
- Status-plus-error capture is not atomic; native thread/lifetime and consumer ordering remain unproved hypotheses.

### Test coverage

- No test imports only the public barrel.
- No test asserts null/non-null native errors, null/length-bounded strings, or error lifetime.
- No test invokes the SHA-1, ref-name, or object-type predicates.
- Existing `getLastError()` calls occur only as diagnostic reasons after operations expected to succeed.

### Concurrency and consistency

- The facade owns no persistent Dart state.
- Error retrieval and lazy decoding are separate operations over borrowed native state, with no local thread/lifetime proof.
- The intended null paths are guarded in `toDartString()` and `getLastError()`.

## Promotion and deduplication

| Candidate | Severity | Result |
|---|---|---|
| C-DFF-01, public internal-use error constructor accepts arbitrary pointers | Medium | `BUG-20260817-AAKR` (#10) |
| Public `Libgit2Opts` ABI widths | Critical | Exact dedupe to bug #3 |
| Stale generated ABI cache | High | Exact dedupe to bug #7 |

Validator semantics, borrowed lifetime, thread attribution, generated ABI completeness, and external compatibility remain lacunae or evidence gaps.

## Confidence impact

- Static barrel shape and simple null-path behavior remain high-confidence.
- Public error construction safety is now a confirmed defect.
- Direct test confidence remains low; complete ABI/runtime/consumer confidence remains red.
- The completed core Reversa score was not rewritten.

## Residual blockers

- Current generated bindings, native artifacts, and direct facade tests are absent.
- Native error lifetime/thread contract and actual invalid-pointer symptom were not replayed.
- External consumer usage was not inspected by scope.

No source, test, staged, committed, global-setting, or external-repository change was made.

