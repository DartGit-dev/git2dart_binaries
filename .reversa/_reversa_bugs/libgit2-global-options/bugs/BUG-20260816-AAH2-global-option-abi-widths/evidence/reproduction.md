# Reproduction capsule — BUG-20260816-AAH2

- Base branch: `1.12.2`
- Environment: Windows, Dart/Flutter package checkout
- Date: 2026-08-23

## Before CHG-002

Command:

```text
flutter test -j 1 test/opts_bindings_integration_test.dart
```

Result: failed during compilation. The pointer-width test allocations exposed
the old contracts, for example `Pointer<Size>` and `Pointer<IntPtr>` could not
be passed to wrappers requiring `Pointer<Int>`. The same mismatch occurred for
mwindow, cached-memory, file-limit, and pack-object getter paths.

Classification: deterministic static reproduction; the source-level mismatch
occurred before native loading.

## After CHG-002: source-only checkout

The same focused test compiled beyond the previous Dart type errors and reached
runtime library loading. It then stopped at an external pre-existing Windows
dependency failure:

```text
Failed to load dynamic library 'F:\git2dart_binaries\windows\libssh2.dll'
error code: 126
```

This prevents a local native 64-bit green run. It is distinct from the
corrected ABI declarations and does not reproduce the pre-fix type mismatch.

## After CHG-002: installed 1.12.1 native bundle

Command:

```text
GIT2DART_BINARIES_PACKAGE_ROOT=C:\Users\Viktor\AppData\Local\Pub\Cache\hosted\pub.dev\git2dart_binaries-1.12.1
flutter test -j 1 test/opts_bindings_integration_test.dart
```

Result: PASS, 13 of 13 tests. The bundle supplied `libgit2.dll`,
`libssh2.dll`, `libcrypto-3-x64.dll`, and `libssl-3-x64.dll`; it was used only
through the runtime's package-root diagnostic override and was not copied into
the source checkout. This is the required native 64-bit regression proof for
the affected mwindow, cache, and pack option paths.

## Full regression after CHG-002

Using the same installed 1.12.1 bundle override:

```text
flutter test -j 1
```

Result: PASS, exit code 0; 34 tests passed and 3 platform/package-dependent
tests were skipped. No test failure remained after the ABI correction.
