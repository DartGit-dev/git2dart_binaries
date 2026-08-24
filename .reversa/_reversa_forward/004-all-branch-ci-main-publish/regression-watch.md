# Regression watch — 004-all-branch-ci-main-publish

| ID | Origin | Rule expected after change | Type | Violation signal |
|---|---|---|---|---|
| W001 | `domain.md`, rule 31 | Any branch push starts the validation workflow. | presença | A feature or maintenance branch is excluded by `push.branches`. |
| W002 | `domain.md`, rules 31–32 | `publish_package` is eligible only when event is `push` and ref is `refs/heads/main`. | redação | A PR, feature branch, or maintenance branch can schedule publication. |
| W003 | `domain.md`, rules 31–33 | Existing publication dependencies and proof, inventory, provenance, size, and dry-run gates remain. | presença | Guarding publication removes or weakens a release gate. |
| W004 | `domain.md`, rule 31 | The `publish_package` job remains available for configured validation outside an exact main push; only `Publish package` has the main-push predicate, and PRs still archive the package. | presença | A job-level main-only condition skips package validation, or the PR archive step is absent. |

## Observations

- Hosted evidence for feature, maintenance, PR-to-main, and main pushes remains open; local source tests do not prove Actions behavior.

## Re-extraction history

None.

## Archived

None.
