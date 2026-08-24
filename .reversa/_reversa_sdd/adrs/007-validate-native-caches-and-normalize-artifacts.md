# ADR-007: Validate Native Caches and Normalize Artifacts Before Reuse

- **Status:** Accepted in current automation
- **Date inferred:** 2026-07 lineage
- **Confidence:** 🟢 current-file evidence; 🟡 exact merge lineage

## Context

Cross-platform native compilation is expensive, but stale caches can silently mix toolchains, versions, or artifact recipes. A cache hit alone is not proof that an artifact is usable.

## Decision

Key caches by platform, architecture, toolchain fingerprint, dependency versions, and recipe hash. Store a manifest describing the export. Validate restored content; if invalid, clear the cache/build directories and rebuild. Before upload, normalize filenames and verify required symbols.

## Alternatives considered

1. Disable native caching.
2. Key only by dependency version.
3. Trust the cache service's hit result without inspecting contents.

## Consequences

- Positive: repeat builds can be faster without blindly accepting stale binaries.
- Positive: required ABI symbols are checked at artifact creation.
- Negative: cache-manifest tooling is another critical build component.
- Negative: fingerprint changes can reduce cache hit rate.

## Evidence

Current `.github/actions/*/action.yml` and `.github/scripts/native_cache_manifest.py`. Related side-branch commit `8e8b1f0` is not a direct ancestor, so the current design is confirmed from files rather than that commit's lineage.

