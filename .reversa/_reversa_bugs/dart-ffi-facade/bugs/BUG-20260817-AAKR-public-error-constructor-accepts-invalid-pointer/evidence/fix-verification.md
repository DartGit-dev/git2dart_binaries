# Fix verification — BUG-20260817-AAKR

## Implemented change

`LibGit2Error` now has a library-private native-pointer constructor. The
nullable `getLastError()` extension lives in the same Dart library and is the
only construction path; it checks `nullptr` before creating a wrapper.

## Regression evidence

On 2026-08-23:

```text
flutter test -j 1 test/error_api_test.dart
flutter analyze lib/src/error.dart lib/src/extensions.dart test/error_api_test.dart
```

Both commands passed.

## Ownership boundary

The wrapper remains non-owning: it never frees the native error pointer
returned by libgit2.
