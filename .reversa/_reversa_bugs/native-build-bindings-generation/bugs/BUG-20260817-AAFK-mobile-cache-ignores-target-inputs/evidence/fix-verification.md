# Fix verification — BUG-20260817-AAFK

## Root cause

Android API level, iOS deployment target, and iOS OpenSSL target change native
build configuration but were absent from the toolchain fingerprints. The
fingerprints are part of both cache keys and cache-manifest validation.

## Implemented change

The Android fingerprint now includes `android_api_level`. The iOS fingerprint
now includes `ios_deployment_target` and `openssl_target`.

## Regression evidence

On 2026-08-23, this command passed:

```text
flutter test -j 1 test/mobile_cache_fingerprint_test.dart
```

The test requires every target input in its corresponding fingerprint source.

## Boundary

The test is static. Hosted Android and iOS builds must still demonstrate a
cache miss after each target change and a valid later cache hit.
