# Cross-check audit: Process-global libgit2 lifecycle ownership

> Feature: `001-libgit2-process-lifecycle`
> Date: `2026-08-22`
> Inputs: `requirements.md`, `roadmap.md`, `actions.md`
> Evidence: current production/tests, `gate-1-red.md`, `gate-2-green.md`, packaged `git2dart_binaries-1.12.1/lib/src/bindings.dart`
> Mode: strict Reversa audit; requirements, roadmap, and actions were read-only during this audit

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |

Gate 1 RED and Gate 2 binaries GREEN are coherent with the approved requirements and roadmap. All 17 actions are closed, dependency ordering is acyclic, and no unresolved cross-check finding remains. This is a binaries verdict only: the separate `git2dart` consumer gate and final feature closure remain pending.

## Findings

| ID | Severity | Axis | Description | Where |
|----|----------|------|-------------|-------|
| None | - | - | No unresolved audit finding remains. | - |

## Coverage passed

| Requirement cluster | Roadmap decisions | Actions/evidence | Result |
|---------------------|-------------------|------------------|--------|
| RF-01–RF-02 checked initialization and lease reuse | D-01, D-02, D-06 | T001–T003, T008, T011; runtime and native tests | PASS |
| RF-03 transient-call protection | D-03, D-05 | T003, T008; state-machine tests | PASS |
| RF-04–RF-07 exact-once ownership, rollback/transfer, failure retention | D-03, D-04, D-07, D-08 | T004, T009, T010; owner tests | PASS |
| RF-08–RF-10 guarded/idempotent/terminal/isolate shutdown | D-01, D-09, D-10 | T005, T006, T008; real two-isolate Windows test | PASS on available host |
| RF-11–RF-13 breaking surface, supported raw-call boundary, bootstrap ordering | D-02, D-10–D-12 | T007, T011–T016; source scan, exports, platform tests | PASS with accepted A001 residual risk |
| RF-14 deterministic seams and diagnostics | D-03, D-06, D-08, D-09 | T001–T006, T008–T010; injected callbacks | PASS |
| RF-15 gated delivery | delivery plan | T001–T017, Gate 1 and Gate 2 evidence | PASS for binaries; consumer gate pending |

## Consistency passed

- Public names and semantics match across requirements, roadmap, actions, implementation, tests, and README: `libgit2Runtime`, `Libgit2Runtime`, `Libgit2RuntimeState`, `Libgit2OwnerLease`, `bindings`, `options`, `withCall`, `acquireOwner`, and `shutdown`.
- Backward compatibility is consistently not required; `libgit2` and `libgit2Opts` production globals are absent.
- The ready packaged `bindings.dart` remains authoritative for design and implementation and is byte-identical at SHA-256 `C2C124AA68CD763CC219F92AB03852A96E03D1B8ECA88DAB28D059177D02E925`.
- Raw generated init/shutdown remain publicly reachable only as the explicitly accepted unsupported escape hatch. Supported production transitions are owned by `lib/src/runtime.dart`; the other direct calls are a controlled native test probe.
- A positive shutdown result remains valid and is covered by deterministic and two-isolate tests.

## Legacy coherence passed

- The changed code stays within the extracted Dart FFI facade, Generated FFI layer, Native loader/lifecycle, Global-options wrapper, Platform packaging, and Validation components.
- iOS process loading, Android system loading, desktop bare-name/package fallback, fail-closed error propagation, Windows dependency order, macOS filename, and Android TLS ordering are preserved.
- The former red ownership gap is closed without moving `DynamicLibrary`, platform paths, dependencies, or process state into `git2dart`.

## Action sanity passed

- T001–T017 exist and are `[X]`; each implementation decision has an action and evidence.
- Dependencies reference valid IDs and contain no cycle.
- `[//]` actions operate on separate primary files.
- `progress.jsonl` remains append-only with one done record per action.

## Implementation evidence boundary

- `dart analyze`: PASS, no issues.
- Final Windows `flutter test -j 1`: PASS, 33 passed and 2 macOS-only skipped.
- Real Windows native evidence includes independent two-isolate increments, options integration, and plain-Dart package-root loading from installed package 1.12.1.
- macOS, Linux, iOS, and Android execution is not claimed on this Windows host.
- No `git2dart` source change, consumer regression result, final spec verdict, commit, or push is claimed.

## Resolved historical findings

| ID | Former severity | Resolution |
|----|-----------------|------------|
| A001 | HIGH | The user explicitly accepted the generated raw-method escape hatch as non-critical residual risk. RF-12/D-12 define the supported-path convention, runtime-owned symmetric use, and package/consumer scans. |
| AUD-001 | MEDIUM | Proposal confidence and implementation proof boundaries are explicit; Gate 2 now supplies binaries evidence without overstating consumer/platform coverage. |
