# libgit2 Global Options, Technical Design

## Interface
`Libgit2Opts(DynamicLibrary)` stores `lookup`, then lazily materializes typed Dart functions for the single native symbol `git_libgit2_opts`. Public methods group into integer, size, buffer/string, search-path, cache, TLS, and string-array signatures. 🟢

## Main Flow
1. Construct the wrapper from the loader's dynamic library. 🟢
2. On first use of a signature family, resolve `git_libgit2_opts` and convert it to the matching Dart function. 🟢
3. Pass the option discriminator followed by typed arguments. 🟢
4. Return the libgit2 status code without reinterpretation. 🟢

## Alternative Flows
- Negative pack object size throws locally. 🟢
- Native failures remain integer codes; callers may query the last error through the facade. 🟢
- The caller allocates the outer `git_buf`/`git_strarray` and must invoke the corresponding libgit2 disposal function for contents populated by libgit2. 🟢 current tests; 🟡 unobserved wrappers

## Dependencies and Decisions
- Depends on generated enums/structs and the loaded native symbol. 🟢
- Multiple FFI typedefs over one variadic symbol trade abstraction for ABI-specific type safety at Dart call sites. 🟢
- No global-option values are cached in Dart; libgit2 is the source of state. 🟢

## Observability
No logging or metrics are emitted. Status codes and `git_error_last()` are the observable failure channel. 🟢

## Risks and Gaps
- 🟢 A wrong discriminator/signature pairing can corrupt the ABI boundary.
- 🟢 Most integer arguments lack Dart-side range or enum validation.
- 🔴 Many wrappers lack direct integration coverage.
- 🟡 Global mutations can leak between consumers if not restored.
