# Data Dictionary

## Dart FFI facade structures

| Structure / value | Fields or shape | Ownership / lifecycle | Confidence |
|---|---|---|---|
| `Libgit2LifecycleOperation` | enum values: `initialize`, `rollback`, `shutdown`, `finalizerCleanup` | immutable Dart enum exported through the public barrel | 🟢 CONFIRMED |
| `Libgit2LifecycleException` | `operation: Libgit2LifecycleOperation` (required); `nativeResult: int?`; `cause: Object?`; `causeStackTrace: StackTrace?`; `ownerLabel: String?` | immutable Dart exception; `toString()` includes `operation` and non-null result/owner/cause, but not the stored stack trace | 🟢 CONFIRMED |
| `LibGit2Error` | `_errorPointer: Pointer<git_error>` (required, private); derived `message: String`; derived `errorClass: git_error_t` | borrowed native pointer; constructible only inside `error.dart` after a non-null `git_error_last()` result | 🟢 CONFIRMED |
| `Pointer<Char>.toDartString` input | receiver pointer plus optional `length: int?` byte count | null pointer maps to `''`; non-null pointer is borrowed and decoded without ownership transfer | 🟢 CONFIRMED |
| Git validation inputs | `String` for SHA-1/ref predicates; `int` for object-type threshold predicate | immutable receiver values; no native allocation or call | 🟢 CONFIRMED |

## Runtime structures

| Structure / value | Fields or shape | Ownership / lifecycle | Confidence |
|---|---|---|---|
| `libgit2Runtime` | top-level `Libgit2Runtime` | lazily created once per Dart isolate; owns one loaded library and at most one checked native init increment | 🟢 CONFIRMED |
| `Libgit2Runtime` | `_bindings: Libgit2`; `_options: Libgit2Opts`; `_state: Libgit2RuntimeState` | public managed facade; bindings/options share one dynamic library and state epoch | 🟢 CONFIRMED |
| `Libgit2RuntimeState` | `_initializeNative`, `_shutdownNative`, `_onFinalizerError`; `_phase`; `_activeCallCount=0`; `_liveOwnerCount=0`; late `_shutdownResult`; owner finalizer | isolate-local deterministic lifecycle bookkeeping with injected native transition callbacks | 🟢 CONFIRMED |
| `_RuntimePhase` | `uninitialized`, `initialized`, `terminated`, `faulted` | private monotonic lifecycle phase except failed init with successful rollback remains retryable as `uninitialized` | 🟢 CONFIRMED |
| `Libgit2OwnerLease` | `_cleanup: _OwnerCleanup`; `_finalizer`; derived `debugLabel`, `isCompleted` | exact-once persistent owner pin; explicit completion detaches the fallback finalizer | 🟢 CONFIRMED |
| `_OwnerCleanup` | `runtime`; `debugLabel`; optional `_destructor`; `_isCompleting=false`; `_isCompleted=false` | invokes destructor before marking completion; failure retains the runtime pin | 🟢 CONFIRMED |
| `NativeLoaderPlan` | `libraryName: String`; `packageSubdirectory: String?`; derived `hasPackageFallback` | immutable non-iOS loader plan exposed for tests | 🟢 CONFIRMED |
| Platform target record | `name: String`, `subDir: String?` | ephemeral internal record projected from `NativeLoaderPlan` | 🟢 CONFIRMED |
| `_cachedPackageRoot` | nullable absolute path | lazily populated and retained | 🟢 CONFIRMED |
| Package-config document | JSON object with `packages: List`; matching entry has `name` and `rootUri` | read-only parsed data, errors collapse to no result | 🟢 CONFIRMED |
| `AndroidSSLDependencies` | `temporaryDirectory: Future<Directory> Function()`; `loadCertificateAsset: Future<Uint8List> Function()`; `writeCertificate: Future<void> Function(File, Uint8List)` | immutable operation bundle; default singleton binds Flutter/platform I/O, while tests inject deterministic operations | 🟢 CONFIRMED; 🔴 non-private seam is barrel-exported despite test-only intent |
| Android TLS completion state | `_initialized: bool=false`; `_certPath: String?=null` | static isolate-local sequential cache; committed only after the selected writer completes; reset only by test hook | 🟢 CONFIRMED |
| Android TLS initialization attempt | selected `AndroidSSLDependencies`; resolved `Directory`; target `File`; loaded `Uint8List` | ephemeral async values; no stored in-flight operation, content digest, validity marker, or partial-file cleanup | 🟢 CONFIRMED |

