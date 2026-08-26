# Android TLS Bootstrap, Implementation Tasks

## Prerequisites
- [ ] Declare the CA file as a Flutter package asset.
- [ ] Make Flutter bindings and the temporary-directory provider available.

## Tasks
- [ ] ATB-T-01, Package and address the CA asset. Origin: `pubspec.yaml:61`, `assets/certs/cacert.pem:1`. Done when package-qualified loading returns the expected bytes. Confidence: 🟢
- [ ] ATB-T-02, Implement extract/flush/cache behavior. Origin: `lib/src/android_ssl_helper.dart:68`. Done when sequential calls reuse a successfully written path. Confidence: 🟢
- [ ] ATB-T-03, Preserve retry-on-failure semantics. Origin: `lib/src/android_ssl_helper.dart:68`. Done when failed calls do not set cached success. Confidence: 🟢
- [ ] ATB-T-04, Preserve post-init Android certificate application in the external consumer. Origin: user-confirmed integration contract; local helper documentation. Done when a current `git2dart` run initializes managed libgit2, extracts the CA, and applies the returned path. Confidence: 🟢 contract; 🔴 current proof.
- [ ] ATB-T-05, Add one shared in-flight platform-initialization operation for Android and iOS in the external `git2dart` consumer. Done when concurrent first callers await one operation and current tests cover both branches. Confidence: 🟢 user-confirmed required policy; 🔴 current external implementation evidence.

## Test Tasks
- [ ] ATB-TT-01, Verify byte-for-byte extraction and sequential idempotence.
- [ ] ATB-TT-02, Inject an asset/write failure and verify retry.
- [ ] ATB-TT-03, Run an Android HTTPS integration test through libgit2.

## Suggested Order
Package asset, implement extraction, bind native option, then perform device HTTPS validation. 🟢

## Pending Gaps
🔴 Verify the required serialized platform bootstrap and Android HTTPS on a device/emulator; the integration contract is user-confirmed, but the external application call was not re-inspected in this refresh. 🟢 policy; 🔴 current cross-repository proof

## 2026-08-25 Completion Gates

- [ ] ATB-T-06, Preserve cache-after-write and all retry edges. Origin: `lib/src/android_ssl_helper.dart:97`, `test/android_ssl_helper_test.dart:44`. Done when directory, asset, and write failure each retry successfully. Confidence: 🟢.
- [ ] ATB-T-07, Prove default Android dependencies and HTTPS. Origin: W003. Done when emulator/device evidence covers package asset, filesystem, native option, and network path. Confidence: 🔴.
- [ ] ATB-T-08, Serialize concurrent first attempts through the confirmed shared in-flight operation. Origin: `lib/src/android_ssl_helper.dart:96`. Done when Android and iOS concurrency tests observe one shared operation and all callers await it. Confidence: 🟢 confirmed target policy; 🔴 implementation evidence.
