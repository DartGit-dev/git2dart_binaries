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
| `.github/actions/generate-bindings/action.yml` | `native-build-bindings-generation` | CI-only authoritative Dart ABI producer; uploads the same-run artifact | 🟢 user-confirmed policy |
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
| `lib/src/bindings.dart` | `native-build-bindings-generation`, `dart-ffi-facade`, and `validation-release-assembly` | CI-generated artifact only; must never be tracked or committed; same-run artifact is injected into validation and the expanded package | 🟢 user-confirmed policy; 🔴 implementation-state verification pending |
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

---

## 2026-08-25 Full Re-extraction Matrix

This section supersedes the historical 47-file/7-unit count above for the current Writer refresh. The current primary scope contains **59 files**, **8 feature units**, **24 canonical files**, **40 unit-level optional files**, and this global matrix: **65 Writer files total**. 🟢 scope from `surface.json`, approved Writer plan, and current extraction artifacts

A mapping means the file has an operational specification owner; it does not promote source/configuration evidence to runtime, hosted, external-consumer, or publication proof. 🟢

| # | Scoped file | Primary unit | Coverage | Confidence |
|---:|---|---|---|---|
| 1 | `lib/git2dart_binaries.dart` | `dart-ffi-facade` | Public export barrel. | 🟢 |
| 2 | `lib/src/android_ssl_helper.dart` | `android-tls-bootstrap` | CA extraction/cache/retry state. | 🟢 |
| 3 | `lib/src/error.dart` | `dart-ffi-facade` | Lifecycle diagnostics and borrowed last error. | 🟢 |
| 4 | `lib/src/extensions.dart` | `dart-ffi-facade` | Pointer conversion and validators. | 🟢 |
| 5 | `lib/src/opts_bindings.dart` | `libgit2-global-options` | 33 methods/14 variadic shapes. | 🟢 |
| 6 | `lib/src/runtime.dart` | `native-loader-lifecycle` | Loader, checked lifecycle, pins, shutdown. | 🟢 |
| 7 | `lib/src/util.dart` | `native-loader-lifecycle` | Compatibility export path. | 🟢 |
| 8 | `pubspec.yaml` | `platform-packaging` | Package/platform/assets/version contract. | 🟢 |
| 9 | `pubspec.lock` | `native-build-bindings-generation` | Generator/analyzer dependency resolution. | 🟢 |
| 10 | `ffigen.yaml` | `native-build-bindings-generation` | CI-owned ABI generation configuration. | 🟢 |
| 11 | `analysis_options.yaml` | `behavior-proving-tests` | Static-analysis policy input. | 🟢 |
| 12 | `README.md` | `dart-ffi-facade` | Public role and usage claims; not runtime proof. | 🟡 |
| 13 | `assets/certs/cacert.pem` | `android-tls-bootstrap` | Flutter package CA asset. | 🟢 |
| 14 | `android/src/main/assets/certs/cacert.pem` | `android-tls-bootstrap` | Android-source CA copy. | 🟢 |
| 15 | `android/build.gradle` | `platform-packaging` | Android namespace/SDK/NDK integration. | 🟢 |
| 16 | `android/CMakeLists.txt` | `platform-packaging` | Android FFI/plugin native integration. | 🟢 |
| 17 | `android/src/main/AndroidManifest.xml` | `platform-packaging` | Android plugin manifest. | 🟢 |
| 18 | `android/src/main/cpp/git2dart_binaries_plugin.cpp` | `platform-packaging` | Android native registration shim. | 🟢 |
| 19 | `ios/git2dart_binaries.podspec` | `platform-packaging` | XCFramework/force-load/version contract. | 🟢 |
| 20 | `ios/Classes/Git2dartBinariesPlugin.swift` | `platform-packaging` | iOS registration shim. | 🟢 |
| 21 | `linux/CMakeLists.txt` | `platform-packaging` | Linux payload bundling. | 🟢 |
| 22 | `linux/git2dart_binaries_plugin.cc` | `platform-packaging` | Linux plugin implementation. | 🟢 |
| 23 | `linux/include/git2dart_binaries/git2dart_binaries_plugin.h` | `platform-packaging` | Linux registration API. | 🟢 |
| 24 | `macos/git2dart_binaries.podspec` | `platform-packaging` | macOS dylib/version contract. | 🟢 |
| 25 | `macos/Classes/Git2dartBinariesPlugin.swift` | `platform-packaging` | macOS registration shim. | 🟢 |
| 26 | `windows/CMakeLists.txt` | `platform-packaging` | Windows DLL inventory/bundling. | 🟢 |
| 27 | `windows/git2dart_binaries_plugin.cpp` | `platform-packaging` | Windows plugin implementation. | 🟢 |
| 28 | `windows/git2dart_binaries_plugin.h` | `platform-packaging` | Windows plugin class contract. | 🟢 |
| 29 | `windows/git2dart_binaries_plugin_c_api.cpp` | `platform-packaging` | Windows C registration bridge. | 🟢 |
| 30 | `windows/include/git2dart_binaries/git2dart_binaries_plugin_c_api.h` | `platform-packaging` | Exported Windows registration API. | 🟢 |
| 31 | `.github/workflows/build_package.yml` | `validation-release-assembly` | 14-job DAG, gates, event routing. | 🟢 configuration; 🔴 execution |
| 32 | `.github/actions/generate-bindings/action.yml` | `native-build-bindings-generation` | Same-run binding producer. | 🟢 recipe; 🔴 artifact |
| 33 | `.github/actions/build-android/action.yml` | `native-build-bindings-generation` | Android native producer. | 🟢 recipe; 🔴 current payload |
| 34 | `.github/actions/build-ios/action.yml` | `native-build-bindings-generation` | iOS producer and manifest divergence site. | 🟢 |
| 35 | `.github/actions/build-linux/action.yml` | `native-build-bindings-generation` | Linux native producer. | 🟢 recipe; 🔴 current payload |
| 36 | `.github/actions/build-macos/action.yml` | `native-build-bindings-generation` | macOS native producer. | 🟢 recipe; 🔴 current payload |
| 37 | `.github/actions/build-windows/action.yml` | `native-build-bindings-generation` | Windows producer/cache-prefix risk. | 🟢 |
| 38 | `.github/scripts/native_cache_manifest.py` | `native-build-bindings-generation` | W004 cache manifest CLI. | 🟢 local; 🔴 current producer bytes |
| 39 | `.github/scripts/platform_release_proof.py` | `validation-release-assembly` | W004 proof producer/aggregate validator. | 🟢 local; 🔴 identity join |
| 40 | `.github/openssl-exceptions/README.md` | `validation-release-assembly` | Approved-exception operating policy. | 🟢 declaration; 🔴 current records |
| 41 | `.github/openssl-exceptions/exception.schema.json` | `validation-release-assembly` | Exact-parity exception schema. | 🟢 |
| 42 | `test/support/behavior_proof_fixture.dart` | `behavior-proving-tests` | Guarded roots/processes/sanitization. | 🟢 |
| 43 | `test/fixtures/abi_probe/abi_probe.dart` | `behavior-proving-tests` | W001 exact size probe. | 🟢 mechanism; 🔴 current matrix |
| 44 | `test/fixtures/loader_probe.dart` | `behavior-proving-tests` | W002 loader process record. | 🟢 local; 🔴 handle origin |
| 45 | `test/opts_bindings_integration_test.dart` | `libgit2-global-options` | Native option/availability evidence. | 🟢 bounded |
| 46 | `test/runtime_loader_process_test.dart` | `native-loader-lifecycle` | Fresh-process W002 evidence. | 🟢 local |
| 47 | `test/libgit2_runtime_test.dart` | `native-loader-lifecycle` | Injected lifecycle/pin state machine. | 🟢 |
| 48 | `test/libgit2_lifecycle_integration_test.dart` | `native-loader-lifecycle` | Declared native lifecycle integration. | 🟢 mechanism; 🔴 current matrix |
| 49 | `test/android_ssl_helper_test.dart` | `android-tls-bootstrap` | W003 deterministic transitions. | 🟢 |
| 50 | `test/native_cache_manifest_cli_test.dart` | `behavior-proving-tests` | W004 cache CLI matrix. | 🟢 local |
| 51 | `test/platform_release_proof_test.dart` | `behavior-proving-tests` | W004 proof behavior and weak aggregate cases. | 🟢 local |
| 52 | `test/package_consumer_bundle_test.dart` | `behavior-proving-tests` | W005 disposable consumer. | 🟢 local; 🔴 same-run identity |
| 53 | `test/architecture_policy_ast_test.dart` | `behavior-proving-tests` | W006 AST facts. | 🟢 local structural |
| 54 | `test/workflow_policy_graph_test.dart` | `behavior-proving-tests` | W006 DAG/condition facts. | 🟢 local structural |
| 55 | `test/workflow_trigger_policy_test.dart` | `behavior-proving-tests` | Branch/PR/main reachability. | 🟢 local structural |
| 56 | `test/release_inventory_workflow_facts_test.dart` | `behavior-proving-tests` | Release inventory gate facts. | 🟢 local structural |
| 57 | `tool/architecture_policy_facts.dart` | `behavior-proving-tests` | Analyzer 8.2.0 AST fact collector. | 🟢 local model |
| 58 | `tool/workflow_policy_facts.dart` | `behavior-proving-tests` | Fail-closed workflow fact model. | 🟢 local model |
| 59 | `tool/package_consumer_bundle.dart` | `behavior-proving-tests` | W005 bundle assembly/consumer CLI. | 🟢 local mechanism |

