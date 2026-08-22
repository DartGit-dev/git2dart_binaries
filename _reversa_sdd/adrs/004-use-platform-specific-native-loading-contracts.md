# ADR-004: Use Platform-Specific Native Loading Contracts

- **Status:** Retrospectively accepted
- **Date:** 2025-11 to 2026-05
- **Confidence:** 🟢 CONFIRMED

## Context

Flutter's native packaging differs materially across Android, Apple platforms, Linux, and Windows. A universal `DynamicLibrary.open(packagePath)` strategy does not work for statically linked iOS frameworks or compiled Flutter apps without package config.

## Decision

- iOS: resolve libgit2 through `DynamicLibrary.process()` and force-load the static archive.
- Android: open `libgit2.so` through the platform loader.
- Desktop: open the platform filename, then use a package-local fallback.
- Preload dependent libraries only on platforms where the chosen packaging requires it.

## Alternatives considered

1. Use a Flutter method channel instead of Dart FFI.
2. Require a single uniform shared-library layout on all platforms.
3. Statically link all platforms into the application process.

## Consequences

- Positive: packaging follows native platform conventions.
- Positive: the high-volume Git API avoids method-channel serialization.
- Negative: loader behavior and artifact names are a cross-file contract.
- Negative: platform-specific tests are mandatory to detect packaging drift.

## Evidence

`lib/src/util.dart`; `pubspec.yaml`; platform CMake/podspec files; iOS `OTHER_LDFLAGS`; commits `40c398d`, `99f4f49`.

