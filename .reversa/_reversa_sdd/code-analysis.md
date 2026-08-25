# Consolidated Code Analysis

## Analysis boundary

This document analyzes only `F:\git2dart_binaries` at commit `680d914c8e2b87682f0b68318aee855838eb58e8`. The neighboring Dart repository was not read. Product-level connections to `git2dart` are explicitly marked as inferred.

Confidence scale: 🟢 **CONFIRMED** from local code/configuration; 🟡 **INFERRED** from local patterns; 🔴 **GAP** requiring external evidence.

## System role

🟢 **CONFIRMED:** the repository is a Flutter FFI plugin and pub package that creates a Dart-facing libgit2 ABI, loads or links native libraries at runtime, and packages the required native artifacts for five platform families. It is also the build factory for generated bindings and the release payload.

🟡 **INFERRED:** within the combined product, `git2dart_binaries` owns the native ABI and distribution boundary while `git2dart` owns higher-level Git objects and operations. The local README describes `git2dart` as the consumer, but the consumer manifest/import sites are outside this repository and were not inspected.

## Module 1: Dart FFI facade

### Responsibilities

- 🟢 `lib/git2dart_binaries.dart` is the public export barrel for Android TLS support, the CI-generated ABI, native error/lifecycle diagnostics, validation/conversion extensions, libgit2 option wrappers, the checked runtime, and compatibility loader globals.
- 🟢 `Libgit2LifecycleOperation` classifies checked failures as `initialize`, `rollback`, `shutdown`, or `finalizerCleanup`. `Libgit2LifecycleException` carries that required operation plus optional native result, cause, stack trace, and owner label. Its `toString()` always emits the operation and conditionally emits the non-null diagnostic fields except `causeStackTrace`.
- 🟢 `LibGit2Error` wraps a borrowed `Pointer<git_error>` behind a private constructor. Its `message` getter maps a null native message pointer to `''` and otherwise decodes zero-terminated UTF-8; `errorClass` converts the native integer through `git_error_t.fromValue`.
- 🟢 `GetLastError.getLastError()` calls `git_error_last()`, returns `null` for `nullptr`, and is the only production path in this library that constructs `LibGit2Error`.
- 🟢 `ToDartString.toDartString({length})` maps a null `Pointer<Char>` to `''`; otherwise it casts to `Pointer<Utf8>` and forwards the optional byte length to `package:ffi`.
- 🟢 `IsValidSHA.isValidSHA1()` requires one or more hexadecimal characters and a length between generated libgit2 minimum-prefix and SHA-1 hexadecimal-size constants, inclusive.
- 🟢 `IsValidRefName.isValidRefName()` rejects empty strings, whitespace and the local `~^:?*[` character set, trailing `.` or `/`, and any `..` or `./` sequence. This is a handwritten subset predicate, not a call to libgit2's reference-name validator.
- 🟢 `IsValidGitObjectType.isValidGitObjectType()` is a lower-bound comparison only: every integer greater than or equal to `GIT_OBJECT_COMMIT.value` is accepted, including values not proven to be declared enum members.

### Control and ownership notes

- 🟢 The public library is an export barrel; merely importing or defining an export does not prove that a generated binding or native payload is present. Dart top-level values remain lazy, so use of exported compatibility globals can trigger loading/initialization only when those values are read.
- 🟢 `LibGit2Error` does not copy or own native memory. The pointer and the native message it references remain subject to libgit2's borrowed last-error lifetime; callers cannot manufacture wrappers from arbitrary addresses through the public API.
- 🟢 `test/error_api_test.dart` checks private-constructor source text. It proves a local textual policy only; it does not call libgit2, observe pointer lifetime, or establish hosted/runtime behavior.
- 🟢 The feature-005 consumer fixture is designed to compile the public barrel from a disposable assembled bundle and reject an internal import, but it reports evidence unavailable when its declared external package fixture is absent. The test route is local evidence; this extraction did not inspect a same-run hosted execution or publication result.
- 🔴 No tracked test directly references `isValidSHA1`, `isValidRefName`, or `isValidGitObjectType`. `toDartString` is used by native option integration tests, but those calls do not by themselves prove the three validation predicates or external-consumer reachability.
- 🟡 The validation extensions appear intended for a higher-level Dart consumer, but no production consumer call sites exist in this repository. Definitions, exports, and local tests are not evidence of reachability in that external consumer.
- 🔴 `lib/src/bindings.dart` is exported and imported but intentionally absent from the current working tree after the CI-owned-bindings change. The complete generated ABI inventory, a same-run assembled package, hosted workflow provenance, and publication remain external evidence gaps for this pass.

## Module 2: Native loader and lifecycle

### Managed runtime construction and access

- 🟢 `lib/src/util.dart` is now a compatibility import path that only exports `runtime.dart`; the former eager `libgit2` and `libgit2Opts` globals are removed.
- 🟢 The top-level `libgit2Runtime` is lazily created per Dart isolate. `Libgit2Runtime._load()` loads one dynamic library, constructs generated `Libgit2` and handwritten `Libgit2Opts` views over it, injects checked init/shutdown callbacks into `Libgit2RuntimeState`, and returns without calling native initialization yet.
- 🟢 Reading `bindings` or `options`, calling `ensureInitialized`, entering `withCall`, or acquiring an owner triggers the same state object's checked initialization. Logical reuse does not add another native increment after the phase becomes `initialized`.
- 🟢 `withCall<T>` is synchronous: it initializes, increments `activeCallCount`, executes the callback, and decrements the count in `finally`, including when the callback throws.

### Checked initialization state machine

`Libgit2RuntimeState` begins in private phase `uninitialized` and accepts four terminal/working phases: `uninitialized`, `initialized`, `terminated`, and `faulted`.

1. If already initialized, `ensureInitialized()` returns without a native call.
2. `terminated` and `faulted` reject managed re-entry with `StateError`.
3. `git_libgit2_init()` succeeds only when it returns a positive count without throwing.
4. A thrown, zero, or negative init result triggers one `git_libgit2_shutdown()` rollback attempt.
5. Successful rollback leaves the phase uninitialized and throws an `initialize` lifecycle exception, allowing a later retry.
6. A negative or throwing rollback sets `faulted` and throws a `rollback` lifecycle exception; the runtime becomes terminal.

🟢 This replaces the previous unchecked initializer. 🟡 When the rollback callback itself throws, the exception's `nativeResult` records the failed init result because no rollback result was returned.

### Persistent owners and exact-once cleanup

