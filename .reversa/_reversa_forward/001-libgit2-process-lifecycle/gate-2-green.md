# Gate 2 GREEN evidence: Process-global libgit2 lifecycle ownership

> Feature: `001-libgit2-process-lifecycle`
> Date: `2026-08-22`
> Authorization: explicit `APPROVE GATE 2`
> Scope: T008-T017 in `git2dart_binaries` only
> Verdict: GREEN on the available Windows host; separate `git2dart` consumer gate remains closed

## Implemented contract

- `Libgit2RuntimeState` provides checked positive initialization, single rollback, one native lease per isolate, transient call pins, guarded/idempotent/terminal shutdown, and fault retention.
- `Libgit2OwnerLease` provides exact-once destructor completion, construction rollback, ownership transfer, explicit cleanup, non-throwing finalizer fallback, and fail-closed retained pins.
- `Libgit2Runtime` owns platform library discovery, generated bindings/options construction, and the only supported package calls to generated `git_libgit2_init()`/`git_libgit2_shutdown()`.
- Legacy eager `libgit2`/`libgit2Opts` globals are removed. The package barrel exports the managed runtime contract.
- Generated raw lifecycle methods remain an explicitly accepted unsupported escape hatch.

## Packaged binding integrity

The Gate 2 `lib/src/bindings.dart` is byte-identical to the user-selected installed package artifact:

- Source: `C:\Users\Viktor\AppData\Local\Pub\Cache\hosted\pub.dev\git2dart_binaries-1.12.1\lib\src\bindings.dart`
- Destination: `lib/src/bindings.dart`
- SHA-256 for both: `C2C124AA68CD763CC219F92AB03852A96E03D1B8ECA88DAB28D059177D02E925`
- Generated lifecycle signatures used by the runtime: `int git_libgit2_init()` and `int git_libgit2_shutdown()`

## Validation

| Check | Result | Evidence boundary |
|-------|--------|-------------------|
| `dart format` on handwritten changed Dart/test files | PASS | No formatting delta remains; generated binding bytes were deliberately not reformatted. |
| `dart analyze` | PASS, `No issues found!` | Entire current package checkout. |
| `flutter test -j 1` with the installed 1.12.1 artifact root and native lifecycle opt-in | PASS, `33 passed`, `2 skipped` | All discovered tests on Windows; skips are the two macOS-only packaging tests. |
| Two-isolate native lifecycle test | PASS | Real `libgit2.dll` process count: independent isolate increments, first shutdown leaves the second usable, second shutdown balances its lease. |
| Options integration | PASS, 11 scenarios plus teardown | Repeated bindings/options reuse and one managed terminal shutdown. |
| Windows packaging/plain-Dart loader | PASS, 3 scenarios | OpenSSL packaging contracts and package-root fallback using the managed runtime. |
| Raw lifecycle source scan | PASS | Production calls occur only in `lib/src/runtime.dart` plus generated ABI; controlled count probe remains test-only. |

The first native attempt correctly failed because the feature worktree is source-only and lacks expanded DLLs. Validation then used the already installed package artifact through the package-owned `GIT2DART_BINARIES_PACKAGE_ROOT` diagnostic override; no native DLL was copied into the worktree.

## Remaining proof boundary

- macOS, Linux, iOS, and Android runtime/platform validation was not executable on this Windows host.
- `git2dart` has not been edited or tested. Its ownership inventory and migration require the separately approved consumer integration/regression gate.
- Final Reversa spec verdict/closure must wait for that consumer gate.
- No commit or push was performed.
