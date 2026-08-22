# Native Build and Bindings Generation

## Overview
CI must generate version-keyed, manifest-validated Dart bindings and native libgit2 packages from pinned upstream tags for every supported platform. 🟢 The stronger claim of bit-for-bit reproducibility is not established. 🟡

## Responsibilities and Rules
- Pin libgit2 1.9.6, libssh2 1.11.1, and Flutter 3.44.0. Android/iOS/macOS use the declared OpenSSL 3.0.15 input; Windows instead discovers and fingerprints the runner-installed OpenSSL version. 🟢 [Codex cross-review]
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

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| Reproducibility | Versions and toolchain fingerprints participate in cache keys. | composite actions | 🟢 |
| Integrity | Per-file SHA-256 and size are stored in native manifests. | `native_cache_manifest.py` | 🟢 |
| Supply chain | Upstream sources are fetched by tags, not immutable commit hashes. | checkout steps | 🟡 |

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
Must: pins, binding generation, native builds, cache validation, export verification. Should: immutable upstream provenance. Could: SBOM/signatures. Won't claim: reproducibility of an unobserved CI run. 🔴

## Code Traceability
`.github/actions/*/action.yml`, `.github/scripts/native_cache_manifest.py`, `ffigen.yaml`. 🟢
