# Unresolved Gaps — git2dart_binaries

> Reviewer refresh: 2026-08-25

## Critical

1. **Same-run release identity** — no current hosted feature-005/five-platform run joins generated bindings, native payloads, platform proofs, disposable bundle, expanded package, and publication candidate by verifiable hashes/run identity. 🔴
2. **Release metadata divergence** — `pubspec.yaml` is 1.12.1 while the iOS and macOS podspecs are 1.11.2. The user-confirmed exact-match policy makes the present divergence release-blocking. 🟢 observed defect and policy
3. **Aggregate proof authority** — current aggregate validation does not enforce candidate identity, complete semantic inventory, version/linkage/attestation meaning, or proof hashes against downloaded payload bytes. 🟢 observed defect; 🔴 corrected hosted proof
4. **Android TLS product path** — injected extraction/cache/retry behavior is locally green, but shared first-call serialization, default Flutter/device I/O, native option application, recovery, and HTTPS are unobserved. 🟢 local tier; 🔴 device/external tier
5. **External compatibility and publication** — no current `git2dart` selected-pair coordinator run, balanced external lifecycle observation, exact-main publisher execution, or pub.dev registry acceptance was inspected. 🔴

## Moderate

1. **Generated/native bytes absent** — `lib/src/bindings.dart` and current native payloads are intentionally absent from the checkout. W001/W002/runtime compilation is therefore unavailable without a declared matching artifact. 🔴
2. **Loaded-handle origin** — W002 records requested name/root and bounded failure stages but not the actual path that supplied a successful handle. 🔴
3. **Global-options completion** — source declares 33 methods/14 shapes, but same-run generated discriminators and complete native success/error/ownership/restoration coverage remain unobserved. 🔴
4. **Native cache defects** — create-side `ValueError` handling can raise secondary `NameError`; iOS adds provenance after manifest creation; the Windows restore prefix omits recipe identity from semantic validation. 🟢 observed defects
5. **Hosted control boundary** — GitHub protections, approvals, token scopes, action trust, and publication controls are not repository-visible. Existing controls are user-confirmed and no new control decision is requested. 🟢 policy; 🔴 repository-visible proof

## Cosmetic

1. **Duplicate CA copies** — package and Android-source CA copies have no explicit digest-equality gate. 🟢 observation
2. **Historical matrix section** — `code-spec-matrix.md` retains the older 47-file/7-unit snapshot before the explicitly superseding 59-file/8-unit section. The supersession text is clear, but consumers must use the dated current section. 🟢

## User-input status

None of these gaps requires another stakeholder preference to keep the specification internally coherent. They close through implementation, current artifacts/runs, device evidence, registry evidence, or an independently scoped external-repository inspection.