## libgit2 global-option FFI structures

| Structure / value | Fields or shape | Ownership / lifecycle | Confidence |
|---|---|---|---|
| `Libgit2Opts` | `_lookup: Pointer<T> Function<T extends NativeType>(String)` plus 14 lazy pointer/Dart-function adapter pairs | one wrapper view over a caller-supplied `DynamicLibrary`; allocates no native arguments | 🟢 CONFIRMED |
| Variadic signature family | `return: ffi.Int`; leading `option: ffi.Int`; discriminator-specific `ffi.VarArgs` tuple; corresponding Dart `int Function(...)` | lazily resolved once per used family from `git_libgit2_opts` | 🟢 CONFIRMED |
| ABI probe record | `availability: available|unavailable`; `pointer_width: int`; `submitted_size: int`; conditional `observed_size: int` | JSON emitted by a bounded subprocess; submitted value is `0x100000011` | 🟢 CONFIRMED |

### Variadic argument shapes

| Native tuple after discriminator | Uses | Caller obligation | Confidence |
|---|---|---|---|
| `Pointer<Int>` | integer getter: owner validation | allocate/free output and inspect native status | 🟢 CONFIRMED |
| `Int` | ten boolean/integer setters | supply native-compatible value; most wrappers do not validate 0/1 or enum range | 🟢 CONFIRMED |
| `Pointer<Size>` | five pointer-width unsigned getters | allocate exact-width output and free it | 🟢 CONFIRMED |
| `Size` | five pointer-width setters | supply non-negative native-width value; only pack maximum object size rejects negatives explicitly | 🟢 CONFIRMED |
| `IntPtr` | signed pointer-width cache maximum setter | preserve signed pointer width | 🟢 CONFIRMED |
| `Pointer<git_buf>` | template path and user-agent getters | initialize fields; dispose with `git_buf_dispose`; then free wrapper | 🟢 CONFIRMED |
| `Pointer<Char>` | template path and user-agent setters | retain null-terminated input for call duration | 🟢 CONFIRMED |
| `Int, Pointer<git_buf>` | configuration-level search-path getter | provide valid level and disposable output buffer | 🟢 CONFIRMED |
| `Int, Pointer<Char>` | configuration-level search-path setter | provide valid level and retained C string | 🟢 CONFIRMED |
| `Int, Size` | cache object type and pointer-width limit | validate object type/range outside wrapper | 🟢 CONFIRMED |
| `Pointer<IntPtr>, Pointer<IntPtr>` | current and allowed signed pointer-width cache memory | allocate/free both outputs | 🟢 CONFIRMED |
| `Pointer<Char>, Pointer<Char>` | certificate file and directory locations | at least one non-null is documented, but not Dart-validated | 🟢 CONFIRMED |
| `Pointer<git_strarray>` | supported extension getter | dispose with `git_strarray_dispose`; then free wrapper | 🟢 CONFIRMED |
| `Pointer<Pointer<Char>>, Size` | extension input array and pointer-width length | retain pointer array and every C string for call duration | 🟢 CONFIRMED |
| `git_libgit2_opt_t` discriminator | selects the variadic interpretation | generated numeric value must match the selected tuple and pinned native header | 🟢 source mapping; 🔴 generated values absent |

## Platform packaging structures

| Structure / value | Fields or shape | Ownership / lifecycle | Confidence |
|---|---|---|---|
| Flutter plugin platform record | `platform`; `pluginClass`; `ffiPlugin=true` | declarative `pubspec.yaml` entry consumed by Flutter tooling for five platforms | 🟢 CONFIRMED |
| Native artifact set | `platform`; `abi/slice`; `relative paths`; `link/load mode`; optional provenance sidecar | generated by platform actions, downloaded into the expanded package, then consumed by Flutter/CocoaPods/CMake/runtime loader | 🟢 recipe confirmed; 🔴 current artifacts absent |
| Android package configuration | `namespace=com.dartgit.git2dart_binaries`; `compileSdk=34`; `minSdk=21`; `Java=1.8`; `ANDROID_STL=c++_shared`; four declared ABIs in workflow | Gradle/CMake source metadata; APK payload comes from `jniLibs/<ABI>` | 🟢 CONFIRMED |
| Apple pod package configuration | `pod name`; `version`; `minimum OS`; vendored artifacts; library/search/link flags | CocoaPods consumes checked-in podspec plus CI-injected binaries | 🟢 CONFIRMED |
| `BundleEvidence` | `bundleRoot: Directory`; `platform: String`; `bindingOrigin: String`; `payloadFiles: List<String>`; JSON schema/bundle marker | returned by assembler and persisted as `bundle-proof.json`; label is asserted, not cryptographically attested | 🟢 CONFIRMED; 🔴 standalone provenance insufficient |
| `ConsumerRunResult` | `exitCode: int`; `category: String`; `stdout: String`; `stderr: String`; derived `succeeded` | immutable subprocess result; diagnostics replace consumer/bundle/override absolute roots | 🟢 CONFIRMED |

