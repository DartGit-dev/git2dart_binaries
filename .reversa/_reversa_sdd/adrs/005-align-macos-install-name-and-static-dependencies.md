# ADR-005: Align macOS Artifact Identity and Link libssh2/OpenSSL Statically

- **Status:** Retrospectively accepted
- **Date:** 2026-05-29 to 2026-06-04
- **Confidence:** 🟢 CONFIRMED

## Context

Real Flutter macOS applications failed in layers: the vendored filename differed from the dylib install name; transitive dylibs were not embedded; and compiled apps could not rely on package-config fallback. Shipping multiple dependent dylibs also increased packaging/signing complexity.

## Decision

Normalize the exported library to `libgit2.dylib`, set its ID to `@rpath/libgit2.dylib`, make the podspec and Dart loader use the same filename, and statically link libssh2 and OpenSSL into that dylib. Reject Homebrew paths or remaining dynamic references during CI.

## Alternatives considered

1. Preserve libgit2's versioned experimental install name everywhere.
2. Vendor libssh2/OpenSSL dylibs separately and declare/sign each one.
3. Rewrite dependency paths after packaging without changing link mode.

## Consequences

- Positive: one self-contained dylib enters the consumer app bundle.
- Positive: runtime identity is consistent across build output, CocoaPods, and Dart.
- Positive: CI checks prevent accidental Homebrew/dependency leakage.
- Negative: native build time and complexity increase due to source-built static dependencies.
- Negative: upstream dependency updates must be retested as a combined binary.

## Evidence

Commits `dd2b068`, `99f4f49`, `fc80f9f`; `.github/actions/build-macos/action.yml`; macOS podspec and packaging tests.

