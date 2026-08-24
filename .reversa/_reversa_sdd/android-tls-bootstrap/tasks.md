# Android TLS Bootstrap, Implementation Tasks

## Prerequisites
- [ ] Declare the CA file as a Flutter package asset.
- [ ] Make Flutter bindings and the temporary-directory provider available.

## Tasks
- [ ] ATB-T-01, Package and address the CA asset. Origin: `pubspec.yaml:61`, `assets/certs/cacert.pem:1`. Done when package-qualified loading returns the expected bytes. Confidence: 🟢
- [ ] ATB-T-02, Implement extract/flush/cache behavior. Origin: `lib/src/android_ssl_helper.dart:68`. Done when sequential calls reuse a successfully written path. Confidence: 🟢
- [ ] ATB-T-03, Preserve retry-on-failure semantics. Origin: `lib/src/android_ssl_helper.dart:68`. Done when failed calls do not set cached success. Confidence: 🟢
- [ ] ATB-T-04, Preserve `git2dart`'s post-init Android certificate application. Origin: `F:\git2dart\lib\src\platform_specific.dart:15`, `F:\git2dart\lib\src\libgit2.dart:304`. Done when the platform bootstrap initializes libgit2, extracts the CA, then applies the extracted path. Confidence: 🟢 cross-repository source evidence
- [ ] ATB-T-05, Add one shared in-flight `PlatformSpecific.initialize()` operation for Android and iOS in `F:\git2dart`. Done when concurrent first callers await one operation and tests cover both platform branches. Confidence: 🟢 user-confirmed required policy; implementation not yet evidenced

## Test Tasks
- [ ] ATB-TT-01, Verify byte-for-byte extraction and sequential idempotence.
- [ ] ATB-TT-02, Inject an asset/write failure and verify retry.
- [ ] ATB-TT-03, Run an Android HTTPS integration test through libgit2.

## Suggested Order
Package asset, implement extraction, bind native option, then perform device HTTPS validation. 🟢

## Pending Gaps
🔴 Verify the required serialized platform bootstrap and Android HTTPS on a device/emulator. The current application call is located and documented. 🟢 cross-repository source evidence; 🟢 user-confirmed policy
