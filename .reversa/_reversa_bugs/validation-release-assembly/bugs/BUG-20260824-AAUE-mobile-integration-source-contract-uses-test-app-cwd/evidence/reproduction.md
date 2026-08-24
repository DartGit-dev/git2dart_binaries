# Reproduction capsule

- Base commit: `4f40d79db46f4c5914361bf8a376ed8dc473f9f2`
- Workflow: GitHub Actions `Build package`, push run `32703598224`
- Classification: deterministic, Android and iOS both failed

Both jobs completed the native cache-option tests and then failed at `test/opts_bindings_integration_test.dart:179` with:

```
PathNotFoundException: Cannot open file, path = 'lib/src/opts_bindings.dart'
```

The mobile workflow runs the copied test from a generated application, which has no repository-relative `lib/src/opts_bindings.dart`.