- 🟢 `acquireOwner()` initializes the runtime, increments `liveOwnerCount`, creates a `_OwnerCleanup`, and attaches it to a Dart `Finalizer` through `Libgit2OwnerLease`.
- 🟢 A lease accepts at most one destructor. `release()` and `rollbackConstruction()` invoke it; `transfer()` completes the logical pin without invoking it; repeated completion after success is a no-op.
- 🟢 `_OwnerCleanup._complete()` rejects reentrant cleanup. It marks completion and decrements the owner count only after the optional destructor succeeds.
- 🟢 A throwing destructor leaves the owner incomplete and pinned, so shutdown remains blocked. The finalizer route catches cleanup errors, reports a `finalizerCleanup` lifecycle exception, and does not throw across the finalizer boundary.
- 🟡 Dart finalization is a fallback, not deterministic consumer cleanup; production callers must still explicitly release, roll back, or transfer owners.

### Guarded terminal shutdown

- 🟢 Shutdown rejects any non-zero active-call or live-owner count before calling native code.
- 🟢 Shutdown from `uninitialized` records result `0`, enters `terminated`, and performs no native shutdown call.
- 🟢 Shutdown from `initialized` accepts any non-negative native result, caches it, and becomes terminal. Repeated shutdown returns the cached result without another native call; positive remaining process counts are preserved.
- 🟢 Negative or throwing native shutdown moves the runtime to `faulted` and raises a checked lifecycle exception. Both `terminated` and `faulted` make `isTerminated` true and prevent reinitialization.
- 🔴 The production API now has a symmetric shutdown owner, but no inspected external consumer call site proves that real owners are drained and `shutdown()` is invoked in deployed use. Raw generated init/shutdown methods also remain technically callable outside the supported manager.

### Platform-selection and fallback algorithm

| Platform | Loader target | Package subdirectory | Initial mechanism |
|---|---|---|---|
| iOS | process image | none | `DynamicLibrary.process()` before plan selection |
| Android | `libgit2.so` | none | bare system/app loader only |
| Linux | `libgit2.so` | `linux` | bare name, then package path |
| macOS | `libgit2.dylib` | `macos` | bare name, then package path |
| Windows | `libgit2.dll` | `windows` | bare name, then package path |

`NativeLoaderPlan` exposes the non-iOS mapping for tests; unsupported names throw `UnsupportedError`. For non-iOS platforms `_loadLibrary()` opens the bare name first. Android logs and rethrows the first error because it has no package fallback. Desktop fallback resolves a package root, preloads dependencies, opens `<root>/<subdirectory>/<library>`, and on failure logs the bare attempt plus the current fallback stage before rethrowing the fallback error.

Linux preloads `linux/libssh2.so`; macOS expects dependencies statically linked into its libgit2 dylib; Windows opens sorted `libcrypto*.dll` files, then sorted `libssl*.dll` files, then `libssh2.dll`. A missing Windows package directory deliberately attempts its `libssh2.dll` path and fails closed.

### Package-root resolution

`_resolvePackageRoot()` uses the first successful source:

1. non-empty `GIT2DART_BINARIES_PACKAGE_ROOT`, normalized to an absolute directory path;
2. synchronous resolution of the public package URI;
3. package-config JSON found through `Isolate.packageConfigSync`, `DART_PACKAGE_CONFIG`, or a `--packages=` executable argument;
4. otherwise `StateError`.

The successful root is cached. Package-config parsing validates container types, scans for a `git2dart_binaries` entry with string `rootUri`, resolves it against the config URI, and returns an absolute path. Missing files, malformed data, and parse/IO errors collapse to no config result.

### Feature-005 evidence and remaining gaps

- 🟢 `libgit2_runtime_test.dart` exercises the injected Dart lifecycle state machine: positive initialization, rollback/retry, terminal faults, call pins, exact-once owner cleanup, transfer, cleanup failure, and idempotent shutdown. This is deterministic local state-machine evidence, not a native process-count or hosted-CI observation.
- 🟢 `runtime_loader_process_test.dart` launches a bounded disposable Dart process, clears common dynamic-loader search variables, sanitizes its temporary root, and checks terminal desktop diagnostics plus the host-independent Android plan.
- 🟡 The Android test calls `nativeLoaderPlanForTesting('android')` on the host; it proves the plan mapping, not execution inside an Android loader.
- 🔴 The positive desktop case returns early as `unavailable` without a declared native package payload. When available, it asserts only process success and `status=loaded`; the probe reports the supplied package root but not the actual loaded-library path, so it does not independently prove that the bare-name attempt failed and the fallback branch supplied the handle.
- 🔴 The loader probe imports internal `src/runtime.dart`, and this pass did not inspect a same-run hosted execution, cross-isolate native counter trace, external production consumer, or publication result.

## Module 3: libgit2 global options

### Dispatch architecture

🟢 `Libgit2Opts` receives a `DynamicLibrary`, stores its generic lookup callback, and exposes 33 public typed methods over the single C variadic symbol `git_libgit2_opts`. Each method hard-codes one generated `git_libgit2_opt_t` discriminator, selects one of 14 lazy `NativeFunction`/`asFunction` adapters, forwards caller-owned arguments, and returns the native integer status unchanged.

The 14 current variadic shapes cover `Int` get/set, unsigned pointer-width `Size` get/set, signed pointer-width `IntPtr` set, `git_buf`, C strings, level-plus-buffer/string, object-type-plus-`Size`, two `IntPtr` outputs, two C-string inputs, `git_strarray`, and C-string-array-plus-`Size`. All late adapters independently look up the same symbol; only their variadic tuple differs.

🟢 The source now represents pointer-width contracts with `ffi.Size`/`Pointer<ffi.Size>` and `ffi.IntPtr`/`Pointer<ffi.IntPtr>` rather than the former 32-bit family. 🔴 `bindings.dart` is absent from the working tree, so the current numeric discriminator values and generated struct/enum definitions cannot be revalidated from this checkout alone against the pinned libgit2 header.

### Exposed option families

| Family | Public operations | Count |
|---|---|---:|
| Memory mapping | get/set window size, mapped limit, file limit | 6 |
| Search paths | get/set configuration search path by level | 2 |
| Cache | object limit, maximum size, current/allowed memory, enable/disable | 4 |
| Template path | get/set default template path | 2 |
| TLS and identity | certificate locations; get/set user agent | 3 |
| Strictness and behavior | strict object/symbolic-ref/hash checks, offset deltas, fsync, unsaved-index safety, keep-file checks, HTTP Expect, owner validation | 10 |
| Pack limits | get/set maximum objects and maximum object size | 4 |
| Repository extensions | get/set supported extension array | 2 |

### Validation and ownership

- 🟢 `git_libgit2_opts_set_pack_max_object_size` is the only public wrapper with explicit Dart validation: negative input throws `RangeError` before conversion to `size_t`.
- 🟢 Other integers, enum-like levels/types, boolean flags, pointer nullability, array lengths, and size ranges pass through without Dart-side checks; native status or FFI conversion behavior decides the outcome.
- 🟢 The wrapper allocates and frees nothing. Callers retain all input storage and must dispose libgit2-filled `git_buf` and `git_strarray` values with the generated native disposers before freeing their Dart allocation.
- 🟢 Getter output pointers must match the exact adapter width. C strings must remain valid for the duration of the call, and extension arrays must retain both the pointer array and each pointed-to string.

