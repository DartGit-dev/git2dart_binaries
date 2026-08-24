# Code to Specification Matrix

## Scope
This matrix maps all 47 tracked files at commit `680d914c8e2b87682f0b68318aee855838eb58e8` to the seven feature-folder specifications. A mapping means the file has an explained responsibility; it does not prove runtime execution or external-consumer compatibility. 🟢

| Tracked file | Primary specification | Relationship | Confidence |
|---|---|---|---|
| `.actrc` | `validation-release-assembly` | Local workflow-runner configuration | 🟢 |
| `.github/actions/build-android/action.yml` | `native-build-bindings-generation` | Android native producer | 🟢 |
| `.github/actions/build-ios/action.yml` | `native-build-bindings-generation` | iOS native producer | 🟢 |
| `.github/actions/build-linux/action.yml` | `native-build-bindings-generation` | Linux native producer | 🟢 |
| `.github/actions/build-macos/action.yml` | `native-build-bindings-generation` | macOS native producer | 🟢 |
| `.github/actions/build-windows/action.yml` | `native-build-bindings-generation` | Windows native producer | 🟢 |
| `.github/actions/generate-bindings/action.yml` | `native-build-bindings-generation` | Generated Dart ABI producer | 🟢 |
| `.github/scripts/native_cache_manifest.py` | `native-build-bindings-generation` | Cache integrity manifest | 🟢 |
| `.github/workflows/build_package.yml` | `validation-release-assembly` | Build/test/release DAG | 🟢 |
| `.gitignore` | `validation-release-assembly` | Excludes generated/build payloads from source | 🟡 |
| `.metadata` | `platform-packaging` | Flutter project/plugin metadata | 🟢 |
| `CHANGELOG.md` | `validation-release-assembly` | Release history and compatibility evidence | 🟢 |
| `LICENSE` | `validation-release-assembly` | Published package legal payload | 🟡 |
| `README.md` | `dart-ffi-facade` | Public role and consumer-boundary description | 🟢 |
| `analysis_options.yaml` | `dart-ffi-facade` | Dart static-analysis policy | 🟡 |
| `android/CMakeLists.txt` | `platform-packaging` | Android bundled-library contract | 🟢 |
| `android/build.gradle` | `platform-packaging` | Android plugin build integration | 🟢 |
| `android/src/main/AndroidManifest.xml` | `platform-packaging` | Android plugin manifest | 🟢 |
| `android/src/main/assets/certs/cacert.pem` | `android-tls-bootstrap` | Android-source CA copy | 🟢 |
| `android/src/main/cpp/git2dart_binaries_plugin.cpp` | `platform-packaging` | Android native registration shim | 🟢 |
| `assets/certs/cacert.pem` | `android-tls-bootstrap` | Flutter package CA asset read at runtime | 🟢 |
| `ffigen.yaml` | `native-build-bindings-generation` | ABI generation configuration | 🟢 |
| `integration_test/opts_bindings_integration_test.dart` | `libgit2-global-options` | Device integration-test adapter | 🟢 |
| `ios/Classes/Git2dartBinariesPlugin.swift` | `platform-packaging` | iOS registration/method-channel shim | 🟢 |
| `ios/git2dart_binaries.podspec` | `platform-packaging` | iOS XCFramework and force-load contract | 🟢 |
| `lib/git2dart_binaries.dart` | `dart-ffi-facade` | Public export barrel | 🟢 |
| `lib/src/android_ssl_helper.dart` | `android-tls-bootstrap` | CA extraction state machine | 🟢 |
| `lib/src/error.dart` | `dart-ffi-facade` | Borrowed native-error translation | 🟢 |
| `lib/src/extensions.dart` | `dart-ffi-facade` | String/input validation helpers | 🟢 |
| `lib/src/opts_bindings.dart` | `libgit2-global-options` | Typed variadic option wrappers | 🟢 |
| `lib/src/util.dart` | `native-loader-lifecycle` | Platform loader plus independent lazy option and libgit2 globals | 🟢 |
| `linux/CMakeLists.txt` | `platform-packaging` | Linux bundled-library contract | 🟢 |
| `linux/git2dart_binaries_plugin.cc` | `platform-packaging` | Linux registration/method-channel shim | 🟢 |
| `linux/include/git2dart_binaries/git2dart_binaries_plugin.h` | `platform-packaging` | Linux plugin registration API | 🟢 |
| `macos/Classes/Git2dartBinariesPlugin.swift` | `platform-packaging` | macOS registration/method-channel shim | 🟢 |
| `macos/git2dart_binaries.podspec` | `platform-packaging` | macOS dylib packaging contract | 🟢 |
| `pubspec.yaml` | `platform-packaging` | Package, dependencies, assets, and platform declarations | 🟢 |
| `test/macos_dylib_packaging_test.dart` | `platform-packaging` | macOS dependency/install-name/load validation | 🟢 |
| `test/opts_bindings_integration_test.dart` | `libgit2-global-options` | Native option round-trip tests | 🟢 |
| `test/windows_packaging_test.dart` | `platform-packaging` | Windows inventory/plain-Dart load validation | 🟢 |
| `test_driver/integration_test.dart` | `validation-release-assembly` | Device test driver | 🟢 |
| `windows/.gitignore` | `platform-packaging` | Windows generated-file exclusions | 🟡 |
| `windows/CMakeLists.txt` | `platform-packaging` | Windows DLL bundling contract | 🟢 |
| `windows/git2dart_binaries_plugin.cpp` | `platform-packaging` | Windows plugin implementation | 🟢 |
| `windows/git2dart_binaries_plugin.h` | `platform-packaging` | Windows plugin class contract | 🟢 |
| `windows/git2dart_binaries_plugin_c_api.cpp` | `platform-packaging` | Windows C registration bridge | 🟢 |
| `windows/include/git2dart_binaries/git2dart_binaries_plugin_c_api.h` | `platform-packaging` | Windows exported registration API | 🟢 |

