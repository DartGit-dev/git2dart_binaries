# ADR-007: Validate Native Caches and Normalize Artifacts Before Reuse

- **Status:** Accepted in current automation
- **Date inferred:** 2026-07 lineage
- **Confidence:** 🟢 current-file evidence; 🟡 exact merge lineage

## Context

Cross-platform native compilation is expensive, but stale caches can silently mix toolchains, versions, or artifact recipes. A cache hit alone is not proof that an artifact is usable.

## Decision

Key caches by platform, architecture, toolchain fingerprint, dependency versions, and recipe hash. Store a manifest describing the export. Validate restored content; if invalid, clear the cache/build directories and rebuild. Before upload, normalize filenames and verify required symbols.

Feature 005 makes the manifest CLI itself part of the contract: unsafe paths, contradictory provenance, malformed/unreadable input, metadata drift, file-set drift, and hash/size drift must return non-success with bounded diagnostics.

## Alternatives considered

1. Disable native caching.
2. Key only by dependency version.
3. Trust the cache service's hit result without inspecting contents.

## Consequences

- Positive: repeat builds can be faster without blindly accepting stale binaries.
- Positive: required ABI symbols are checked at artifact creation.
- Negative: cache-manifest tooling is another critical build component.
- Negative: fingerprint changes can reduce cache hit rate.
- Negative: symlink containment, approved-exception execution, and one create-side empty-export error route remain incomplete evidence.

## Evidence

Current `.github/actions/*/action.yml`, `.github/scripts/native_cache_manifest.py`, `test/native_cache_manifest_cli_test.dart`, and commits `d74f0f3`, `9cdf794`, `cedc8af`, `8a33ca3`.
