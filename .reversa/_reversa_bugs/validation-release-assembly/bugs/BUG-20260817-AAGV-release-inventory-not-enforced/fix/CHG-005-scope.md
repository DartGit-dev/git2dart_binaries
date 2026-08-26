# CHG-005 corrective Gate 2 scope

## Proposed implementation

Only .github/scripts/platform_release_proof.py would change.

1. A successful loader probe with no process output would receive a stable, non-empty diagnostic, allowing the producer's valid linkage.result: passed proof to satisfy the existing aggregate linkage requirement.
2. Attestation would become an exact per-platform contract:
   - every platform: emitted_payload_sha256;
   - macOS/iOS additionally: input_sha256, emitted_sha256, toolchain, sdk, and compiled_metadata.
3. All declared digest fields would require lowercase SHA-256 syntax. macOS/iOS metadata must match the proof's version evidence.
4. Aggregate validation with its existing --payload-root would recompute the payload tree hash and require it to match emitted_payload_sha256; macOS/iOS would also require emitted_sha256 to match that same tree hash.

## Workflow decision

No workflow change is proposed. CHG-003 already supplies --payload-root . to the aggregate validation step, which is the input needed for byte-to-attestation binding.

## Boundary

The aggregate step cannot independently re-hash the original Apple input artifact because that artifact is not preserved in the assembled payload. CHG-005 validates the input digest's format and provenance field, while binding both emitted digests to the final payload bytes.
