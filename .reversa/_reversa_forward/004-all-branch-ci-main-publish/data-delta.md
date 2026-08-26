# Data Delta: All-branch CI with main-only publication

## Conceptual diff

No persistent business database is affected. The changed records are ephemeral
GitHub Actions run/job states from
`.reversa/_reversa_sdd/state-machines.md#Release qualification`.

| Record | Legacy value | Delta | Migration |
|---|---|---|---|
| Workflow push trigger | Allow-list: `main`, `1.11.2` | Use `branches: ['**']` to accept every branch push while retaining branch-only scope. | No stored migration; new branches now produce runs. |
| `publish_package` eligibility | A triggered non-PR run can enter the job. | Require `event_name=push` and `ref=refs/heads/main` at job entry. | Existing runs stay immutable; later ineligible runs show skipped. |
| Release observability | Event distinction occurs late in release steps. | Job condition/result exposes eligibility before assembly begins. | No artifact schema change. |

## Invariants

1. The exact full ref authorizes publication.
2. A skipped job is the expected fail-closed outcome for PR/non-main runs.
3. Main release evidence (platform proof, inventory, OpenSSL provenance, size,
   dry-run) remains unchanged.
4. No publication-token value enters a new record or test fixture.

## Data migration

None. GitHub Actions history is not rewritten; behavior changes only for later
workflow runs.
