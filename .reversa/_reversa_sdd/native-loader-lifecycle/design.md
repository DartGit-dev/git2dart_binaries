# Native Loader and Lifecycle, Technical Design

## Interface
| Symbol | Contract | Result | Confidence |
|---|---|---|---|
| `libgit2Runtime` | package-owned isolate-local runtime | initializes and protects generated bindings/options | 🟢 cross-repository lifecycle research |
| `_loadLibrary()` | internal platform dispatch | `DynamicLibrary` or exception | 🟢 |
| `_resolvePackageRoot()` | package metadata lookup | absolute package directory | 🟢 |

## Main Flow
1. Reading `libgit2Runtime.bindings` or `.options` loads the package-owned runtime and ensures initialization before native access. 🟢 cross-repository lifecycle research
2. iOS uses the process image; other platforms try the bare filename. 🟢
3. Desktop failure triggers package-root resolution, dependency preload, and package-local open. 🟢
4. The runtime constructs `Libgit2` and `Libgit2Opts` from one library and is the only production location with raw `git_libgit2_init()`/`git_libgit2_shutdown()` transitions. 🟢 cross-repository lifecycle research

## Alternatives
- Android rethrows the first open failure because it has no package-path fallback. 🟢
- Package root is resolved synchronously first, then from package-config URI/environment/VM arguments. 🟢
- Package-config parse and IO errors collapse to no result; exhaustion becomes `StateError`. 🟢

## Decisions, State, Observability
- Import alone does not execute lifecycle work; managed `bindings` and `options` accessors own initialization over the shared loaded library. 🟢 cross-repository lifecycle research
- Package-relative fallback supports transitive/plain-Dart consumers. 🟢
- State is the loaded library plus a package-owned runtime lifecycle. `git2dart` wrapper objects acquire managed owner leases and release them with explicit/finalizer cleanup; native object lifetime blocks shutdown. 🟢 cross-repository lifecycle research
- Only stderr diagnostics exist; no metrics or structured tracing. 🟢

## Risks and Gaps
- 🟢 The initialization return value is not checked.
- 🟢 `git2dart_binaries` owns raw shutdown transitions through `libgit2Runtime`. The existing public lifecycle API remains unchanged; no automatic teardown or isolate-lifetime policy is introduced. 🟢 user-confirmed compatibility decision
- 🟢 The observed missing-Windows-directory branch attempts a DLL open inside that directory and fails indirectly. The intended policy is now fixed: treat a missing bundled-library directory as an explicit incomplete-package error and do not retry a bare system library name. 🟢 user-confirmed policy
- 🟢 Consumers do not need to order bindings before options: both managed accessors ensure initialization. Public shutdown remains available as a deliberate compatibility decision; misuse risk is accepted. 🟢 user-confirmed compatibility decision