### Behavior-proving evidence tiers

1. **Source/type declarations — 🟢 local static fact.** The current file declares 33 discriminator-specific wrappers and 14 typed variadic adapters. This establishes Dart-side shape, not native execution or header conformance by itself.
2. **Feature-005 serialized ABI probe — 🟢 when prerequisites are present.** A bounded subprocess rejects non-64-bit hosts as unavailable, saves the original mwindow file limit, sets `0x100000011`, reads it back through `Pointer<Size>`, compares exact equality, restores the original value, and shuts down the managed runtime. A disposable assembled-bundle route performs the same public-API round trip.
3. **Direct libgit2 integration round-trips — 🟢 local native evidence when the injected payload loads.** Tests set and exactly read back cache maximum size and pack maximum objects with `1 << 32` growth, set/read pack maximum object size, reject its negative input before native dispatch, and toggle/read owner validation. They restore mutable global values in teardown paths.
4. **Hosted cross-platform proof — 🔴 not established by this pass.** The tests and workflow declarations exist, but no same-run hosted matrix result or published-package provenance was inspected here.

The search-path and user-agent cases call get/set/get and restore the original buffers, but do not assert that the second getter contains the requested value. The extensions case proves only successful retrieval and disposal. These are real native calls when prerequisites load, but weaker than value-preserving round-trip assertions.

### Remaining coverage and ABI gaps

- 🔴 No direct current behavior test covers mwindow size, mwindow mapped limit, cache object limit, caching toggle, template path, SSL certificate locations, strict object/symbolic-ref/hash flags, offset delta, fsync, unsaved-index safety, keep-file checks, HTTP Expect, or setting extension arrays.
- 🔴 The exact-value probes exercise the common `Size` family, signed cache-size `IntPtr` family, and integer owner-validation family, but not every 14-shape adapter or every discriminator/signature pairing.
- 🔴 `opts_bindings_integration_test.dart` reads `libgit2Runtime.bindings` and `.options` while registering tests, before its ABI case checks whether `GIT2DART_BINARIES_PACKAGE_ROOT` exists. On a source-only host with no loadable system library, the file can fail before emitting the intended unavailable evidence classification.
- 🟡 Global options mutate process-wide libgit2 state. Current tests restore selected values and serialize the dedicated subprocess probe, but this does not prove isolation from unrelated concurrent consumers.
- 🔴 Local native success with an externally supplied package root does not by itself prove that the tested binding/native payload came from the same hosted run or that every supported platform executed the same ABI path.

## Module 4: Android TLS bootstrap

### Public facade and feature-005 seam

`AndroidSSLHelper.initialize()` delegates to `_initialize(_defaultDependencies)`. The default dependency bundle resolves `getTemporaryDirectory()`, loads `packages/git2dart_binaries/assets/certs/cacert.pem` through `rootBundle`, and writes the bytes with `File.writeAsBytes(..., flush: true)`. `initializeWith(...)` selects an injected bundle instead; `certPath`, `isInitialized`, and `resetForTesting()` expose or reset the two static completion fields. 🟢 source-confirmed

Feature 005 added `AndroidSSLDependencies` with three operations: `temporaryDirectory`, `loadCertificateAsset`, and `writeCertificate`. This isolates the state machine from `path_provider` and Flutter's root asset bundle so host Flutter tests can deterministically fail each awaited operation. 🟢 source-confirmed

Although documented and annotated as test-only, the dependency typedefs, `AndroidSSLDependencies`, `initializeWith`, and `resetForTesting` are non-private Dart declarations. `lib/git2dart_binaries.dart` exports the whole helper library, so the seam is reachable through the package barrel; `@visibleForTesting` expresses lint intent but does not make it internal. 🔴 the feature's intended internal-only seam is not enforced by the current public namespace

### Extraction and state-transition algorithm

`_initialize(dependencies)` implements sequential process-local caching:

1. If `_initialized` is true and `_certPath` is non-null, return that path without invoking any dependency.
2. Await the temporary-directory operation and target `<temporary>/cacert.pem`.
3. Await the certificate-asset operation.
4. Await the writer operation.
5. Only after the writer completes, assign `_certPath`, set `_initialized = true`, and return the path.
6. If directory resolution, asset loading, or writing throws, emit `Android cert initialization failed.` to stderr and rethrow the original error. The helper does not assign success state in the failing attempt.

The two repository certificate copies are currently byte-identical (234,415 bytes; SHA-256 `9C0683BC1DB52A9C21BE6D592D283DBF8632DC242BE47522EB7201D882BD1CEB`). Only `assets/certs/cacert.pem` is declared in `pubspec.yaml` and addressed by the default loader; no helper read site targets `android/src/main/assets/certs/cacert.pem`. 🟢 current file/hash and source-reference evidence

### Idempotence, retry, and concurrency

- 🟢 Fresh host Flutter execution of `android_ssl_helper_test.dart` and `android_ssl_helper_diagnostic_test.dart` passed five cases. Injected behavior proves a successful attempt calls directory/load/write once, a second sequential call reuses the cached path, each of the three dependency failures leaves the completion fields empty, and a later injected attempt can succeed.
- 🟢 The success flag is written after the awaited writer, so a thrown writer cannot be mistaken for cached success. A dependency may still create or partially write the target before throwing; the helper tracks neither file integrity nor cleanup, and the retry overwrites the same pathname.
- 🟡 Sequential idempotence is proven only while the static path remains valid. The helper never checks that a cached temporary file still exists or still contains the bundled bytes.
- 🔴 There is no in-flight future or mutex. Concurrent first calls can pass the guard together, duplicate directory/load/write operations, race on the same path, and produce one failed Future even if another call has already committed shared success state.

### Runtime ordering and proof boundaries

The class documentation prescribes managed libgit2 initialization → certificate extraction → application of the returned path to libgit2 certificate-location options. The helper itself does not inspect `libgit2Runtime`, initialize it, require Android, or call `git_libgit2_opts_set_ssl_cert_locations`; its successful return means only that its selected writer completed. 🟢 source-confirmed responsibility boundary

- 🟢 **Host Flutter tests:** prove the injected state transitions and a host temporary-file writer chosen by the test. They bypass the default `rootBundle` and `path_provider` operations, do not assert written byte equality, and do not assert the stderr diagnostic.
- 🟡 **Android plan/source wiring:** `pubspec.yaml` declares the package CA asset and the default dependencies name the Flutter and platform operations, but declarations and host tests do not prove an Android asset lookup, device filesystem write, or Android HTTPS request.
- 🟡 **External consumer:** existing Reversa feature records identify a `git2dart` source sequence that initializes libgit2, awaits extraction, and applies the path. This pass is restricted to `git2dart_binaries`; feature 005 explicitly excludes uninspected neighboring-repository behavior, so that record is source-level context rather than current external execution evidence.
- 🔴 **Hosted/runtime proof:** no inspected same-run hosted result or Android device integration demonstrates the default dependency bundle, consumer invocation, native certificate-option application, or a successful HTTPS operation. Local green tests cannot close those boundaries.

