# Gate 2 — green source verification

Feature: `004-all-branch-ci-main-publish`
Date: 2026-08-24

## Local verification

`flutter test -j 1 test/workflow_trigger_policy_test.dart test/release_inventory_workflow_test.dart`

Result: 3 passed.

`git diff --check` for the feature scope completed without whitespace errors.

## Hosted-run evidence still required

| Required run | Evidence slot | Status |
|---|---|---|
| Feature-branch push | workflow starts; `publish_package` is skipped | not run locally |
| Maintenance-branch push | workflow starts; `publish_package` is skipped | not run locally |
| Pull request to main | workflow starts; `publish_package` is skipped | not run locally |
| Push to main | workflow starts; guarded publication job is eligible after its preserved gates | not run locally |

Source tests prove the workflow text only; they do not establish GitHub-hosted behavior.
