# ADR-010: Use Layered Behavior Evidence for Acceptance

- **Status:** Accepted in the feature-005 working tree
- **Date:** 2026-08-25
- **Confidence:** 🟢 local implementation and recorded execution; 🔴 current hosted run

## Context

Source substring assertions previously treated declarations, YAML fragments, or diagnostic strings as proof of ABI behavior, loader routing, artifact rejection, package consumption, and publication policy. Those checks were formatting-sensitive and could remain green without executing the relevant native boundary, CLI, subprocess, or workflow model. Conversely, native prerequisites are not always present in a source checkout, so evidence must state when execution is unavailable instead of silently overstating success.

## Decision

Classify every W001–W006 acceptance claim by evidence tier:

1. source/configuration for presence and recipe facts only;
2. exact-pinned analyzer AST or fail-closed YAML graph facts for structural policies;
3. injected deterministic state machines for host-independent transitions;
4. bounded CLI/subprocess/native fixtures for exact host and payload behavior;
5. current-run hosted artifacts/platform jobs for same-run and platform authority;
6. external registry/consumer observation for publication and cross-repository outcomes.

Retire feature-005 source-string acceptance and keep an explicit replacement ledger. Treat `unavailable` as a gap, not a behavior pass. Pin analyzer 8.2.0 and YAML 3.1.3 as direct development dependencies; missing/incompatible parser prerequisites fail closed.

## Alternatives considered

1. Keep substring assertions as a fast acceptance fallback.
2. Require all tests to run natively on every developer host.
3. Treat a green test containing an `unavailable` branch as equivalent to executed behavior.
4. Use only hosted CI and remove deterministic local fixtures.
5. Let parser dependencies resolve transitively and skip on incompatibility.

## Consequences

- Positive: claims become traceable to the observation that can actually support them.
- Positive: corruption, unsafe paths, retry edges, and terminal failures are executable and fail closed.
- Positive: local deterministic feedback remains available without pretending to be five-platform hosted evidence.
- Positive: formatting/comment changes no longer define lifecycle or workflow acceptance.
- Negative: the suite is more complex and has multiple authority levels that reports must preserve.
- Negative: parser models are still approximations; the AST visitor is name-based and the workflow evaluator supports only a bounded condition subset.
- Negative: some native tests can return successfully after declaring `unavailable`; aggregation must inspect evidence records, not only suite exit status.
- Negative: source-only checkout cannot establish current generated/native/package/publication outcomes.

## Evidence

Feature `005-behavior-proving-tests` requirements, replacement inventory, W001–W006 regression watches, 22 focused behavior tests, parser/CLI tools, and `.reversa/_reversa_sdd/code-analysis.md`. The Archaeologist recorded 39/39 safe current local cases and cached-1.12.1 Windows fixture behavior; no current feature-005 hosted run was inspected.

