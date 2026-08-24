# Domain Model and Implicit Rules

## Scope and confidence

This domain is a native-runtime distribution package, not a user/business application. Its central concepts are ABI compatibility, native artifact identity, loader reachability, platform packaging, and release qualification.

Evidence is limited to `F:\git2dart_binaries`, its Git history, and current files at `680d914c8e2b87682f0b68318aee855838eb58e8`. No neighboring repository state was read.

- 🟢 **CONFIRMED** — current code/configuration or an ancestor commit directly supports the statement.
- 🟡 **INFERRED** — a design intent synthesized from multiple facts or non-ancestor history.
- 🔴 **GAP** — requires a consumer, binary, CI run, or maintainer confirmation.

## Glossary

| Term | Meaning in this repository | Confidence |
|---|---|---|
| Binding | Generated Dart FFI declarations derived from pinned libgit2 headers | 🟢 |
| Native artifact | A platform library delivered inside the expanded pub package | 🟢 |
| Expanded package | Source checkout plus generated bindings and downloaded native artifacts assembled by CI | 🟢 |
| Platform loader | OS mechanism resolving a bare library name in an application/process | 🟢 |
| Package fallback | Desktop retry using the resolved pub package root and platform subdirectory | 🟢 |
| Transitive consumer | An application that reaches this package through another Dart package and may have a different cwd | 🟢 historical intent; 🔴 current external call site |
| Install name | macOS dylib identity that dyld resolves inside the application bundle | 🟢 |
| Artifact cache manifest | CI metadata used to validate that a cached export matches versions, toolchain, recipe, and files | 🟢 |
| Release gate | Required build/test/size/dry-run conditions before publication | 🟢 |
| Global option | A process-wide libgit2 setting accessed through `git_libgit2_opts` | 🟢 |
| Android TLS bootstrap | Ordered extraction and later application of the bundled CA certificate | 🟢 |

## Implicit and explicit rules

### ABI and version rules

1. 🟢 Bindings and native libgit2 artifacts must be derived from the same pinned libgit2 version. The workflow feeds `LIBGIT2_VERSION` to both generation and builds.
2. 🟢 Experimental SHA-256 must be enabled in both header generation and native builds.
3. 🟢 Required exports include at least `git_libgit2_init` and `git_repository_open`; platform actions fail if these are absent.
4. 🟢 Typed `Libgit2Opts` argument layouts must match their `git_libgit2_opt_t` discriminator because all wrappers call one variadic C symbol.
5. 🟢 A negative pack maximum object size must be rejected in Dart before conversion to native `size_t`.
6. 🔴 The repository does not define a formal compatibility matrix between pub-package versions, libgit2 versions, and the neighboring `git2dart` constraint.

### Loader and lifecycle rules

7. 🟢 iOS must resolve symbols from the process image because static frameworks are force-loaded into the application.
8. 🟢 Android must load `libgit2.so` through the Android app/system loader; there is no package-root fallback.
9. 🟢 Desktop platforms must first allow the application loader to resolve the bare filename, then use a package-local fallback.
10. 🟢 Package-root fallback must not depend solely on current working directory; commit `3ec5df2` explicitly introduced package URI/config resolution for transitive consumers.
11. 🟢 Loader failures are terminal for the import path: errors are logged and rethrown rather than silently continuing without native support.
12. 🟢 Windows fallback loads matching OpenSSL runtime DLLs before `libssh2.dll`, then libgit2.
13. 🟢 macOS's opened filename, vendored filename, and dylib install name must agree. The history records actual application launch/sync failures when they did not.
14. 🔴 Production ownership of `git_libgit2_shutdown()` is not present in this repository.

### Android TLS rules

15. 🟢 libgit2 initialization must precede Android certificate configuration; early configuration can be overwritten.
16. 🟢 The CA asset path must be `packages/git2dart_binaries/assets/certs/cacert.pem` and the extracted file is stored in app temporary storage.
17. 🟢 Initialization becomes cached only after a successful asset write; failures rethrow and remain retryable.
18. 🟡 Concurrent first-time calls can duplicate the extraction because no synchronization primitive exists.
19. 🔴 The higher-level code that calls `AndroidSSLHelper.initialize()` and then applies the path is outside this repository.

### Packaging rules

