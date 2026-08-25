# Semantic regression occurrence, 2026-08-25

## Source

- Intake: `../../../intake/relato-20260825-1802.md`
- Regression watch: `../../../../../_reversa_forward/003-platform-release-proof/regression-watch.md`, item `W002`
- Effective addendum: `../../../../../_reversa_sdd/addenda/003-platform-release-proof.md`

## Observation

The completed 2026-08-25 semantic re-extraction checked 23 regression-watch items. Twenty-two were green and `003-platform-release-proof/W002` was red.

The aggregate validator accepts records with `status=passed`, empty `inventory` and `versions`, and a null `attestation`. It also does not compare proof digests with the downloaded release payload bytes. A structurally present platform proof can therefore advance without proving complete inventory semantics or payload identity.

## Expected contract

W002 requires each final payload report to inventory expected artifact-relative paths, SHA-256 values, sizes, and a platform loader or linkage result. Aggregate acceptance must reject semantically empty records and establish that the proof digests identify the assembled payload bytes.

## Dedupe disposition

The user selected update of `BUG-20260817-AAGV` instead of a separate canonical bug. This occurrence extends the existing evidence from missing native inventory enforcement to the aggregate proof's version, linkage, attestation, and proof-to-payload identity semantics.

## Evidence boundary

This is deterministic static source and fixture evidence plus completed semantic re-extraction. It is not proof of a current hosted workflow run, assembled release payload, publication attempt, or registry outcome.

## Classification

The user selected severity `high` and priority `P1` for this occurrence on 2026-08-25. These values match the existing aggregate classification, so the canonical bug fields remain unchanged.