## Native version set

| Field | Value | Source | Confidence |
|---|---:|---|---|
| libgit2 | 1.9.6 | workflow environment | 🟢 CONFIRMED |
| libssh2 | 1.11.1 | workflow environment | 🟢 CONFIRMED |
| OpenSSL | 3.0.15 | workflow environment | 🟢 CONFIRMED |
| Flutter CI | 3.44.0 | workflow environment | 🟢 CONFIRMED |
| pub package | 1.12.1 | `pubspec.yaml` | 🟢 CONFIRMED |
| iOS podspec metadata | 1.11.2 | `ios/git2dart_binaries.podspec` | 🟢 CONFIRMED; differs from pub metadata |
| macOS podspec metadata | 1.11.2 | `macos/git2dart_binaries.podspec` | 🟢 CONFIRMED; differs from pub metadata |
| Android Gradle module | 1.0 | `android/build.gradle` | 🟢 CONFIRMED; differs from pub metadata |

## Native build and cache structures

| Structure / value | Fields or shape | Ownership / lifecycle | Confidence |
|---|---|---|---|
| Native version set | `libgit2=1.9.6`; `libssh2=1.11.1`; `openssl=3.0.15`; `flutter=3.44.0` | workflow-global inputs forwarded into composite actions and manifest expectations | 🟢 CONFIRMED |
| Toolchain fingerprint | SHA-256 of platform-specific host/compiler/CMake/SDK/target text | computed per job; output becomes cache-key and manifest metadata | 🟢 CONFIRMED; 🟡 not every installed output-affecting tool is represented |
| Native cache key | schema/pipeline prefix; platform/ABI; fingerprint; native versions; `hashFiles(...)` recipe digest | GitHub cache lookup/save identity; exact for most actions, prefix fallback additionally used on Windows | 🟢 CONFIRMED |
| Native cache manifest | `schema`; `platform`; `abi`; `libgit2`; `libssh2`; `openssl`; `toolchain`; `provenance`; `source_ref` or `exception_id`; `files` | deterministic JSON created beside an export and used as the cache acceptance contract | 🟢 CONFIRMED |
| Native cache file record | key: safe POSIX relative path; value: `sha256: String`, `size: int` | one entry per recursively discovered file; validation requires exact current file-set/detail equality | 🟢 CONFIRMED |
| Native provenance record | `provenance=source-build` + `source_ref`, or `approved-exception` + `exception_id` | mutually exclusive manifest shape; copied/merged into release artifact sidecars | 🟢 source semantics; 🔴 approved-exception CLI behavior untested here |
| Binding generation configuration | output `lib/src/bindings.dart`; entry headers; compiler include/define; class name/comments | `ffigen.yaml` drives CI-only ABI generation from pinned libgit2 headers | 🟢 CONFIRMED; 🔴 generated output absent |
| Platform build export | normalized native files plus release provenance sidecar | produced from validated cache or pinned source build, uploaded for one day, then injected into test/release jobs | 🟢 recipe confirmed; 🔴 current hosted output uninspected |

## Release validation and assembly structures

