# Fix verification — BUG-20260816-AAH6

## Root cause

The Linux CMake manifest did not carry `libssh2.so` even though the Linux build
exports it and `libgit2.so` depends on it.

## Implemented change

`linux/CMakeLists.txt` now adds `libssh2.so` to
`git2dart_binaries_bundled_libraries` beside `libgit2.so`.

## Regression evidence

On 2026-08-23, the following command passed:

```text
flutter test -j 1 test/linux_packaging_test.dart
```

The test verifies that the CMake manifest declares both shared libraries.

## Boundary

This is a static packaging-manifest test run on Windows. A clean Linux Flutter
bundle and runtime load still require Linux CI or a Linux consumer environment.