## Module 5: Platform packaging

### Flutter metadata and registration shims

`pubspec.yaml` declares Android, iOS, Linux, macOS, and Windows as `ffiPlugin: true`. Android through macOS name `Git2dartBinariesPlugin`; Windows names the C API entry `Git2dartBinariesPluginCApi`. The package also declares the root CA asset. 🟢 source declaration

iOS, macOS, Linux, and Windows contain generated-style registration shims for a `git2dart_binaries` method channel and a `getPlatformVersion` response. These shims do not expose Git operations or load libgit2; the product path remains Dart FFI plus platform artifact packaging. Android's CMake file defines only a bundled-library list and does not compile the checked-in C++ no-op registrar. No Java/Kotlin class matching the declared Android `pluginClass` exists in the current tree. 🟢 source mapping; 🟡 whether Flutter's FFI-plugin tooling intentionally ignores that class declaration requires build execution

### Platform artifact map

| Platform | Declaration and expanded-package payload | Link/load contract | Executed route represented in current source |
|---|---|---|---|
| Android | Gradle namespace `com.dartgit.git2dart_binaries`, compile SDK 34, min SDK 21, Java 8, CMake/NDK; four ABI directories each require `libgit2.so`, `libssh2.so`, `libssl.so`, and `libcrypto.so` | Android CMake advertises only `libgit2.so`; the other libraries rely on conventional `jniLibs/<ABI>` APK packaging and native transitive resolution | Workflow builds four ABIs, verifies two libgit2 exports, and runs the integration suite only on an API-29 x86_64 emulator. 🟢 graph/source; 🔴 no inspected current hosted/device result |
| iOS | Four vendored XCFrameworks: libgit2, libssh2, libssl, libcrypto; each contains iphoneos-arm64 and iphonesimulator-arm64 slices; minimum iOS 12.0 | Static framework; podspec adds `z`/`iconv`, slice search paths, and `-force_load` for the libgit2 archive so process-symbol lookup can see it | Workflow builds an arm64 simulator app and runs integration tests on a simulator. No physical device or x86_64 simulator slice is declared. 🟢 graph/source; 🔴 no inspected current hosted/device result |
| macOS | Vendored `macos/libgit2.dylib`; minimum macOS 10.11 | Action rewrites its ID to `@rpath/libgit2.dylib`, requires libssh2/OpenSSL to be static, rejects Homebrew/dependency references, and exports required libgit2 symbols | Host job runs upstream and Flutter tests; dedicated test checks ID/dependencies/direct load only on macOS. Build is for the runner architecture, not a declared universal binary. 🟢 graph/source; 🔴 unavailable on this Windows pass |
| Linux | CMake bundles `linux/libgit2.so` and `linux/libssh2.so` | Runtime preloads libssh2 and then opens libgit2; build uses shared OpenSSL but the package inventory does not include libssl/libcrypto, so the target environment supplies compatible OpenSSL | Host job runs upstream/Flutter tests; publish job's disposable bundle compiles and loads only the Linux payload. 🟢 graph/source; 🔴 no inspected current hosted result |
| Windows | CMake bundles `libgit2.dll`, `libssh2.dll`, and every root-level `libcrypto*.dll`/`libssl*.dll` | Runtime preloads matched OpenSSL DLLs and libssh2 before libgit2; action checks libgit2 exports and explicitly loads a restored-cache DLL | Host job runs upstream/Flutter tests. A fresh local disposable bundle loaded cached 1.12.1 Windows payload, not current same-run output. 🟢 local fixture execution; 🔴 current hosted provenance not established |

All generated native payloads and `lib/src/bindings.dart` are absent from the current checkout. The tables therefore confirm declarations, recipes, and selected external-fixture execution, not current binary contents. 🟢 absence confirmed

### Feature-005 disposable consumer assembly

`assembleConsumerBundle(...)` performs the following algorithm:

1. Accept only the literal `bindingOrigin == 'same-run'`, require a binding file, and reject a binding physically inside the source checkout.
2. Require a payload directory and scan file basenames for the desktop platform's minimum inventory: Windows four library families, Linux libgit2/libssh2, or macOS libgit2.
3. Require an empty output root, copy package metadata plus `lib`, assets, and every platform directory while excluding checkout `lib/src/bindings.dart`.
4. Inject the supplied binding at `lib/src/bindings.dart`, overlay the selected payload under its platform directory, collect sorted relative payload paths, and write `bundle-proof.json` with schema `git2dart-consumer-bundle/v1`.

The assembler supports only Windows, Linux, and macOS payload validation. Its origin label is caller-supplied: it does not cryptographically bind inputs to a workflow run, infer that a binding came from the global cache, or require the payload root to be outside the checkout. Basename validation can accept a required file in a nested location; the later native-load process is what detects an unusable final layout. 🟢 algorithm; 🔴 provenance is not established by `BundleEvidence` alone

`runCleanConsumer(...)` requires the proof file, rejects imports containing `/src/`, creates a new temporary consumer with a path dependency on the bundle, runs offline dependency resolution, and verifies `.dart_tool/package_config.json` resolved exactly to the bundle root. It then runs one bounded subprocess mode with a package-root override and sanitized diagnostics:

- `compile-public-api`: public barrel import and managed lifecycle test;
- `load-native`: public barrel import and native initialize/shutdown;
- `abi-probe`: native pointer-width set/get/restore behavior;
- `loader-probe`: internal runtime import used to test loader success/failure;
- `android-plan`: internal runtime import that checks only the calculated no-fallback plan.

Timeout, invalid bundle, internal import, and loader failure have explicit result categories. The last two modes are diagnostic probes, not external-public-API consumer evidence. 🟢 behavior/source boundary

### Observed local behavior

- 🟢 Fresh Windows execution passed all four `package_consumer_bundle_test.dart` cases: origin/checkout guards, public compile versus internal-import rejection, native load, and ABI/loader/Android-plan probes.
- 🟡 Those tests defaulted to the globally cached `git2dart_binaries-1.12.1` binding and Windows payload, while the assembler defaulted their recorded origin to `same-run`. They prove the current assembler/runner working with that declared external fixture, not same-run production provenance.
- 🔴 A fresh combined run reached `runtime_loader_process_test.dart` but its first fresh-process case failed at Dart compilation because this checkout has no generated `lib/src/bindings.dart`; it never reached the intended terminal-loader diagnostic. The macOS-only dylib tests are skipped on this Windows host.

### Hosted, device, and publication boundaries

