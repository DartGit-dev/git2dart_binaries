# Dependency Inventory

## Dart and Flutter dependencies

Source: `pubspec.yaml` and resolved `pubspec.lock`.

| Dependency | Declared constraint | Resolved version | Role |
|---|---|---:|---|
| Dart SDK | `>=3.7.2 <4.0.0` | environment constraint | FFI/package runtime |
| Flutter SDK | `>=3.29.3` | environment constraint | Multi-platform FFI plugin integration |
| `ffi` | `^2.0.0` | 2.1.4 | Native memory, pointers, UTF-8 conversion |
| `meta` | `^1.16.0` | 1.17.0 | Dart annotations/utilities |
| `path` | `^1.8.1` | 1.9.1 | Platform-safe package/artifact paths |
| `path_provider` | `^2.1.0` | 2.1.5 | Android temporary directory for CA extraction |
| `pub_semver` | `^2.1.3` | 2.2.0 | Semantic-version values |

Development dependencies include ffigen 18.1.0, test 1.26.3, Flutter test/integration_test SDK packages, lints 5.1.1, and the generated transitive dependency graph in `pubspec.lock`.

## Native dependency set

| Component | CI version | Use |
|---|---:|---|
| libgit2 | 1.9.6 | Git implementation and exported C ABI |
| libssh2 | 1.11.1 | SSH transport used by libgit2 |
| OpenSSL | 3.0.15 | TLS/crypto backend |
| zlib / iconv | platform-provided on iOS | Apple link dependencies declared by the podspec |

Builds enable libgit2 experimental SHA-256 support. The generated Dart bindings are derived from the matching libgit2 tag and `ffigen.yaml`.

## Build and package toolchain

- Flutter CI: 3.44.0.
- Android Gradle plugin: 7.3.0; compile SDK 34; minimum SDK 21; Java 8 compatibility.
- CMake minimums: Android/Linux 3.10, Windows 3.14.
- Apple package integration: CocoaPods podspecs; Swift 5.0; iOS 12.0; macOS 10.11.
- GitHub Actions performs source checkout, native compilation, cache-manifest validation, artifact upload/download, ffigen generation, platform testing, package-size validation, dry-run publication, and pub.dev publication.

## Packaging relationships

1. `generate-bindings` checks out the pinned libgit2 headers and emits `lib/src/bindings.dart`.
2. Platform actions build native libraries into named CI artifacts.
3. Platform test jobs inject both generated bindings and native artifacts into the checkout before running tests.
4. The publish job downloads every platform artifact into its package path, validates the expanded payload is at most 256 MiB, and performs `dart pub publish --dry-run`.
5. Pull requests retain a `release-package` artifact; non-PR runs invoke the Dart package publisher action.

## Confidence notes

- **CONFIRMED:** versions and packaging edges above are directly declared in local manifests and workflows.
- **INFERRED:** `F:\git2dart` consumes this published package; this repository describes the git2dart relationship but does not contain the consumer manifest or import sites.
- **GAP:** the native artifacts and generated bindings are absent from the tracked checkout and were not rebuilt during this read-only source investigation.

