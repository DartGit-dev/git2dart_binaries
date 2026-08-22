# ADR-006: Bundle Version-Agnostic Windows OpenSSL Runtime DLLs

- **Status:** Retrospectively accepted
- **Date:** 2026-06-29
- **Confidence:** 🟢 CONFIRMED

## Context

The Windows libgit2/libssh2 build dynamically depends on OpenSSL runtime DLLs. Their concrete filenames vary by installed OpenSSL version and distribution. Bundling only libgit2/libssh2, or hard-coding an OpenSSL 1.1 filename, leaves consumer applications unable to load the dependency chain.

## Decision

During build, copy every runtime matching `libcrypto*.dll` and `libssl*.dll` into the export. In Flutter CMake, glob those patterns and include the results in bundled libraries. In Dart package fallback, discover, sort, and preload matching DLLs before `libssh2.dll`.

## Alternatives considered

1. Require OpenSSL to be installed globally on every consumer machine.
2. Hard-code one OpenSSL DLL version.
3. Statically link OpenSSL into the Windows libraries.

## Consequences

- Positive: the expanded package carries its Windows crypto runtime.
- Positive: generic patterns tolerate versioned filenames.
- Negative: multiple matching runtime DLLs may be opened if present.
- Negative: dynamic dependency ABI compatibility still depends on the CI-built set remaining coherent.

## Evidence

Commit `1acc02c`; Windows composite action, CMake file, loader, and packaging regression tests.

