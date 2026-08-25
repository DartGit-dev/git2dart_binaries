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
- Production bindings derive from official libgit2 1.9.6 headers in CI. The matching official artifact is acquired from the server first and downloaded at the exact version when unavailable locally. `lib/src/bindings.dart` is never tracked or committed; validation and production assembly consume only the generated artifact from that same workflow run, with no local or source-controlled fallback. 🟢 user-confirmed ABI artifact policy
- Multiple FFI typedefs over one variadic symbol trade abstraction for ABI-specific type safety at Dart call sites. 🟢
- No global-option values are cached in Dart; libgit2 is the source of state. 🟢

## Observability
No logging or metrics are emitted. Status codes and `git_error_last()` are the observable failure channel. 🟢

## Risks and Gaps
- 🟢 A wrong discriminator/signature pairing can corrupt the ABI boundary.
- 🟢 Most integer arguments lack Dart-side range or enum validation.
- 🟢 Current direct integration coverage is incomplete; complete native coverage is mandatory before the full option set is accepted as supported. 🟢 user-confirmed coverage gate
- 🟡 Global mutations can leak between consumers if not restored.

## 2026-08-25 ABI Shape

The 14 shapes cover `Int`, `Size`, `IntPtr`, `git_buf`, C strings, search-level pairs, object-type plus size, two signed outputs, two strings, `git_strarray`, and pointer-array plus size. 🟢

HC-04 couples every discriminator to exactly one variadic tuple and native ownership rule; source types alone do not prove header or runtime agreement. 🟢 contract; 🔴 generated values/current matrix

W001 supplies one strong pointer-width observation when its declared native fixture is available; it does not establish all 33 wrappers or five platforms. 🟢 bounded evidence
