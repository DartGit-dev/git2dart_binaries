# Addendum — Behavior-proving package validation

> Feature: `005-behavior-proving-tests`
> Date: `2026-08-25`
> Scenario: `legacy`

## Vigência

Vigente desde 2026-08-25.

Superado pela re-extração de 2026-08-25.

## Resumo da entrega

This feature replaces FR-01–FR-08 source-string acceptance with executable and structural behavior evidence for the native FFI package and its release factory. It proves ABI preservation, loader fallback and failure behavior, fail-closed artifact utilities, Android TLS retry semantics, expanded-package consumption, and workflow authorization facts without changing the public runtime contracts.

All 34 planned actions are complete.

## Impacto por artefato da extração

| Artefato | Seção | Tipo de impacto | Delta |
|---|---|---|---|
| `.reversa/_reversa_sdd/domain.md` | [Android TLS rules](../domain.md#android-tls-rules) | regra-alterada | Android TLS is now observed through injected operations; success is cached only after writing, and pre-write failures remain retryable. |
| `.reversa/_reversa_sdd/domain.md` | [Loader and lifecycle rules](../domain.md#loader-and-lifecycle-rules) | regra-alterada | The unchanged desktop fallback and terminal error contract now has an internal loader-plan seam for isolated process proof. |
| `.reversa/_reversa_sdd/domain.md` | [Build, test, and publication rules](../domain.md#build-test-and-publication-rules) | regra-alterada | Native-cache manifests now reject unsafe recorded paths and return sanitized validation failures. |
| `.reversa/_reversa_sdd/domain.md` | [Build, test, and publication rules](../domain.md#build-test-and-publication-rules) | regra-alterada | Platform release proof now rejects unsafe nested paths, distinguishes version mismatch, and sanitizes aggregate proof paths. |
| `.reversa/_reversa_sdd/architecture.md` | [Architectural invariants](../architecture.md#architectural-invariants) | componente-novo | The analyzer AST fact tool establishes exact-pinned, fail-closed lifecycle ownership evidence. |
| `.reversa/_reversa_sdd/architecture.md` | [Architectural invariants](../architecture.md#architectural-invariants) | componente-novo | The workflow fact tool parses dependencies, triggers, conditions, and cache inputs fail-closed. |
| `.reversa/_reversa_sdd/architecture.md` | [Architectural purpose](../architecture.md#architectural-purpose) | componente-novo | The bundle tool assembles injected same-run bindings and native payload into a disposable package for a clean consumer proof. |
| `.reversa/_reversa_sdd/domain.md` | [Build, test, and publication rules](../domain.md#build-test-and-publication-rules) | regra-nova | Publication eligibility now requires same-run bundle assembly and public/native consumer proof before dry-run and publication. |
| `.reversa/_reversa_sdd/domain.md` | [Build, test, and publication rules](../domain.md#build-test-and-publication-rules) | delta-de-contrato-externo | `analyzer` 8.2.0 and `yaml` 3.1.3 are direct exact development dependencies for policy validation. |
| `.reversa/_reversa_sdd/architecture.md` | [Technical debt and risk register](../architecture.md#technical-debt-and-risk-register) | regra-alterada | FR-01–FR-08 acceptance now uses executable, AST, CLI, subprocess, bundle, and parsed-graph evidence rather than source-string matching. |

## Regras sob vigilância

- [W001](../../_reversa_forward/005-behavior-proving-tests/regression-watch.md): ABI size preservation.
- [W002](../../_reversa_forward/005-behavior-proving-tests/regression-watch.md): Loader fallback and terminal failure behavior.
- [W003](../../_reversa_forward/005-behavior-proving-tests/regression-watch.md): Android TLS cache-after-write and retry behavior.
- [W004](../../_reversa_forward/005-behavior-proving-tests/regression-watch.md): Fail-closed cache and platform proof validation.
- [W005](../../_reversa_forward/005-behavior-proving-tests/regression-watch.md): Injected same-run expanded-package consumer evidence.
- [W006](../../_reversa_forward/005-behavior-proving-tests/regression-watch.md): Validation reachability and exact-main publication authorization.

## Fontes

- `.reversa/_reversa_forward/005-behavior-proving-tests/legacy-impact.md`
- `.reversa/_reversa_forward/005-behavior-proving-tests/regression-watch.md`
- `.reversa/_reversa_forward/005-behavior-proving-tests/requirements.md`
- `.reversa/_reversa_forward/005-behavior-proving-tests/progress.jsonl`
