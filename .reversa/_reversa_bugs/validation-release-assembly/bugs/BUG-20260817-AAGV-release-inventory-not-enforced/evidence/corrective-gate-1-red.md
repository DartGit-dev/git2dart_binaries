# Corrective Gate 1 red evidence - BUG-20260817-AAGV

## Authorized scope

Only the approved CHG-004 test change was applied:

- test/platform_release_proof_test.dart

The validator and GitHub workflow were not modified.

## Command

    flutter test -j 1 test/platform_release_proof_test.dart

## Result

Exit code: **1** (expected red result).

The test suite reached the target behavior checks and reported four failures:

1. arbitrary-attestation aggregate input fails closed - expected non-zero exit, actual 0.
2. incomplete-apple-attestation aggregate input fails closed - expected non-zero exit, actual 0.
3. attestation-digest-mismatch aggregate input fails closed - expected non-zero exit, actual 0.
4. producer proof with silent successful linkage round-trips - expected 0, actual 1; validator output: windows-default/proof.json: invalid linkage.

The remaining 13 checks completed, including the existing empty inventory, empty versions, null attestation, payload-byte mismatch, and producer failure-family cases. This isolates the corrective defect to attestation shape/digest enforcement and the producer/validator treatment of a successful loader probe with no output.

## Traceability

- Regression source: test/platform_release_proof_test.dart
- Planned corrective implementation: fix/CHG-005-code-proposed.diff
- No source code or workflow was changed at this gate.