| Structure / value | Fields or shape | Ownership / lifecycle | Confidence |
|---|---|---|---|
| `ReleasePayload` | generated binding; desktop payloads; four Android ABI payloads; four iOS XCFrameworks; provenance sidecars; package metadata | assembled only in `publish_package` from current-run artifact names, then dry-run validated and conditionally uploaded/published | 🟢 graph confirmed; 🔴 current payload absent |
| `PlatformReleaseProof` | `schema`; `candidate`; `platform`; `abi`; `status`; `inventory`; `linkage`; `versions`; nullable `attestation`; `failure_codes` | producer writes `proof.json`/`proof.md`; aggregate release gate consumes eight scopes | 🟢 CONFIRMED |
| `PlatformProofInventory` | `expected: List<String>`; `present: List<PlatformProofFileRecord>`; `missing: List<String>`; `unexpected: List<String>` | derived from producer export; aggregate validator currently checks only that inventory is a map and present paths are safe | 🟢 source; 🔴 aggregate semantic validation incomplete |
| `PlatformProofFileRecord` | `path: safe relative String`; `sha256: String`; `size: int` | one matched producer file; not compared with the corresponding downloaded release file | 🟢 producer semantics; 🔴 release identity join absent |
| `DependencyVersionObservation` | `intended`; `observed`; `comparison=match|mismatch|unavailable`; `evidence=payload|build-input|unavailable` | generated for libgit2/libssh2/OpenSSL by payload/build-input text search | 🟢 CONFIRMED; 🟡 not a dependency API query |
| `ApplePlatformAttestation` | `input_sha256`; `emitted_sha256`; `toolchain`; `sdk`; `compiled_metadata` | emitted for iOS/macOS proof creation; nullable elsewhere; aggregate validator does not inspect contents | 🟢 producer semantics; 🔴 aggregate enforcement absent |
| `WorkflowCondition` | `kind: always|pullRequest|mainPush|cacheMiss`; `source: String` | parsed fail-closed from the supported YAML `if` subset and evaluated for event/ref facts | 🟢 CONFIRMED |
| `WorkflowStepFact` | `name`; nullable `uses`; nullable `run`; `condition`; `withValues` | immutable parsed view of one workflow step | 🟢 CONFIRMED |
| `WorkflowJobFact` | `id`; `needs: Set<String>`; `condition`; `steps` | validates all dependencies refer to known jobs; supplies named-step/order lookup | 🟢 CONFIRMED |
| `WorkflowPolicyFacts` | `events: Map`; `jobs: Map<String,WorkflowJobFact>` | parsed checked-in workflow model used by feature-005 policy tests | 🟢 local parser; 🟡 simplified GitHub semantics |
| `OpenSSLExceptionRecord` | `id`; `platform`; `abi`; `openssl`; `infeasibility_evidence`; `approver`; `review_by`; `exact_parity=verified` | optional checked-in reviewed exception; normal provenance remains `source-build` | 🟢 declared schema; 🔴 no current records/behavior fixture |

## Release proof scope contract

| Proof scope | Expected producer route | Runtime strength |
|---|---|---|
| `linux/default` | Linux native builder | desktop ctypes load |
| `macos/default` | macOS native builder | desktop ctypes load plus Apple attestation |
| `windows/default` | Windows native builder | desktop ctypes load |
| `ios/default` | assembled iOS XCFramework job | plist parse plus `nm`; no app execution in proof creator |
| `android/x86_64` | Android x86_64 builder | `readelf -d`; separately device-tested by emulator job |
| `android/{arm64-v8a,x86,armeabi-v7a}` | Android-other matrix | `readelf -d` only; no device execution |

## Behavior evidence structures

| Structure / value | Fields or shape | Ownership / lifecycle | Confidence |
|---|---|---|---|
| `BehaviorProofFixture` | `root: Directory`; guarded `file()`; `sanitize()`; bounded `runBounded()`; `dispose()` | one disposable test root; child process defaults to 30 seconds; cleanup recursively deletes fixture | 🟢 CONFIRMED |
| `ABIProbeRecord` | `availability=available|unavailable`; `pointer_width`; `submitted_size`; optional `observed_size` | JSON stdout from isolated ABI probe; original native value restored before process exit | 🟢 CONFIRMED; 🟡 unavailable can coexist with green enclosing test |
| `LoaderProbeRecord` | `status=loaded`; `package_root`, or Android `library` + `package_fallback` | JSON stdout from plain-Dart internal probe; package root is reported input, not observed handle path | 🟢 shape confirmed; 🔴 load origin absent |
| `AnalyzerResolution` | `version: String`; `root: String` | resolved from package config and analyzer package metadata; exact 8.2.0 required | 🟢 CONFIRMED |
| `ArchitectureFact` | `file`; `kind=class|native-lifecycle-transition|prohibited-lifecycle-global`; `symbol`; `allowed` | emitted from syntactic AST visitor and serialized by policy CLI | 🟢 CONFIRMED; 🟡 name-based rather than resolved element identity |
| `BehaviorRegressionWatch` | `id=W001..W006`; `origin`; `expected_rule`; `verification_type`; `violation_signal` | durable feature watch stored outside Archaeologist artifacts; read-only input to this extraction | 🟢 CONFIRMED |
| `SourceAssertionReplacement` | `requirement=FR-01..FR-08`; `retired_assertion`; `replacement_evidence`; `action_ids` | traceability ledger requiring replacement proof before retirement | 🟢 CONFIRMED |
| `EvidenceClassification` | `tier`; `prerequisites`; `observable`; `proves`; `does_not_prove` | cross-test classification used to prevent source/local/fixture/hosted evidence inflation | 🟡 extracted analytical model |

