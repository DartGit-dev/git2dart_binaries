# Validation and Release Assembly, Implementation Tasks

## Prerequisites
- [ ] Every build action emits its declared artifact.
- [ ] Platform runners/emulators and pub credentials are configured externally.

## Tasks
- [ ] VRA-T-01, Recreate the build/test dependency DAG. Origin: `.github/workflows/build_package.yml:1`. Done when no release job can bypass required platforms. Confidence: 🟢
- [ ] VRA-T-02, Inject bindings/binaries into each validation environment. Origin: workflow test jobs. Done when tests exercise the expanded rather than source-only package. Confidence: 🟢
- [ ] VRA-T-03, Assemble and inventory the pub payload. Origin: workflow release job. Done when all platform artifacts occupy their manifest paths. Confidence: 🟢
- [ ] VRA-T-04, Enforce 256 MiB and pub dry-run gates. Origin: workflow release checks. Done when either failure blocks publication. Confidence: 🟢
- [ ] VRA-T-05, Preserve PR-upload/non-PR-publish branching. Origin: workflow step conditions. Done when event simulations cannot publish from PRs. Confidence: 🟢

## Test Tasks
- [ ] VRA-TT-01, Run the full matrix with fresh artifacts.
- [ ] VRA-TT-02, Inject missing, oversized, and invalid package cases.
- [ ] VRA-TT-03, Verify PR and push event behavior without using production credentials.
- [ ] VRA-TT-04, Add external `git2dart` compatibility validation.

## Suggested Order
Artifact contracts, platform tests, assembly, gates, event policy, then credentials. 🟢

## Pending Gaps
🔴 Confirm current remote run evidence, publication controls, and the two-repository compatibility matrix.
