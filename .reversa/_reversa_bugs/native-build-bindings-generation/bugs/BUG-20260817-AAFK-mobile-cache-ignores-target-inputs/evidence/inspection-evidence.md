# Inspection Evidence

## Android

- `.github/actions/build-android/action.yml:16-17` declares `android_api_level`.
- Lines 172, 202, and 235 use the value in OpenSSL and CMake build flags.
- Lines 123-149 and 275-290 omit it from the fingerprint, cache key, and manifest metadata.

## iOS

- `.github/actions/build-ios/action.yml:19-28` declares `openssl_target` and `ios_deployment_target`.
- Lines 99-102 place both in the build environment; lines 114-190 use them in compilation and configuration.
- Lines 32-64 and 243-258 omit both from the fingerprint, cache key, and manifest metadata.

For each input, two requests that differ only by the target value share the same validated cache identity even though their requested binary configurations differ. The cross-configuration reuse path is statically confirmed.

