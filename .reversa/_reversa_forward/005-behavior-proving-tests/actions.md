# Actions: Behavior-proving package validation

> Identifier: `005-behavior-proving-tests`
> Date: `2026-08-25`
> Roadmap: `.reversa/_reversa_forward/005-behavior-proving-tests/roadmap.md`

## Resumo

| Metric | Value |
|---------|-------|
| Total actions | 34 |
| Parallelizable (`[//]`) | 15 |
| Longest dependency chain | 6 |

## Phase 1, Preparation

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-----------|--------------|-------------|--------------|-------------|--------|
| T001 | Add reusable temporary-root, sanitized-diagnostic, and bounded-subprocess fixture utilities for behavior-evidence tests. | - | `[//]` | `test/support/behavior_proof_fixture.dart` | 🟢 | `[X]` |
| T002 | Add a test-only native ABI probe fixture that observes a `size_t` value across the FFI boundary and declares unsupported payloads unavailable. | - | `[//]` | `test/fixtures/abi_probe/` | 🟢 | `[X]` |
| T003 | Extract Android TLS filesystem/asset operations behind an internal injectable dependency bundle while preserving `AndroidSSLHelper.initialize()` as the public static facade. | - | - | `lib/src/android_ssl_helper.dart` | 🟡 | `[X]` |
| T020 | Create the FR-01–FR-08 source-assertion replacement inventory, mapping every retired assertion to its executable, CLI, subprocess, analyzer-AST, or workflow-graph proof and retirement action. | - | `[//]` | `.reversa/_reversa_forward/005-behavior-proving-tests/source-assertion-replacement-inventory.md` | 🟢 | `[X]` |
| T021 | Add `analyzer` as a direct, exactly pinned `dev_dependency` compatible with the declared Dart SDK; do not rely on transitive resolution. | - | `[//]` | `pubspec.yaml` | 🟡 | `[X]` |

## Phase 2, Tests

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-----------|--------------|-------------|--------------|-------------|--------|
| T004 | Replace the host-dependent `ffi.Size` assertions with a serialized ABI-probe test that submits and restores a value above `0xffffffff`, asserting exact observation on declared 64-bit payloads or `unavailable`. | T001, T002 | - | `test/opts_bindings_integration_test.dart` | 🟢 | `[X]` |
| T005 | Add fresh-process loader cases for desktop package-root fallback success, bare-name terminal failure, and explicit Android no-fallback semantics using isolated package config and environment fixtures. | T001 | `[//]` | `test/runtime_loader_process_test.dart` | 🟢 | `[X]` |
| T006 | Add Android TLS state-transition tests proving successful initialization, cached reuse after success, failed write/load, and retry after failure through injected internal dependencies. | T003 | `[//]` | `test/android_ssl_helper_test.dart` | 🟡 | `[X]` |
| T007 | Add executable native-cache-manifest CLI fixture tests for one valid manifest and independent corrupt, unsafe-path, incomplete, mismatch, and unreadable cases, checking exit class and sanitized diagnostics. | T001 | `[//]` | `test/native_cache_manifest_cli_test.dart` | 🟢 | `[X]` |
| T008 | Replace platform-release-proof source-text assertions with valid and per-failure-family CLI fixtures that assert schema, exit class, fail-closed status, and path sanitization. | T001 | - | `test/platform_release_proof_test.dart` | 🟢 | `[X]` |
| T009 | Add an external-consumer fixture test that compiles only public `package:git2dart_binaries/...` imports and rejects internal imports with the contract category. | T001 | - | `test/package_consumer_bundle_test.dart` | 🟢 | `[X]` |
| T010 | Add analyzer AST/element policy tests for lifecycle ownership boundaries, reporting stable fact records instead of production-source regex matches. | T001, T015, T021, T022 | - | `test/architecture_policy_ast_test.dart` | 🟡 | `[X]` |
| T011 | Add parsed workflow graph/fact tests for validation reachability and publication being reachable only from a `push` to `refs/heads/main`. | T001, T014 | - | `test/workflow_policy_graph_test.dart` | 🟡 | `[X]` |
| T022 | Add an analyzer validation prerequisite that compares the resolved direct package version with the exact pin and exits non-zero for missing or incompatible resolution rather than skipping AST coverage. | T021 | - | `test/architecture_policy_ast_test.dart` | 🟢 | `[X]` |
| T023 | Retire the `ffi.VarArgs` source-string contract assertion and record its FR-01 replacement as the ABI probe that observes the >32-bit native value. | T004, T020 | - | `test/opts_bindings_source_contract_test.dart` | 🟢 | `[X]` |
| T024 | Retire loader diagnostic source-string assertions and record the isolated fallback and terminal-error subprocess cases as their FR-02 replacement. | T005, T020 | - | `test/loader_diagnostic_test.dart` | 🟢 | `[X]` |
| T025 | Retire native-cache action source-string assertions and record the valid/corrupt manifest CLI matrix as their FR-03 replacement. | T007, T020 | `[//]` | `test/native_cache_action_contract_test.dart` | 🟢 | `[X]` |
| T026 | Replace generated-binding cache-key text assertions with parsed workflow-fact evidence for the required cache inputs and provenance behavior. | T011, T014, T020 | `[//]` | `test/generate_bindings_cache_test.dart` | 🟡 | `[X]` |
| T027 | Retire platform-proof workflow substring and ordering assertions and replace them with parsed graph/fact assertions for same-run proof dependency and release-gate reachability. | T011, T014, T020 | `[//]` | `test/platform_release_proof_workflow_test.dart` | 🟡 | `[X]` |
| T028 | Retire release-inventory workflow substring assertions and replace them with parsed graph/fact assertions that keep native inventory and proof qualification upstream of publication eligibility. | T011, T014, T020 | `[//]` | `test/release_inventory_workflow_test.dart` | 🟡 | `[X]` |
| T029 | Retire Android TLS diagnostic source-string assertions and record injected success, cache, failure, and retry cases as their FR-06 replacement. | T006, T020 | `[//]` | `test/android_ssl_helper_diagnostic_test.dart` | 🟡 | `[X]` |
| T030 | Retire public lifecycle and raw-transition source scans and replace them with mandatory analyzer-AST ownership facts, retaining behavior tests only for the public API contract. | T010, T020 | - | `test/public_lifecycle_api_test.dart` | 🟢 | `[X]` |
| T033 | Replace OpenSSL provenance source-string assertions with the native-cache-manifest CLI fixture matrix for FR-03 and parsed workflow facts for FR-08 provenance/release-policy edges. | T007, T011, T014, T020 | `[//]` | `test/openssl_provenance_workflow_test.dart` | 🟢 | `[X]` |
| T034 | Replace Linux payload-path source-string assertions with disposable expanded-package assembly and clean consumer load-native evidence for the FR-05 Linux payload contract. | T016, T020 | `[//]` | `test/linux_packaging_test.dart` | 🟢 | `[X]` |

