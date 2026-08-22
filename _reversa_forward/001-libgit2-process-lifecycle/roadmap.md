# Roadmap: Process-global libgit2 lifecycle ownership

> Identifier: `001-libgit2-process-lifecycle`
> Date: `2026-08-22`
> Requirements: `_reversa_forward/001-libgit2-process-lifecycle/requirements.md`
> Status: Gate 1 RED and Gate 2 binaries GREEN completed on `2026-08-22`; separate consumer gate awaiting approval
> Decision confidence: 🟢 CONFIRMED by current code, authoritative upstream contract, or explicit user approval; 🟡 INFERRED; 🔴 GAP
> Implementation proof: BINARIES GREEN CLAIMED by analyzer, unit, native two-isolate, options, and Windows loader evidence; consumer integration remains unproved

## 1. Approach summary

Replace the unchecked initializer in `lib/src/util.dart` with one isolate-local runtime manager that owns the existing library loader, generated binding object, and exactly one checked native initialization increment. Logical transient-call and persistent-owner pins protect active work without changing the native counter. Successful shutdown is guarded by zero live pins, releases the calling isolate's increment once, and terminates that isolate's runtime epoch. Backward compatibility is not required: the legacy `libgit2` and `libgit2Opts` globals may be removed, and supported access moves to the runtime manager. `git2dart` later migrates to this public contract in a separate gate.

## 2. Applied principles

No `.reversa/principles.md` exists. The proposal applies the confirmed extracted invariants instead.

| Principle | Relationship | Status |
|-----------|--------------|--------|
| Native loading remains inside `git2dart_binaries` | The manager is layered on the existing loader and does not expose `DynamicLibrary` or paths. | respects |
| Fail closed on unsupported/loading failure | Lifecycle errors do not commit usable state. | respects |
| Prefer one explicit lifecycle surface | Legacy lifecycle globals may be removed; required non-lifecycle FFI capability is reached through the manager. | respects |
| Treat cross-repository behavior as a separate proof boundary | `git2dart` changes are postponed to an explicit consumer gate. | respects |

## 3. Technical decisions

