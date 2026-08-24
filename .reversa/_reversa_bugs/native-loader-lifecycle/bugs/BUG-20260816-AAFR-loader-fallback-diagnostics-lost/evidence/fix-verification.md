# Fix verification — BUG-20260816-AAFR

## Implemented change

The desktop fallback now tracks the active stage: package-root resolution,
dependency preload, or the package library path. A single catch reports that
stage and its failure alongside the original bare-name loader failure.

## Regression evidence

On 2026-08-23:

```text
flutter test -j 1 test/loader_diagnostic_test.dart
flutter analyze lib/src/runtime.dart test/loader_diagnostic_test.dart
```

Both commands passed.

## Boundary

The regression test verifies the diagnostic aggregation structure. A forced
desktop loader failure on each supported desktop platform remains needed to
prove emitted runtime text.
