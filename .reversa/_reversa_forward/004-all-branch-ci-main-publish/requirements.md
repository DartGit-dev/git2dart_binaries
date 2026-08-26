# Requirements: All-branch CI with main-only publication

> Identifier: `004-all-branch-ci-main-publish`
> Date: `2026-08-24`
> Reverse-extraction directory: `.reversa/_reversa_sdd/`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP / OPEN QUESTION

## 1. Executive summary

The package release factory shall validate every branch change through its build and test workflow. Publication remains deliberately narrow: the `publish_package` job may run only for a `push` event whose reference is `refs/heads/main`. Pull-request validation may continue as an additional signal, but it cannot run `publish_package` or publish a package. This replaces the current branch-limited push policy while preserving the existing release-gate order and fail-closed platform-proof policy. 🟢 user-confirmed policy

## 2. Context from the legacy system

| Source | Relevant excerpt | Confidence |
|-------|------------------|-------------|
| `.reversa/_reversa_sdd/architecture.md#Supply path` | Native builds and platform tests flow into package assembly, dry-run, PR handling, and publication. | 🟢 |
| `.reversa/_reversa_sdd/architecture.md#Architectural invariants` | Publication remains downstream of required platform tests/builds, size gate, and pub dry-run. | 🟢 |
| `.reversa/_reversa_sdd/validation-release-assembly/requirements.md#Responsibilities and Rules` | Current configured push triggers are limited to `main` and `1.11.2`; the feature-branch policy requires validation before merge eligibility and a distinct main run before publication. | 🟢 user-confirmed policy; 🔴 current CI evidence |
| `.reversa/_reversa_sdd/validation-release-assembly/design.md#Alternative Flows` | Pull requests never publish, and branch trigger selection determines which non-PR runs occur. | 🟢 |
| `.reversa/_reversa_sdd/code-analysis.md#Module 7: Validation and release assembly` | The workflow is a build/test dependency DAG whose release stage follows all platform validation. | 🟢 |
| `.reversa/_reversa_sdd/addenda/003-platform-release-proof.md#Impacto por artefato da extração` | Valid same-run platform proof is a fail-closed prerequisite before existing release transitions. | 🟢 |

## 3. Personas and usage scenarios

| Persona | Goal | Key scenario |
|---------|------|--------------|
| Feature developer | Receive the same build and test signal for every branch change before merge. | A push to a feature branch starts the complete configured build/test workflow. |
| Release maintainer | Publish only from the protected release branch after all gates pass. | A push to `main` reaches `publish_package` only after the required dependency jobs succeed. |
| CI reviewer | Distinguish validation from publication authorization. | A pull-request or non-main push shows validation results but no `publish_package` execution. |

## 4. New or changed business rules

1. **BR-01:** Every push to a branch, including feature branches, shall start the configured build and test workflow. 🟢 user-confirmed policy
   - Legacy source: `.reversa/_reversa_sdd/validation-release-assembly/requirements.md#Responsibilities and Rules`
   - Type: changed
2. **BR-02:** `publish_package` shall run only when the event name is `push` and the full Git reference is exactly `refs/heads/main`. 🟢 user-confirmed policy
   - Legacy source: `.reversa/_reversa_sdd/validation-release-assembly/design.md#Alternative Flows`
   - Type: changed
3. **BR-03:** Pull-request validation may remain an additional workflow entry point, but it shall not execute `publish_package` or publish a package. 🟢 user-confirmed policy
   - Legacy source: `.reversa/_reversa_sdd/validation-release-assembly/requirements.md#Functional Requirements`
   - Type: changed
4. **BR-04:** No other event or reference, including a push to a non-main branch, shall satisfy the publication condition. 🟢 user-confirmed policy
   - Legacy source: `.reversa/_reversa_sdd/architecture.md#Architectural invariants`
   - Type: new
5. **BR-05:** The all-branch trigger policy shall preserve existing required build, test, platform-proof, size, and dry-run gates for any run that reaches `publish_package`. 🟢
   - Legacy source: `.reversa/_reversa_sdd/addenda/003-platform-release-proof.md#Impacto por artefato da extração`
   - Type: new