| ID | Decision | Justification | Alternatives discarded | Confidence and provenance |
|----|----------|---------------|------------------------|---------------------------|
| D-01 | Add an isolate-local public runtime manager named `Libgit2Runtime`, exposed as `libgit2Runtime`. | Dart top-level state is isolate-local while libgit2's count is process-global; one manager per isolate composes naturally through the native counter. | consumer-owned manager; process coordinator isolate; init per call | 🟢 UPSTREAM + USER-APPROVED |
| D-02 | The manager owns one `DynamicLibrary`, one generated `Libgit2`, one `Libgit2Opts`, and at most one package native increment. | Prevents multiple loading/initialization paths and keeps all platform behavior in binaries. | expose library handle; duplicate binding factories | 🟢 CODE + SDD + USER-APPROVED |
| D-03 | Managed surface: checked `bindings`/`options`, `withCall`, `acquireOwner`, and `shutdown`. | Covers ownerless calls, persistent owners, and deterministic lifecycle without leaking platform mechanics. | only static init/shutdown; per-call native refcount | 🟢 REQUIREMENTS + USER-APPROVED |
| D-04 | Persistent token `Libgit2OwnerLease` supports one-time destructor binding, explicit/finalizer release, construction rollback, and transfer. | The consumer needs a reusable ownership primitive for root, derived, transferred, and failed-construction paths. | consumer-local counters; uncoordinated finalizers | 🟢 ZC7X + REQUIREMENTS + USER-APPROVED |
| D-05 | Transient work uses a synchronous `withCall` guard; constructors may use their provisional owner as the in-flight pin. | `try/finally` prevents ownerless/reentrant shutdown without native counter churn. | no transient pins; public manual call token only | 🟢 ZC7X + REQUIREMENTS + USER-APPROVED |
| D-06 | Init succeeds only on a positive native result. Failed or unexpected init triggers one native shutdown rollback before Dart state can commit. | Pinned libgit2 increments its global count before some initialization failures; unchecked failure can leak a count. | cache failed state as initialized; retry without rollback | 🟢 CODE + UPSTREAM + ZC7X |
| D-07 | Cleanup completion is a state machine, not a boolean scattered across wrappers. | Guarantees destructor-before-pin-release and exact-once behavior across explicit cleanup and finalizers. | decrement in `finally`; separate finalizer bookkeeping | 🟢 ZC7X + REQUIREMENTS + USER-APPROVED |
| D-08 | Cleanup failure retains the owner record/pin. Finalizer failure is reported through an injected/internal diagnostic callback and never thrown across the callback boundary. | Falsely declaring the runtime safe would permit premature shutdown while a native owner may still exist. | release pin in `finally`; ignore finalizer failures | 🟢 UPSTREAM + REQUIREMENTS + USER-APPROVED |
| D-09 | Shutdown with live pins throws before native code. First successful call stores the remaining native count; later calls return that stored result without native calls. | Provides guarded idempotence and accepts other isolates/external owners. | loop shutdown to zero; automatic finalizer shutdown | 🟢 UPSTREAM + REQUIREMENTS + USER-APPROVED |
| D-10 | After successful shutdown, managed entry is terminal for that isolate. An unexpected native shutdown result enters a faulted terminal state and is never retried automatically. | A second epoch would require replaying Android TLS and global options; retrying an ambiguous shutdown can over-decrement. | transparent reinit; best-effort repeated shutdown | 🟢 CODE + SDD + USER-APPROVED |
| D-11 | Remove or replace the top-level `libgit2` and `libgit2Opts` lifecycle globals; supported access is through `libgit2Runtime`. | Backward compatibility is explicitly unnecessary, so one managed entry surface is safer and simpler than delegating legacy aliases. | delegating legacy getters; separate eager initializer | 🟢 USER-APPROVED |
| D-12 | Keep the ready packaged `bindings.dart` API shape authoritative. `Libgit2Runtime` integrates its generated `git_libgit2_init()`/`git_libgit2_shutdown()` methods for checked acquisition, rollback, and exact-once shutdown. Direct raw calls remain publicly possible but unsupported outside the runtime owner and controlled probes. | Avoids an unnecessary generated-ABI fork while making the supported package and migrated-consumer path symmetric and accounted. The type-level escape hatch is an explicitly accepted non-critical residual risk. | exclude the two methods through ffigen; full handwritten ABI wrapper; private symbol lookup | 🟢 CODE + REQUIREMENTS + USER-APPROVED RISK |

### Confidence evidence and proof boundary

| Evidence source | Decisions strengthened | What it proves | What remains unproved |
|-----------------|------------------------|----------------|-----------------------|
| Current `lib/src/util.dart`, package exports, and lifecycle tests | D-02, D-06, D-10, D-12 | The loader/bindings ownership boundary, unchecked init path, bootstrap coupling, legacy/raw call sites, and missing production shutdown are real. | Correctness of the future state machine. |
| Extracted `_reversa_sdd/architecture.md`, `state-machines.md`, and `code-analysis.md` | D-02, D-10 | The proposed delta stays inside the existing native loader/lifecycle component and closes a recorded boundary gap. | Runtime behavior after modification. |
| libgit2 main API reference | D-01, D-06, D-09 | Init/shutdown are process-global counted operations; positive remaining counts are meaningful. | Dart-side exact-once ownership. |
| Dart concurrency and `Finalizer` API references | D-01, D-08 | Globals are isolate-local; `DynamicLibrary`/finalizers are unsendable; finalizer callbacks are optional and must not throw. | Multi-isolate native count behavior in this package. |
| Committed ZC7X reproduction/root-cause/debate evidence and approved requirements | D-04–D-09 | Required lease, cleanup, rollback/transfer, and shutdown semantics match the reproduced defect and accepted architecture. | GREEN implementation. |
| Explicit `APPROVE PROPOSAL`, including no backward-compatibility requirement | D-01–D-12 | The design choices and public names are approved for Gate 1 specification. | Compilation, RED specificity, or GREEN behavior. |
| Explicit user decision that the generated raw-method escape hatch is not a critical risk | D-03, D-12 | The packaged bindings stay authoritative; managed code integrates the generated init/shutdown pair and repository/consumer policy tests define the supported boundary. | Prevention of deliberate third-party misuse at the Dart type level. |

Decision confidence is `12/12 🟢` at the proposal level. Gate 2 now proves the binaries implementation on Windows, including real two-isolate native-count behavior; macOS/Linux/iOS/Android runtime proof and the separate `git2dart` consumer integration remain outside the evidence boundary.

