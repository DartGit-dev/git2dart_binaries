# Gate 2 green evidence — BUG-20260817-AAGV

## Applied scope

- `CHG-002` — `.github/scripts/platform_release_proof.py`
- `CHG-003` — `.github/workflows/build_package.yml`

The correction requires complete expected inventory, non-empty structured
attestation, exact version evidence, a shared candidate, and (when the workflow
supplies a payload root) matching SHA-256 and size for every proof inventory
file in the final release layout.

## Validation

```text
flutter test -j 1 test/platform_release_proof_test.dart test/platform_release_proof_workflow_facts_test.dart
```

Exit code: `0`.

```text
+14: All tests passed!
```

The passing set covers complete payload-backed proof acceptance; malformed,
failed, unsafe, missing, unexpected, semantically empty, and payload-byte
mismatch inputs; proof creation failures; and the workflow invocation order and
payload-root argument.

```text
dart format --output=none --set-exit-if-changed test/platform_release_proof_test.dart test/platform_release_proof_workflow_facts_test.dart
```

Exit code: `0` (`Formatted 2 files (0 changed)`).

## Boundary

This is local deterministic proof only. It does not prove a hosted GitHub
Actions run, downloaded remote artifact contents, merge, publication, or
registry acceptance.
