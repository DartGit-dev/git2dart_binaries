# Android TLS Bootstrap, Implementation Tasks

## Prerequisites
- [ ] Declare the CA file as a Flutter package asset.
- [ ] Make Flutter bindings and the temporary-directory provider available.

## Tasks
- [ ] ATB-T-01, Package and address the CA asset. Origin: `pubspec.yaml:61`, `assets/certs/cacert.pem:1`. Done when package-qualified loading returns the expected bytes. Confidence: 🟢
- [ ] ATB-T-02, Implement extract/flush/cache behavior. Origin: `lib/src/android_ssl_helper.dart:68`. Done when sequential calls reuse a successfully written path. Confidence: 🟢
- [ ] ATB-T-03, Preserve retry-on-failure semantics. Origin: `lib/src/android_ssl_helper.dart:68`. Done when failed calls do not set cached success. Confidence: 🟢
- [ ] ATB-T-04, Integrate post-init certificate application in the consumer. Origin: `lib/src/android_ssl_helper.dart:9`, `lib/src/opts_bindings.dart:241`. Done when Android HTTPS uses the extracted CA after libgit2 init. Confidence: 🔴

## Test Tasks
- [ ] ATB-TT-01, Verify byte-for-byte extraction and sequential idempotence.
- [ ] ATB-TT-02, Inject an asset/write failure and verify retry.
- [ ] ATB-TT-03, Run an Android HTTPS integration test through libgit2.

## Suggested Order
Package asset, implement extraction, bind native option, then perform device HTTPS validation. 🟢

## Pending Gaps
🔴 Locate and verify the application call in `F:\git2dart`; 🟡 decide concurrent initialization policy.