Authoritative contract references:

- libgit2 counted initialization: https://libgit2.org/docs/reference/main/global/git_libgit2_init.html
- libgit2 counted shutdown and remaining-count result: https://libgit2.org/docs/reference/main/global/git_libgit2_shutdown.html
- Dart isolate-private globals and unsendable native resources: https://dart.dev/language/concurrency
- Dart finalizer guarantees and non-throwing callback rule: https://api.dart.dev/dart-core/Finalizer-class.html

### Approved public contract

The user approved this surface with `APPROVE PROPOSAL` on `2026-08-22`. Gate 1 encoded it as RED compile/behavior contracts; changing the names or semantics now requires an explicit proposal amendment.

```dart
final Libgit2Runtime libgit2Runtime;

final class Libgit2Runtime {
  Libgit2 get bindings;       // checked init, shared instance
  Libgit2Opts get options;    // checked init, shared instance

  T withCall<T>(T Function(Libgit2 bindings) operation);
  Libgit2OwnerLease acquireOwner({String? debugLabel});

  bool get isInitialized;
  bool get isTerminated;
  int get activeCallCount;
  int get liveOwnerCount;
  int shutdown();             // native remaining count; idempotent
}

final class Libgit2OwnerLease {
  void bindDestructor(void Function() destructor);
  void release();
  void releaseFromFinalizer();
  void rollbackConstruction();
  void transfer();
}
```

The injectable constructor/callback seam used by unit tests should not expose `DynamicLibrary`; it may be package-private or explicitly test-only. A dedicated `Libgit2LifecycleException` is proposed for checked init/shutdown failures, carrying the native result and phase.

## 4. Assumptions

No unresolved `[DÚVIDA]` marker remains. D-01/D-03/D-04 names, terminal behavior, and the exact breaking export surface were approved with `APPROVE PROPOSAL`; Gate 1 now locks them as RED contracts.

## 5. Architectural delta

| Component | Legacy source | Change type | Summary |
|-----------|---------------|-------------|---------|
| Native loader/lifecycle | `_reversa_sdd/architecture.md#Component responsibilities` | rule-altered | Add explicit checked isolate runtime ownership and guarded shutdown around the existing loader. |
| Dart FFI facade | `_reversa_sdd/architecture.md#Component responsibilities` | contract-altered | Replace legacy lifecycle globals with the runtime manager/lease contract. |
| Global-options wrapper | `_reversa_sdd/architecture.md#Component responsibilities` | rule-altered | Options access participates in checked initialization and the same runtime epoch. |
| Cross-repository consumer boundary | `_reversa_sdd/inventory.md#Cross-repository boundary requiring validation` | contract-new | `git2dart` receives logical call/owner APIs but no native loading responsibility. |

### Expected production impact after Gate 2 approval

| File | Proposed delta |
|------|----------------|
| `lib/src/util.dart` | Keep platform loading; replace `_initializeLibgit2` and legacy lifecycle globals with the shared managed runtime. |
| `lib/src/runtime.dart` (new, proposed) | Runtime state machine, call guard, owner lease, checked init/rollback, shutdown, and diagnostics. |
| `lib/src/error.dart` | Add a stable lifecycle exception without invalid native-pointer assumptions. |
| `lib/git2dart_binaries.dart` | Export the public runtime contract. |
| `test/libgit2_runtime_test.dart` (new) | Deterministic fake-native RED/GREEN contract tests. |
| Existing platform/integration tests | Remove manual over-balancing assumptions and verify the managed lifecycle against expanded artifacts. |

No production file is authorized for modification at proposal stage.

## 6. Data-model delta

- No persisted schema or user data changes.
- Add isolate-local runtime state and logical lease records described in `data-delta.md`.
- Detail: `_reversa_forward/001-libgit2-process-lifecycle/data-delta.md`.

## 7. External contract delta

No HTTP, queue, gRPC, GraphQL, or file contract changes. The affected external contract is the public Dart package API and is specified above; no `interfaces/` directory is created because the Reversa template reserves it for transport contracts.

## 8. Migration and gated delivery plan

