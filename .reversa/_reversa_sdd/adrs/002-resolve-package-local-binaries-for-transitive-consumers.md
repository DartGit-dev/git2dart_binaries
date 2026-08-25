# ADR-002: Resolve Package-Local Binaries for Transitive Consumers

- **Status:** Retrospectively accepted
- **Date:** 2025-11-20
- **Confidence:** 🟢 CONFIRMED

## Context

Loading binaries relative to the process working directory or direct application package fails when `git2dart_binaries` is a transitive dependency. Commit history explicitly records this compatibility defect.

## Decision

On desktop platforms, first try the bare library name. If that fails, resolve the package root using a synchronous package URI or package-config sources, preload platform dependencies, and open the artifact from its package platform directory.

## Alternatives considered

1. Require consumers to add native directories to `PATH`, `LD_LIBRARY_PATH`, or equivalent.
2. Resolve relative to current working directory.
3. Require the higher-level `git2dart` package to pass an explicit native path.

## Consequences

- Positive: plain-Dart and transitive consumers can locate package-bundled binaries.
- Positive: application loader behavior remains the fast/primary path.
- Negative: package-config resolution adds multiple fallback branches and failure modes.
- Negative: compiled Flutter apps may not have a usable package config, so platform packaging must still make the first bare-name open work where required.
- Negative: the current success probe reports the supplied package root but not the actual opened handle path, so fallback origin still needs stronger observation.

## Evidence

`lib/src/runtime.dart`; commits `3ec5df2`, `4e2ab6d`, `ff30d32`; feature-005 isolated loader and disposable-consumer probes. Missing-root failure and Android plan are locally observed; current same-run positive origin remains a gap.
