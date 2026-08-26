# Onboarding: First validation run

## Goal

Establish which layer of evidence was obtained: source/AST, fixture CLI, host-native, assembled package consumer, or hosted CI.

## Prerequisites

1. Start from a clean working directory without a tracked `lib/src/bindings.dart`.
2. Have the pinned Flutter/Dart toolchain, Python, and the repository-resolved direct exact-pinned `analyzer` dev dependency available.
3. For host-native ABI/loader proof, provide a declared generated binding and matching native payload through the documented CI injection or explicit test fixture. Do not point tests at a system libgit2.
4. For Android integration evidence, use the CI/emulator job; local unit TLS seam tests do not claim Android HTTPS readiness.

## First-run sequence

1. Resolve dependencies and run the analyzer compatibility bootstrap. If `analyzer` is missing or does not expose the pinned expected API, stop on non-zero failure; do not skip AST validation.
2. Run the structural/AST and workflow-graph tests. Confirm that their report labels evidence as source/structure, not package runtime, and records the resolved analyzer version.
3. Verify the FR-01–FR-08 replacement ledger: every retired source-string assertion has an active executable, CLI, analyzer-AST, subprocess, or parsed-workflow replacement.
4. Run the manifest and platform-proof fixture suites. Verify both valid fixtures and each corrupt fixture have the expected non-success category.
5. Run the TLS dependency-injection tests. Confirm success, cache reuse, write/load failure, then successful retry; confirm no state remains cached after failure.
6. If matching host-native artifacts are present, run the ABI and loader subprocess probes. Confirm a >`4294967295` value is preserved exactly and the fallback consumer resolves the disposable package path.
7. In CI, ensure the generate-bindings and platform build outputs from the same run are injected into validation and assembly.
8. Inspect the assembled disposable package bundle. Run its minimal consumer in a clean process and confirm it imports only public `package:git2dart_binaries/...` paths and resolves the bundle rather than the checkout.
9. Inspect the release job result: same-run platform proof, inventory, provenance, size, dry-run, and consumer proof must all pass before publication can be eligible. On non-main push/PR, validation must run while the credential-bearing publication step stays unreachable.

## Interpreting outcomes

| Outcome | Meaning | Next action |
|---------|---------|-------------|
| `passed` host-native probe | Matching payload and selected behavior were observed locally. | Retain CI as authoritative package evidence. |
| `unavailable` host-native probe | Declared local prerequisite is absent. | Inject CI artifacts; do not convert to skip/pass. |
| missing/incompatible `analyzer` | AST gate cannot establish its pinned semantic model. | Fail non-zero; align the direct pinned dependency with the project SDK before rerunning. |
| CLI negative fixture non-zero | Fail-closed input rejection works. | Check expected diagnostic category. |
| Consumer imports checkout/system library | Evidence is invalid. | Fix isolation/package config before accepting the run. |
| CI validation runs but publication unreachable on PR/non-main push | Expected policy. | Verify graph facts and exact event/ref condition. |

## Safety checks

- Never commit generated bindings, native libraries, temporary bundles, manifests, proofs, or fixture payloads.
- Never redact a failure into a skip after prerequisites were declared present.
- Treat an external `git2dart` integration claim as unproven unless it is run from that repository under its own authorized validation workflow.
