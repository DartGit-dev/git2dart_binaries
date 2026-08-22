# Native Build and Bindings Generation, Implementation Tasks

## Prerequisites
- [ ] CI runners provide required compilers, SDKs, and package managers.
- [ ] Upstream source access is available.

## Tasks
- [ ] NBG-T-01, Implement versioned binding generation. Origin: `.github/actions/generate-bindings/action.yml:1`. Done when generated Dart compiles against the public facade. Confidence: 🟢
- [ ] NBG-T-02, Implement five platform native builders. Origin: `.github/actions/build-*/action.yml:1`. Done when normalized artifacts exist for all required architectures. Confidence: 🟢
- [ ] NBG-T-02A, Preserve or replace Windows runner-discovered OpenSSL provenance. Origin: `.github/actions/build-windows/action.yml:18`. Done when the detected version is recorded and the desired pinning policy is explicit. Confidence: 🟢 current behavior; 🔴 desired policy
- [ ] NBG-T-03, Implement manifest create/verify operations. Origin: `.github/scripts/native_cache_manifest.py:1`. Done when changed bytes, versions, platform, or architecture invalidate reuse. Confidence: 🟢
- [ ] NBG-T-04, Verify tests and essential exports before upload. Origin: platform action verification steps. Done when missing symbols fail the build. Confidence: 🟢

## Test Tasks
- [ ] NBG-TT-01, Exercise valid, corrupt, and version-mismatched cache manifests.
- [ ] NBG-TT-02, Compile/analyze generated bindings.
- [ ] NBG-TT-03, Inspect each uploaded artifact's filenames, architecture, dependencies, and symbols.

## Suggested Order
Manifest tool, binding generator, dependency builders, libgit2 builders, verification, upload. 🟢

## Pending Gaps
🔴 Decide whether immutable source commits, SBOMs, signatures, and provenance attestations are release requirements.
