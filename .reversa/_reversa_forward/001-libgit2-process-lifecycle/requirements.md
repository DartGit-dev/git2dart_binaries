# Requirements: Process-global libgit2 lifecycle ownership

> Identifier: `001-libgit2-process-lifecycle`
> Date: `2026-08-22`
> Reverse-extraction folder: `_reversa_sdd/`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP / QUESTION

## 1. Executive summary

`git2dart_binaries` must provide the public lifecycle contract for its loaded libgit2 runtime. The contract must replace unchecked and unbalanced initialization with one checked native lease per participating Dart isolate, reusable logical call and owner leases, deterministic cleanup, and guarded shutdown. `git2dart` remains a consumer of this API and must not load native libraries or own process-level runtime state. Backward compatibility with the existing lifecycle globals is not required; a breaking migration to one explicit managed surface is allowed.

## 2. Context from the legacy system

| Source | Relevant finding | Confidence |
|--------|------------------|------------|
| `_reversa_sdd/architecture.md#Component responsibilities` | The Native loader/lifecycle component owns platform selection, dependency preload, package-root fallback, and initialization. | 🟢 |
| `_reversa_sdd/native-loader-lifecycle/requirements.md#Responsibilities and Rules` | The current lazy binding initializes libgit2, while production shutdown ownership is undefined. | 🟢 |
| `_reversa_sdd/native-loader-lifecycle/design.md#Decisions, State, Observability` | Tests expose native reference-count semantics, but production ownership is absent. | 🟢 |
| `_reversa_sdd/domain.md#Loader and lifecycle rules` | Native loading is package-owned, platform-dependent, and fail-closed. | 🟢 |
| `_reversa_sdd/code-analysis.md#Module 2: Native loader and lifecycle` | `lib/src/util.dart` creates the shared library and calls `git_libgit2_init()` without validating or balancing the result. | 🟢 |
| `_reversa_sdd/inventory.md#Cross-repository boundary requiring validation` | Consumer behavior and two-repository integration require separate validation. | 🔴 |

Fresh read-only discovery additionally confirmed the committed consumer defect `BUG-20260817-ZC7X`: repeated public calls grew the observed process count `2 -> 3 -> 4`, and the former consumer-owned loader proposal is superseded.

## 3. Personas and usage scenarios

| Persona | Goal | Key scenario |
|---------|------|--------------|
| `git2dart` maintainer | Use libgit2 safely without owning loading or process state | Acquire logical call/owner protection from the binaries package and release it deterministically. |
| Direct `git2dart_binaries` consumer | Migrate to the managed lifecycle contract | Obtain bindings and options only through the runtime manager and never own an implicit native increment. |
| Test and release maintainer | Prove lifecycle behavior on supported platforms | Observe stable native counts, rollback, guarded shutdown, and independent isolate leases. |

## 4. New or changed business rules

1. **RN-01: Single package owner.** `git2dart_binaries` exclusively owns `DynamicLibrary`/process loading, platform paths and dependencies, native binding construction, process-level init/shutdown accounting, and isolate lifecycle semantics. 🟢
   - Legacy origin: `_reversa_sdd/architecture.md#Component responsibilities`
   - Type: changed
2. **RN-02: One native lease per isolate.** Each participating Dart isolate may contribute at most one package-owned `git_libgit2_init()` increment, regardless of logical call or owner count. 🟡
   - Legacy origin: `_reversa_sdd/native-loader-lifecycle/design.md#Decisions, State, Observability`
   - Type: new
3. **RN-03: Logical ownership is separate from native refcount.** Transient calls and persistent native owners pin the isolate runtime without calling native init/shutdown per operation. 🟡
   - Type: new
4. **RN-04: Cleanup proves safety.** An owner pin is released only after successful destruction, valid transfer, or rollback that accounts for any partially created owner. Cleanup failure retains the pin and blocks shutdown. 🟡
   - Type: new
5. **RN-05: Shutdown is isolate-scoped and terminal.** Successful shutdown releases only the calling isolate's native lease, is idempotent, and prevents transparent reinitialization in that isolate. A positive remaining native count is valid. 🟡
   - Type: new
6. **RN-06: Consumer boundary.** `git2dart` may coordinate its wrappers through the public lifecycle API but must not duplicate library discovery, loading, platform configuration, or process runtime state. 🟢
   - Type: changed
7. **RN-07: Breaking lifecycle migration is accepted.** Existing top-level lifecycle globals may be removed or replaced; the new managed contract takes precedence over source compatibility. 🟢
   - Type: changed

