# Legacy impact — 004-all-branch-ci-main-publish

Date: 2026-08-24. Legacy anchor: `_reversa_sdd/architecture.md` and `domain.md`.

| Affected file | Component | Type | Severity | Justification |
|---|---|---|---|---|
| `.github/workflows/build_package.yml` | Validation/release assembly | regra-alterada | HIGH | Every push validates the existing release DAG; the credential-bearing publication job is eligible only for a main push. |
| `.github/workflows/build_package.yml` | Validation/release assembly | regra-alterada | HIGH | The package assembly, proof, inventory, provenance, size, dry-run, and PR archive validations remain runnable outside `main`; only the credential-bearing `Publish package` step is main-push-only. |
| `test/workflow_trigger_policy_test.dart` | Workflow policy regression tests | regra-alterada | MEDIUM | Source assertions distinguish job-level validation availability from the single guarded publication step and require the PR archive. |

## Conceptual delta

Branch selection moves from an allow-list to the literal all-branch filter.
The release DAG, its validation gates, and PR-to-main trigger remain unchanged.
Publication is now job-level gated before any publication-job credential use.

## Preserved

- Domain rule 31: publication remains downstream of Linux, macOS, Windows, iOS, Android, and remaining Android ABI validation.
- Domain rules 32–33: PRs do not publish; size and dry-run gates remain in the guarded job.

## Modified

- Domain rule 31: validation now starts for every branch push, while publication is explicit main-push only.
