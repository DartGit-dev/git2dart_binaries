# ADR-003: Make Android TLS Bootstrap Explicit and Ordered

- **Status:** Retrospectively accepted
- **Date:** 2025-11-19 to 2025-11-20
- **Confidence:** 🟢 CONFIRMED for local helper and history; 🔴 consumer call site

## Context

Android does not expose its certificate store through the filesystem paths expected by this libgit2/OpenSSL build. Early attempts to configure certificates automatically during import ran before Flutter bindings were ready and caused crashes or overwritten configuration.

## Decision

Bundle a Mozilla CA file as a Flutter asset. Expose `AndroidSSLHelper.initialize()` so consumer code explicitly extracts it after libgit2 initialization and then applies the returned path through libgit2 options. Cache successful extraction; rethrow failures.

Feature 005 preserves that public facade and injects directory, asset, and writer operations only through a test-visible dependency bundle. State commits only after the writer completes, making directory/asset/write failure and later retry directly observable.

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
- Negative: deterministic tests do not exercise `rootBundle`, `path_provider`, Android storage, native option application, or HTTPS.

## Evidence

`lib/src/android_ssl_helper.dart`; `pubspec.yaml`; `test/android_ssl_helper_test.dart`; commit `40c398d`; removal of eager configuration in `b7f474f`; feature-005 W003.