20. 🟢 Every platform declared in `pubspec.yaml` is an FFI plugin target and must receive its expected artifact path/name.
21. 🟢 iOS packages libgit2, libssh2, libssl, and libcrypto as XCFrameworks and force-loads libgit2.
22. 🟢 macOS packages a self-contained `libgit2.dylib`; CI rejects dynamic references to libssh2/OpenSSL or Homebrew paths.
23. 🟢 Windows must package version-agnostic `libcrypto*.dll` and `libssl*.dll` matches, not a single hard-coded OpenSSL filename. Commit `1acc02c` and regression tests encode this.
24. 🟢 Linux packages `libgit2.so` and expects package-local `libssh2.so` for fallback preloading.
25. 🟢 Android release payload covers x86_64, arm64-v8a, x86, and armeabi-v7a.
26. 🟢 The tracked source checkout is intentionally incomplete as a runnable distribution: generated bindings and native outputs are injected by CI.
27. 🔴 Apple podspec versions are 1.11.2 while the pub package is 1.12.1; no explicit synchronization policy explains this divergence.

### Build, test, and publication rules

28. 🟢 A release uses pinned source tags rather than ambient system libgit2/libssh2 sources.
29. 🟢 Cache reuse is accepted only after manifest validation; an invalid cache is cleared and rebuilt.
30. 🟢 Native builds normalize platform filenames and verify essential symbols before upload.
31. 🟢 Publication waits for Linux, macOS, Windows, iOS, Android tests and the remaining Android ABI builds.
32. 🟢 Pull requests never invoke pub.dev publication; they upload a temporary `release-package` artifact instead.
33. 🟢 The expanded package must not exceed 256 MiB and must pass `dart pub publish --dry-run`.
34. 🟢 iOS test timeout handling must attempt TERM, then KILL in an ensure path, while tolerating already-exited or unkillable process groups (`f85882c`).
35. 🟢 Artifact-dependent local tests may skip when generated bindings/binaries are absent; CI injects those prerequisites before authoritative platform tests.
36. 🔴 No current CI result, binary signature/hash, or pub.dev publication result was verified during this extraction.

## Git archaeology timeline

| Era | Evidence | Decision signal |
|---|---|---|
| 2023 | Initial plugin, macOS bindings, Dart 3 | Establish a Dart/Flutter FFI distribution package |
| May–Jun 2025 | Repeated path/export, libssh2, varargs, ffigen, Windows/macOS CI fixes | ABI generation and native packaging are the product's primary correctness surface |
| Nov 2025 | Android support, CA bundle, loader work, transitive-consumer fix | Runtime initialization and location cannot assume desktop/cwd semantics |
| May–Jun 2026 | macOS install-name and dependency fixes, payload reduction, static linkage | Application-bundle portability outranks mirroring upstream filenames/dependency layout |
| Jun–Jul 2026 | Windows OpenSSL runtime bundling, pinned libgit2 1.9.6/Flutter 3.44, timeout hardening | Release reproducibility and platform validation are explicit gates |

There are 162 commits reachable from the current local HEAD. No commit with a `revert` subject is reachable or present in the inspected refs. Many fixes are incremental rather than formal reversions.

## Historical evidence caveats

- Commit `a7fcc3a` describes an Android SIGSEGV and CMake flags, and its narrative is incorporated into squash commit `40c398d`; however, `a7fcc3a` itself is not an ancestor of current HEAD. Current Android action uses libssh2 and does not contain the exact four historic flags. Therefore the old root-cause statement is 🟡 historical evidence, not a current build invariant.
- Cache commits `32d26d5` and `8e8b1f0` exist on the side branch `1.12.0`, not current HEAD, even though current action files include cache-manifest behavior through later lineage. Claims are based on current files, not assumed branch merge.
- Commit messages that claim end-to-end external app success are valuable user/test evidence but are not a current independent replay.

## Logs and monitored events

No tracked runtime log files were found. Operational observability exists in CI output:

- native version/toolchain fingerprints;
- cache validation outcome;
- native tests and essential export checks;
- before/after artifact sizes;
- emulator/simulator diagnostics on failure;
- package-size diagnostics and pub dry-run results.

These are pipeline events, not application-domain telemetry.

## Product-boundary gaps

1. 🔴 Exact dependency/import edge from `F:\git2dart` to this package.
2. 🔴 Owner and balancing policy for libgit2 init/shutdown calls.
3. 🔴 Consumer call sequence for Android certificate configuration.
4. 🔴 Supported version matrix and release coordination across the two repositories.
5. 🔴 Current live CI and expanded-package evidence for commit `680d914`.

