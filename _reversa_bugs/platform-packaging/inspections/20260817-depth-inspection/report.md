# Depth Inspection Report: platform-packaging

## Inspection metadata

```yaml
feature: platform-packaging
context: platform-packaging
date: 2026-08-17
mode: read-only-diagnostic
closure_policy: package
source_modified: false
existing_feature_bugs: 1
runtime_replay: blocked
```

## Feature map

### Specifications

- `_reversa_sdd/platform-packaging/requirements.md`
- `_reversa_sdd/platform-packaging/design.md`
- `_reversa_sdd/platform-packaging/tasks.md`
- `_reversa_sdd/flowcharts/platform-packaging.md`
- `_reversa_sdd/flowcharts/platform-packaging-artifact-selection.md`

### Production and package boundaries

| Platform | Produced artifact set | Package boundary | Current proof |
|---|---|---|---|
| Android | `libgit2.so`, `libssh2.so`, `libssl.so`, and `libcrypto.so` per ABI | `src/main/jniLibs/<ABI>` plus Flutter FFI CMake | x86_64 emulator recipe only |
| iOS | Four static XCFrameworks with device and simulator slices | CocoaPods vendoring plus libgit2 force-load | arm64 simulator recipe only |
| Linux | `libgit2.so` and `libssh2.so` | Flutter CMake bundled libraries | Confirmed sidecar omission, existing bug #1 |
| macOS | `libgit2.dylib` with static libssh2/OpenSSL linkage | CocoaPods vendored library | Direct artifact and plain-Dart loader recipe |
| Windows | `libgit2.dll`, `libssh2.dll`, and versioned OpenSSL DLLs | Flutter CMake bundled libraries | Source-string and package-local loader recipe |

The workflow injects generated bindings and all native build artifacts before the expanded-size check, `dart pub publish --dry-run`, and publication. No generated binding, native artifact, assembled application, or expanded publish payload is present in this checkout.

### Existing bug deduplication

The Linux producer exports `libssh2.so`, but `linux/CMakeLists.txt` bundles only `libgit2.so`. This is the same causal defect already recorded as `BUG-20260816-AAH6` (display #1, open, High/P1). It was not registered again.

## Findings by lens

### Spec conformity

- The five plugin registrations, artifact names, Android ABI destinations, iOS XCFramework declarations, macOS install-name recipe, and Windows dependency names align with the effective specifications at the recipe level.
- Linux package carriage deviates from `PPK-RF-02`; the deviation is already represented by bug #1.
- Apple podspecs declare `1.11.2` while `pubspec.yaml` declares `1.12.1`. The mismatch is verified, but synchronization is an explicit unresolved policy, so it was not promoted.
- Android declares `pluginClass: Git2dartBinariesPlugin` without a Java/Kotlin implementation. The similarly named C++ registration function uses a desktop registrar type and is not built by Android CMake. This remains manifest-drift observation because `ffiPlugin: true` may intentionally make native registration unnecessary and no generated registrant or failing build is available.

### Data flow

- Android build artifacts flow into four `jniLibs` ABI directories. Runtime proof covers only x86_64; sidecar carriage relies on Gradle's standard `jniLibs` behavior while CMake explicitly lists only libgit2.
- iOS device and simulator libraries flow into four XCFrameworks. The consumer recipe force-loads libgit2, while only the simulator slice is launched in CI.
- Linux downloads both produced libraries but drops the sidecar at the Flutter CMake boundary, as captured by bug #1.
- Final assembly downloads all platform artifacts, checks only aggregate size, runs pub dry-run, and publishes. It has no explicit filename, architecture, dependency, version, or hash inventory gate.

### Contracts and integrations

- Desktop tests open artifacts from the package checkout and do not build clean Flutter consumer applications. They therefore do not prove CMake or podspec carriage into final application bundles.
- Mobile recipes build path-dependent consumer applications, but runtime coverage is limited to Android x86_64 and iOS arm64 simulator.
- Build-cache manifests validate inputs before artifact upload, but those manifests are not carried into final assembly. End-to-end provenance after artifact download remains unproved.
- Package signing, notarization, and the external Dart consumer boundary remain outside repository evidence.

### Error states and edge cases

- Windows OpenSSL libraries are selected with globs that may be empty without a CMake failure. Normal CI copies matching files, and no current expanded package proves an omission, so this remains a conditional fail-open risk.
- Missing artifacts cause the Windows runtime test to skip. The current checkout therefore cannot prove loader success or transitive dependency resolution.
- Pushes to the analyzed `1.12.1` branch do not match the workflow's `main` and `1.11.2` push triggers. Intended branch eligibility is an explicit release-policy lacuna.

### Test coverage

- No complete current artifact inventory is available locally.
- Linux/Windows/macOS application-bundle carriage is not exercised by a clean consumer app.
- Android arm64-v8a, x86, and armeabi-v7a are built for publication but not launched.
- The iOS device slice is assembled but not launched.
- Windows tests use source-text assertions for the packaging recipe rather than final DLL inventory.
- The CA asset declaration has no package-qualified runtime packaging test.

### Concurrency and consistency

- Workflow dependencies correctly order iOS assembly, platform tests, remaining Android ABI builds, and final package assembly within one workflow run.
- The two CA copies are byte-identical in this snapshot: 234415 bytes and SHA-256 `9C0683BC1DB52A9C21BE6D592D283DBF8632DC242BE47522EB7201D882BD1CEB`. No synchronization gate prevents future drift.
- Push runs on one ref are serialized but not cancelled. Possible stale or duplicate publication remains a release-policy hypothesis without workflow-run evidence.

## Consolidated result

| Classification | Count |
|---|---:|
| New confirmed promotable candidates | 0 |
| Deduplicated confirmed defect | 1 |
| Conditional packaging risks | 2 |
| Coverage and current-evidence gaps | 6 |
| Metadata, branch, or release-policy lacunae | 3 |
| Verified conformity or negative assurance groups | 4 |

No new canonical bug was created. The Windows empty-glob path was not promoted because the normal producer supplies the files and no assembled payload demonstrates omission. Metadata and branch differences were not promoted because their intended policies are explicitly unresolved.

## Confidence impact

- Recipe-level confidence remains high for producer-to-injection mappings on all five platforms.
- Current artifact and expanded-package correctness remain red because all generated/native outputs are absent locally.
- Desktop assembled-application confidence remains red; mobile runtime confidence is partial.
- Linux confidence is represented by the existing High/P1 bug rather than a new finding.
- The completed core Reversa score was not rewritten.

## Residual blockers

- Generated bindings and all platform-native roots are absent.
- No current CI run, expanded release artifact, or assembled desktop consumer application was inspected.
- Three Android ABI runtimes and an iOS physical-device runtime remain unobserved.
- Apple version synchronization, release-branch eligibility, publication ordering, signing, and notarization policies remain unsettled or outside scope.
- The authoritative supported desktop and Apple architecture matrix is not declared.
- `F:\git2dart` was not read. Cross-repository consumer behavior remains explicitly unverified.

No source, test, staged, committed, global-setting, or external-repository change was made.
