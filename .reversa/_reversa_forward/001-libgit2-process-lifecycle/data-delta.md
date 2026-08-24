# Data delta: Process-global libgit2 lifecycle ownership

> Feature: `001-libgit2-process-lifecycle`
> Persistent storage impact: none

## Conceptual state added

| State/field | Scope | Initial value | Rule |
|-------------|-------|---------------|------|
| lifecycle phase | Dart isolate | `uninitialized` | Transitions only through checked init or guarded shutdown. |
| native lease owned | Dart isolate | `false` | Becomes true after positive init; cleared/finalized exactly once. |
| generated binding | Dart isolate | absent/lazy | One instance bound to the package-owned library. |
| options binding | Dart isolate | absent/lazy | One instance bound to the same library and managed epoch. |
| active call count | Dart isolate | `0` | Increment/decrement in a synchronous guard; never changes native refcount. |
| live owner records | Dart isolate | empty | One record per independently usable owned native value. |
| shutdown remaining count | Dart isolate | absent | Stored after first successful native shutdown and returned idempotently. |
| terminal fault | Dart isolate | absent | Captures ambiguous init rollback/shutdown/cleanup failures; fails closed. |
| finalizer diagnostics | Dart isolate/test seam | empty | Records non-throwing fallback cleanup failures. |

## Owner lease state

```text
provisional
  -> owned       (destructor bound)
  -> rolled-back (partial cleanup succeeds)
  -> transferred (ownership consumed elsewhere, no destructor)

owned
  -> released       (destructor succeeds, pin released)
  -> cleanup-failed (pin retained, shutdown blocked)
  -> transferred    (no destructor, pin released)

completed states are idempotent for repeated completion calls.
```

## Removed conceptual state

- Unchecked implicit native increment with no Dart owner.
- Independent package paths that may each initialize the same loaded library.
- Test assumptions that two manual shutdowns are the normal balance for legacy eager initialization plus a probe increment.

## Migration

No database, file, serialization, or user-data migration is needed. Runtime state exists only for the lifetime of a Dart isolate. Public API migration is handled by the separate `git2dart` consumer gate after binaries Gate 2 is GREEN.
