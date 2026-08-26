# ADR-011: Route Generated and Native Inputs From One Workflow Run

- **Status:** Accepted policy and current workflow design
- **Date:** 2026-08-25
- **Confidence:** 🟢 source/workflow route; 🔴 current-run identity attestation

## Context

The publishable product does not exist in the tracked checkout. CI generates the Dart binding and builds platform payloads, while cache reuse and independently downloaded proof records create opportunities to mix revisions, recipes, or artifact bytes. A local cached package can prove consumer behavior but cannot prove that the current workflow generated the tested/published product.

## Decision

Keep `lib/src/bindings.dart` untracked. Generate it from the pinned official libgit2 headers and download that artifact, native payloads, platform proofs, and provenance sidecars into validation and `publish_package` from the same workflow run. Reject checkout binding fallback and require a disposable consumer package to resolve exactly to the assembled bundle before dry-run/publication eligibility.

Use workflow routing as the current source of same-run provenance. Treat `binding_origin: same-run`, proof `candidate`, `bundle-proof.json`, and artifact names as evidence labels, not cryptographic attestations. Do not upgrade local published-cache fixture behavior to current-run proof.

## Alternatives considered

1. Commit the generated binding and publish directly from the checkout.
2. Reuse any locally cached binding/native package when the filenames match.
3. Let each platform publish independently without one assembled package gate.
4. Accept a caller-supplied `same-run` label as sufficient provenance.
5. Validate proof files without assembling and running a disposable consumer.

## Consequences

- Positive: the release job consumes the generated binding and payload jobs that precede it in one workflow graph.
- Positive: checkout-local stale binding fallback is explicitly rejected.
- Positive: a clean consumer validates public imports, package-root resolution, and Linux native loading before publication eligibility.
- Positive: cached native artifacts retain provenance sidecars after cache restoration.
- Negative: the source checkout is intentionally incomplete and cannot independently represent the publishable package.
- Negative: current proof validation does not compare producer hashes with the separately downloaded release payload.
- Negative: `bundle-proof.json` is checked for existence, not authenticated content or byte identity.
- Negative: the disposable release consumer covers Linux only, and current hosted feature-005 transfer/publication remains unobserved.

## Evidence

User-confirmed addendum `005-ci-owned-generated-bindings.md`; `.github/workflows/build_package.yml`; `tool/package_consumer_bundle.dart`; commits `9af8df2`, `cedc8af`, `8a33ca3`, `b372be1`; feature-005 W005/W006. Historical run `32750817127` validates the predecessor revision only.

