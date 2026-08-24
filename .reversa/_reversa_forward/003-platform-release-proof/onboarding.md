# First-run onboarding: Platform Release Artifact Proof

## Goal

Qualify an expanded CI release candidate using final-payload evidence. This is not a
request to rebuild native artifacts locally or to treat source declarations as proof.

## Before running

1. Choose and document the bounded retention duration for release/tag proof artifacts;
   it must be longer than the PR review window and permitted by Actions policy.
2. Confirm the workflow builds the existing Android ABI set: `x86_64`, `arm64-v8a`,
   `x86`, and `armeabi-v7a`.
3. Confirm the candidate has generated bindings and downloaded/assembled native
   artifacts. A source-only checkout is expected to report proof unavailable.
4. Do not add runner OpenSSL discovery, source-parity changes, Git-history checks,
   secrets, or absolute host paths to proof inputs or output.

## Expected workflow experience

1. Each platform build/package path calculates final artifact SHA-256 values and
   emits its `proof.json` and `proof.md` after final assembly.
2. Android produces one proof for each ABI. Windows, Linux, macOS, and iOS produce
   their platform/slice-scoped proofs using their own loader/linkage model.
3. iOS/macOS static-linkage output includes a build-time attestation of intended
   inputs, toolchain/SDK, every relevant final archive/XCFramework slice, SHA-256
   values, readable compiled metadata, and comparison result.
4. The release job downloads only same-run proof artifacts, validates schema,
   expected scope coverage, and all terminal results, then emits a concise aggregate
   reviewer summary without publishing it into the package or checkout.
5. Any missing artifact, loader/linkage failure, unreadable required version, digest
   mismatch, invalid report, or failing scope stops release qualification before
   release-package handoff/publish eligibility.

## What a reviewer checks

- There is exactly one readable JSON and Markdown proof for every expected platform
  and Android ABI, and their candidate/run identities agree.
- Inventory paths are relative and all required payload entries are present; unexpected
  payload is surfaced rather than silently ignored.
- Digests identify the final inspected files, not only build inputs.
- Intended and observed compiled versions are distinct. iOS/macOS attestation does
  not claim a runtime dependency version when only static linkage exists.
- The retained proof artifact follows the selected PR vs release/tag retention policy.
- The gate has not changed OpenSSL source-parity or strict Git-validation behavior.

## Expected failure handling

1. Stop at the affected platform/ABI proof; do not bypass it with a source tag,
   cache fingerprint, or warning-only status.
2. Use the JSON failure code and Markdown summary to locate the final relative path
   and probe that failed.
3. If static Apple version evidence is unreadable, keep the explicit `unavailable`
   evidence and fix the extractor/attestation; do not replace it with a claim from
   CMake, podspec, or source input.
4. If local artifacts are absent, report source-only package-proof unavailability;
   obtain a CI-expanded candidate for authoritative qualification.

## Success criteria

The candidate is eligible for PR handoff or publication only after every required
same-run platform/ABI proof passes and the reports are retrievable under the approved
retention policy.
