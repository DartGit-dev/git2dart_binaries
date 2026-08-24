# Repository Inventory

## Scope and evidence policy

This inventory covers only `F:\git2dart_binaries` at Git commit `680d914c8e2b87682f0b68318aee855838eb58e8` (branch `1.12.1`). The neighboring `F:\git2dart` repository was not read and none of its Reversa state was reused.

- **CONFIRMED** means the statement is directly supported by files in this repository.
- **INFERRED** means the statement connects local evidence into a likely product-level relationship and requires confirmation in the Dart repository.
- **GAP** means the expected generated or packaged artifact is not present in the current tracked checkout.

## Role in the product

- **CONFIRMED:** `git2dart_binaries` is a Flutter FFI plugin and Dart package that exposes generated libgit2 bindings and bundles native libgit2 artifacts for Android, iOS, Linux, macOS, and Windows (`pubspec.yaml`, `ffigen.yaml`).
- **CONFIRMED:** the public Dart library exports generated bindings, loader utilities, global-option wrappers, error helpers, validation/conversion extensions, and Android CA-certificate extraction (`lib/git2dart_binaries.dart`).
- **CONFIRMED:** the repository builds and publishes the native payload rather than implementing high-level Git domain operations. Its handwritten Dart code is predominantly loading, initialization, low-level option access, and packaging support.
- **INFERRED:** this repository is the native-binaries/FFI half of the wider git2dart product, while `F:\git2dart` is the high-level Dart API half. Local evidence is the package description and README saying that the `git2dart` package uses libgit2, plus the shared DartGit-dev organization; the actual dependency edge must be confirmed in `F:\git2dart`.

## Tracked surface

The Git index contains 47 files. Generated Reversa files, ignored build output, `.dart_tool`, and the untracked example build tree are excluded.

| Area | Tracked files | Purpose |
|---|---:|---|
| `.github` | 8 | Native builds, bindings generation, platform tests, package assembly and publication |
| `lib` | 6 | Public exports, dynamic-library loading, option wrappers, helpers |
| `windows` | 6 | Flutter plugin shim and CMake bundling declarations |
| `android` | 5 | Flutter/Gradle/CMake integration and CA bundle |
| `test` | 3 | Native option and packaging regression tests |
| `linux` | 3 | Flutter plugin shim and CMake bundling declaration |
| `ios` | 2 | Swift plugin shim and CocoaPods packaging |
| `macos` | 2 | Swift plugin shim and CocoaPods packaging |
| `assets` | 1 | Cross-platform CA certificate bundle |
| `integration_test` / `test_driver` | 2 | Device integration-test entry points |

### Language counts

Counts are based on tracked filename extensions, not generated or ignored files.

| Language / format | Files |
|---|---:|
| Dart (`.dart`) | 11 |
| YAML (`.yml`, `.yaml`) | 10 |
| C/C++ (`.cpp`, `.cc`, `.h`) | 7 |
| Swift (`.swift`) | 2 |
| Ruby DSL (`.podspec`) | 2 |
| Python (`.py`) | 1 |
| Gradle/Groovy (`.gradle`) | 1 |
| XML (`.xml`) | 1 |
| Certificates (`.pem`) | 2 |

Primary application language: **Dart**. Native packaging and CI are materially multi-language.

## Functional modules

1. **Dart FFI facade** — `lib/git2dart_binaries.dart`, generated `lib/src/bindings.dart` export (not tracked in this checkout), error and extension helpers.
2. **Native loader and lifecycle** — `lib/src/util.dart` selects a platform filename, opens libgit2, loads dependencies where necessary, resolves the package root, and calls `git_libgit2_init()`.
3. **Global libgit2 options** — `lib/src/opts_bindings.dart` wraps `git_libgit2_opts` variants with typed Dart methods.
4. **Android TLS bootstrap** — `lib/src/android_ssl_helper.dart` extracts the packaged CA bundle after libgit2 initialization.
5. **Platform packaging** — Android Gradle/CMake, Apple podspecs, Linux CMake, and Windows CMake/plugin shims.
6. **Native build and binding generation** — reusable GitHub composite actions for libgit2, libssh2, OpenSSL, and ffigen.
7. **Validation and release assembly** — `.github/workflows/build_package.yml` builds, tests, assembles a publish payload, enforces a 256 MiB expanded-size limit, dry-runs pub publication, and publishes on non-PR runs.

