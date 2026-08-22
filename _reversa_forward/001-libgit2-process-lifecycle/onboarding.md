# Onboarding: Validate the libgit2 lifecycle feature

> Feature: `001-libgit2-process-lifecycle`
> Current stage: proposal only; do not execute Gate 1 or modify production code without approval

## Preconditions

1. Work in branch `reversa/libgit2-lifecycle` based on commit `e824baf` (`1.12.2`).
2. Confirm `git status --short --branch` contains only the approved Reversa feature artifacts before a gate begins.
3. Keep `F:/git2dart` read-only until the separate consumer integration gate; ignore its unrelated `Python/` directory.
4. Use the expanded package/native artifacts required by existing tests when available. Record missing artifacts as a proof gap, not as a passing result.

## Read the proposal

1. Read `requirements.md` for the behavioral contract.
2. Review `roadmap.md#Proposed public contract for approval` for proposed names/signatures.
3. Review `investigation.md#Alternatives evaluated` and `data-delta.md#Owner lease state`.
4. Approve or revise the proposal before creating tests.

## Gate 1 procedure after explicit approval

1. Add tests only; do not edit `lib/`.
2. Run formatting/checks appropriate for test-only changes.
3. Run the fake-native lifecycle unit group and capture the expected missing-API/behavior RED result.
4. Where native artifacts are available, run the stable-count and two-isolate integration groups and capture their RED reason.
5. Verify existing unrelated tests were not rewritten to manufacture RED.
6. Present exact test diff and RED evidence; stop for Gate 2 approval.

## Gate 2 procedure after explicit approval

1. Implement only the approved binaries API and manager.
2. Run focused unit tests first, then analyzer and existing package/platform tests.
3. Verify a rejected shutdown does not change the native count and that a successful shutdown changes it by exactly the isolate-owned delta.
4. Verify repeated shutdown performs no native call and managed post-shutdown entry is rejected.
5. Verify all supported binding/options access uses the managed runtime and the removed/replaced legacy lifecycle globals are not required by the approved tests.
6. Record unavailable cross-platform proof explicitly; stop before touching `git2dart`.

## Consumer gate after binaries GREEN

1. Restore/adapt the preserved ZC7X contract from the committed Reversa evidence, not the removed active test file.
2. Replace direct initialization ownership with the approved binaries lifecycle API.
3. Classify native values as root-owned, derived-owned, borrowed, materialized, transferred, or failed-construction.
4. Prove deterministic cleanup, stable counts, live-owner rejection, transfer, rollback, and two-isolate behavior.
5. Run focused tests and the full available analyzer/test suite, separating known unrelated failures from feature regressions.
6. Stop for final spec verdict/closure; commit and push require separate authorization.

## Expected success signal

- Repeated supported public use within one isolate contributes one native increment total.
- The isolate releases exactly its own increment after all pins are complete.
- Other isolates/external owners remain valid when the returned native count is positive.
- No consumer owns library discovery, platform dependencies, or process runtime state.
