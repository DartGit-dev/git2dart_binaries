# Investigation: Platform Release Artifact Proof

## Local evidence

- `.github/workflows/build_package.yml` assembles the expanded payload in
  `publish_package`, already uploads intermediate native artifacts with one-day
  retention, retains PR `release-package` for seven days, then either dry-runs or
  publishes.
- `_reversa_sdd/code-analysis.md#Module 5: Platform packaging` establishes the
  non-uniform artifact and loader contracts: four Android ABIs; iOS XCFrameworks
  and process-image symbols; self-contained macOS dylib; Linux package-local
  `libssh2.so`; Windows libgit2/libssh2/OpenSSL DLL preloading.
- `_reversa_sdd/inventory.md#Native libraries and artifacts` confirms the tracked
  checkout lacks final native binaries and generated bindings. Consequently a local
  checkout cannot claim package proof.
- Existing build actions fingerprint toolchains and validate native cache manifests,
  but these are build-input evidence, not final-artifact compiled-version evidence.

## Chosen evidence model

For each final platform/ABI payload, produce:

1. `proof.json`: schema-versioned machine record.
2. `proof.md`: concise reviewer rendering of the same facts/failures.
3. On iOS/macOS where dependencies are static, a build-time attestation adjacent to
   the emitted final archive/XCFramework slice; the platform proof references it.

The record must include candidate/run identity; platform and ABI/architecture;
sanitized artifact-relative names; required/present/unexpected inventory; SHA-256
for every inspected final artifact; intended libgit2/libssh2/OpenSSL inputs;
toolchain/SDK identity; loader/linkage probe; observed version evidence and extractor;
comparison result; and terminal pass/fail/unavailable reason.

## Platform probe matrix

| Scope | Required payload / probe | Compiled-version evidence |
|---|---|---|
| Android x86_64, arm64-v8a, x86, armeabi-v7a | `libgit2.so`, `libssh2.so`, `libssl.so`, `libcrypto.so`; app-loader resolution from final ABI directory. | Readable ELF metadata/strings/symbol evidence for every delivered dependency; unavailable required evidence fails. |
| iOS device + simulator slices | Four XCFramework payloads and force-loaded/process-image symbol availability. | Attestation records tags, SDK/toolchain, per-slice/archive SHA-256 and readable archive/object metadata; absent required readable evidence fails. |
| macOS | Final `libgit2.dylib`; `otool`/`nm` self-containment and loader reachability. | Attestation records static libssh2/OpenSSL inputs and final dylib digest plus readable compiled metadata; unavailable required evidence fails. |
| Linux | `libgit2.so` plus package-local `libssh2.so`; actual fallback/preload reachability. | Readable ELF evidence for delivered/linkage-relevant dependencies; unavailable required evidence fails. |
| Windows | `libgit2.dll`, `libssh2.dll`, all matched OpenSSL runtime DLLs; actual preload/open order. | Readable PE version/string/export evidence for every delivered dependency; unavailable required evidence fails. |

## Alternatives considered

| Alternative | Decision | Why |
|---|---|---|
| Treat pinned source tags/toolchain fingerprint as compiled-version proof | Rejected | They identify inputs, not the final binary or static linkage result. |
| One aggregate report emitted by `publish_package` | Rejected | Loses independent platform/ABI diagnosis and makes absent per-slice proof harder to gate. |
| Commit reports into source/package | Rejected | Contradicts the clarified run-scoped location and risks stale, secret-bearing, or non-release evidence. |
| Reuse a single DLL loader test across all targets | Rejected | It conflicts with iOS process-image and macOS static-linkage contracts. |
| Warn on unreadable compiled version | Rejected | FR-04 requires fail-closed release qualification. |
| Add OpenSSL source-build parity or strict Git checks | Rejected | Separate feature responsibilities; this feature consumes proof, not dependency-origin or Git-history policy. |

## External references

1. [GitHub Actions: Store and share data with workflow artifacts](https://docs.github.com/en/actions/tutorials/store-and-share-data) — workflow artifacts can transfer data between jobs and define per-artifact retention.
2. [GitHub Actions: Downloading workflow artifacts](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/download-workflow-artifacts) — reviewer retrieval and retention boundary.

## Open questions carried to implementation

- The organization-approved numerical retention for release/tag proof artifacts is
  not in repository evidence. It must be chosen as a bounded CI policy before merge.
- Exact platform-native extractors for static archive/object version metadata must be
  selected during implementation, but their contract is fixed: record method/output,
  compare it, and fail if required evidence is unreadable.
