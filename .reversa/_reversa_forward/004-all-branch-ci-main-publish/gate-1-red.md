# Gate 1 — red baseline

Feature: `004-all-branch-ci-main-publish`
Date: 2026-08-24

## Observed baseline

- `push.branches` permits only `main` and `1.11.2`; ordinary feature and
  maintenance branches do not start the workflow.
- `publish_package` has no job-level event/ref eligibility guard.
- Pull requests are limited to `main` and the existing validation/release DAG
  must remain unchanged.

## Required matrix

| Event/ref | Workflow validation | `publish_package` |
|---|---|---|
| Push feature branch | yes | no |
| Push maintenance branch | yes | no |
| Pull request to main | yes | no |
| Push main | yes | yes |
