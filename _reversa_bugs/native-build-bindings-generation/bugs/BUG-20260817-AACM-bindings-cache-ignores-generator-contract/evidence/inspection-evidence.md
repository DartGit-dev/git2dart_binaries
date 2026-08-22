# Inspection Evidence

## Cache identity

- `.github/actions/generate-bindings/action.yml:13-27` fingerprints OS, architecture, clang, CMake, Flutter, and libgit2, then hashes only the action and manifest utility.
- `ffigen.yaml` and the resolved ffigen dependency do not enter that key.
- `.github/scripts/native_cache_manifest.py:16-25` has no generator-configuration or generator-version metadata field.

## Causal path

- `.github/actions/generate-bindings/action.yml:35-47` accepts a matching manifest and copies cached `bindings.dart`.
- `.github/actions/generate-bindings/action.yml:53-106` runs checkout, header preparation, ffigen, and manifest creation only when the cache was not accepted.
- `ffigen.yaml:1-14` controls entry points, compiler defines, output, naming, and comments.
- `pubspec.yaml:19-20` permits a range of ffigen implementations.

The stale-output path is statically complete. Runtime replay is not required to establish that a generator-contract-only change can reuse old bytes and skip regeneration.

