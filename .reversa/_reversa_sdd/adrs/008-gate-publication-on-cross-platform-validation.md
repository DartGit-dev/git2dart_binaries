# ADR-008: Gate Publication on Cross-Platform Validation and Payload Limits

- **Status:** Retrospectively accepted
- **Date:** 2025-11 to 2026-07
- **Confidence:** 🟢 CONFIRMED

## Context

The deliverable is an assembled multi-platform package, not the tracked source tree. Packaging defects may appear only after native artifacts are injected or an app is built for a simulator/emulator. Native binaries can also make the pub payload too large.

## Decision

Build and test all supported platform families before the publish job. Inject generated bindings and native artifacts into each test environment. Assemble every release artifact, enforce an expanded-package ceiling, perform a pub dry-run, and publish only for non-pull-request events. Preserve PR packages as short-lived artifacts for inspection.

## Alternatives considered

1. Publish after static Dart tests only.
2. Test platforms independently after publication.
3. Publish platform artifacts in separate packages.
4. Rely on compressed archive size rather than expanded package size.

## Consequences

- Positive: publication is downstream of platform-specific packaging evidence.
- Positive: PRs can inspect the actual expanded package without accessing publishing secrets.
- Positive: size regressions fail with diagnostics.
- Negative: the release critical path is long and sensitive to simulator/emulator stability.
- Negative: timeout/retry process management becomes part of release correctness.

## Evidence

`.github/workflows/build_package.yml`; commits `40c398d`, `e9664db`, `dc6df78`, `f5410de`, `f85882c`, `513d0b6`.