## Phase 3, Core

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-----------|--------------|-------------|--------------|-------------|--------|
| T012 | Implement the disposable expanded-package bundle assembler, requiring injected same-run `bindings.dart` and platform payload and recording only relative evidence metadata. | T001 | - | `tool/package_consumer_bundle.dart` | 🟢 | `[X]` |
| T013 | Implement the clean consumer subprocess runner for `compile-public-api` and `load-native`, enforcing unique roots, bounded timeout, bundle-only resolution, and categorized sanitized results. | T012 | - | `tool/package_consumer_bundle.dart` | 🟢 | `[X]` |
| T014 | Implement the workflow job/step dependency and condition parser used by the policy tests, failing closed on unsupported event/ref/needs/step-if expressions. | T001 | - | `tool/workflow_policy_facts.dart` | 🟡 | `[X]` |
| T015 | Implement the analyzer visitor and fact emitter used by the lifecycle-boundary policy tests. | T001, T021 | - | `tool/architecture_policy_facts.dart` | 🟡 | `[X]` |

## Phase 4, Integration

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-----------|--------------|-------------|--------------|-------------|--------|
| T016 | Wire the external-consumer test to the bundle assembler and runner, proving checkout, global-cache, system-library, and tracked-binding fallbacks are rejected. | T009, T013 | - | `test/package_consumer_bundle_test.dart` | 🟢 | `[X]` |
| T017 | Replace workflow policy source-string coverage with graph-fact coverage backed by the workflow parser. | T011, T014, T020 | - | `test/workflow_trigger_policy_test.dart` | 🟡 | `[X]` |
| T018 | Add the CI job/steps that download same-run generated bindings and native payload, assemble the disposable bundle, and run the clean consumer proof before publish dry-run/publication eligibility. | T012, T013, T016 | - | `.github/workflows/build_package.yml` | 🟢 | `[X]` |
| T031 | Replace platform cache/provenance text assertions with parsed workflow facts that prove required cache fingerprint and provenance edges without relying on literal YAML. | T011, T014, T020 | `[//]` | `test/mobile_cache_fingerprint_test.dart` | 🟡 | `[X]` |
| T032 | Replace native packaging source-string assertions with executable package-bundle or parsed workflow evidence, as classified by the replacement inventory, for the platform payload contract. | T016, T017, T020 | - | `test/windows_packaging_test.dart` | 🟡 | `[X]` |

## Phase 5, Polish

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-----------|--------------|-------------|--------------|-------------|--------|
| T019 | Document local-versus-CI evidence availability, unavailable outcomes, and the required focused proof commands without claiming host-independent native success. | T004, T005, T007, T008, T016, T017, T018 | - | `README.md` | 🟢 | `[X]` |

## Execution notes

<!-- Reserved for /reversa-coding to record warnings or observations that arise during execution. -->

- Local Windows native evidence used an explicitly injected expanded fixture package; same-run provenance remains a hosted-CI boundary.
- The checkout intentionally has no tracked `lib/src/bindings.dart`; consumer tests assemble current sources with an injected binding in a disposable bundle.
- Final local validation: `flutter analyze` reported no issues and `flutter test -j 1` passed 67 tests with 3 platform/environment skips.

## Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-25 | Initial version generated by `/reversa-to-do` | reversa |
