# Legacy impact — 002-openssl-source-parity

Date: 2026-08-24. Legacy anchor: `_reversa_sdd/architecture.md` and `domain.md`.

| Affected file | Component | Type | Severity | Rationale |
|---|---|---|---|---|
| `.github/actions/build-windows/action.yml` | Native build/binding generation | regra-alterada | HIGH | Replaces runner OpenSSL discovery with pinned source build and preserves exported DLL names. |
| `.github/actions/build-{linux,macos,android,ios}/action.yml` | Artifact/cache fabric | regra-alterada | HIGH | Emits v2 source provenance beside platform artifacts. |
| `.github/scripts/native_cache_manifest.py` | Artifact/cache fabric | delta-de-contrato-externo | HIGH | Cache/sidecar metadata now fail-closes on provenance identity. |
| `.github/workflows/build_package.yml` | Validation/release assembly | regra-nova | HIGH | Release eligibility requires all platform provenance evidence. |
| `.github/openssl-exceptions/*` | Validation/release assembly | componente-novo | MEDIUM | Checked-in opt-in exception format expires and requires exact parity. |

## Preserved

- Domain rules 12 and 23: Windows retains the loader order and version-agnostic OpenSSL DLL export contract.
- Domain rules 20–21 and 24–25: platform artifact paths and iOS/Android packaging remain intact.

## Modified

- Domain rule 28: OpenSSL joins the pinned source-tag policy on Windows and Linux.
- Domain rule 29: cache validation now includes provenance/source reference.
- Domain rule 31: release qualification includes provenance eligibility before publish.
