# Regression Watch: 003-platform-release-proof

## Watch items

| ID | Origin (file, section) | Rule expected after change | Verification type | Violation signal |
|---|---|---|---|---|
| W001 | `domain.md`, Build, test, and publication rules / Rule 31 | Same-run proof for Linux, macOS, Windows, iOS, and all four Android ABIs passes before size, dry-run, PR handoff, or publication eligibility. | presence | Gate is absent, ordered after a downstream transition, or accepts missing/failed/unavailable proof. |
| W002 | `domain.md`, Packaging rules / Rules 20–26 | Each final payload report inventories expected artifacts with relative paths, SHA-256, size, and a platform loader/linkage result. | redacao | A report relies on source declarations, contains host paths, omits digest/inventory/linkage, or source-only output passes. |
| W003 | `domain.md`, Loader and lifecycle rules / Rules 7–13 | Apple static linkage stays attested from final slices, while established loader semantics remain unchanged. | presence | Apple report lacks input/emitted hashes, toolchain/SDK identity, readable metadata, or fails to reject unavailable/mismatched evidence. |

## Historico de re-extracoes

None yet.

## Arquivadas

None.

## Observacoes

No inferred or gap rules are weighted in the main watch. CI execution of the new
cross-platform proof producers is still required to establish live evidence.
