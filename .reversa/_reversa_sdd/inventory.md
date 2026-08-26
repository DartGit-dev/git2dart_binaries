# Repository Inventory — Scout re-extraction (2026-08-25)

## Surface and confidence

Current checkout contains 59 files outside excluded Reversa/build/cache directories. `git2dart_binaries` is a Flutter plugin/package exposing Dart FFI bindings and distributing libgit2 native binaries for Android, iOS, Linux, macOS, and Windows. Generated bindings and native payloads are produced by CI and absent from this source checkout; local evidence cannot prove final hosted artifacts or publication.

## Languages

Dart 34; C/C++ 7; YAML 3; Swift 2; Ruby podspec 2; Python 1; Gradle 1; XML 1. Dart is primary; native packaging and CI are multi-language.

## Modules

1. dart-ffi-facade (`lib/` public exports, bindings, errors, extensions)
2. native-loader-lifecycle (`lib/src/runtime.dart`, `util.dart`)
3. libgit2-global-options (`lib/src/opts_bindings.dart`)
4. android-tls-bootstrap (`lib/src/android_ssl_helper.dart`, certificate assets)
5. platform-packaging (Android/iOS/Linux/macOS/Windows plugin/build files)
6. native-build-bindings-generation (`.github/actions/`, `ffigen.yaml`)
7. validation-release-assembly (`.github/workflows/build_package.yml`, release scripts)
8. behavior-proving-tests (`test/`, 22 test files and fixtures)

## Entry points and CI

Public entry: `lib/git2dart_binaries.dart`; loader/initialization: `lib/src/util.dart`; probes: `test/fixtures/`. CI: `.github/workflows/build_package.yml` plus six platform/bindings composite actions and release-proof scripts. No Docker, server routes, UI application, or database schema found.

## Organization suggestion

`feature` remains the Scout suggestion: no centralized endpoint routing, top-level domain folders, or dominant Gherkin/E2E organization; boundaries are runtime, packaging, build/release, and behavior proof.

## Evidence boundaries

Confirmed: local manifests, source tree, tests, and workflows. Inferred: relationship to sibling high-level `git2dart`. Gaps: generated bindings/native binaries, consumer import sites, hosted same-run workflow provenance, publication outcome, and external token/protection controls.