The workflow source downloads generated bindings and platform artifacts into host test jobs. Android x86_64 and iOS arm64-simulator create temporary Flutter apps that depend on the checkout and execute integration tests on emulators/simulators. The three desktop jobs run Flutter tests after same-run artifact download. The publish job downloads every platform, validates proof/inventory/provenance, assembles a separate Linux consumer bundle, runs public compile and native load, then performs `dart pub publish --dry-run`; credentialed publication is conditional on an exact push to `refs/heads/main`. 🟢 workflow graph/source

A previously recorded hosted run passed the predecessor workflow and `publish_package`, but it predates the current feature-005 consumer route. No same-run hosted result for the current checkout was inspected in this pass. Therefore source reachability is 🟢, historical delivery is 🟡 context, and current hosted artifact/publication success remains 🔴.

### Version and compatibility gaps

- 🟢 Pub metadata is 1.12.1, both Apple podspecs remain 1.11.2, and the Android Gradle module declares 1.0. No local rule synchronizes these three metadata planes.
- 🟡 Linux packaging relies on system OpenSSL compatibility rather than bundling the OpenSSL shared libraries built by the action; exact produced DT_NEEDED/SONAME values are not observable without the artifact.
- 🔴 Mobile integration covers one Android ABI and one iOS simulator slice; the other Android ABIs, physical iOS devices, and external published-package installation are not runtime-proven here.
- 🔴 The hosted disposable consumer validates only Linux. Platform host/device jobs use checkout path dependencies with downloaded artifacts rather than installing the exact final publication payload.

## Module 6: Native build and bindings generation

### Pinned inputs and generated ABI

The workflow supplies libgit2 1.9.6, libssh2 1.11.1, OpenSSL 3.0.15, and Flutter 3.44.0 to all relevant actions. Upstream source refs are `refs/tags/v1.9.6`, `refs/tags/libssh2-1.11.1`, and `refs/tags/openssl-3.0.15`. `ffigen.yaml` reads `headers/git2.h` plus `headers/git2/sys/*.h`, defines `GIT_EXPERIMENTAL_SHA256=ON`, and writes `lib/src/bindings.dart` as class `Libgit2`. 🟢 workflow/config source

The generated binding and copied headers are intentionally absent from the current working tree. Runtime source imports the absent file, so source-only subprocesses that compile the managed runtime can fail before reaching their intended loader branch. CI generation and artifact download, not a checked-in fallback, complete the build product. 🟢 current checkout observation

### Binding-generation state machine

`generate-bindings/action.yml` fingerprints runner OS/architecture, the first reported clang and CMake versions, and the declared Flutter version. Its exact cache key additionally includes libgit2 version and hashes of the action, manifest script, `ffigen.yaml`, and `pubspec.lock`.

- On a cache hit, `native_cache_manifest.py validate` must match platform `bindings`, runner ABI, libgit2/toolchain/source provenance, and the exact exported file set; only then is cached `bindings.dart` copied into `lib/src`.
- On miss or invalid cache, the action deletes the local cache root, checks out the pinned libgit2 tag, moves its include directory to `headers`, removes `git2/deprecated.h`, installs libclang, resolves Flutter dependencies, and runs ffigen with `--ignore-source-errors`.
- It copies the generated file into the cache export, creates a manifest, saves the cache, and always uploads one-day artifact `cache-bindings`.

The cache prefix says `native-v1-bindings` while the shared manifest schema is `native-v2`; these are independent identifiers but the difference is not explained locally. The fingerprint observes the preinstalled `clang`, while generation installs `libclang-dev` later; the exact installed libclang package version is not recorded except indirectly through runner state. 🟢 source fact; 🟡 reproducibility limitation

### Native cache manifest algorithms

`native_cache_manifest.py` models each export with exact metadata plus a deterministic `files` map:

- `safe_relative(value)` rejects absolute paths, any `..` component, and backslashes.
- `metadata(args)` requires one of two exclusive provenance shapes: `source-build + source_ref` or `approved-exception + exception_id`.
- `digest(path)` streams SHA-256 in 1 MiB blocks.
- `exported_files(root)` recursively sorts regular files and records relative POSIX path, digest, and byte size; an empty export is rejected.
- `create(args)` resolves the export root, enumerates it, and writes sorted/indented JSON plus a trailing newline.
- `validate(args)` requires the exact top-level field set, exact expected metadata, safe recorded paths, exact current-versus-recorded file names, and exact digest/size records. Expected failures return status 1.

Fresh feature-005 execution passed 11 focused tests: valid create/validate, seven corrupt/unreadable manifest classes, bindings cache-key facts, Android/iOS target fingerprint facts, and parsed OpenSSL provenance ordering. This is deterministic local CLI/graph evidence, not execution of a compiler, cache service, or hosted artifact transfer. 🟢 locally executed

The test matrix exercises the `validate` catch path but not create-side failures. A direct empty-export invocation reproduced a secondary `NameError`: `main()` catches `ValueError` and calls `sanitized_error(error, root, manifest_path)`, although `root` and `manifest_path` are not defined in that scope. The CLI therefore emits a traceback and leaks the absolute export path instead of its intended sanitized error. 🔴 executable defect/gap

Symlinks are followed by `Path.is_file()`/`open()` but are not rejected or resolved against the export root, and approved-exception metadata is not covered by the feature-005 fixture matrix. 🔴 unproved safety/provenance branches

### Common native build state machine

Android, iOS, Linux, macOS, and Windows actions follow a shared graph:

1. derive a toolchain fingerprint;
2. restore a version/recipe-keyed cache;
3. validate the restored export and provenance metadata with the manifest CLI;
4. if invalid or absent, clear local state and check out pinned OpenSSL, libssh2, and libgit2 sources;
5. compile the target-specific dependency graph with SSH, HTTPS/OpenSSL, and experimental SHA-256 enabled;
6. run upstream tests where configured, normalize/strip exports, and check `git_libgit2_init` plus `git_repository_open` on newly built libgit2;
7. create the manifest/provenance record, save the cache, include a provenance sidecar in the uploaded export, and upload a one-day artifact.

| Route | Fingerprint-specific inputs | Build/test/export behavior |
|---|---|---|
| Android | NDK r26d clang, CMake, host, API level; ABI also in cache key | Four independent ABIs; shared OpenSSL/libssh2/libgit2; upstream libgit2 tests disabled; new exports stripped and symbol-checked |
| iOS | Xcode SDK version, xcrun clang, CMake, SDK, deployment target, OpenSSL target; SDK/arch in key | Static libraries and headers for one slice; tests disabled; libgit2 archive symbol-checked; later workflow assembles four XCFrameworks |
| Linux | reported clang, CMake, OpenSSL input, runner arch | Builds shared OpenSSL/libssh2/libgit2; runs OpenSSL and libgit2 tests; exports libssh2/libgit2 and checks libgit2 symbols |
| macOS | macOS SDK, clang, CMake, runner arch | Static OpenSSL/libssh2 into libgit2 dylib; runs libgit2 tests even after cache restore; rewrites install ID and rejects unwanted dynamic references |
| Windows | MSVC file version, CMake, OpenSSL input, runner arch | Source-builds shared dependency DLLs; tests new libgit2 build; a valid restored cache gets a ctypes load check; new libgit2 exports checked with dumpbin |

