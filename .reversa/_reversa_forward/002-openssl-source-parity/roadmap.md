# Roadmap: OpenSSL source-build provenance parity

> Identifier: `002-openssl-source-parity`
> Date: `2026-08-24`
> Requirements: `.reversa/_reversa_forward/002-openssl-source-parity/requirements.md`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP

## 1. Approach summary

Replace the Windows composite action's runner discovery of OpenSSL with a checkout
of the release-configured `openssl-<version>` tag and an isolated MSVC source
build/install.  `libssh2`, `libgit2`, the exported DLLs, the cache key, and the
cache manifest will consume that installed tree and a declared `source-build`
provenance record.  The release workflow will pass the existing
`OPENSSL_VERSION` into Windows and qualify the Windows artifact from its
machine-readable evidence before it is eligible for package assembly.  A
non-source route is not a normal Windows path: it requires a checked-in,
reviewable exception and successful exact-version parity proof against every
participating release artifact.  Strict Git validation is deliberately excluded.

## 2. Applied principles

`.reversa/principles.md` does not exist, so this stage cannot evaluate any
project-local principle.  The following extracted invariants remain applied.

| Principle / invariant | How the feature relates | Status |
|---|---|---|
| Native build/binding generation uses pinned upstream inputs (`architecture.md#Architectural invariants`) | Windows changes from runner state to the configured OpenSSL input. | follows |
| Cache reuse requires manifest validation (`state-machines.md#Native artifact cache`) | Version and provenance become validated cache identity. | follows |
| Package artifact names must match loader/package declarations (`architecture.md#Architectural invariants`) | Windows still exports the versioned `libcrypto*.dll` / `libssl*.dll` set alongside `libssh2.dll` and `libgit2.dll`. | follows |
| Publication follows platform validation (`state-machines.md#Release qualification`) | Provenance/parity qualification is inserted before the release artifact is eligible. | follows |

## 3. Technical decisions

| ID | Decision | Rationale | Rejected alternatives | Confidence |
|---|---|---|---|---|
| D-01 | Add a required `openssl_version` input to `build-windows` and pass `OPENSSL_VERSION` from `build_package.yml`. | The workflow already declares 3.0.15, but Windows does not consume it. | Infer `openssl version` from the runner; duplicate a Windows-only constant. | 🟢 |
| D-02 | On a Windows cache miss, checkout `openssl/openssl` at `refs/tags/openssl-${openssl_version}`, configure the x64 MSVC shared-library target into an isolated install prefix, build, test, and use that prefix for both CMake consumers and exported DLLs. | OpenSSL 3.0.15 documents the Visual Studio `Configure` + `nmake` build path and `VC-WIN64A` target. | Discover an installed OpenSSL; download an opaque binary distribution. | 🟢 |
| D-03 | Make OpenSSL version plus provenance/source reference explicit native-manifest fields and validate them on cache restore. | The current manifest only records a version passed from the runner; it cannot distinguish source output from a runner installation. | Treat cache-key text or DLL filename as provenance. | 🟢 |
| D-04 | Publish a small per-platform provenance sidecar with each native artifact and add a release-qualification step that rejects absent/mismatched evidence. | The final assembler needs evidence after artifact download; cache-local manifests are not an artifact contract. | Rely on build logs; inspect runner state during publishing. | 🟡 |
| D-05 | Permit a non-source route only through a documented exception record that names platform, version, infeasibility, approver/evidence, and an exact-parity verdict over all released-platform sidecars. | It preserves the requested escape hatch without turning runner discovery into a silent fallback. | Automatic fallback to any installed OpenSSL; version-only assertion without provenance. | 🟡 |

## 4. Assumptions

`requirements.md` has no unresolved requirement marker; no planning premise is
adopted from an unresolved requirement.

## 5. Architectural delta

