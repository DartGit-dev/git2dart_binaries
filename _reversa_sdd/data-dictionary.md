# Data Dictionary

## Runtime structures

| Structure / value | Fields or shape | Ownership / lifecycle | Confidence |
|---|---|---|---|
| Platform target record | `name: String`, `subDir: String?` | ephemeral Dart record returned by `_platformTarget` | 🟢 CONFIRMED |
| `_library` | `DynamicLibrary` | lazy library-level value shared by the two exported globals within one Dart library instance | 🟢 CONFIRMED |
| `libgit2` | generated `Libgit2` binding object | lazy global whose initializer calls `git_libgit2_init()` before returning | 🟢 CONFIRMED |
| `libgit2Opts` | `Libgit2Opts` | process/global wrapper sharing `_library` | 🟢 CONFIRMED |
| `_cachedPackageRoot` | nullable absolute path | lazily populated and retained | 🟢 CONFIRMED |
| Package-config document | JSON object with `packages: List`; matching entry has `name` and `rootUri` | read-only parsed data, errors collapse to no result | 🟢 CONFIRMED |
| `LibGit2Error` | borrowed `Pointer<git_error>`; derived `message`, `errorClass` | native memory is not owned by wrapper | 🟢 CONFIRMED |
| Android TLS state | `_initialized: bool=false`, `_certPath: String?=null` | static process-local cache | 🟢 CONFIRMED |

## FFI argument structures

| Native/Dart type | Meaning | Caller obligation | Confidence |
|---|---|---|---|
| `Pointer<Int>` | output for integer option values | allocate and free; inspect return status | 🟢 CONFIRMED |
| `Pointer<Size>` | output for native `size_t` option values | allocate and free | 🟢 CONFIRMED |
| `Pointer<Char>` | UTF-8/native string input | allocate, null-terminate as required, free after call | 🟢 CONFIRMED |
| `Pointer<git_buf>` | libgit2-owned/filled string buffer | initialize, call, dispose with `git_buf_dispose`, free wrapper | 🟢 CONFIRMED |
| `Pointer<git_strarray>` | libgit2-filled string array | dispose with `git_strarray_dispose`, free wrapper | 🟢 CONFIRMED |
| `Pointer<Pointer<Char>>` + `len` | input extension array | caller constructs array and retains it for call duration | 🟢 CONFIRMED |
| `git_libgit2_opt_t` discriminator | selects the variadic option operation | must match the FFI signature used by the wrapper | 🟢 CONFIRMED |

## Native version set

| Field | Value | Source | Confidence |
|---|---:|---|---|
| libgit2 | 1.9.6 | workflow environment | 🟢 CONFIRMED |
| libssh2 | 1.11.1 | workflow environment | 🟢 CONFIRMED |
| OpenSSL | 3.0.15 | workflow environment | 🟢 CONFIRMED |
| Flutter CI | 3.44.0 | workflow environment | 🟢 CONFIRMED |
| pub package | 1.12.1 | `pubspec.yaml` | 🟢 CONFIRMED |
| Apple podspec metadata | 1.11.2 | iOS/macOS podspecs | 🟢 CONFIRMED |

## Artifact dictionary

| Artifact | Platform / location in expanded package | Link/load mode | Confidence |
|---|---|---|---|
| `bindings.dart` | `lib/src/bindings.dart` | generated Dart ABI; exported publicly | 🟢 recipe confirmed; 🔴 file absent |
| `libgit2.so` | Android `jniLibs/<ABI>` | Android loader | 🟢 recipe confirmed; 🔴 file absent |
| `libssl.so`, `libcrypto.so`, `libssh2.so` | Android `jniLibs/<ABI>` | transitive shared dependencies | 🟢 recipe confirmed; 🔴 files absent |
| four `*.xcframework` bundles | `ios/` | CocoaPods vendoring; libgit2 force-loaded | 🟢 recipe confirmed; 🔴 files absent |
| `libgit2.dylib` | `macos/` | vendored dylib with `@rpath` install name | 🟢 recipe confirmed; 🔴 file absent |
| `libgit2.so`, `libssh2.so` | `linux/` | direct and preload fallback | 🟢 recipe confirmed; 🔴 files absent |
| `libgit2.dll`, `libssh2.dll`, OpenSSL DLLs | `windows/` | direct and ordered preload fallback | 🟢 recipe confirmed; 🔴 files absent |
| `cacert.pem` | root Flutter assets and Android assets | extracted to Android temporary storage | 🟢 CONFIRMED |

## CI artifact names

| Name pattern | Contents |
|---|---|
| `cache-bindings` | generated `bindings.dart` |
| `cache-linux` | Linux export |
| `cache-macos` | macOS export |
| `cache-windows` | Windows export |
| `cache-ios-*` / `cache-ios` | slice exports / assembled XCFrameworks |
| `cache-android-<ABI>` | Android shared libraries for one ABI |
| `release-package` | expanded publishable package on pull requests |

## Configuration fields

| Field | Meaning | Default/pinned value |
|---|---|---|
| `ffiPlugin` | tells Flutter to build/bundle native FFI artifacts | `true` on all declared platforms |
| `GIT_EXPERIMENTAL_SHA256` / `EXPERIMENTAL_SHA256` | include/build experimental SHA-256 ABI | enabled |
| Android `compileSdkVersion` | compile API level | 34 |
| Android `minSdkVersion` | minimum supported API | 21 |
| package payload ceiling | expanded publish size limit | 256 MiB |
