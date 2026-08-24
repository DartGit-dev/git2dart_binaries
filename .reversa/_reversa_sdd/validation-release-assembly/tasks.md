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
- [ ] VRA-T-06, Add version-release branch gates. Done when a new feature branch records its exact version in package/spec metadata, has a complete version-specific changelog entry, and verifies both before commit/push. Confidence: 🟢 user-confirmed policy
- [ ] VRA-T-07, Mark a version feature branch merge-eligible only after every platform test is green; after merge, require a separate green `main` CI/CD run before publication. Retain the distinction between policy and fresh CI proof. Confidence: 🟢 user-confirmed policy; 🔴 current CI evidence
- [ ] VRA-T-08, Preserve the configured GitHub Actions publication-control boundary, including the dedicated pub.dev token, without reading or exposing secrets. Done when the documented external configuration is distinguished from repository-visible evidence. Confidence: 🟢 user-confirmed external configuration; 🔴 repository-visible proof boundary
- [ ] VRA-T-09, Make `git2dart` GitHub Actions the single cross-repository release/build coordinator. Done when its feature CI accepts and records the selected `git2dart` + `git2dart_binaries` version pair, resolves that pair as used by the client, and blocks merge eligibility unless the full client integration suite is green. Confidence: 🟢 user-confirmed coordination policy; 🔴 current workflow/run evidence
- [ ] VRA-T-10, Route post-merge release eligibility through a separate green `main` run of the `git2dart` coordinator before the configured publication pipeline may publish. Done when feature-branch runs cannot publish and a failing/mismatched pair cannot pass either merge or publication gates. Confidence: 🟢 user-confirmed release and coordination policy; 🔴 current workflow/run evidence

## Test Tasks
- [ ] VRA-TT-01, Run the full matrix with fresh artifacts.
- [ ] VRA-TT-02, Inject missing, oversized, and invalid package cases.
- [ ] VRA-TT-03, Verify PR and push event behavior without using production credentials.
- [ ] VRA-TT-04, In `git2dart`, run the full integration suite for the exact selected `git2dart` + `git2dart_binaries` pair after client dependency resolution.
- [ ] VRA-TT-05, Exercise matched and mismatched version-pair inputs and feature-branch versus post-merge `main` gates without production credentials.

## Suggested Order
Artifact contracts, selected-pair coordination and client integration, platform tests, assembly, gates, event policy, then credentials. 🟢 user-confirmed coordination policy

## Pending Gaps
🔴 Confirm the current `git2dart` coordinator workflow/run, the selected-pair integration evidence, and the current version branch's actual all-platform green status. Publication controls are user-confirmed external configuration, not repository-visible proof. 🟢 user-confirmed configuration; 🟢 user-confirmed coordination policy; 🔴 repository-visible proof boundary
