# Regression Watch: 003-platform-release-proof

## Watch items

| ID | Origin (file, section) | Rule expected after change | Verification type | Violation signal |
|---|---|---|---|---|
| W001 | `domain.md`, Build, test, and publication rules / Rule 31 | Same-run proof for Linux, macOS, Windows, iOS, and all four Android ABIs passes before size, dry-run, PR handoff, or publication eligibility. | presence | Gate is absent, ordered after a downstream transition, or accepts missing/failed/unavailable proof. |
| W002 | `domain.md`, Packaging rules / Rules 20–26 | Each final payload report inventories expected artifacts with relative paths, SHA-256, size, and a platform loader/linkage result. | redacao | A report relies on source declarations, contains host paths, omits digest/inventory/linkage, or source-only output passes. |
| W003 | `domain.md`, Loader and lifecycle rules / Rules 7–13 | Apple static linkage stays attested from final slices, while established loader semantics remain unchanged. | presence | Apple report lacks input/emitted hashes, toolchain/SDK identity, readable metadata, or fails to reject unavailable/mismatched evidence. |

## Historico de re-extracoes

### Re-extração 2026-08-25 17:46

| ID | Veredito | Observação |
|----|----------|------------|
| W001 | 🟢 verde | BR-053/BR-057 and `deployment.md` preserve eight same-run scopes and proof qualification before inventory, provenance, size, consumer, dry-run, handoff, or publication. |
| W002 | 🔴 vermelho | Fresh extraction confirms aggregate validation can accept `status=passed` with empty inventory/versions and null attestation, and does not join proof hashes to payload bytes (`domain.md` BR-054; `code-analysis.md` aggregate validation). This matches the recorded violation signal. |
| W003 | 🟢 verde | Proof creation still records Apple input/output hashes and toolchain/SDK metadata, and BR-029–BR-035 preserve loader semantics; current hosted Apple execution remains unobserved. |

None yet.

## Arquivadas

None.

## Observacoes

No inferred or gap rules are weighted in the main watch. CI execution of the new
cross-platform proof producers is still required to establish live evidence.