| Component | Legacy source file | Change type | Summary |
|---|---|---|---|
| Native build/binding generation | `.reversa/_reversa_sdd/architecture.md#Component responsibilities` | rule-changed | Windows joins the explicit OpenSSL source-input policy and emits provenance. |
| Artifact/cache fabric | `.reversa/_reversa_sdd/architecture.md#Container model` | changed-contract | Native cache manifests and uploaded platform artifacts carry version/provenance evidence. |
| Validation/release assembly | `.reversa/_reversa_sdd/architecture.md#Component responsibilities` | rule-changed | Release qualification rejects missing, arbitrary, mismatched, or unproven OpenSSL evidence. |
| Platform packaging | `.reversa/_reversa_sdd/code-analysis.md#Module 5: Platform packaging` | rule-changed | Windows runtime DLLs are copied from the source-built install prefix while retaining current loader-compatible names. |

Planned implementation touchpoints: `.github/actions/build-windows/action.yml`,
`.github/workflows/build_package.yml`, `.github/scripts/native_cache_manifest.py`,
the affected non-Windows native actions or release-sidecar producer, a new
checked-in exception/evidence format, and `test/windows_packaging_test.dart`
plus focused CI-source tests.  No runtime Dart loader API, package CMake glob,
Git policy, secrets, or publication credentials are changed.

## 6. Data-model delta

- Change summary: native cache/artifact evidence gains the configured OpenSSL
  version, provenance kind, source reference or approved exception identity, and
  a release-parity verdict.
- Full details: `.reversa/_reversa_forward/002-openssl-source-parity/data-delta.md`

## 7. External-contract delta

No HTTP, queue, gRPC, or GraphQL contract is affected.  The CI artifact sidecar
is an internal file handoff, specified in `data-delta.md`; therefore no
`interfaces/` directory is created.

## 8. Migration plan

1. Define the manifest/sidecar schema and a fail-closed exception record before
   changing cache reuse.
2. Add the pinned workflow input and implement the Windows OpenSSL source build
   in an isolated workspace/install prefix.
3. Rewire `libssh2`, `libgit2`, export packaging, cache validation, and tests to
   consume only the produced prefix.
4. Upload provenance sidecars, add release parity/exception validation, and
   prove both normal source-build acceptance and failure cases.
5. Run the Windows package-root loader proof against the expanded artifact to
   confirm that `libcrypto*.dll`, `libssl*.dll`, `libssh2.dll`, and `libgit2.dll`
   remain packaged correctly.

## 9. Risks and mitigations

| Risk | Impact | Probability | Mitigation |
|---|---|---|---|
| Windows runner lacks a usable Perl/nmake/MSVC environment for OpenSSL 3.0.15. | high | medium | Verify prerequisites early; use the documented exception only after recording the concrete infeasibility and exact parity proof. |
| Source-built DLL names/dependencies differ from the package loader expectations. | high | medium | Preserve versioned glob exports and run the plain-Dart package-root loader test on the assembled artifact. |
| Cache restores an old runner-derived artifact. | high | medium | Version cache schema/key and validate explicit provenance/source fields before reuse. |
| Other platform evidence is unavailable for fallback comparison. | high | low | Fail release qualification; never infer parity from a runner command or filename. |
| A source tag is mutable or a completed CI run is unavailable locally. | medium | low | Record the selected tag/reference in evidence; treat current-run/binary proof as a release validation task, not as static proof. |

## 10. Definition of done

- [ ] Windows consumes the workflow's explicit OpenSSL version and does not discover/copy runner OpenSSL in its normal path.
- [ ] The Windows source build is tested and its install prefix supplies both link inputs and packaged runtime DLLs.
- [ ] Cache manifests and artifact sidecars fail closed on version/provenance/source-reference mismatch.
- [ ] A non-source exception is documented, opt-in, and release-blocked unless exact parity with all platform sidecars is proven.
- [ ] Windows packaging tests retain version-agnostic DLL checks and an expanded-artifact plain-Dart loader proof.
- [ ] Release qualification reports the provenance/parity verdict before publication eligibility.
- [ ] Strict Git validation remains absent from the implementation and tests for this feature.

## 11. Change history

| Date | Change | Author |
|---|---|---|
| 2026-08-24 | Initial version generated by `/reversa-plan` | reversa |
