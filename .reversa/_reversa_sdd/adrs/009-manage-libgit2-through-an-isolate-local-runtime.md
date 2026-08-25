# ADR-009: Manage libgit2 Through an Isolate-Local Checked Runtime

- **Status:** Retrospectively accepted
- **Date:** 2026-08-22
- **Confidence:** 🟢 CONFIRMED locally; 🔴 external consumer adoption

## Context

libgit2 initialization and shutdown affect a process-global reference count, while Dart code may expose short calls and long-lived native owners. The former eager/global access pattern had no checked rollback, no explicit shutdown owner, and no way to prevent shutdown while native work or resources remained live. A finalizer alone cannot provide deterministic ordering.

## Decision

Use one lazily created `Libgit2Runtime` per Dart isolate. Load one native library and build generated/global-option views over it, but call native initialization only through `Libgit2RuntimeState`. Accept initialization only when the native result is positive; balance failed attempts with one shutdown rollback; make rollback failure terminal.

Protect synchronous operations with `activeCallCount` and persistent owners with exact-once `Libgit2OwnerLease` pins. Reject shutdown while either count is non-zero. Cache a successful non-negative shutdown result and reject re-entry after `terminated` or `faulted`. Use finalization only as a non-throwing fallback that reports cleanup errors.

## Alternatives considered

1. Keep unchecked top-level `git_libgit2_init()` and omit shutdown.
2. Initialize and shut down around every native call.
3. Maintain only a process-global Dart counter shared implicitly across isolates.
4. Depend entirely on Dart finalizers for native resource release.
5. Hide lifecycle policy in the neighboring higher-level package.

## Consequences

- Positive: init/rollback/shutdown failures become typed and observable.
- Positive: active calls and persistent owners prevent premature terminal shutdown.
- Positive: deterministic tests cover the state machine without requiring native payloads.
- Positive: compatibility callers share one handle and one state epoch per isolate.
- Negative: raw generated lifecycle functions remain technically callable and can bypass the manager.
- Negative: isolate-local accounting is not a process-global coordinator; correct aggregate balance depends on all isolates and consumers following the contract.
- Negative: explicit owner completion is still required; finalization timing is nondeterministic.
- Negative: no inspected external consumer proves leases are drained and terminal shutdown is invoked in production.

## Evidence

Commit `ea87cf2`; `lib/src/runtime.dart`; `test/libgit2_runtime_test.dart`; `tool/architecture_policy_facts.dart`; feature-005 W006. Local injected transitions are confirmed; current cross-isolate native counts and neighboring-consumer adoption are gaps.

