# Depth Inspection Report: validation-release-assembly

## Inspection metadata

```yaml
feature: validation-release-assembly
context: validation-release-assembly
date: 2026-08-17
mode: read-only-diagnostic
closure_policy: package
source_modified: false
existing_feature_bugs: 0
runtime_replay: blocked
```

## Feature map

- Specification: `_reversa_sdd/validation-release-assembly/{requirements,design,tasks}.md`.
- Workflow: `.github/workflows/build_package.yml`.
- Inputs: generated bindings, five platform native builds, iOS assembly, and four Android ABI artifacts.
- Gates: five validation jobs, aggregate expanded-size ceiling, pub dry-run, and mutually conditioned PR upload/push publication.
- External boundaries: GitHub protections/secrets, publisher action, pub.dev state, and `git2dart` consumer compatibility.

## Findings by lens

### Spec conformity

- The job DAG, five required platform validations, size gate, pub dry-run, and PR/push split conform statically.
- Final assembly does not enforce the specified expected native inventory. Registered as bug #9.
- Apple/pub version synchronization and release-branch eligibility remain explicit policy lacunae.

### Data flow

- Every named artifact flows into the package tree before size and dry-run gates.
- A named but internally partial artifact has no final filename/ABI/manifest rejection gate. Registered as bug #9.
- Stale binding and mobile-cache outputs can traverse the DAG; their root causes remain canonical bugs #7 and #8.
- Linux validation does not build a clean consumer bundle; the known sidecar root cause remains bug #1.

### Contracts and integrations

- Required job failures and missing named artifacts prevent final assembly.
- Desktop tests use checkout-local artifacts; mobile consumer runtime proof is limited to Android x86_64 and iOS simulator.
- No local two-repository consumer compatibility job exists. `F:\git2dart` was not inspected.

### Error states and edge cases

- Every eligible push attempts publication; unchanged-version and already-published behavior remains a policy/external-state gap.
- Same-ref push runs are serialized but not cancelled when superseded; freshest-commit publication policy is undefined.
- Long-lived credential scope, environment approval, branch protection, and third-party publisher semantics are external.
- The manual size allowlist may drift from pub's exact archive selection; no current omitted publishable path was demonstrated.

### Test coverage

- No workflow test injects missing, partial, oversized, or invalid packages.
- PR/push behavior is not simulated without production credentials.
- No current full fresh-artifact run or expanded release payload is available.
- Three Android ABIs, iOS device, and desktop assembled-app behavior remain unobserved.

### Concurrency and consistency

- Direct and transitive `needs` edges are fail-closed for the configured DAG.
- PR upload and push publication conditions are mutually exclusive for the only configured event types.
- Current branch `1.12.1` is not a push trigger; history shows its removal was explicit, so intended eligibility was not inferred.
- Pubspec/podspec metadata diverges, but no synchronization policy is defined.

## Promotion and deduplication

| Candidate | Severity | Result |
|---|---|---|
| C-VRA-01, missing final native inventory gate | High | `BUG-20260817-AAGV` (#9) |
| Linux incomplete consumer bundle | High | Exact upstream dedupe to bug #1 |
| Stale generated bindings | High | Exact upstream dedupe to bug #7 |
| Mobile cross-configuration cache reuse | High | Exact upstream dedupe to bug #8 |

No branch, version, credential, concurrency, cross-repository, or size-scope lacuna was promoted.

## Confidence impact

- DAG dependencies and PR non-publication retain high static confidence.
- Complete-payload assurance drops because the claimed final inventory gate is absent.
- Current publication and external consumer compatibility remain red and unobserved.
- The completed core Reversa score was not rewritten.

## Residual blockers

- No current GitHub Actions run, expanded package, or pub.dev result.
- Generated bindings and native artifacts are absent locally.
- Credential scopes, protections, publication state, and publisher internals are external.
- Cross-repository compatibility was not inspected by scope.

No source, test, staged, committed, global-setting, or external-repository change was made.

