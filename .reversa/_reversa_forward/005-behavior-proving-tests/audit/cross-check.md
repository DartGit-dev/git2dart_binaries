# Audit cross-check: Behavior-proving package validation

> Date: `2026-08-25`  
> Feature: `005-behavior-proving-tests`  
> Requirements: [`../requirements.md`](../requirements.md)  
> Roadmap: [`../roadmap.md`](../roadmap.md)  
> Actions: [`../actions.md`](../actions.md)  
> Additional cross-check inputs: [`../data-delta.md`](../data-delta.md), [`../interfaces/package-consumer-bundle.md`](../interfaces/package-consumer-bundle.md), extraction `domain.md` and `architecture.md`, and the current repository source/test/workflow structure.

## Recommendation

**GO for `/reversa-coding`.**

The current 34-action plan covers FR-01-FR-08, all six Gherkin scenarios, the exhaustive source-assertion replacement scope, and the direct fail-closed analyzer prerequisite. No CRITICAL, HIGH, MEDIUM, or LOW inconsistency remains in the audited artifacts.

## Summary

| Severity | Count |
|----------|------:|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |

## Findings

| ID | Severity | Axis | Description | Where |
|----|----------|------|-------------|-------|
| - | - | - | No findings. | Requirements, roadmap, data delta, interface, actions, extraction documents, and current source/test/workflow structure |

## Former HIGH findings rechecked

### Source-string replacement coverage

- **Resolved:** T020 creates the exhaustive replacement inventory and T023-T034 explicitly retire or convert every current source reader mapped to FR-01-FR-08.
- T033 targets `test/openssl_provenance_workflow_test.dart` and maps its provenance assertions to the FR-03 native-cache CLI matrix plus FR-08 parsed workflow facts.
- T034 targets `test/linux_packaging_test.dart` and maps its payload-path assertions to FR-05 disposable expanded-package assembly and clean `load-native` consumer evidence.
- `test/error_api_test.dart` also reads production source, but its private native-error constructor contract is outside FR-01-FR-08 and therefore outside the clarified replacement scope.
- `test/macos_dylib_packaging_test.dart` uses executable file, `otool`, dynamic-loader, and subprocess observations rather than reading production source, so it is already behavior evidence.

### Analyzer dependency and fail-closed coverage

- **Resolved:** requirements clarification explicitly requires a direct pinned analyzer dependency and non-success on absence/incompatibility.
- D-06 carries the exact-pinned direct dependency and fail-closed decision.
- T021 adds `analyzer` as a direct exact-pinned `dev_dependency`.
- T022 checks resolved compatibility and exits non-zero instead of skipping.
- T015 depends on T021, and T010 depends on T015, T021, and T022; the former missing analyzer dependency/provider edges are closed.
- Data-delta invariant 6 and the interface validation boundary use the same fail-closed semantics.

### Workflow parser dependency and action summary

- **Resolved:** T011 now depends on T014; T014 exists, depends on T001, and the combined dependency graph is acyclic.
- **Resolved:** the summary declares 34 total actions and 15 parallelizable actions; the table contains exactly 34 action rows and exactly 15 `[//]` rows.

## Checks that passed

### Coverage

- FR-01 maps to D-01 and T002/T004/T023.
- FR-02 maps to D-02 and T005/T024.
- FR-03 maps to D-03 and T007/T025/T033.
- FR-04 maps to D-03 and T008/T027.
- FR-05 and the expanded-package contract map to D-04 and T009/T012/T013/T016/T018/T028/T032/T034.
- FR-06 maps to D-05 and T003/T006/T029 while retaining the public `AndroidSSLHelper.initialize()` facade.
- FR-07 maps to D-04 and T009/T016.
- FR-08 maps to D-06 and T010/T011/T014/T015/T017/T026-T028/T030/T031/T033.
- All six Gherkin scenarios have at least one roadmap decision and one planned action.
- The former traceability gap is closed by T020 plus the FR replacement ledger and data-delta invariant 7.

### Consistency

- Feature identifier `005-behavior-proving-tests` is consistent across the three primary artifacts.
- All cited FR, BR, decision, and action identifiers exist; no ghost identifier was found.
- Terminology for executable evidence, package fallback, expanded package, same-run bindings, analyzer gate, platform proof, and evidence classes is consistent across requirements, roadmap, data delta, interface, and actions.
- The expanded package consumer bundle interface is explicitly listed in the roadmap and implemented by planned actions T012, T013, T016, and T018.
- The interface boundary correctly excludes claims about the separate `git2dart` repository.

### Coherence with the extracted legacy system

- D-01 preserves the typed `size_t` option-path rule and adds runtime evidence rather than changing the public option contract.
- D-02 preserves desktop bare-name-first/package-fallback behavior, terminal diagnostics, and Android no-fallback behavior.
- D-03 preserves fail-closed cache-manifest and platform-proof validation.
- D-04 preserves CI-owned generated bindings and expanded-package release evidence.
- D-05 preserves cache-after-success and retry-after-failure Android TLS behavior.
- D-06 preserves main-only credential-bearing publication and broad validation reachability.
- All roadmap component names correspond to extracted architecture components: Global-options wrapper, Native loader/lifecycle, Android TLS bootstrap, Validation/release assembly, CI-owned generated bindings, and Platform-proof helper.
- No direct conflict with a green legacy rule was found.

### Actions sanity

- All 34 action IDs are unique.
- Every declared dependency points to an existing action ID.
- No dependency cycle was found.
- The `[//]` actions target distinct files/directories; no parallel target collision was found.
- The summary count of 15 parallelizable actions matches the 15 `[//]` rows.
- Shared targets are sequenced: T021 precedes T022/T015/T010, T012 precedes T013 for `tool/package_consumer_bundle.dart`, and T009 precedes T016 for `test/package_consumer_bundle_test.dart`.

## Evidence and verification boundaries

- This was a static, read-only audit of specifications, extraction documents, and the current repository structure. Only this `audit/cross-check.md` report was rewritten.
- No Dart/Flutter test, analyzer resolution, native ABI probe, consumer subprocess, Python fixture matrix, GitHub Actions run, or publication dry-run was executed; this report does not establish implementation, runtime, or hosted-CI success.
- Native artifacts and the external `git2dart` repository were not used as proof. Same-run artifact provenance, actual loader resolution, and cross-repository behavior remain implementation/CI verification boundaries.

> Type **CONTINUAR** to proceed according to the recommendation above.