Linux CMake is not explicitly told to use the clang version included in its fingerprint, and other output-affecting host tools such as installed Perl/Ninja/package revisions are not uniformly captured. 🟡 cache reproducibility is bounded to the recorded fingerprint and recipe hashes

### Cache-hit and provenance edge cases

Most actions use an exact key whose final component hashes that platform action and `native_cache_manifest.py`; Android/iOS also encode target inputs, and the feature-005 parsed tests confirm Android API level plus iOS deployment/OpenSSL target reach the fingerprint. Windows additionally supplies a restore prefix that omits the recipe hash. Because the manifest does not contain the action/script digest, a prefix-restored cache from an older recipe can pass metadata/content self-validation without proving it was produced by the current recipe. 🔴 Windows stale-recipe acceptance gap in the source graph

iOS creates its manifest over `$cache_root/export`, then copies that manifest into the same export as `provenance-<slice>.json` before saving. On the next restore, `validate` re-enumerates the export and sees the added sidecar absent from the recorded file set, so the cache is routed to rebuild. 🔴 source-confirmed self-invalidating iOS cache layout

macOS restore paths omit `/tmp/git2dart-macos-provenance.json` while save paths include it. This path-set asymmetry may alter cache-version/restoration behavior and has no focused test. 🟡 hosted cache-service outcome unproved

Export symbol/link checks run on newly built artifacts, not uniformly on every manifest-valid cache hit. Windows adds an explicit restored-library load; Linux/macOS rerun cached upstream test binaries; Android/iOS rely on manifest byte identity until later jobs. 🟢 source-confirmed

### Evidence boundaries

- 🟢 **Workflow/source graph:** pins, key expressions, conditions, source refs, build flags, export names, provenance-copy steps, and artifact uploads are directly inspectable.
- 🟢 **Local deterministic semantics:** the focused manifest and parsed-action tests passed; the create-error defect was reproduced without a native build.
- 🔴 **Actual toolchains:** this pass did not compile OpenSSL/libssh2/libgit2, run ffigen, inspect new binary exports, or exercise GitHub cache restore/save.
- 🟡 **Historical hosted context:** a prior pre-feature-005 workflow completed including `publish_package` after cache-hit provenance repair, but it does not establish the current action revisions or new behavior-proof routes.
- 🔴 **Current same-run artifacts/publication:** no current workflow run, artifact identity, cache-hit/miss execution, or publication was inspected. Definitions and local CLI tests cannot establish these outcomes.

## Module 7: Validation and release assembly

### Fourteen-job DAG and trigger policy

`build_package.yml` declares 14 jobs. Seven producer definitions generate bindings or native exports (with iOS and three non-x86_64 Android targets expanded as matrices), one job assembles iOS slices, five jobs execute platform tests, and `publish_package` performs release qualification and routing. `publish_package.needs` contains all five platform-test jobs plus `build_libgit2_android_other`, so it receives tested x86_64 Android transitively and waits directly for the three inventory-only Android ABIs. 🟢 parsed workflow graph

| Stage | Jobs and dependency behavior |
|---|---|
| Generation | `generate_bindings` plus Linux, macOS, iOS-slice, Windows, Android x86_64, and Android-other builders |
| Assembly | `assemble_libgit2_ios` waits for both matrix slices and emits the combined XCFramework artifact |
| Host tests | Linux, macOS, and Windows each wait for bindings plus their native artifact, inject both into the checkout, and run `flutter test -r expanded` |
| Mobile tests | iOS waits for assembled XCFrameworks; Android waits for x86_64; each creates a temporary Flutter application and runs the copied integration suite |
| Release | `publish_package` waits for the five test jobs and the remaining Android ABI matrix, then downloads every binding/native/proof artifact |

Pushes from every branch and pull requests targeting `main` enter validation. Only `push + refs/heads/main` enables the final publisher step; pull requests instead upload `release-package`, while feature-branch pushes validate but produce neither release artifact nor publication. Pull-request concurrency is cancel-in-progress; push concurrency is not. Fresh parsed execution reports 14 jobs and `main-publish=true`. 🟢 local parser execution

### Platform artifact injection and runtime routes

- Linux/macOS/Windows jobs inject `cache-bindings` plus the matching native artifact into repository paths and execute the repository Flutter suite. This proves the injected checkout when the hosted job runs, not an external package consumer.
- iOS creates an arm64 simulator application, installs the package by local path, builds an app bundle, boots a simulator, and executes the integration test. A 300-second timeout triggers one simulator reboot and a 600-second retry; other failures do not retry.
- Android creates an API-29 x86_64 emulator application and executes the integration suite with a 900-second command timeout. The other three Android ABIs are built/proved/inventoried but never device-executed.
- Every producer creates a `platform-proof-*` artifact. Proof creation is `continue-on-error` so evidence can still be uploaded for diagnosis, while aggregate qualification later rejects a failed or missing scope. 🟢 fail-closed DAG outcome; 🔴 current hosted execution not inspected

### Platform release proof creation

`platform_release_proof.py create` produces `platform-release-proof/v1`:

1. validate platform/ABI and resolve a payload directory;
2. enumerate the platform-specific expected native inventory, recording relative path, SHA-256, and size, plus missing/unexpected native candidates;
3. search payload/build-input bytes for intended libgit2, libssh2, and OpenSSL versions;
4. execute a platform-specific load/link check: ctypes for desktop, `readelf -d` for Android, or plist parsing plus `nm` for iOS;
5. for Apple payloads, record input/output tree hashes, xcrun clang/SDK text, and compiled version metadata;
6. emit JSON and Markdown with candidate `GITHUB_RUN_ID-GITHUB_RUN_ATTEMPT`, status, inventory, linkage, versions, optional attestation, and normalized failure codes.

Desktop ctypes proves that the selected library can load in a child process with its payload directory on the loader path. Android proof only proves dynamic-section readability on the build host. iOS proof parses metadata and runs `nm` on the first final static libgit2 slice; it does not assert required symbols or execute an app. Version discovery searches arbitrary payload strings and optional build input rather than calling dependency version APIs. 🟢 algorithm; 🟡 semantic strength varies by platform

`inventory()` and `tree_sha256()` follow regular-file symlinks without proving target containment. The record hashes the producer export, but release qualification never compares those hashes with the separately downloaded package payload. 🔴 payload-to-proof identity gap

### Aggregate same-run proof validation