## W001–W006 behavior contract

| Watch | Observable success record | Unavailable/failure boundary |
|---|---|---|
| W001 ABI | 64-bit `submitted_size == observed_size` for `0x100000011` | non-64-bit or absent payload must be explicit; green unavailable is not native success |
| W002 loader | isolated terminal two-stage diagnostic; declared fallback load; Android no-fallback plan | positive probe does not record actual loaded-library path |
| W003 TLS | success cached after one write; every dependency failure leaves retryable state | device asset/filesystem/native SSL route remains external |
| W004 artifact CLIs | valid fixture exits zero; independent corrupt family exits non-zero with sanitized root | real platform-proof success, symlinks and approved exception remain incomplete |
| W005 consumer | bundle-only package-config resolution plus public compile/native modes | caller-labelled origin and proof-file presence do not establish same-run bytes |
| W006 policy | exact analyzer resolution plus parsed AST/workflow facts | parser models are not GitHub/credential/publication execution |

## Artifact dictionary

| Artifact | Platform / location in expanded package | Link/load mode | Confidence |
|---|---|---|---|
| `bindings.dart` | `lib/src/bindings.dart` | generated Dart ABI; exported publicly | 🟢 recipe confirmed; 🔴 file absent |
| Android four-library ABI payload | `android/src/main/jniLibs/{armeabi-v7a,arm64-v8a,x86,x86_64}/` with `libgit2.so`, `libssh2.so`, `libssl.so`, `libcrypto.so` | APK `jniLibs`; CMake bundled list names libgit2 only; other libraries resolve transitively | 🟢 recipe/inventory confirmed; 🔴 files absent; 🔴 current device result uninspected |
| iOS XCFramework set | `ios/{libgit2,libssh2,libssl,libcrypto}.xcframework`; iphoneos-arm64 + iphonesimulator-arm64 | CocoaPods vendoring; `libgit2.a` force-loaded for device/simulator process-symbol visibility | 🟢 recipe confirmed; 🔴 directories absent; 🔴 current simulator/device result uninspected |
| macOS `libgit2.dylib` | `macos/libgit2.dylib`; ID `@rpath/libgit2.dylib`; one runner architecture | CocoaPods vendored dylib; libssh2/OpenSSL required static by build checks | 🟢 recipe confirmed; 🔴 file absent and current host execution unavailable |
| Linux shared payload | `linux/libgit2.so`, `linux/libssh2.so` | CMake bundle; runtime preloads libssh2 then opens libgit2; compatible system OpenSSL remains external | 🟢 recipe confirmed; 🔴 files absent; 🟡 exact dynamic dependencies unavailable |
| Windows DLL payload | `windows/libgit2.dll`, `windows/libssh2.dll`, root `libcrypto*.dll`, root `libssl*.dll` | CMake bundle; runtime preloads matched dependency DLLs before libgit2 | 🟢 recipe confirmed; 🔴 checkout files absent; 🟢 cached 1.12.1 fixture loaded locally |
| disposable consumer bundle | temporary package containing selected source tree, injected binding, one desktop payload, and `bundle-proof.json` | output root must begin empty; consumer process verifies exact path resolution and is deleted after the run | 🟢 feature-005 behavior confirmed; 🔴 label alone is not same-run provenance |
| package `cacert.pem` | `assets/certs/cacert.pem`; 234,415 bytes; SHA-256 `9C0683BC1DB52A9C21BE6D592D283DBF8632DC242BE47522EB7201D882BD1CEB` | declared Flutter asset; default helper loads package-qualified path and writes it as `<temporary>/cacert.pem` | 🟢 source/file identity; 🔴 no current Android-device extraction proof |
| Android-source `cacert.pem` copy | `android/src/main/assets/certs/cacert.pem`; same size and SHA-256 as package copy | retained Android source asset; no `AndroidSSLHelper` read site references this copy | 🟢 source/file identity; 🟡 runtime packaging/use not established here |
| extracted `cacert.pem` | `<getTemporaryDirectory()>/cacert.pem` | created/replaced by the selected writer; path cached after successful completion; existence/content are not revalidated on cache hits | 🟢 algorithm; 🟢 injected host-file execution; 🔴 default Android file not observed |

