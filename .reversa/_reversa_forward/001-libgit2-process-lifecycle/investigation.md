# Investigation: Process-global libgit2 lifecycle ownership

> Feature: `001-libgit2-process-lifecycle`
> Date: `2026-08-22`
> Mode: read-only discovery; no production changes or runtime launch

## Evidence boundary

- 🟢 Current `lib/src/util.dart` lazily loads one platform library per isolate, creates `libgit2Opts`, and creates `libgit2` through `_initializeLibgit2`, which invokes `git_libgit2_init()` without checking its result.
- 🟢 No production path in this package invokes `git_libgit2_shutdown()`.
- 🟢 Existing packaging tests manually call extra init and two shutdowns, demonstrating reference-count assumptions but not production ownership.
- 🟢 Committed `git2dart` evidence at `b118faf` preserves ZC7X reproduction/root cause/debate. The reproduction observed `2 -> 3 -> 4`; the active RED consumer test and consumer-owned loader proposal were removed before that commit.
- 🟢 `F:/git2dart/Python/` remains unrelated and untouched.
- 🟡 Cross-platform and multi-isolate behavior is not yet proven in this feature branch; that is gated test work.

## Upstream contract

Official libgit2 documentation states that initialization is required before other APIs, may be called multiple times, and returns the number of unmatched initializations or an error code:

- https://libgit2.org/docs/reference/main/global/git_libgit2_init.html
- https://libgit2.org/docs/reference/main/global/git_libgit2_shutdown.html
- https://github.com/libgit2/libgit2#initialization

The upstream guidance requires matching shutdown calls and delaying shutdown until worker threads have exited. This supports an isolate lease model but does not define Dart ownership, finalizers, or wrapper transfer; those are package responsibilities.

## Current causal chain

1. Reading the legacy `libgit2` top-level value evaluates `_library` and `_initializeLibgit2` in that isolate.
2. `_initializeLibgit2` increments the process-global native count and ignores success/failure.
3. `git2dart` independently calls raw `git_libgit2_init()` across many public entry points.
4. Neither production package owns the corresponding shutdown path.
5. Repeated public calls therefore increase the count without a bounded lifecycle.

The binaries package's current eager-on-first-read increment is not itself unbounded within one isolate, but it is unowned and prevents the consumer from defining a correct boundary. Moving loading into `git2dart` would duplicate platform knowledge and was correctly superseded.

## Alternatives evaluated

### A. One managed native lease per isolate plus logical pins — selected

The first supported entry checks native init and records one lease. Later calls and owners reuse it. Logical transient and persistent pins prevent premature shutdown. This matches the native refcount model, Dart isolate state, and the confirmed package boundary.

### B. Init/shutdown around every public call — rejected

Per-call native transitions create counter churn, cannot protect wrappers that outlive the call, and can tear down global options/TLS while derived owners remain usable.

### C. One process coordinator isolate — rejected

A coordinator could serialize counters but cannot safely centralize arbitrary FFI pointers or synchronous wrapper use across isolate heaps. It adds messaging and failure modes without replacing the native atomic count.

### D. Automatic runtime finalizer or isolate-exit shutdown — rejected

Dart finalization is nondeterministic and cannot prove all native owners or callbacks are finished. Shutdown must be explicit and deterministic; finalizers are fallback cleanup for individual owners only.

### E. Consumer-owned loader/runtime — rejected

This duplicates `DynamicLibrary`, platform path/dependency loading, and process state in `git2dart`, violating the confirmed architecture.

### F. Remove the entire generated binding surface — rejected for this feature

Backward compatibility is not required, so the legacy top-level lifecycle globals can be removed. However, `git2dart` still needs broad non-lifecycle FFI access; replacing the whole generated binding with handwritten wrappers would expand this lifecycle feature far beyond its purpose. The runtime may expose the generated binding object for managed non-lifecycle calls, while raw init/shutdown methods remain unsupported and unused outside controlled probes.

## Lifecycle state model

```text
uninitialized
  -- checked init succeeds --> initialized
  -- init/rollback ambiguity --> faulted-terminal

initialized
  -- acquire/release logical pins --> initialized
  -- shutdown with pins --> initialized + StateError
  -- shutdown succeeds --> terminated
  -- ambiguous shutdown result --> faulted-terminal

terminated
  -- repeated shutdown --> terminated (stored result)
  -- managed entry --> rejected
```

Initialization failure before Dart state commit performs exactly one rollback because supported libgit2 implementations may increment before later initialization work reports failure. If rollback is ambiguous, fail closed instead of retrying either transition.

## Ownership classification for the later consumer gate

| Class | Runtime protection | Completion |
|-------|--------------------|------------|
| Ownerless synchronous call | transient call pin | `finally` |
| Root native owner | persistent owner pin | destructor then release |
| Derived independent owner | its own persistent pin | its own destructor then release |
| Borrowed view | protected by source owner | no new pin |
| Materialized Dart value | call/source protection only | no persistent pin |
| Transferred native owner | provisional/persistent pin | transfer without destructor |
| Failed constructor | provisional pin | rollback partial owner, then release |

## Open proof obligations

- Gate 1 must establish the intended API and state machine as RED without production edits.
- Gate 2 must prove initialization rollback, shutdown failure handling, and exclusive supported access through the runtime manager after removal/replacement of legacy lifecycle globals.
- Expanded-package/native tests must prove the calling-isolate delta, not assume the process count begins or ends at zero.
- The consumer gate must inventory all ownership-producing paths rather than mechanically replacing the 66 init calls.
- Platform CI must confirm no regression in Windows dependency preload, macOS install-name loading, Linux sidecars, iOS process symbols, or Android TLS ordering.
