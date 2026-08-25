# Gate 1 red evidence — BUG-20260817-AAGV

## Applied test scope

- `test/platform_release_proof_test.dart`
- `test/platform_release_proof_workflow_facts_test.dart`

No validator, workflow, production source, specification, or external harness
was modified for this gate.

## Command

```text
flutter test -j 1 test/platform_release_proof_test.dart test/platform_release_proof_workflow_facts_test.dart
```

Exit code: `1` (expected red).

## Defect proof

The existing aggregate CLI returned `0` where the new reproduction tests require
a non-zero exit:

```text
empty-inventory aggregate input fails closed
Expected: not <0>
Actual: <0>

empty-versions aggregate input fails closed
Expected: not <0>
Actual: <0>

null-attestation aggregate input fails closed
Expected: not <0>
Actual: <0>
```

The same run also proves the missing integration surface for the correction:

```text
platform_release_proof.py: error: unrecognized arguments: --payload-root <fixture-root>\payload

Expected: contains '--payload-root .'
Actual: 'python3 .github/scripts/platform_release_proof.py validate --proofs .platform-proofs'
```

## Test-isolation adjustment

The first attempted Gate 1 run exposed test-only fixture issues (Dart argument
syntax and Windows path separators), not a product behavior claim. Those test
details were corrected within the approved Gate 1 scope before this final red
run. The final evidence above is the authoritative red result.
