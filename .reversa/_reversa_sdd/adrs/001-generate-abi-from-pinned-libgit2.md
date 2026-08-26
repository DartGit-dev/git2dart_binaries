# ADR-001: Generate the Dart ABI from the Same Pinned libgit2 Source as Native Builds

- **Status:** Retrospectively accepted
- **Date inferred:** 2025-05 to 2026-07
- **Confidence:** 🟢 CONFIRMED

## Context

The package exports generated Dart declarations whose layouts, enums, and function signatures must agree with the native library. Historical commits repeatedly corrected ffigen inputs, header coverage, and variadic signatures. A mismatched pair can compile as Dart yet fail at symbol lookup or call time.

## Decision

Use one workflow-level `LIBGIT2_VERSION` for header checkout, ffigen generation, and every platform's native build. Enable experimental SHA-256 in both generation and compilation. Treat `bindings.dart` as a CI-owned, untracked artifact transferred from the generating job into same-run tests and release assembly. A tracked, checkout-local, stale, or ambient cached copy is not an authoritative fallback.

## Alternatives considered

1. Commit a generated binding permanently and update it manually.
2. Generate bindings from system-installed headers.
3. Let each platform choose an independent libgit2 version.

## Consequences

- Positive: the generated ABI and built library share a source tag.
- Positive: the repository avoids a large generated file in the tracked source snapshot.
- Negative: the source checkout is not independently runnable without the generated artifact.
- Negative: CI is a required part of package construction, not merely validation.
- Negative: local source-only validation cannot compile the complete public ABI without an explicitly declared external fixture.

## Evidence

`ffigen.yaml`; `.github/actions/generate-bindings/action.yml`; `.github/workflows/build_package.yml`; addendum `005-ci-owned-generated-bindings.md`; commits `bb32c30`, `fd3463f`, `9f8d21f`, `513d0b6`, `b372be1`.