## Native libraries and artifacts

| Platform | Declared artifact(s) | Packaging/build boundary | Evidence |
|---|---|---|---|
| Android | `libgit2.so`; CI also produces `libssl.so`, `libcrypto.so`, `libssh2.so` per ABI | `jniLibs/<ABI>` populated from CI artifacts; Flutter CMake exposes `libgit2.so` | `android/CMakeLists.txt`, `.github/actions/build-android/action.yml`, workflow |
| iOS | `libgit2.xcframework`, `libssh2.xcframework`, `libssl.xcframework`, `libcrypto.xcframework` | CocoaPods vendored frameworks; libgit2 is force-loaded for device and simulator | `ios/git2dart_binaries.podspec`, workflow assembly |
| macOS | `libgit2.dylib` | CocoaPods vendored dylib; CI description says libssh2/OpenSSL are linked statically | `macos/git2dart_binaries.podspec`, build action, loader comments |
| Linux | `libgit2.so` | Flutter CMake returns the shared library as a bundled library | `linux/CMakeLists.txt` |
| Windows | `libgit2.dll`, `libssh2.dll`, versioned `libcrypto*.dll`, `libssl*.dll` | Flutter CMake globs OpenSSL runtimes and bundles all libraries | `windows/CMakeLists.txt`, build action, packaging tests |

Native source versions pinned by CI are libgit2 **1.9.6**, libssh2 **1.11.1**, and OpenSSL **3.0.15**. Flutter CI is pinned to **3.44.0**.

**GAP:** no generated `lib/src/bindings.dart`, libgit2 headers, or platform native binaries are tracked in the current checkout. The workflow generates/downloads them before tests and package publication. Therefore the checked-out source alone is not the expanded pub package.

## Runtime loading boundary

- iOS uses `DynamicLibrary.process()`, expecting statically linked symbols in the process.
- Android opens `libgit2.so` through the platform loader.
- Windows, Linux, and macOS first try the platform filename on the system/app search path, then resolve the package root and open the platform-local artifact.
- Windows preloads matching OpenSSL DLLs and `libssh2.dll`; Linux attempts to preload `libssh2.so`; macOS expects libssh2 and OpenSSL to be statically incorporated into `libgit2.dylib`.
- Android consumers must extract the bundled CA certificate after libgit2 initialization and then configure libgit2 with that path.

## Entry points and configuration

- Public package entry: `lib/git2dart_binaries.dart`.
- Lazy native loading/initialization paths: top-level values in `lib/src/util.dart`; reading `libgit2Opts` does not itself read the initializing `libgit2` global. 🟢
- Binding generator: `ffigen.yaml`, with libgit2 headers and experimental SHA-256 enabled.
- Flutter plugin registration: `pubspec.yaml` plus platform plugin shims.
- CI/CD: `.github/workflows/build_package.yml` and six supporting action/script files.
- Package configuration: `pubspec.yaml`, `pubspec.lock`, `.metadata`, `analysis_options.yaml`.
- No database schema, migrations, server routes, Docker files, or application UI were found.

## Tests

The repository uses `flutter_test`, `test`, and Flutter `integration_test`.

- 3 tracked primary test files plus 2 integration driver/entry files.
- 15 explicit `test(...)` cases were found: libgit2 option behavior, Windows packaging/loading, and macOS dylib packaging/loading.
- The CI workflow runs Flutter tests on Linux, macOS, Windows, an iOS simulator, and an Android emulator after injecting generated bindings and native artifacts.
- No coverage percentage or coverage report is configured; file counts are not a coverage measurement.

## Cross-repository boundary requiring validation

The following are product-level inferences, not independently confirmed consumer calls:

1. `git2dart` likely depends on the published `git2dart_binaries` package and imports its generated C API and loader.
2. High-level repository, commit, tree, remote, credential, and similar Git abstractions likely live in `git2dart`, because they are absent here.
3. Initialization order and Android certificate setup may be coordinated by the Dart repository, but no call site exists in this checkout.
4. Compatibility must be validated across the `git2dart_binaries` package version, generated bindings from libgit2 1.9.6, and the dependency constraint used by `git2dart`.