## Specification Coverage Summary
| Feature | Primary tracked files | Canonical SDD files | Coverage status |
|---|---:|---:|---|
| `dart-ffi-facade` | 5 | 3 | 🟢 Mapped |
| `native-loader-lifecycle` | 1 | 3 | 🟢 Mapped |
| `libgit2-global-options` | 3 | 3 | 🟢 Mapped |
| `android-tls-bootstrap` | 3 | 3 | 🟢 Mapped |
| `platform-packaging` | 21 | 3 | 🟢 Mapped |
| `native-build-bindings-generation` | 8 | 3 | 🟢 Mapped |
| `validation-release-assembly` | 6 | 3 | 🟢 Mapped |

All tracked files are mapped: **47/47 (100%)**. The seven feature folders contain **21/21** requested canonical documents. 🟢

## Untracked or Injected Artifacts
| Artifact | Expected feature | Status | Confidence |
|---|---|---|---|
| `lib/src/bindings.dart` | `native-build-bindings-generation` and `dart-ffi-facade` | Generated in CI; absent locally | 🔴 |
| `headers/` | `native-build-bindings-generation` | Temporary generation input; absent locally | 🔴 |
| Platform native binaries/frameworks | build, packaging, release | Injected by CI; absent locally | 🔴 |

## Cross-Repository Boundary
The dependency/import/test links from `F:\git2dart` to this package remain **INFERRED** from local README/package evidence. They are not counted as confirmed code coverage and require direct inspection in that repository's independently scoped Reversa work. 🟡

## Remaining Red Gaps
1. Production owner and balance policy for `git_libgit2_shutdown()`. 🔴
2. Consumer-side Android sequence that applies the extracted CA path. 🔴
3. A compatibility matrix joining `git2dart`, this package, generated bindings, and libgit2. 🔴
4. Evidence from a current complete CI run and its expanded package. 🔴
5. External publication permissions, branch protection, signing, SBOM, and provenance controls. 🔴
