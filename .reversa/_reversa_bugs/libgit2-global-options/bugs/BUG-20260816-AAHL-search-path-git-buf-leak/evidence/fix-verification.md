# Fix verification — BUG-20260816-AAHL

## Implemented change

The test copies the first libgit2-owned search-path value into caller-owned
memory, disposes the first `git_buf` contents before reuse, disposes the second
population in `finally`, and frees all caller-owned allocations.

## Regression evidence

On 2026-08-23, the global-option integration suite passed with the bundled
libgit2 DLLs:

```text
flutter test -j 1 test/opts_bindings_integration_test.dart
```

## Boundary

The suite exercises both getter calls and the matching disposal code. A native
leak detector run is still needed for independent allocation-level proof.