## 5. Functional requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|----|-------------|----------|----------------------|------------|
| RF-01 | Initialize through a checked package-owned path. | Must | A positive native result commits the lease; an error or unexpected result is surfaced and the attempted increment is rolled back without caching initialized state. | 🟢 |
| RF-02 | Reuse the isolate's native lease. | Must | Repeated binding access, options access, transient calls, and persistent owners do not add native init increments after the first successful initialization. | 🟢 |
| RF-03 | Expose logical transient-call protection. | Must | Consumer code can protect an ownerless native call; the pin is released in `finally`, including when the call throws. | 🟡 |
| RF-04 | Expose persistent owner protection. | Must | Every independently usable native owner can hold a pin until explicit release, fallback finalization, rollback, or transfer completes it. | 🟡 |
| RF-05 | Enforce exact-once cleanup. | Must | Explicit cleanup and finalizer cleanup share one stateful token; duplicate completion cannot invoke a destructor or decrement a pin twice. | 🟡 |
| RF-06 | Support construction rollback and ownership transfer. | Must | Failed construction destroys any registered partial owner before releasing its pin; transfer releases the pin without invoking the destructor. | 🟡 |
| RF-07 | Fail closed on cleanup failure. | Must | Synchronous cleanup failure is surfaced and retains the owner pin; finalizer failure is reported without throwing across the finalizer boundary and also retains the pin. | 🟡 |
| RF-08 | Provide guarded idempotent shutdown. | Must | Shutdown with live call/owner pins throws without native counter change; first successful shutdown calls native shutdown exactly once; later shutdown calls are no-ops returning the stored outcome. | 🟢 |
| RF-09 | Enforce terminal post-shutdown behavior. | Must | Managed native entry after successful shutdown throws synchronously and never creates a second configuration epoch. | 🟡 |
| RF-10 | Compose correctly across isolates and external owners. | Must | Two isolates contribute independent native increments; one isolate's shutdown leaves the other usable; a positive remaining count is accepted. | 🟡 |
| RF-11 | Replace legacy lifecycle globals with the managed API. | Must | Supported consumers obtain bindings/options through the runtime manager; `libgit2` and `libgit2Opts` need not remain source-compatible top-level globals. | 🟢 |
| RF-12 | Keep raw lifecycle calls outside the supported consumer contract. | Must | The runtime manager integrates the generated `git_libgit2_init()`/`git_libgit2_shutdown()` methods as its native transition mechanism. Package code outside that owner and the migrated consumer never call them directly. Their continued public presence on the generated `Libgit2` type is an accepted, unsupported escape hatch rather than a second managed ownership path. | 🟢 |
| RF-13 | Preserve platform bootstrap ordering. | Must | Android TLS/global-option configuration remains valid for the entire isolate epoch; no shutdown occurs while protected work or owners remain. | 🟡 |
| RF-14 | Expose deterministic diagnostics/test seams. | Should | Tests can inject native init/shutdown callbacks and observe state/counters without loading a real platform artifact; finalizer errors have a non-throwing diagnostic path. | 🟡 |
| RF-15 | Preserve gated delivery. | Must | Gate 1 adds RED tests in binaries; Gate 2 implements GREEN; a separate approved consumer gate adapts `git2dart`; final closure records a spec verdict. | 🟢 |

## 6. Non-functional requirements

| Type | Requirement | Evidence or rationale | Confidence |
|------|-------------|-----------------------|------------|
| Safety | Never shut down while a protected native call or independently usable owner remains live. | `_reversa_sdd/native-loader-lifecycle/requirements.md#Responsibilities and Rules` plus ZC7X debate evidence | 🟡 |
| Determinism | Native init/shutdown transitions and logical token completion must be synchronous and exactly-once. | Process-global reference count and finalizer nondeterminism | 🟡 |
| Migration | A breaking public-API migration is permitted, but supported platforms, loading fallback, and the non-lifecycle FFI capability required by `git2dart` must remain functional. | Confirmed user decision and `_reversa_sdd/architecture.md#Runtime path` | 🟢 |
| Isolation | Maintain isolate-local Dart bookkeeping while composing with the native process-global count. | Dart top-level state plus libgit2 global contract | 🟡 |
| Observability | Surface init, shutdown, cleanup, and finalizer failures with stable error categories and test-visible state. | Current lifecycle has only stderr loader diagnostics | 🟡 |
| Performance | Logical pins must not add native init/shutdown churn per API call. | ZC7X unbounded-growth root cause | 🟢 |
| Portability | Unit behavior must be platform-independent; native count tests must cover the available expanded artifacts and CI platforms. | `_reversa_sdd/native-loader-lifecycle/requirements.md#Non-Functional Requirements` | 🟢 |

## 7. Acceptance criteria

