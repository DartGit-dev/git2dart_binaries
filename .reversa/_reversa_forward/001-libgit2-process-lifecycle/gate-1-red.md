# Gate 1 RED evidence: Process-global libgit2 lifecycle ownership

> Feature: `001-libgit2-process-lifecycle`
> Date: `2026-08-22`
> Authorization: explicit `APPROVE GATE 1`
> Scope: T001-T007, tests only
> Verdict: EXPECTED RED; Gate 2 required

## Added contracts

| File | Scenarios | Contract boundary |
|------|-----------|-------------------|
| `test/libgit2_runtime_test.dart` | 15 | Checked init/rollback, lease reuse, transient pins, exact-once owner cleanup, rollback/transfer, cleanup failure, guarded/idempotent/terminal/faulted shutdown. |
| `test/public_lifecycle_api_test.dart` | 3 | Approved breaking export, absence of legacy globals, raw lifecycle transitions restricted to the runtime owner. |
| `test/libgit2_lifecycle_integration_test.dart` | 1 | Two isolate-local leases compose through the process count and one isolate remains usable after the other shuts down. |

## Focused validation

| Command | Result | Expected reason |
|---------|--------|-----------------|
| `dart format <three Gate 1 files>` | PASS | All three files are formatted. |
| `dart analyze test/public_lifecycle_api_test.dart` | PASS | Source-contract test is independently valid without generated bindings. |
| `dart test test/public_lifecycle_api_test.dart -r expanded` | RED, `+0 -3` | `lib/src/runtime.dart` is absent; legacy `libgit2` remains; `lib/src/util.dart` still performs raw init. |
| `dart test test/libgit2_runtime_test.dart -r expanded` | RED while loading | Approved `package:git2dart_binaries/src/runtime.dart`, `Libgit2RuntimeState`, and `Libgit2LifecycleException` do not exist. |
| `dart test test/libgit2_lifecycle_integration_test.dart -r expanded` | RED while loading | Approved runtime entry `libgit2Runtime` does not exist. |
| Combined three-file run | RED, `+0 -5` | Two missing-runtime load failures plus the three independent public/source contract failures. |

The RED reason is the missing approved lifecycle contract, not a product regression introduced by tests. The native integration scenario is opt-in when an expanded artifact is present (`GIT2DART_RUN_NATIVE_LIFECYCLE_TESTS=1` or a platform artifact in the package tree).

## Packaged generated binding selected for Gate 2 development

The user directed development to reuse the ready generated file from the installed package. The compatible artifact was verified read-only:

- Source: `C:\Users\Viktor\AppData\Local\Pub\Cache\hosted\pub.dev\git2dart_binaries-1.12.1\lib\src\bindings.dart`
- Package version: `1.12.1`, equal to this repository's `pubspec.yaml`
- Size: `1,324,106` bytes
- SHA-256: `C2C124AA68CD763CC219F92AB03852A96E03D1B8ECA88DAB28D059177D02E925`
- Generated class: `Libgit2`
- Verified lifecycle signatures: `int git_libgit2_init()` and `int git_libgit2_shutdown()`
- Native pin compatibility: repository workflow and SDD both identify libgit2 `1.9.6`

The file was not copied into `lib/` during Gate 1 because this gate is test-only. Gate 2 may copy the verified artifact as a development prerequisite after explicit approval.

## Boundary proof

- `git diff -- lib` produced no output.
- No existing test was changed.
- No commit or push was performed.
- Gate 2 production implementation remains unauthorized.