## 5. Functional requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|----|-------------|----------|----------------------|------------|
| FR-01 | Start the configured build/test workflow for every branch `push`. | Must | Pushes to `main`, existing maintenance branches, and newly created feature branches each create a workflow run with the configured build/test jobs. | 🟢 user-confirmed policy |
| FR-02 | Restrict `publish_package` to the exact main-branch push condition. | Must | `publish_package` runs only when `github.event_name` is `push` and `github.ref` is `refs/heads/main`. | 🟢 user-confirmed policy |
| FR-03 | Deny `publish_package` for a non-main branch push. | Must | A completed feature-branch or maintenance-branch push may expose build/test results but has `publish_package` skipped and performs no package publication. | 🟢 user-confirmed policy |
| FR-04 | Deny `publish_package` for a pull-request event. | Must | A pull-request workflow may run its configured validation jobs, but `publish_package` is skipped and no publication credential is used. | 🟢 user-confirmed policy |
| FR-05 | Preserve the release dependency gates for an eligible main push. | Must | On an eligible main push, `publish_package` remains downstream of all required platform builds/tests, same-run platform proof, package-size validation, and dry-run validation; any failed prerequisite prevents the job. | 🟢 |
| FR-06 | Make the event and reference decision observable in CI results. | Should | CI output makes it possible to determine whether `publish_package` ran or was skipped because the event/reference condition was not met. | 🟡 |

## 6. Non-functional requirements

| Type | Requirement | Evidence or rationale | Confidence |
|------|-------------|-----------------------|------------|
| Safety | Publication authorization shall fail closed: any event/reference combination other than an exact main push prevents `publish_package`. | User-confirmed policy; `.reversa/_reversa_sdd/architecture.md#Architectural invariants` | 🟢 |
| Consistency | Branch pushes shall use one consistent build/test workflow contract rather than branch-specific validation coverage. | User-confirmed all-branch CI policy | 🟢 |
| Observability | CI results shall preserve the existing job and dependency visibility needed to distinguish validation from publication. | `.reversa/_reversa_sdd/validation-release-assembly/design.md#State and Observability` | 🟢 |
| Scope control | This feature changes only event/ref CI policy. It shall not change OpenSSL provenance, strict Git validation, native payload contents, consumer repositories, or runtime behavior. | User-provided scope boundary | 🟢 |

## 7. Acceptance criteria

```gherkin
Scenario: Feature branch push is validated
  Given a push to a feature branch
  When the package workflow is evaluated
  Then the configured build and test jobs run
  And publish_package is skipped
  And CI results identify the non-main reference as the reason for the skip
  And no package is published

Scenario: Main branch push is publication-eligible
  Given a push whose reference is refs/heads/main
  And all required build, test, proof, size, and dry-run gates pass
  When the package workflow is evaluated
  Then publish_package runs
  And CI results identify the push to refs/heads/main as publication-eligible
  And publication may proceed through the configured release path

Scenario: Pull request remains validation-only
  Given a pull-request event
  When the package workflow is evaluated
  Then any configured pull-request validation may run
  And publish_package is skipped
  And CI results identify the pull-request event as the reason for the skip
  And no package is published

Scenario: Non-main push cannot publish
  Given a push whose reference is not refs/heads/main
  When the package workflow is evaluated
  Then publish_package is skipped regardless of build/test success
  And no package is published
```

## 8. MoSCoW priority

| Item | MoSCoW | Rationale |
|------|--------|-----------|
| FR-01 | Must | Every branch needs CI validation. |
| FR-02 | Must | Exact event/ref matching is the publication authority. |
| FR-03 | Must | A successful non-main push must remain non-publishing. |
| FR-04 | Must | Pull requests are validation-only. |
| FR-05 | Must | Main-only publication cannot bypass existing release safety gates. |
| FR-06 | Should | Reviewers need a clear policy decision in the run result. |
| Safety NFR | Must | Any non-exact condition must fail closed. |

## 9. Clarifications

> No clarification session has been recorded yet. Run `/reversa-clarify` when an `[OPEN QUESTION]` remains.

## 10. Gaps

- No open questions. The all-branch validation policy and the exact main-only publication condition are fully determined. 🟢

## 11. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-24 | Initial version generated by `/reversa-requirements` | reversa |

## Emendas

### E001, 2026-08-24

What changes: Non-publication package validation continues for branch pushes and pull requests, while only the actual package publication step is restricted to an exact push to `main`.
Reason: The prior implementation placed the main-only condition on the whole `publish_package` job, incorrectly skipping package validation and the PR package archive.
Planned files: `.github/workflows/build_package.yml`, `test/workflow_trigger_policy_test.dart`
