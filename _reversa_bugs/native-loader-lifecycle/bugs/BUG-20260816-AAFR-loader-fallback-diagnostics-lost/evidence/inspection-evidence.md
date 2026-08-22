# Inspection Evidence

## Static causal path

1. `lib/src/util.dart:41-43` captures the initial bare-name failure as `firstError`.
2. `lib/src/util.dart:52-54` resolves the package root and preloads dependencies before entering the final fallback open handler.
3. `lib/src/util.dart:55-64` is the only block that prints both `firstError` and the package fallback path.
4. `lib/src/util.dart:77-92` catches dependency failures but prints only the dependency error.
5. `lib/src/util.dart:123-135` can throw a generic package-location `StateError` before the combined diagnostic is reached.
6. `_reversa_sdd/native-loader-lifecycle/requirements.md:26` requires both attempts to be retained.

## Evidence status

The control-flow deviation is statically confirmed. No native artifact is required to establish that the combined diagnostic is bypassed on these branches.
