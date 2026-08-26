# Addendum: All-branch CI with main-only publication

> Feature: `004-all-branch-ci-main-publish`
> Date: `2026-08-24`
> Scenario: `legacy`

## Vigencia

Vigente desde 2026-08-24.

Superado pela re-extração de 2026-08-25.

## Resumo da entrega

The package release factory now validates every branch push while preserving
pull-request validation. Publication remains fail-closed: only the actual
credential-bearing package-publication step may proceed for an exact `push` to
`refs/heads/main`; package validation and the PR archive remain available
outside that case. All 9 of 9 feature actions are completed.

## Impacto por artefato da extracao

| Artefato | Secao | Tipo de impacto | Delta |
|---|---|---|---|
| `_reversa_sdd/domain.md` | Build, test, and publication rules | regra-alterada | Every branch push now starts the existing validation DAG; the all-branch trigger replaces the former push allow-list. |
| `_reversa_sdd/domain.md` | Build, test, and publication rules | regra-alterada | Package assembly, proof, inventory, provenance, size, dry-run, and PR archive validation remain available outside `main`; only the credential-bearing publication step requires an exact main push. |
| `_reversa_sdd/domain.md` | Build, test, and publication rules | regra-alterada | Workflow-policy regression tests now distinguish validation availability from publication authorization and require the PR archive. |

## Regras sob vigilancia

- `W001` - `_reversa_forward/004-all-branch-ci-main-publish/regression-watch.md`
- `W002` - `_reversa_forward/004-all-branch-ci-main-publish/regression-watch.md`
- `W003` - `_reversa_forward/004-all-branch-ci-main-publish/regression-watch.md`
- `W004` - `_reversa_forward/004-all-branch-ci-main-publish/regression-watch.md`

## Fontes

- `_reversa_forward/004-all-branch-ci-main-publish/legacy-impact.md`
- `_reversa_forward/004-all-branch-ci-main-publish/regression-watch.md`
- `_reversa_forward/004-all-branch-ci-main-publish/requirements.md`
- `_reversa_forward/004-all-branch-ci-main-publish/progress.jsonl`
- `_reversa_forward/004-all-branch-ci-main-publish/actions.md`
