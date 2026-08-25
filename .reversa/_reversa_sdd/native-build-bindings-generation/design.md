# Native Build and Bindings Generation, Technical Design

## Build Interfaces
Composite actions receive version/architecture inputs and upload named artifacts. The Python manifest utility records platform, architecture, versions, file sizes, and SHA-256 digests. 🟢

## Main Flow
1. Fingerprint the runner toolchain and form a version/content-aware cache key. 🟢
2. Restore and validate a prior manifest; continue on hit. 🟢
3. On miss, fetch pinned-tag upstream sources and compile dependencies/libgit2. 🟢
4. Run configured upstream tests, normalize filenames, and verify essential exports. 🟢
5. Generate a manifest, save cache, and upload the platform artifact. 🟢
6. Separately in CI, checkout matching libgit2 headers, run ffigen for `lib/src/bindings.dart`, and upload the generated file without tracking or committing it. 🟢
7. Downstream jobs download that same workflow run's binding artifact; they never read a source-controlled, stale, or local fallback copy. 🟢 user-confirmed policy

## Platform Variants
- Android builds four ABIs using NDK r26d. 🟢
- iOS produces device/simulator slices and XCFrameworks. 🟢
- macOS statically links libssh2/OpenSSL into the release dylib. 🟢
- Windows consumes the workflow's OpenSSL 3.0.15 input, checks out the matching tag, source-builds it, records that input in the fingerprint/manifest, and copies the resulting runtime DLLs. 🟢 current workflow recipe. Hosted artifact bytes and cross-platform parity still require current-run proof. 🔴

## Decisions, State, Observability
The cache manifest is the durable native build-state record; the uploaded binding artifact plus its workflow-run identity is the authoritative Dart ABI handoff. Logs include versions, sizes, symbol checks, cache decisions, and binding-artifact origin. A tracked `lib/src/bindings.dart` is a contract violation, not a fallback. 🟢 user-confirmed policy

## Risks and Gaps
- 🔴 No built artifact or current workflow run was inspected locally.
- 🟡 Tag references can theoretically move upstream.
- 🔴 No SBOM, signing, or provenance-attestation step is configured.
- 🟢 ABI alignment depends on all paths retaining the same libgit2 pin.
- 🟢 A committed binding or a consumer fallback to the source checkout can silently bypass the authoritative CI artifact and must fail closed. 🟢 user-confirmed policy
- 🟢 The current Windows recipe source-builds the workflow pin. 🔴 A current Windows artifact and five-platform parity record were not observed, so recipe compliance is not promoted to hosted release evidence.

## 2026-08-25 Cache and Provenance Boundary

S01 produces the generated ABI, S02 produces five-platform payloads, and S03 validates/cache-publishes normalized artifacts and provenance. 🟢

W004's local CLI matrix can prove deterministic manifest/proof parser behavior and sanitized failures; it cannot prove GitHub cache service behavior or the bytes emitted by a current producer. 🟢 local; 🔴 hosted producer

W005 requires downstream bundle injection from the same workflow run, but current record labels do not cryptographically join proof, payload, binding, and bundle. 🟢 graph; 🔴 identity join
