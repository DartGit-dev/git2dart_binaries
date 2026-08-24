# Native Build and Bindings Generation, Technical Design

## Build Interfaces
Composite actions receive version/architecture inputs and upload named artifacts. The Python manifest utility records platform, architecture, versions, file sizes, and SHA-256 digests. 🟢

## Main Flow
1. Fingerprint the runner toolchain and form a version/content-aware cache key. 🟢
2. Restore and validate a prior manifest; continue on hit. 🟢
3. On miss, fetch pinned-tag upstream sources and compile dependencies/libgit2. 🟢
4. Run configured upstream tests, normalize filenames, and verify essential exports. 🟢
5. Generate a manifest, save cache, and upload the platform artifact. 🟢
6. Separately, checkout matching libgit2 headers and run ffigen for Dart bindings. 🟢

## Platform Variants
- Android builds four ABIs using NDK r26d. 🟢
- iOS produces device/simulator slices and XCFrameworks. 🟢
- macOS statically links libssh2/OpenSSL into the release dylib. 🟢
- Windows currently discovers the runner-installed OpenSSL, includes its detected version in the fingerprint/manifest, and copies matching runtime DLLs; it does not consume the workflow's 3.0.15 input. 🟢 workflow evidence. The required target is a source build of the explicitly pinned OpenSSL version; if source build is infeasible, release validation must prove exact parity with every other platform. 🟢 user-confirmed policy

## Decisions, State, Observability
The cache manifest is the durable build-state record; uploaded artifacts are the handoff boundary. Logs include versions, sizes, symbol checks, and cache decisions. 🟢

## Risks and Gaps
- 🔴 No built artifact or current workflow run was inspected locally.
- 🟡 Tag references can theoretically move upstream.
- 🔴 No SBOM, signing, or provenance-attestation step is configured.
- 🟢 ABI alignment depends on all paths retaining the same libgit2 pin.
- 🟢 The current Windows runner-installed OpenSSL path can diverge from the workflow pin and is release-ineligible under the confirmed policy until replaced or exact-version parity is verified.