## CI artifact names

| Name pattern | Contents |
|---|---|
| `cache-bindings` | generated `bindings.dart` |
| `cache-linux` | Linux export |
| `cache-macos` | macOS export |
| `cache-windows` | Windows export |
| `cache-ios-*` / `cache-ios` | slice exports / assembled XCFrameworks |
| `cache-android-<ABI>` | Android shared libraries for one ABI |
| `platform-proof-<platform>[-<ABI>]` | same-run release-proof directory downloaded before eligibility |
| `release-package` | expanded publishable package on pull requests |

## Cache key and fingerprint fields

| Pipeline | Fingerprint inputs | Recipe hash inputs / notable lookup behavior | Confidence |
|---|---|---|---|
| bindings | runner OS/arch, clang line, CMake line, Flutter version | generation action, manifest script, `ffigen.yaml`, `pubspec.lock`; exact `native-v1-bindings` key | 🟢 CONFIRMED |
| Android | runner OS/arch, NDK r26d clang, CMake, API level | Android action + manifest script; ABI and native versions in exact key | 🟢 CONFIRMED |
| iOS | runner OS/arch, xcrun clang, CMake, SDK/version, deployment target, OpenSSL target | iOS action + manifest script; SDK/arch/native versions in exact key | 🟢 CONFIRMED |
| Linux | runner OS/arch, reported clang, CMake, OpenSSL input | Linux action + manifest script; native versions in exact key | 🟢 source; 🟡 actual CMake compiler not pinned to reported clang |
| macOS | runner OS/arch, macOS SDK, clang, CMake | macOS action + manifest script; save path set additionally contains provenance file omitted from restore path list | 🟢 source; 🟡 hosted restoration consequence unknown |
| Windows | runner OS/arch, MSVC file version, CMake, OpenSSL input | Windows action + manifest script; prefix restore omits recipe hash | 🟢 source; 🔴 older-recipe cache can satisfy self-contained manifest metadata |

## Configuration fields

| Field | Meaning | Default/pinned value |
|---|---|---|
| `ffiPlugin` | tells Flutter to build/bundle native FFI artifacts | `true` on all declared platforms |
| `GIT_EXPERIMENTAL_SHA256` / `EXPERIMENTAL_SHA256` | include/build experimental SHA-256 ABI | enabled |
| Android `compileSdkVersion` | compile API level | 34 |
| Android `minSdkVersion` | minimum supported API | 21 |
| iOS deployment target | minimum iOS version in build and podspec | 12.0 |
| macOS deployment target | minimum macOS version in podspec | 10.11 |
| `consumerEvidenceSchema` | disposable consumer proof schema | `git2dart-consumer-bundle/v1` |
| consumer mode | subprocess behavior selector | `compile-public-api`, `load-native`, `abi-probe`, `loader-probe`, `android-plan` |
| native manifest schema | deterministic cache/provenance record | `native-v2` |
| native provenance kind | mutually exclusive provenance selector | `source-build`, `approved-exception` |
| native digest block | streaming read size for SHA-256 | 1 MiB |
| cache artifact retention | generated binding/native artifact lifetime | 1 day |
| package payload ceiling | expanded publish size limit | 256 MiB |
| platform proof schema | producer/aggregate proof record | `platform-release-proof/v1` |
| required proof scopes | unique aggregate scopes | 8 |
| platform proof/release artifact retention | diagnostic proof and PR-expanded-package lifetime | 7 days |
| validation trigger | branches entering package validation | every push; pull requests targeting `main` |
| publication condition | credentialed publisher reachability | `push` on `refs/heads/main` only |
| analyzer evidence version | exact resolved AST parser prerequisite | `8.2.0` |
| ABI proof submitted value | above-uint32 `size_t` test value | `0x100000011` |
| behavior fixture default timeout | bounded child-process duration | 30 seconds |
| feature-005 test-layer files | test entrypoints plus support/probes | 22 Dart files: 19 tests + 3 support/probes |
| current focused behavior result | safe no-production-injection subset | 39/39 passed |
