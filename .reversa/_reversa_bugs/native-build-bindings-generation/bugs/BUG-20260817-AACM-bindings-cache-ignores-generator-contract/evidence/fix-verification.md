# Fix verification — BUG-20260817-AACM

## Root cause

The bindings-cache restore/save keys omitted both `ffigen.yaml` and
`pubspec.lock`. Those files represent the ffigen configuration and resolved
generator dependency graph, respectively.

## Implemented change

Both bindings-cache keys now hash the action, manifest utility, `ffigen.yaml`,
and `pubspec.lock`.

## Regression evidence

On 2026-08-23, this command passed:

```text
flutter test -j 1 test/generate_bindings_cache_test.dart
```

The test requires both inputs to appear in both cache keys.

## Boundary

The local test validates the composite-action declaration only. GitHub Actions
must still demonstrate cache invalidation and a subsequent valid cache hit.
