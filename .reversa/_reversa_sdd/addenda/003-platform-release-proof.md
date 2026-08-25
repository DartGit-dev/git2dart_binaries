# Addendum: Platform Release Artifact Proof

> Feature: `003-platform-release-proof`
> Date: `2026-08-24`
> Scenario: `legacy`

## Vigência

Vigente desde 2026-08-24.

Superado pela re-extração de 2026-08-25.

## Resumo da entrega

This feature adds fail-closed, same-run evidence that the expanded release payload
contains complete and loadable native artifacts for Linux, macOS, Windows, iOS, and
all supported Android ABIs. All 11 planned actions are recorded as completed.

## Impacto por artefato da extração

| Artefato | Seção | Tipo de impacto | Delta |
|---|---|---|---|
| `_reversa_sdd/architecture.md` | Architectural invariants | regra-alterada | Release eligibility now requires valid same-run platform proof before existing inventory, size, dry-run, PR handoff, or publication transitions. |
| `_reversa_sdd/domain.md` | Build, test, and publication rules | regra-alterada | The assembled package, not source declarations, must supply complete platform/ABI proof with readable compiled-version evidence. |
| `_reversa_sdd/domain.md` | Packaging rules | regra-nova | Per-platform proof records now inventory artifact-relative paths, digests, sizes, and loader or linkage observations. |
| `_reversa_sdd/architecture.md` | Component responsibilities | componente-novo | The platform-proof helper and its workflow contract provide a fail-closed release-assembly evidence component. |

## Regras sob vigilância

- `W001` — `_reversa_forward/003-platform-release-proof/regression-watch.md`
- `W002` — `_reversa_forward/003-platform-release-proof/regression-watch.md`
- `W003` — `_reversa_forward/003-platform-release-proof/regression-watch.md`

## Fontes

- `_reversa_forward/003-platform-release-proof/legacy-impact.md`
- `_reversa_forward/003-platform-release-proof/regression-watch.md`
- `_reversa_forward/003-platform-release-proof/requirements.md`
- `_reversa_forward/003-platform-release-proof/progress.jsonl`
- `_reversa_forward/003-platform-release-proof/actions.md`
