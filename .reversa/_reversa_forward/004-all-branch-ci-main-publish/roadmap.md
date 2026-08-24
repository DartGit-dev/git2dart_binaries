# Roadmap: All-branch CI with main-only publication

> Identifier: `004-all-branch-ci-main-publish`
> Date: `2026-08-24`
> Requirements: `.reversa/_reversa_forward/004-all-branch-ci-main-publish/requirements.md`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP

## 1. Approach summary

Replace the `push.branches` allow-list in `build_package.yml` with the all-branch
`'**'` filter, while retaining `pull_request` targeting `main`. Add the
exact condition `github.event_name == 'push' && github.ref == 'refs/heads/main'`
to the `publish_package` job. Every branch push will retain the current build
and test DAG, while a PR, maintenance branch, or feature branch skips the whole
release-assembly job and its credentials. Eligible main pushes retain all
existing dependency, proof, inventory, provenance, size, and dry-run gates.

## 2. Applied principles

`.reversa/principles.md` does not exist. The extracted invariants below apply.

| Principle / invariant | How the feature relates | Status |
|---|---|---|
| Publication is downstream of required platform tests/builds, size gate, and pub dry-run (`architecture.md#Architectural invariants`) | The job condition narrows eligibility without weakening `needs` or gates. | follows |
| Pull requests cannot execute publication (`architecture.md#Architectural invariants`) | The event/ref job condition enforces it at job entry. | follows |
| Release qualification fails closed (`addenda/003-platform-release-proof.md#Impacto por artefato da extração`) | Every non-main event/ref combination skips `publish_package`. | follows |

## 3. Technical decisions

| ID | Decision | Rationale | Rejected alternatives | Confidence |
|---|---|---|---|---|
| D-01 | Use `push.branches: ['**']`, keep `pull_request.branches: [main]`. | The all-branch filter satisfies every branch push without also broadening the existing workflow to tag pushes. | Static allow-list; bare `on: push`. | 🟢 |
| D-02 | Put the exact push-plus-full-ref predicate on `publish_package`. | Prevents ineligible runs from entering release assembly or accessing publisher credentials. | Guard only the final publisher step; compare a short branch name. | 🟢 |
| D-03 | Preserve the existing `needs` list and release validation order. | Event policy must not weaken platform proof, inventory, OpenSSL, size, or dry-run safety. | Reduced feature-branch DAG; duplicated release job. | 🟢 |
| D-04 | Resolve the PR inspection-artifact step deliberately after the job becomes main-only. | Its current PR-only condition becomes unreachable inside a main-only job. | Leave unreachable behavior; enter release job on non-main pushes. | 🟡 |
| D-05 | Add focused workflow-source tests. | The YAML policy is executable release control. | Manual UI review only. | 🟢 |

## 4. Assumptions

`requirements.md` has no unresolved requirement marker; no planning premise is
adopted from an unresolved requirement.

## 5. Architectural delta

| Component | Legacy source file | Change type | Summary |
|---|---|---|---|
| Validation/release assembly | `.reversa/_reversa_sdd/architecture.md#Component responsibilities` | rule-changed | All branch pushes run validation; only an exact main push reaches release assembly/publication. |
| GitHub Actions workflow boundary | `.reversa/_reversa_sdd/c4-context.md#System Context` | changed-contract | Validation intake broadens while publication authorization narrows. |
| Release qualification state machine | `.reversa/_reversa_sdd/state-machines.md#Release qualification` | rule-changed | PR/non-main runs end after validation with `publish_package` skipped. |

Planned touchpoints: `.github/workflows/build_package.yml` and focused
workflow-policy test(s) under `test/`. No native build action, artifact schema,
runtime API, secret value, Git policy, consumer repository, or remote
configuration changes.

## 6. Data-model delta

- Change summary: no persistent data changes; only Actions run classification
  (event, ref, eligibility, skipped/running job result) changes.
- Full details: `.reversa/_reversa_forward/004-all-branch-ci-main-publish/data-delta.md`

## 7. External-contract delta

No HTTP, queue, gRPC, or GraphQL contract changes. GitHub Actions configuration
is an internal CI control; no `interfaces/` directory is created.

## 8. Migration plan

1. Change only the top-level push filter to `'**'` and the `publish_package` job condition.
2. Reconcile the now-unreachable PR/non-PR terminal steps so inspection-artifact
   behavior is explicit and validation-only runs never reference publication.
3. Add source tests for unfiltered push validation, main-targeted PR validation,
   exact main eligibility, and denied non-main/PR cases.
4. Verify a feature push, maintenance push, PR to main, and authorized main push;
   only the last may run `publish_package` after existing gates pass.

## 9. Risks and mitigations

| Risk | Impact | Probability | Mitigation |
|---|---|---|---|
| A malformed all-branch pattern omits a branch class. | medium | low | Source-test the literal `'**'` branch filter and observe a newly created branch run. |
| A step-level guard leaves release assembly reachable. | high | medium | Apply and source-test the exact job-level predicate. |
| PR artifact logic becomes unreachable. | medium | high | Relocate or retire it explicitly during implementation. |
| Feature validation loses a required gate. | high | low | Preserve DAG and inspect a feature-branch run. |
| Source checks do not prove hosted behavior. | medium | medium | Treat four event/ref runs as validation evidence. |

## 10. Definition of done

- [ ] Every branch push creates the configured build/test workflow run.
- [ ] PRs targeting main remain validation-only.
- [ ] `publish_package` has the exact main-push predicate.
- [ ] No PR or non-main push can start `publish_package`, access its publisher, or publish.
- [ ] Eligible main pushes retain all current release gates.
- [ ] Workflow-source tests cover trigger and publication predicate regressions.
- [ ] Strict Git validation and unrelated release/native changes remain out of scope.

## 11. Change history

| Date | Change | Author |
|---|---|---|
| 2026-08-24 | Initial version generated by `/reversa-plan` | reversa |
