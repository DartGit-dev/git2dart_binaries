# Platform Packaging, Implementation Tasks

## Prerequisites
- [ ] Native build outputs exist for every target architecture.
- [ ] Loader filename contracts are frozen.

## Tasks
- [ ] PPK-T-01, Declare Flutter FFI platforms and assets. Origin: `pubspec.yaml:43`, `pubspec.yaml:61`. Done when Flutter tooling recognizes all targets. Confidence: 🟢
- [ ] PPK-T-02, Recreate Android/Linux/Windows CMake bundling. Origin: `android/CMakeLists.txt:1`, `linux/CMakeLists.txt:1`, `windows/CMakeLists.txt:1`. Done when application bundles contain required libraries. Confidence: 🟢
- [ ] PPK-T-03, Recreate iOS force-load XCFramework packaging. Origin: `ios/git2dart_binaries.podspec:18`. Done when process lookup resolves libgit2 symbols. Confidence: 🟢
- [ ] PPK-T-04, Recreate macOS dylib packaging. Origin: `macos/git2dart_binaries.podspec:18`. Done when install name/dependencies pass inspection. Confidence: 🟢
- [ ] PPK-T-05, Preserve native plugin registration shims. Origin: platform `Classes`/plugin sources. Done when Flutter registration succeeds. Confidence: 🟢

## Test Tasks
- [ ] PPK-TT-01, Inspect artifact inventory for every platform/architecture.
- [ ] PPK-TT-02, Run plain-Dart and Flutter loading tests on desktops.
- [ ] PPK-TT-03, Run iOS simulator and Android emulator smoke tests.

## Suggested Order
Freeze names, build artifacts, configure package managers, register plugins, then validate packaged apps. 🟢

## Pending Gaps
🔴 Resolve podspec/pub version divergence and define signing/notarization ownership.
