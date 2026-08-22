# Actions: Process-global libgit2 lifecycle ownership

> Identifier: `001-libgit2-process-lifecycle`
> Date: `2026-08-22`
> Roadmap: `_reversa_forward/001-libgit2-process-lifecycle/roadmap.md`
> Gate status: Gate 1 RED and Gate 2 binaries GREEN completed on `2026-08-22`; separate consumer gate is not authorized

## Summary

| Metric | Value |
|--------|-------|
| Total actions | 17 |
| Parallelizable (`[//]`) | 6 |
| Longest dependency chain | 11 |

## Phase 1, Preparation

| ID | Description | Dependencies | Parallelism | Primary target | Confidence | Status |
|----|-------------|--------------|-------------|----------------|------------|--------|
| T001 | Create the Gate 1 test-only runtime fixture and encode the approved breaking API imports without changing `lib/`. | - | - | `test/libgit2_runtime_test.dart` | 🟢 | [X] |

## Phase 2, Tests

| ID | Description | Dependencies | Parallelism | Primary target | Confidence | Status |
|----|-------------|--------------|-------------|----------------|------------|--------|
| T002 | Add RED cases for checked initialization, uncached failure, and exactly-one native rollback. | T001 | - | `test/libgit2_runtime_test.dart` | 🟢 | [X] |
| T003 | Add RED cases proving repeated calls reuse one isolate native lease and transient pins release in `finally`. | T002 | - | `test/libgit2_runtime_test.dart` | 🟡 | [X] |
| T004 | Add RED cases for owner exact-once cleanup, rollback, transfer, and cleanup-failure pin retention. | T003 | - | `test/libgit2_runtime_test.dart` | 🟡 | [X] |
| T005 | Add RED cases for guarded, idempotent, terminal, and faulted shutdown states. | T004 | - | `test/libgit2_runtime_test.dart` | 🟡 | [X] |
| T006 | Add a RED native integration contract for stable counts and independent leases in two isolates. | T001 | `[//]` | `test/libgit2_lifecycle_integration_test.dart` | 🟡 | [X] |
| T007 | Add a RED public-surface contract proving supported bindings/options access is available only through the runtime manager, with no legacy-global requirement. | T001 | `[//]` | `test/public_lifecycle_api_test.dart` | 🟢 | [X] |

## Phase 3, Core

| ID | Description | Dependencies | Parallelism | Primary target | Confidence | Status |
|----|-------------|--------------|-------------|----------------|------------|--------|
| T008 | Implement the isolate-local runtime state machine, checked init, single rollback, transient call guard, and guarded terminal shutdown. | T005, T006, T007 | - | `lib/src/runtime.dart` | 🟡 | [X] |
| T009 | Implement the persistent owner lease state machine with destructor binding, explicit/finalizer release, rollback, transfer, and fail-closed cleanup errors. | T008 | - | `lib/src/runtime.dart` | 🟡 | [X] |
| T010 | Add the stable lifecycle exception and diagnostic payload for init, rollback, shutdown, and finalizer failures. | T005, T006, T007 | `[//]` | `lib/src/error.dart` | 🟡 | [X] |
| T011 | Connect the existing platform loader to the runtime manager, use the ready generated `Libgit2.git_libgit2_init/shutdown` pair for accounted native transitions, and remove the unchecked initializer plus legacy lifecycle globals. | T009, T010 | - | `lib/src/util.dart` | 🟢 | [X] |
| T012 | Export the approved runtime/lease contract as the supported lifecycle coordination surface while retaining the generated `Libgit2` ABI shape. | T011 | - | `lib/git2dart_binaries.dart` | 🟢 | [X] |

## Phase 4, Integration

| ID | Description | Dependencies | Parallelism | Primary target | Confidence | Status |
|----|-------------|--------------|-------------|----------------|------------|--------|
| T013 | Adapt the existing options integration test to checked managed runtime access and exact isolate-owned shutdown. | T012 | - | `test/opts_bindings_integration_test.dart` | 🟢 | [X] |
| T014 | Adapt Windows packaging lifecycle assertions to the managed count delta without manual over-balancing. | T012 | `[//]` | `test/windows_packaging_test.dart` | 🟢 | [X] |
| T015 | Adapt macOS packaging lifecycle assertions to the managed count delta without manual over-balancing. | T012 | `[//]` | `test/macos_dylib_packaging_test.dart` | 🟢 | [X] |

## Phase 5, Polish

| ID | Description | Dependencies | Parallelism | Primary target | Confidence | Status |
|----|-------------|--------------|-------------|----------------|------------|--------|
| T016 | Document the breaking runtime API, terminal shutdown contract, unsupported raw lifecycle escape hatch, and consumer migration boundary. | T012 | `[//]` | `README.md` | 🟡 | [X] |
| T017 | Generate the feature regression watch after binaries GREEN evidence is complete and before the separate consumer gate. | T013, T014, T015, T016 | - | `_reversa_forward/001-libgit2-process-lifecycle/regression-watch.md` | 🟡 | [X] |

## Execution notes

- **Gate 1 boundary:** T001-T007 were explicitly approved and completed test-only. RED is recorded in `gate-1-red.md`; `lib/` remained unchanged.
- **Gate 2 result:** T008-T017 completed after explicit `APPROVE GATE 2`; `dart analyze` is clean and the final Windows run is GREEN with 33 passed and 2 macOS-only skipped tests.
- **Accepted amendment:** the ready packaged generated bindings remain the decision and development base. Their raw init/shutdown methods are integrated by the runtime manager and remain an unsupported public escape hatch; no Gate 1 test adjustment is required.
- The later `git2dart` ownership inventory and consumer migration are deliberately excluded from this binaries action list. They require a separate consumer integration/regression gate and their own scoped actions after binaries GREEN.
- No commit or push action is included; both remain separately authorized operations.

## Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-22 | Initial action decomposition generated by `/reversa-to-do` after proposal approval | reversa |
| 2026-08-22 | T001-T007 completed under explicit Gate 1 approval; expected RED recorded and Gate 2 left closed | reversa |
| 2026-08-22 | Amended T011/T012/T016 after the user accepted the generated raw-method escape hatch as a non-critical residual risk | reversa |
| 2026-08-22 | T008-T017 completed under explicit Gate 2 approval; binaries GREEN recorded and consumer gate left closed | reversa |
