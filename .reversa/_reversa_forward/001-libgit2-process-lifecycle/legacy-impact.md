# Legacy impact: Process-global libgit2 lifecycle ownership

> Feature: `001-libgit2-process-lifecycle`
> Date: `2026-08-22`
> Round: Gate 1 RED plus Gate 2 binaries GREEN
> Legacy anchor: `_reversa_sdd/architecture.md` and `_reversa_sdd/domain.md`

## Affected files

| Affected file | Component | Type | Severity | Justification |
|---------------|-----------|------|----------|---------------|
| `lib/src/bindings.dart` | Generated FFI layer | component-new in tracked feature state | MEDIUM | Adds the byte-identical generated ABI from installed package 1.12.1; lifecycle methods remain raw ABI used by the runtime owner. |
| `lib/src/runtime.dart` | Native loader/lifecycle | rule-new | HIGH | Adds checked isolate-local lifecycle accounting, logical pins, exact-once ownership, rollback/transfer, finalizer fallback, and guarded terminal shutdown. |
| `lib/src/util.dart` | Native loader/lifecycle | rule-altered | HIGH | Removes eager unchecked initialization and legacy globals; retains only the managed-runtime compatibility import path. |
| `lib/src/error.dart` | Dart FFI facade / native errors | rule-new | MEDIUM | Adds stable lifecycle operation/error diagnostics without coupling pure tests to Flutter. |
| `lib/git2dart_binaries.dart` | Dart FFI facade | rule-altered | HIGH | Exports the breaking managed lifecycle contract. |
| `README.md` | Dart FFI facade documentation | rule-altered | LOW | Documents managed use, owner leases, terminal shutdown, and the unsupported raw-method escape hatch. |
| `test/libgit2_runtime_test.dart` | Native loader/lifecycle validation | rule-new contract | LOW | Covers 15 deterministic lifecycle state-machine scenarios. |
| `test/public_lifecycle_api_test.dart` | Dart FFI facade validation | contract-delta test | LOW | Locks the runtime export, legacy-global removal, and package raw-call boundary. |
| `test/libgit2_lifecycle_integration_test.dart` | Native loader/lifecycle validation | rule-new contract | MEDIUM | Proves real process-count composition across two Dart isolates. |
| `test/opts_bindings_integration_test.dart` | Global-options wrapper validation | rule-altered | LOW | Uses cached managed bindings/options and one exact isolate shutdown. |
| `test/windows_packaging_test.dart` | Platform packaging validation | rule-altered | LOW | Proves managed package-root loading in a plain Dart subprocess against an expanded artifact root. |
| `test/macos_dylib_packaging_test.dart` | Platform packaging validation | rule-altered | LOW | Removes manual lifecycle over-balancing and specifies managed package-root use for macOS. |
| `lib/src/bindings.dart`; platform-native build/release artifacts | Native build and release assembly | rule-altered | MEDIUM | Defines generated bindings and assembled native artifacts as build/release outputs, not source-checkout inputs. Removes the four untracked Windows runtime DLLs; tests requiring an expanded package must explicitly declare and supply that artifact-root precondition. |

## Conceptual delta by component

### Native loader/lifecycle

Library selection, dependency preload, and package-root fallback moved behind `Libgit2Runtime`. The previous unchecked eager increment is replaced by a checked positive native lease that is acquired at most once per isolate. Failed attempts roll back once. Transient calls and persistent owners are logical pins only; shutdown refuses live pins, performs one native decrement, stores the remaining process count, and makes the isolate terminal.

### Dart FFI facade and native errors

The supported public lifecycle surface is now `libgit2Runtime`, `Libgit2Runtime`, `Libgit2RuntimeState`, and `Libgit2OwnerLease`. Source compatibility with `libgit2` and `libgit2Opts` is intentionally removed. Stable lifecycle diagnostics distinguish initialization, rollback, shutdown, and finalizer cleanup failures.

### Generated FFI layer

The generated file is not redesigned. It is byte-identical to the selected installed 1.12.1 package artifact. Raw init/shutdown methods remain technically public as an explicitly accepted non-critical escape hatch; supported package and migrated-consumer code route accounting through the runtime manager.

### Validation and platform packaging

Existing options and platform tests no longer add or over-balance lifecycle increments. Windows evidence covers a real two-isolate count, selected global options, and a plain-Dart fallback loader. macOS-specific execution remains host-skipped and must be supplied by its platform gate/CI.

## Preserved confirmed rules

- `_reversa_sdd/domain.md#ABI and version rules` rule 1: bindings and native artifacts remain version-aligned; the selected package and repository are both 1.12.1 with pinned libgit2 1.9.6 evidence.
- Loader rule 7: iOS still resolves from `DynamicLibrary.process()`.
- Loader rule 8: Android still opens `libgit2.so` through the app/system loader without desktop package fallback.
- Loader rules 9–10: desktop still tries the bare filename before package URI/config fallback; the diagnostic artifact-root override remains package-owned.
- Loader rule 11: loading/dependency failures remain logged and rethrown.
- Loader rule 12: Windows fallback still preloads matching OpenSSL DLLs, then `libssh2.dll`, before libgit2.
- Loader rule 13: the macOS target remains `libgit2.dylib`, preserving filename/install-name alignment.
- Android TLS rule 15: managed initialization still precedes certificate configuration, and terminal shutdown prevents transparent epoch replay.
- Build/test rule 35: source-only local tests may skip absent platform artifacts, while expanded-artifact proof can be injected explicitly.

## Modified confirmed rules

No pre-existing 🟢 domain rule was removed or weakened. The implementation changes the ownership mechanism inside the confirmed Native loader/lifecycle component and closes the former 🔴 rule-14 gap: production now has an explicit, guarded owner of one symmetric `git_libgit2_shutdown()` per isolate lease.

- Build/test rule 35 is clarified: generated bindings and assembled platform-native artifacts are owned by build/release validation rather than source checkout tests; an expanded-package test must declare and provide its artifact-root precondition.