`validate` expects exactly eight unique scopes: Linux, macOS, Windows, iOS, and four Android ABIs. It requires the exact top-level record keys, schema, `status=passed`, an empty failure list, an inventory object, safe paths for each `present` item, and no unknown/duplicate/missing scope.

The validator does not check candidate equality/current run ID, expected-versus-present completeness, linkage result, dependency version results, attestation contents, hashes, sizes, or platform-specific inventory. The feature fixture deliberately passes with empty inventory/versions and null attestation. Same-run origin therefore comes from `download-artifact` defaulting to the current workflow run, not from the proof record itself; the proof is not cryptographically joined to the release files. 🔴 aggregate semantic gap

### Release eligibility sequence

After downloading all artifacts, `publish_package` executes these ordered gates:

1. aggregate the eight platform proofs;
2. require non-empty bindings, desktop libraries, four libraries for each Android ABI, and four iOS XCFramework `Info.plist` files;
3. scan all `*provenance*.json` files, require schema `native-v2`, configured OpenSSL 3.0.15, non-empty file maps, and all five platforms;
4. for `approved-exception`, require a matching checked-in record, exact platform/ABI/version parity, non-empty infeasibility evidence and approver, literal `exact_parity=verified`, and an unexpired review date;
5. sum an explicit package-path list and reject more than 256 MiB;
6. assemble a Linux disposable bundle from the downloaded binding and payload, compile the public API, and load the native runtime;
7. hide the generated-binding checkout delta, then run `flutter pub get` and `dart pub publish --dry-run`.

Inventory validates existence/layout, not hashes or architectures. Provenance validation checks platform-set coverage but not every ABI/slice, source refs, recorded file hashes against payload bytes, exact exception-schema fields, or the checked-in JSON Schema. The custom size list is not derived from `dart pub publish`'s effective file set; the later dry run remains the authoritative local packaging check. 🔴/🟡 bounded release gates

### Disposable consumer and publication routing

The release job copies the downloaded binding outside the checkout and calls `package_consumer_bundle.dart assemble` with the downloaded Linux payload. It then executes `compile-public-api` and `load-native`. This is the only release-job disposable consumer and covers Linux only. `BundleEvidence` records a caller-supplied `same-run` label and file names; `runCleanConsumer` checks only that `bundle-proof.json` exists, not that its JSON is valid or matches the bundle. 🟢 workflow route; 🔴 self-attestation gap

Fresh local execution passed 22 focused feature-005 tests. The native consumer cases used the declared cached published 1.12.1 fixture on Windows while accepting the default `same-run` label; they prove clean package resolution and native behavior for that fixture, not current workflow provenance. Proof-CLI tests cover seven aggregate corruption families and create-side missing/unexpected/version/load/unavailable failures. Parser tests prove checked-in ordering/conditions, not GitHub service evaluation. 🟢 locally executed behavior; 🔴 current same-run provenance absent

Pull requests upload the expanded package for seven days. Main pushes invoke `k-paxian/dart-package-publisher@v.1.6.2` with pub.dev access/refresh secrets and `skipTests=true` after prior gates. Source declarations do not establish token scope, publisher-action integrity, pub.dev acceptance, or an externally observable release. A historical pre-feature-005 run completed the `publish_package` job, but it cannot establish the current proof gates or credentialed publication. 🟡 historical hosted context; 🔴 current publication proof

### Evidence boundaries

- 🟢 **Parsed workflow/source:** jobs, dependencies, artifact destinations, gate order, event conditions, and credentials references.
- 🟢 **Local deterministic execution:** 22 focused tests plus the 14-job parser entry point.
- 🟢 **Local external fixture:** cached 1.12.1 Windows bundle compiled, loaded, exercised ABI/loader routes, and failed closed for a missing override.
- 🔴 **Current hosted run:** no current artifact download, GitHub cache/artifact service, simulator/emulator, or five-platform matrix result was inspected.
- 🔴 **Credentialed publication:** no current pub.dev action execution, token authorization, package identity, or registry acceptance was observed.

## Module 8: Behavior-proving tests

### Feature-005 test surface

Feature 005 replaces the FR-01–FR-08 source-substring acceptance checks with observable fixtures, subprocesses, CLIs, analyzer AST facts, and parsed workflow facts. The test layer contains 22 Dart files: 19 `*_test.dart` entry points, `BehaviorProofFixture` support, and dedicated ABI/loader probe programs. The implementation record reports a full expanded-package run of 67 tests with three declared platform/environment skips; that run is historical feature-local evidence rather than a current hosted result. 🟢 checked-in inventory and execution record

The current source-only checkout intentionally lacks `lib/src/bindings.dart` and native payloads. A full native suite cannot be compiled here without modifying production paths or injecting the generated product. This pass instead freshly ran the safe parser/CLI/AST/TLS/disposable-fixture subset: 39/39 cases passed. The disposable consumer supplied its binding and Windows native payload from cached published package 1.12.1. 🟢 current local behavior; 🔴 not current same-run provenance

| Evidence tier | What it can establish | Current classification |
|---|---|---|
| Source text/declarations | presence, signatures, recipes, and out-of-scope textual invariants | 🟢 static fact; never behavior acceptance for W001–W006 |
| Parsed AST/YAML facts | structural ownership and modeled workflow edges independent of formatting | 🟢 local structural behavior; 🟡 simplified model |
| Injected deterministic state machine | Dart transition behavior without platform globals | 🟢 host execution |
| CLI/isolated subprocess fixture | exit classes, diagnostics, path safety, package resolution, and selected native behavior | 🟢 for the exact fixture/host |
| Expanded same-run hosted package | generated binding plus platform artifact identity and platform runtime | 🔴 no current run inspected |
| Credentialed publication/external repository | pub.dev acceptance and neighboring-consumer behavior | 🔴 outside current proof |

One source-text assertion remains in `error_api_test.dart` for the private error constructor. It is not mapped to FR-01–FR-08 or W001–W006, so its presence does not violate the replacement inventory; it remains static evidence only. 🟢 scope boundary

The other pre-existing entry points complement the watches: `libgit2_runtime_test.dart` executes 15 injected lifecycle cases, `libgit2_lifecycle_integration_test.dart` conditionally checks two-isolate native process counts, and `macos_dylib_packaging_test.dart` contains two macOS-only dylib/loader cases. The last three native cases require expanded platform artifacts and may skip outside their declared host; definitions or skips are not runtime success. 🟢 test inventory; 🟡 prerequisite-bound execution

### W001 — ABI value preservation

`abi_probe.dart` requires a 64-bit pointer width, reads the original mwindow file limit, submits `0x100000011` through the public `Libgit2Opts` size path, reads it back through `Pointer<Size>`, emits a JSON record, restores the original value in `finally`, and exits 2 on truncation. Errors emit only the error type and exit 1. `opts_bindings_integration_test.dart` serializes this in a fresh process, while the disposable bundle has an equivalent `abi-probe` mode. 🟢 executable algorithm