Secondary tests listed in `behavior-proving-tests/tests.md` refine these owners but do not change the approved 59-file primary scope. 🟢

## Current Coverage Summary

| Unit | Canonical | Optional | Principal watches | Primary mapping status |
|---|---:|---:|---|---|
| `dart-ffi-facade` | 3 | 5 | W006 indirect | 🟢 mapped |
| `native-loader-lifecycle` | 3 | 5 | W002, W006 | 🟢 mapped |
| `libgit2-global-options` | 3 | 5 | W001 | 🟢 mapped |
| `android-tls-bootstrap` | 3 | 5 | W003 | 🟢 mapped |
| `platform-packaging` | 3 | 5 | W002, W005 | 🟢 mapped |
| `native-build-bindings-generation` | 3 | 5 | W004, W005 | 🟢 mapped |
| `validation-release-assembly` | 3 | 5 | W004-W006 | 🟢 mapped |
| `behavior-proving-tests` | 3 | 5 | W001-W006 | 🟢 mapped |

Primary scope coverage is **59/59 (100%)**. Writer artifact coverage is **65/65 (100%)**: 24 canonical, 40 unit optional, and 1 global matrix. 🟢 structural count

`openapi/` is not applicable because no HTTP/RPC API exists; `user-stories/` is not applicable because the product is a technical FFI/build package and no extracted end-user workflow warrants a separate story artifact. 🟢

## Current Red-Gap Index

| Gap | Unclosed proof boundary | Confidence |
|---|---|---|
| RG-01 | Current hosted feature-005 run and same-run five-platform artifacts. | 🔴 |
| RG-02 | Hash/identity join across proof, payload, bundle, and publication. | 🔴 |
| RG-03 | Observable origin of the successfully loaded native handle. | 🔴 |
| RG-04 | Real Android TLS/HTTPS path, concurrency, and recovery. | 🔴 |
| RG-05 | External `git2dart` lifecycle and selected-pair coordination. | 🔴 |
| RG-06 | Current pub.dev publisher execution and registry acceptance. | 🔴 |
| RG-07 | GitHub protections, approvals, token scopes, and action trust. | 🔴 |
| RG-08 | Generated binding and native payload bytes absent from checkout. | 🔴 |
