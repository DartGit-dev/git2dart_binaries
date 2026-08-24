# Native Build and Bindings Generation

## Overview
CI must generate version-keyed, manifest-validated Dart bindings and native libgit2 packages from pinned upstream tags for every supported platform. 🟢 The stronger claim of bit-for-bit reproducibility is not established. 🟡

## Responsibilities and Rules
- Pin libgit2 1.9.6, libssh2 1.11.1, Flutter 3.44.0, and the required OpenSSL version. Current Android/iOS/macOS actions accept the declared OpenSSL 3.0.15 input; current Windows CI instead discovers and fingerprints the runner-installed OpenSSL version. 🟢 workflow evidence. The target policy requires a source build of the explicitly pinned OpenSSL version for every platform, including Windows. If a path cannot build from source, release validation must require the exact same OpenSSL version as all other platforms; an arbitrary runner-installed Windows version is forbidden. 🟢 user-confirmed policy
- Generate bindings from the matching libgit2 headers with experimental SHA-256 enabled. 🟢
- Fingerprint toolchains, validate content manifests, and rebuild invalid cache entries. 🟢
- Verify essential libgit2 exports before publishing artifacts. 🟢

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| NBG-RF-01 | Generate `lib/src/bindings.dart` from pinned headers. | Must | Ffigen completes and uploads the binding artifact. | 🟢 |
| NBG-RF-02 | Build native outputs for all declared platform architectures. | Must | Each action uploads the expected normalized artifact set. | 🟢 |
| NBG-RF-03 | Accept cache hits only when manifest/toolchain/version checks pass. | Must | A mismatch forces rebuild. | 🟢 |
| NBG-RF-04 | Verify required symbols and upstream native tests where configured. | Must | Missing exports or test failures stop the action. | 🟢 |
| NBG-RF-05 | Ensure every release platform uses the explicitly pinned OpenSSL version. | Must | Every platform builds that exact version from source, or an approved non-source path proves exact version equality across all platform artifacts; any arbitrary runner-installed Windows version blocks release. | 🟢 user-confirmed policy |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| Reproducibility | Versions and toolchain fingerprints participate in cache keys. | composite actions | 🟢 |
| Integrity | Per-file SHA-256 and size are stored in native manifests. | `native_cache_manifest.py` | 🟢 |
| Supply chain | Upstream sources are fetched by tags, not immutable commit hashes. | checkout steps | 🟡 |
| Cross-platform dependency parity | OpenSSL is source-built from the explicitly pinned version for all platforms; a non-source exception still proves exact version equality before release. | user-confirmed release policy; current Windows action is noncompliant | 🟢 policy; 🟢 observed Windows divergence |

## Acceptance Scenarios
```gherkin
Given a valid matching native cache
When a platform build action runs
Then the manifest is verified and the cached artifact is exported

Given a cache mismatch
When the action validates it
Then the cache is rejected and pinned upstream sources are rebuilt
```

## MoSCoW
Must: pins, binding generation, native builds, cache validation, export verification, and exact cross-platform OpenSSL version parity. Should: source-build the pinned OpenSSL version on every platform. Could: SBOM/signatures. Won't claim: reproducibility of an unobserved CI run. 🟢 user-confirmed policy

## Code Traceability
`.github/actions/*/action.yml`, `.github/scripts/native_cache_manifest.py`, `ffigen.yaml`. 🟢
