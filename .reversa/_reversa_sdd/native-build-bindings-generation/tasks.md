# Native Build and Bindings Generation, Implementation Tasks

## Prerequisites
- [ ] CI runners provide required compilers, SDKs, and package managers.
- [ ] Upstream source access is available.

## Tasks
- [ ] NBG-T-01, Implement versioned CI binding generation. Origin: `.github/actions/generate-bindings/action.yml:1`. Done when CI generates the Dart ABI from pinned official headers, uploads it, and the generated Dart compiles against the public facade without a tracked source copy. Confidence: 🟢
- [ ] NBG-T-01A, Remove any tracked `lib/src/bindings.dart` and add a fail-closed repository/CI guard that rejects future commits of the generated path. Done when the path is untracked and only the same-run CI artifact can supply production bindings. Confidence: 🟢 user-confirmed policy
- [ ] NBG-T-02, Implement five platform native builders. Origin: `.github/actions/build-*/action.yml:1`. Done when normalized artifacts exist for all required architectures. Confidence: 🟢
- [ ] NBG-T-02A, Preserve and verify the Windows source build of the explicitly pinned OpenSSL version. Origin: `.github/actions/build-windows/action.yml:10`, `.github/actions/build-windows/action.yml:113`. Done when the current hosted Windows payload records the declared pin and release validation proves exact cross-platform parity. Confidence: 🟢 current source recipe; 🔴 current hosted payload
- [ ] NBG-T-03, Implement manifest create/verify operations. Origin: `.github/scripts/native_cache_manifest.py:1`. Done when changed bytes, versions, platform, or architecture invalidate reuse. Confidence: 🟢
- [ ] NBG-T-04, Verify tests and essential exports before upload. Origin: platform action verification steps. Done when missing symbols fail the build. Confidence: 🟢

## Test Tasks
- [ ] NBG-TT-01, Exercise valid, corrupt, and version-mismatched cache manifests.
- [ ] NBG-TT-02, Compile/analyze generated bindings.
- [ ] NBG-TT-02A, Assert that `lib/src/bindings.dart` is untracked and that every consumer uses the generating job's artifact from the same workflow run; fail on a source-checkout fallback.
- [ ] NBG-TT-03, Inspect each uploaded artifact's filenames, architecture, dependencies, and symbols.

## Suggested Order
Manifest tool, binding generator, dependency builders, libgit2 builders, verification, upload. 🟢

## Pending Gaps
🔴 Decide whether immutable source commits, SBOMs, signatures, and provenance attestations are release requirements.

## 2026-08-25 Completion Gates

- [ ] NBG-T-05, Repair manifest create-side error handling. Origin: `.github/scripts/native_cache_manifest.py:137`. Done when invalid/empty exports return the intended sanitized non-zero result without secondary `NameError`. Confidence: 🟢 observed defect.
- [ ] NBG-T-06, Make iOS export and manifest file sets identical. Origin: `.github/actions/build-ios/action.yml:240`. Done when provenance is included before manifest creation or separately excluded by explicit contract. Confidence: 🟢 observed defect.
- [ ] NBG-T-07, Bind Windows cache restoration to the exact recipe. Origin: `.github/actions/build-windows/action.yml:48`. Done when fallback cannot accept an older recipe through self-validation. Confidence: 🟢 observed defect.
- [ ] NBG-T-08, Close W004 on current producer artifacts and W005 on same-run injection. Origin: workflow/actions and proof tools. Done when hosted artifacts preserve a verifiable identity join. Confidence: 🔴 current proof.
