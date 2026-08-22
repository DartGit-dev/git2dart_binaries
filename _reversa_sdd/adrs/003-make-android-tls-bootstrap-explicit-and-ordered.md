# ADR-003: Make Android TLS Bootstrap Explicit and Ordered

- **Status:** Retrospectively accepted
- **Date:** 2025-11-19 to 2025-11-20
- **Confidence:** 🟢 CONFIRMED for local helper and history; 🔴 consumer call site

## Context

Android does not expose its certificate store through the filesystem paths expected by this libgit2/OpenSSL build. Early attempts to configure certificates automatically during import ran before Flutter bindings were ready and caused crashes or overwritten configuration.

## Decision

Bundle a Mozilla CA file as a Flutter asset. Expose `AndroidSSLHelper.initialize()` so consumer code explicitly extracts it after libgit2 initialization and then applies the returned path through libgit2 options. Cache successful extraction; rethrow failures.

## Alternatives considered

1. Perform asynchronous certificate setup eagerly during package import.
2. Depend on system certificate paths.
3. Embed the CA bytes directly into handwritten Dart source.
4. Disable HTTPS or require consumers to supply their own bundle exclusively.

## Consequences

- Positive: ordering is documented and controlled by application startup.
- Positive: failed extraction remains retryable.
- Negative: the consumer must perform a non-obvious two-step initialization.
- Negative: extraction success is distinct from applying the path; misuse can leave HTTPS broken.
- Negative: concurrent first calls are not serialized.

## Evidence

`lib/src/android_ssl_helper.dart`; `pubspec.yaml`; commit `40c398d`; removal of eager configuration in `b7f474f`.