The direct integration file initializes `libgit2Runtime.bindings/options` while registering tests, before its test body checks `GIT2DART_BINARIES_PACKAGE_ROOT`. A checkout without generated bindings/native loadability can therefore fail before its intended `unavailable` classification. On a non-64-bit host the probe emits `unavailable` and the enclosing test returns successfully; green suite status alone does not mean the >32-bit round trip ran. The fresh Windows disposable fixture did execute the available route, but it used published 1.12.1 bytes. 🔴 availability/result aggregation gap; 🟡 fixture-native proof

### W002 — isolated loader behavior

`BehaviorProofFixture.runBounded` launches probes in disposable roots, collects both output streams, applies a 30-second default timeout, kills a timed-out child, and replaces its root in diagnostics. `runtime_loader_process_test.dart` clears common loader-path variables, proves a missing desktop root exits non-zero with both bare and package attempts represented, conditionally exercises a declared payload, and queries the Android no-fallback plan in a fresh process.

The positive probe reports the environment-supplied package root but not the actual library pathname or successful loader stage. `runCleanConsumer` also inherits the ambient native loader environment. A successful load can therefore be attributed to the bundle only when the missing-root negative case and host isolation assumptions hold; no handle-origin observation enforces it. Android plan execution is host-side mapping, not an Android loader process. 🟢 failure/plan behavior; 🔴 positive-origin and device gaps

### W003 — Android TLS retry state

Five fresh tests passed. Injected dependencies count directory, asset, and writer calls; success is cached only after the writer completes, the second call performs no dependency work, each of directory/asset/write failure leaves `isInitialized=false` and `certPath=null`, and a later invocation succeeds. The diagnostic test separately observes a typed directory failure and unchanged state. 🟢 deterministic state-transition proof

These tests bypass `rootBundle`, `path_provider`, Android storage, bundled certificate bytes, native SSL option application, and HTTPS. Concurrent first-call races and cached-file disappearance remain untested. 🔴 device/integration/concurrency gaps

### W004 — fail-closed artifact CLIs

`BehaviorProofFixture` creates guarded temporary paths, bounds subprocesses, sanitizes its own root, and deletes fixtures. The native manifest matrix passed one create/validate route plus seven independent metadata, file-list, digest/size, provenance, unsafe-path, malformed-JSON, and unreadable failures. The platform proof matrix passed one hand-written eight-scope aggregate plus seven corrupt aggregate families and one create-side failure-family scenario. 🟢 17 fresh CLI cases

The platform suite does not create a successful proof from a real loadable native payload; its passing aggregate records may contain empty inventory/versions and null attestation. The aggregate implementation accepts those omissions. Native manifest create-side error sanitization, symlink containment, and approved-exception behavior remain uncovered; a direct empty-export run in Module 6 reproduced a secondary `NameError`. 🔴 semantic and safety gaps

### W005 — disposable expanded-package consumer

The assembler rejects non-`same-run` origin labels, a binding lexically inside the checkout when such a file exists, missing desktop payload families, and non-empty output roots. It copies source while excluding checkout bindings, injects the supplied binding/payload, emits sorted relative evidence, then `runCleanConsumer` creates a separate package, performs offline resolution, verifies package-config points exactly at the bundle, and executes categorized bounded modes.

Four fresh tests passed public compilation/internal-import rejection, native load, ABI/loader probes, Android plan, and missing-override diagnostics against cached package 1.12.1. The tests pass the default caller label `same-run` to this global published fixture. `bundle-proof.json` is checked only for existence, the inside-checkout rejection branch is conditional on an absent generated file, required payload checks are basename-only, and native handle origin is not observed. 🟡 consumer behavior; 🔴 same-run/bundle-only identity not established locally

### W006 — architecture and workflow policy

`architecture_policy_facts.dart` requires resolved analyzer 8.2.0, parses every current `lib/**/*.dart` file, records runtime class declarations, native init/shutdown invocation names, and prohibited top-level lifecycle globals. Tests prove missing/mismatched analyzer metadata fails and all current transition facts are confined to `runtime.dart`. The analyzer is exactly declared in `dev_dependencies`, although `verifyAnalyzerResolution` itself proves resolution/version rather than direct-dependency origin. 🟢 local AST facts

`WorkflowPolicyFacts` parses 14 jobs, normalizes dependencies, rejects unknown needs/unsupported conditions, and models validation/publication reachability. Related fact tests require proof, inventory, provenance, size, consumer, dry-run, cache-fingerprint, and mobile target-input edges upstream of publication. These are executable parser oracles over the current YAML, not GitHub Actions execution, artifact transfer, secret authorization, or publisher behavior. 🟢 parsed graph; 🔴 hosted service boundary

The AST visitor is name-based syntactic analysis, not resolved element ownership: an unrelated same-named invocation can become a false positive, while aliases/dynamic dispatch could escape the rule. It also ignores parser diagnostics and uses the latest analyzer language feature set. 🔴 structural oracle completeness gap

### W001–W006 proof ladder and remaining authority

| Watch | Fresh/local result | Strongest established evidence | Still required |
|---|---|---|---|
| W001 ABI | bundled probe passed within the cached fixture suite | Windows 64-bit published-fixture native round trip | current generated binding + each supported hosted ABI |
| W002 loader | missing override, successful fixture load, and host Android plan passed | isolated Windows fixture subprocess | observed handle origin; Android/device and other desktops |
| W003 TLS | 5/5 passed | injected host state machine | default Android extraction, native option application, HTTPS |
| W004 CLIs | 17/17 passed | deterministic CLI corruption behavior | successful real platform-proof creation and unresolved safety branches |
| W005 consumer | 4/4 passed | clean package resolution/native behavior for cached 1.12.1 | current same-run artifact identity and external `git2dart` consumer |
| W006 policy | 13/13 parser/AST/fact cases passed | checked-in source/workflow structural model | current hosted DAG, secrets, publication and registry result |

A historical workflow before feature 005 completed all jobs including `publish_package`. It proves that predecessor revision's hosted gate, not the current W001–W006 implementation, same-run proof contents, cross-platform results, or credentialed registry publication. 🟡 historical context

## Cross-repository contract

| Contract | Local evidence | Classification |
|---|---|---|
| Consumer imports `package:git2dart_binaries` | README/product description only | 🟡 INFERRED |
| Consumer relies on exported generated `Libgit2` API | public export surface suggests this | 🟡 INFERRED |
| Consumer owns high-level Git entities and shutdown | absent locally | 🔴 GAP |
| Consumer performs Android certificate ordering | helper documentation suggests it | 🔴 GAP |
| Native ABI version is libgit2 1.9.6 | workflow and generation action | 🟢 CONFIRMED |
| Package distribution version is 1.12.1 | `pubspec.yaml` | 🟢 CONFIRMED |

No statement in this document treats the neighboring repository's behavior as confirmed without direct evidence.