```gherkin
Scenario: First managed entry acquires one checked native lease
  Given an uninitialized isolate runtime
  When a managed binding or call is requested
  Then native initialization is called once and a positive result is retained

Scenario: Failed initialization rolls back
  Given native initialization returns an error after attempting an increment
  When managed initialization runs
  Then the error is surfaced, native shutdown is invoked once for rollback, and the runtime remains uninitialized or faulted rather than usable

Scenario: Repeated public use reuses the lease
  Given a successfully initialized isolate
  When multiple binding, option, call, and owner operations run
  Then the package-owned native initialization count does not increase again

Scenario: Live work rejects shutdown unchanged
  Given at least one transient call or persistent owner pin is live
  When shutdown is requested
  Then a StateError is thrown and no native shutdown occurs

Scenario: Cleanup is exact once
  Given one persistent owner with a registered destructor
  When explicit and fallback cleanup paths are both attempted
  Then the destructor runs at most once and the owner pin is decremented at most once

Scenario: Transfer does not destroy transferred ownership
  Given a provisional or committed persistent owner
  When ownership is transferred to a consuming native operation
  Then its logical pin is completed without invoking its destructor

Scenario: Isolates compose through the process count
  Given two isolates have initialized their runtimes
  When the first isolate shuts down
  Then its increment is released and the second isolate remains usable

Scenario: Shutdown is idempotent and terminal
  Given an isolate has completed successful shutdown
  When shutdown or managed entry is requested again
  Then repeated shutdown does not call native code and managed entry is rejected
```

## 8. MoSCoW priority

| Item | MoSCoW | Justification |
|------|--------|---------------|
| RF-01 through RF-13 | Must | They form the minimum coherent managed lifecycle and breaking migration contract. |
| RF-14 | Should | Deterministic RED/GREEN gates need injectable seams. |
| RF-15 | Must | The change is cross-package and high-risk. |

## 9. Clarifications

### Session 2026-08-22

- **Q:** Which package owns native loading and process runtime state? **A:** `git2dart_binaries` exclusively; `git2dart` consumes a public lifecycle API and owns no `DynamicLibrary`, path, dependency, or process-state logic.
- **Q:** Does every logical call/owner acquire a native increment? **A:** No. One checked native lease is owned per participating isolate; transient and persistent pins are isolate-local bookkeeping only.
- **Q:** What shutdown model applies? **A:** Guarded, synchronous, idempotent, calling-isolate scoped, and terminal after success. A positive native remaining count is valid because other isolates or external consumers may still own increments.
- **Q:** Is backward compatibility required? **A:** No. The feature may remove or replace `libgit2`, `libgit2Opts`, and other legacy lifecycle entry points. Supported access moves to the managed runtime API; generated non-lifecycle FFI capability is retained only where the migrated consumer actually requires it.
- **Q:** What is the delivery sequence? **A:** Proposal approval, binaries Gate 1 RED tests, binaries Gate 2 implementation/GREEN, separate `git2dart` consumer integration/regression gate, then final spec verdict and closure.
- **Q:** Must generated `git_libgit2_init()`/`git_libgit2_shutdown()` be hidden from the public `Libgit2` type? **A:** No. This is not a critical risk for this feature. Keep the ready packaged `bindings.dart` authoritative and unchanged in shape; integrate those methods inside the runtime manager, treat direct consumer calls as unsupported, and enforce the supported path in package and migrated-consumer tests/scans.

## 10. Gaps

- No unresolved requirement question remains. Exact Dart API names and signatures were approved with the proposal and locked by Gate 1 RED contracts.
- The generated binding type can technically bypass the manager. The user explicitly accepted this non-critical residual risk; this feature prevents the defect on the supported package and migrated-consumer path rather than making misuse impossible at the type level.
- Cross-platform native-count behavior remains to be proven by the gated tests; current conclusions are static plus Windows reproduction evidence.

## 11. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-22 | Initial version generated by `/reversa-requirements` | reversa |
| 2026-08-22 | Integrated scope, ownership, shutdown, compatibility, and gate answers through `/reversa-clarify` | reversa |
| 2026-08-22 | Clarified that backward compatibility is not required and authorized a breaking lifecycle API migration | reversa |
| 2026-08-22 | Accepted public raw lifecycle methods as a non-critical unsupported escape hatch and required the runtime manager to integrate their symmetric use | user |

## Emendas

### E001, 2026-08-24

O que muda: Generated bindings and platform-native artifacts are build/release outputs, not source-checkout inputs; tests that require an expanded package must state that precondition explicitly.
Motivo: Keep `lib/src/bindings.dart` and platform native artifacts, including Windows DLLs, out of checkout-test commit scope; build/release validation owns generating or obtaining them.
Arquivos previstos: `lib/src/bindings.dart`; platform-native artifacts, including `windows/libcrypto-3-x64.dll`, `windows/libssl-3-x64.dll`, `windows/libssh2.dll`, and `windows/libgit2.dll`; expanded-package tests.
