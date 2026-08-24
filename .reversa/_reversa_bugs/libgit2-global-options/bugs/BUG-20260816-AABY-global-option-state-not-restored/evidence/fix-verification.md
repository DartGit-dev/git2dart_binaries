# Fix verification — BUG-20260816-AABY

## Implemented change

Every test that changes a readable global option now registers exact-value
restoration in teardown or uses `finally` for string-backed options. Tests for
options without a corresponding getter no longer mutate process-global state in
the shared integration process.

## Regression evidence

On 2026-08-23, the following command passed using the bundled libgit2 DLLs:

```text
flutter test -j 1 test/opts_bindings_integration_test.dart
```

The suite completed 12 tests successfully.

## Boundary

The test framework guarantees teardown after a test failure; a deliberately
failing production test was not added. Merge and package publication remain
required for closure.
