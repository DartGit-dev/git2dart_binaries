# Android TLS Bootstrap

## Overview
Android runtime support extracts the packaged CA bundle in `git2dart_binaries`; applying the returned path through the external `git2dart` consumer is a user-confirmed contract not re-inspected in this extraction. 🟢 local extraction; 🔴 current cross-repository proof

## Responsibilities and Rules
- The external consumer must initialize managed libgit2, extract the certificate, then apply the returned path through the native certificate-location option. 🟢 confirmed contract; 🔴 current cross-repository execution
- Load `packages/git2dart_binaries/assets/certs/cacert.pem`, write it to the temporary directory, flush, and return its path. 🟢
- Cache only a successfully written path; failures remain retryable. 🟢
- Extraction alone does not configure libgit2. 🟢

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| ATB-RF-01 | Extract the bundled CA bytes to `<temporary>/cacert.pem`. | Must | Output bytes equal the asset and the file exists. | 🟢 |
| ATB-RF-02 | Return the cached path after successful initialization. | Must | A second sequential call performs no additional asset write. | 🟢 |
| ATB-RF-03 | Rethrow failures without marking initialization complete. | Must | A later call can retry successfully. | 🟢 |
| ATB-RF-04 | Preserve post-libgit2-init ordering for native TLS configuration in the external Android platform bootstrap. | Must | Managed libgit2 initialization precedes extraction and application of the returned path. | 🟢 contract; 🔴 current external execution |
| ATB-RF-05 | Serialize concurrent first `PlatformSpecific.initialize()` calls for Android and iOS through one shared in-flight operation. | Must | Exactly one first platform initialization runs; all concurrent callers await its result, and neither platform is claimed to have this behavior until it is implemented and tested. | 🟢 user-confirmed required policy; 🟢 current iOS path inspected |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| Integrity | Flush extracted bytes before reporting success. | `lib/src/android_ssl_helper.dart` | 🟢 |
| Idempotence | Sequential repeated calls reuse one cached path. | static state in helper | 🟢 |
| Concurrency | Concurrent first `PlatformSpecific.initialize()` calls must share one in-flight operation on Android and iOS; later callers await that operation. | The current Android helper has only static completion flags and the current iOS path has no shared in-flight guard. | 🟢 observed implementation; 🟢 user-confirmed required policy |

## Acceptance Scenarios
```gherkin
Given initialized libgit2 and a readable packaged CA asset
When AndroidSSLHelper.initialize is called
Then the CA file is flushed to temporary storage and its path is returned

Given asset loading fails
When initialization is retried after the asset becomes available
Then extraction is attempted again
```

## MoSCoW
Must: correct asset, flushed write, retry semantics, the observed post-init `git2dart` bootstrap sequence, and shared first-call serialization for both Android and iOS. Could: integrity metadata. Won't claim: live Android HTTPS proof without a device integration test. 🟢 observed flow; 🟢 user-confirmed concurrency policy

## Code Traceability
`lib/src/android_ssl_helper.dart`, `assets/certs/cacert.pem`, `android/src/main/assets/certs/cacert.pem`, `pubspec.yaml`, `test/android_ssl_helper_test.dart`. 🟢 local; 🔴 external `git2dart` files not inspected in this refresh

## 2026-08-25 Re-extraction Contract

- `_certPath` and `_initialized` are committed only after the injected/default write completes. 🟢
- Directory, asset, and write failures are rethrown and leave a first attempt retryable. 🟢
- Concurrent first attempts are not serialized by the current helper because no in-flight future or mutex is stored. 🟢
- W003 proves injected host transitions only; default Android storage/asset execution, native option application, HTTPS, and concurrency remain outside local authority. 🟢 local; 🔴 device/external outcome
