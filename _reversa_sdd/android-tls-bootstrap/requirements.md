# Android TLS Bootstrap

## Overview
Android runtime support must extract the packaged CA bundle to a filesystem path that can later be supplied to libgit2. 🟢

## Responsibilities and Rules
- The helper documentation requires use after libgit2 initialization and before applying certificate locations, but the helper does not enforce or observe that ordering. 🟡 intent; 🔴 consumer execution
- Load `packages/git2dart_binaries/assets/certs/cacert.pem`, write it to the temporary directory, flush, and return its path. 🟢
- Cache only a successfully written path; failures remain retryable. 🟢
- Extraction alone does not configure libgit2. 🟢

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| ATB-RF-01 | Extract the bundled CA bytes to `<temporary>/cacert.pem`. | Must | Output bytes equal the asset and the file exists. | 🟢 |
| ATB-RF-02 | Return the cached path after successful initialization. | Must | A second sequential call performs no additional asset write. | 🟢 |
| ATB-RF-03 | Rethrow failures without marking initialization complete. | Must | A later call can retry successfully. | 🟢 |
| ATB-RF-04 | Preserve post-libgit2-init ordering for native TLS configuration. | Must | Consumer flow applies the returned path only after init. | 🟡 |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| Integrity | Flush extracted bytes before reporting success. | `lib/src/android_ssl_helper.dart` | 🟢 |
| Idempotence | Sequential repeated calls reuse one cached path. | static state in helper | 🟢 |
| Concurrency | Concurrent first calls should not corrupt output. | no synchronization present | 🟡 |

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
Must: correct asset, flushed write, retry semantics, post-init ordering. Should: synchronized first call. Could: integrity metadata. Won't claim: HTTPS readiness without applying the path. 🟢

## Code Traceability
`lib/src/android_ssl_helper.dart`, `assets/certs/cacert.pem`, `pubspec.yaml`. 🟢