1. **Proposal approval:** approve or revise the decisions and proposed API names/signatures in this roadmap.
2. **Gate 1, binaries RED:** after explicit `APPROVE GATE 1`, add only lifecycle contract tests. Required RED groups:
   - failed init is not cached and performs one rollback;
   - repeated managed use contributes one native increment;
   - active transient/persistent pins reject shutdown unchanged;
   - explicit/finalizer cleanup is exact-once;
   - constructor rollback, transfer, derived-owner independence, and cleanup failure semantics;
   - idempotent terminal shutdown;
   - two-isolate native-count composition;
   - all supported binding/options access flows through the manager; legacy lifecycle globals are not required to compile.
3. Record focused RED output and the precise reason each test fails. Stop for Gate 2 approval.
4. **Gate 2, binaries GREEN:** after explicit approval, implement the minimum production delta; run formatting, analyzer, focused unit tests, native integration tests, and available platform packaging tests. Do not change `git2dart` yet.
5. Record the binaries breaking API/version decision and GREEN evidence. Stop for consumer gate approval.
6. **Consumer integration/regression gate:** in `git2dart`, adapt the preserved ZC7X Gate 1 contract to the approved binaries API; remove 66 direct package-owned init transitions; wire transient/persistent leases and deterministic cleanup; run focused and full non-regression checks. Do not add loader/path/process state to the consumer.
7. **Closure:** update Reversa regression evidence, issue/spec verdict, `regression-watch.md`, and final cross-repository proof. Commit/push remain separately authorized actions.

## 9. Risks and mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| A consumer bypasses the manager through raw generated lifecycle methods or caches bindings past terminal shutdown. | high | low | Accepted non-critical residual risk: remove legacy globals, declare raw lifecycle calls unsupported, adapt `git2dart`, and enforce the supported path with package and migrated-consumer scans/tests. |
| A wrapper ownership path is misclassified. | high | medium | Consumer gate inventories owned, derived-owned, borrowed, materialized, and transferred values; require tests for each class. |
| Finalizer or destructor failure falsely releases a pin. | high | low | Destructor-before-release ordering and fail-closed retained records. |
| Another isolate/external consumer owns native increments. | high | medium | Never require shutdown result zero; verify only the calling isolate's delta. |
| Failed init leaves a native increment. | high | low | Mandatory single rollback before state commit; fake-native tests cover failure and rollback failure. |
| Shutdown return is ambiguous after native cleanup error. | high | low | Enter faulted terminal state and never retry automatically. |
| Android/global options need replay after reinit. | high | medium | Terminal single epoch; no transparent reinitialization. |
| Tracked checkout lacks generated bindings/native artifacts. | medium | high | Split pure state-machine unit tests from expanded-package/platform integration gates; record unavailable proof explicitly. |
| Public API naming creates avoidable churn. | medium | low | The proposed surface is approved and locked by Gate 1; later changes require an explicit proposal amendment. |

## 10. Definition of done

- [x] Proposal decisions and public API are explicitly approved.
- [x] Gate 1 binaries tests are approved, applied, and RED for the expected missing contract only.
- [x] Gate 2 binaries implementation is approved and GREEN in focused/unit/native/platform validation available to the project.
- [x] The approved breaking export surface exposes one supported managed lifecycle path, with one tracked native lease per isolate.
- [ ] Separate `git2dart` consumer integration/regression gate is approved and GREEN without consumer-side loader/process ownership.
- [ ] `regression-watch.md` and final spec verdict are recorded.
- [ ] No CRITICAL/HIGH unresolved cross-check finding remains.

## 11. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-22 | Initial proposal generated by `/reversa-plan` | reversa |
| 2026-08-22 | Removed backward-compatibility requirement and changed the proposal to a breaking managed-API migration | reversa |
| 2026-08-22 | Proposal approved by the user; no authorization for Gate 1 test edits implied | user |
| 2026-08-22 | Confidence hardened with current-code, extracted-SDD, official Dart/libgit2, ZC7X, and explicit approval provenance; implementation proof remains gated | reversa |
| 2026-08-22 | Gate 1 completed with 19 test scenarios and expected RED; no production source changed | reversa |
| 2026-08-22 | Amended D-12: retain the packaged generated raw methods, integrate them only through the runtime owner on the supported path, and accept the public escape hatch as non-critical residual risk | user + reversa |
| 2026-08-22 | Gate 2 binaries implementation completed GREEN: analyzer clean, 33 passed/2 host-skipped tests, real Windows two-isolate count proof, consumer gate still separate | reversa |
