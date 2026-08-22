# Native Loader and Lifecycle, Technical Design

## Interface
| Symbol | Contract | Result | Confidence |
|---|---|---|---|
| `libgit2` | top-level global | initialized generated binding object | 🟢 |
| `libgit2Opts` | lazy top-level global | `Libgit2Opts` bound to the same library; does not read `libgit2` | 🟢 |
| `_loadLibrary()` | internal platform dispatch | `DynamicLibrary` or exception | 🟢 |
| `_resolvePackageRoot()` | package metadata lookup | absolute package directory | 🟢 |

## Main Flow
1. Reading either public global lazily evaluates `_library`, which selects filename and platform policy. 🟢
2. iOS uses the process image; other platforms try the bare filename. 🟢
3. Desktop failure triggers package-root resolution, dependency preload, and package-local open. 🟢
4. Reading `libgit2Opts` binds option lookups only; reading `libgit2` constructs `Libgit2`, calls `git_libgit2_init()`, and returns it. 🟢 [Codex cross-review]

## Alternatives
- Android rethrows the first open failure because it has no package-path fallback. 🟢
- Package root is resolved synchronously first, then from package-config URI/environment/VM arguments. 🟢
- Package-config parse and IO errors collapse to no result; exhaustion becomes `StateError`. 🟢

## Decisions, State, Observability
- Lazy top-level globals implement independent entry paths over the shared `_library`; import alone does not execute either path. 🟢 [Codex cross-review]
- Package-relative fallback supports transitive/plain-Dart consumers. 🟢
- State is the loaded library plus initialized binding/option globals. Tests balance repeated init calls with repeated shutdown calls, indicating native reference-count semantics, but production ownership remains undefined. 🟡
- Only stderr diagnostics exist; no metrics or structured tracing. 🟢

## Risks and Gaps
- 🟢 The initialization return value is not checked.
- 🔴 No production component owns the matching shutdown call.
- 🟢 The missing-Windows-directory branch attempts a DLL open inside that directory and fails indirectly.
- 🔴 The repository does not establish whether consumers must read `libgit2` before calling `libgit2Opts`; the helper docs require such ordering for Android TLS, but the wrapper does not enforce it.
