# Investigation: All-branch CI with main-only publication

## Observed baseline

- `build_package.yml` filters `push` to `main` and `1.11.2`; `pull_request`
  targets `main`.
- `publish_package` already depends on the full platform test/build DAG and runs
  same-run proof, inventory, OpenSSL provenance, size, and pub dry-run gates.
- Its publisher step uses only `github.event_name != 'pull_request'`, so a
  non-main push would be publication-capable if it were triggered.
- Existing workflow-source tests protect CI release invariants without publishing.

## Applicable external sources

1. [GitHub Actions push branch filters](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#onpushbranches--branches-ignore) documents branch-filter behavior and the distinction between configured branch and tag refs.
2. [GitHub Actions job conditions](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-jobs-with-conditions) documents job-level `if` evaluation and skipped jobs.
3. `.reversa/_reversa_sdd/validation-release-assembly/design.md#Alternative Flows` records the existing release DAG and branch-limited state.

## Alternatives considered

| Alternative | Result | Reason |
|---|---|---|
| Enumerate known branches. | Rejected | New feature branches again lack CI. |
| `branches: ['**']` filter. | Selected | It reaches every branch while preserving the feature's branch-only trigger scope. |
| Guard only the publisher step. | Rejected | Non-main runs enter release assembly and may reach credentials. |
| Exact job-level event/ref predicate. | Selected | Enforces authorization at the release boundary and visibly skips ineligible jobs. |
| PR-only feature validation. | Rejected | Every branch push must validate before merge. |

## Implementation checks

- Keep the all-branch filter so tag pushes remain outside this branch-policy feature.
- Put the exact condition on `publish_package`, not only `Publish package`.
- Resolve the PR inspection artifact after job-level restriction makes its current
  location unreachable.
- Hosted runs, not local YAML reading, prove actual CI behavior.
