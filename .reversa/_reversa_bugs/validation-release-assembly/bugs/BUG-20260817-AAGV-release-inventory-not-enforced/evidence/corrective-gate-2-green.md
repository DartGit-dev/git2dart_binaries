# Corrective Gate 2 green evidence - BUG-20260817-AAGV

## Authorized implementation scope

Only CHG-005 changed .github/scripts/platform_release_proof.py.

- Successful linkage probes with no process output now emit a stable non-empty diagnostic.
- Attestation is an exact platform contract: all proofs require emitted_payload_sha256; macOS/iOS also require input_sha256, emitted_sha256, toolchain, sdk, and compiled_metadata.
- Digest values require lowercase SHA-256 syntax; Apple compiled metadata must equal the proof versions.
- The aggregate validator recomputes the hash of the platform and ABI payload segment and compares it with the emitted attestation digest. macOS/iOS emitted_sha256 is bound to the same segment.
- Tree hashing orders relative POSIX paths, keeping the digest deterministic across runner path conventions.

No workflow was changed: the already-approved CHG-003 continues to pass --payload-root to aggregate validation.

## Validation

    python -m py_compile .github/scripts/platform_release_proof.py
    flutter test -j 1 test/platform_release_proof_test.dart test/platform_release_proof_workflow_facts_test.dart

Result: exit code 0; 18 tests passed.

The suite includes the corrected red cases:

- arbitrary attestation is rejected;
- incomplete Apple attestation is rejected;
- attestation digest/payload mismatch is rejected;
- a producer proof whose successful loader probe has no output validates end-to-end.

## Remaining boundary

This is local targeted evidence only. The package closure policy still requires independent review approval plus hosted release-assembly, merge, and publication evidence.
