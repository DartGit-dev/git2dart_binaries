# Platform Packaging, Technical Design

## Artifact Model
| Platform | Contract | Confidence |
|---|---|---|
| Android | `jniLibs/<ABI>/{libgit2,libssh2,libssl,libcrypto}.so`; CMake publishes libgit2 | 🟢 |
| iOS | four vendored XCFrameworks; force-load libgit2 device/simulator archives | 🟢 |
| Linux | bundled `libgit2.so`; package-local `libssh2.so` | 🟢 |
| macOS | vendored `libgit2.dylib` with `@rpath/libgit2.dylib` id | 🟢 |
| Windows | `libgit2.dll`, `libssh2.dll`, versioned `libcrypto*.dll`, `libssl*.dll` | 🟢 |

## Main Flow
1. `pubspec.yaml` registers FFI plugin targets and the certificate asset. 🟢
2. Platform build systems consume artifacts injected into platform directories. 🟢
3. CMake/podspec metadata carries artifacts into the application bundle. 🟢
4. Flutter tooling registers the platform shims, while Git behavior resolves native symbols through Dart FFI; a strict registration-before-loader ordering is not established locally. 🟢 surfaces; 🟡 ordering

## Alternatives and Decisions
- iOS uses `DynamicLibrary.process()` and therefore force-loads the static libgit2 archive. 🟢
- macOS embeds dependencies statically to avoid unbundled transitive dylibs. 🟢
- Windows uses filename globs for versioned OpenSSL runtimes. 🟢
- Native method-channel shims retain `getPlatformVersion`, but Git behavior uses FFI. 🟢

## State and Observability
Packaging holds no runtime domain state. Build-system inventories and platform tests are the evidence channels. 🟢

## Risks and Gaps
- 🟢 Apple podspec version 1.11.2 differs from pub version 1.12.1.
- 🔴 Current native artifacts are absent from the tracked checkout.
- 🟡 Duplicate CA copies may drift without an explicit synchronization check.
- 🔴 Signing, notarization, and platform security review are external controls.
