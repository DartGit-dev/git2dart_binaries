# Native Build and Bindings Generation

## Overview
CI must generate version-keyed, manifest-validated Dart bindings and native libgit2 packages from pinned upstream tags for every supported platform. 🟢 The stronger claim of bit-for-bit reproducibility is not established. 🟡

## Responsibilities and Rules
- Pin libgit2 1.9.6, libssh2 1.11.1, Flutter 3.44.0, and OpenSSL 3.0.15. The current Android/iOS/macOS and Windows actions consume the declared OpenSSL input; Windows checks out `openssl-${{ inputs.openssl_version }}` and source-builds it before libssh2/libgit2. 🟢 current workflow recipe. The confirmed policy still requires that exact source-built pin on every platform, or an approved non-source path with exact cross-platform parity. Current hosted outputs remain unobserved. 🟢 user-confirmed policy; 🔴 current payload evidence
- Generate bindings from the matching libgit2 headers with experimental SHA-256 enabled. 🟢
- Treat `lib/src/bindings.dart` as CI-owned generated output: it must never be tracked or committed, and every production consumer must use the binding artifact generated from pinned headers in the same CI workflow run. A local, stale, or source-controlled copy is not an allowed fallback. 🟢 user-confirmed policy
- Fingerprint toolchains, validate content manifests, and rebuild invalid cache entries. 🟢
- Verify essential libgit2 exports before publishing artifacts. 🟢

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| NBG-RF-01 | Generate `lib/src/bindings.dart` from pinned headers in CI. | Must | Ffigen completes in CI and uploads the binding artifact; the generated path is absent from the tracked source checkout. | 🟢 |
| NBG-RF-02 | Build native outputs for all declared platform architectures. | Must | Each action uploads the expected normalized artifact set. | 🟢 |
| NBG-RF-03 | Accept cache hits only when manifest/toolchain/version checks pass. | Must | A mismatch forces rebuild. | 🟢 |
| NBG-RF-04 | Verify required symbols and upstream native tests where configured. | Must | Missing exports or test failures stop the action. | 🟢 |
| NBG-RF-05 | Ensure every release platform uses the explicitly pinned OpenSSL version. | Must | Every platform builds that exact version from source, or an approved non-source path proves exact version equality across all platform artifacts; any arbitrary runner-installed Windows version blocks release. | 🟢 user-confirmed policy |
| NBG-RF-06 | Keep generated Dart bindings out of source control and make the same-run CI artifact authoritative. | Must | `lib/src/bindings.dart` is not tracked; CI rejects a committed copy; downstream validation and assembly download only the artifact produced by the generating job in that workflow run. | 🟢 user-confirmed policy |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| Reproducibility | Versions and toolchain fingerprints participate in cache keys. | composite actions | 🟢 |
| Integrity | Per-file SHA-256 and size are stored in native manifests. | `native_cache_manifest.py` | 🟢 |
| Supply chain | Upstream sources are fetched by tags, not immutable commit hashes. | checkout steps | 🟡 |
| Cross-platform dependency parity | OpenSSL is source-built from the explicitly pinned version for all platforms; a non-source exception still proves exact version equality before release. | user-confirmed release policy; current Windows action source-builds the declared pin | 🟢 source recipe; 🔴 current hosted parity |
| Source-control hygiene | Generated bindings never enter version control; the workflow artifact is the only production handoff. | user-confirmed policy; CI tracking and artifact-origin gates required | 🟢 user-confirmed policy |

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
Must: pins, CI-only untracked binding generation, same-run artifact consumption, native builds, cache validation, export verification, and exact cross-platform OpenSSL version parity. Should: source-build the pinned OpenSSL version on every platform. Could: SBOM/signatures. Won't claim: reproducibility of an unobserved CI run. 🟢 user-confirmed policy

## Code Traceability
`.github/actions/*/action.yml`, `.github/scripts/native_cache_manifest.py`, `ffigen.yaml`. 🟢

## 2026-08-25 Re-extraction Contract

- Cache acceptance requires exact schema, platform/ABI, versions, toolchain, provenance, safe relative file set, hashes, and sizes. 🟢
- W004 proves independent local CLI corruption classes only; a cache hit is never acceptance before validation. 🟢
- The current iOS action adds a provenance sidecar after manifest creation, so saved export contents can diverge from the manifest file set. 🟢 observed defect
- The Windows restore prefix omits the recipe hash while the manifest does not record it, so an older recipe cache may self-validate. 🟢 observed defect
- Create-side `ValueError` handling references undefined names and can mask the intended sanitized error with `NameError`. 🟢 observed defect
- Current hosted build outputs and same-run binding/native identity remain unobserved. 🔴
