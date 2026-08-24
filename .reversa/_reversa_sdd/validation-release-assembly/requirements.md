# Validation and Release Assembly

## Overview
The workflow must gate publication on generated bindings, all native builds, platform validation, package assembly, size control, and pub dry-run success. 🟢

## Responsibilities and Rules
- Build/test dependencies form an explicit DAG; release assembly waits for required jobs. 🟢
- Inject generated/native artifacts into an ephemeral expanded package. 🟢
- Reject expanded packages above 256 MiB and reject pub dry-run errors. 🟢
- Publish only on non-pull-request workflow runs; configured push triggers are limited to `main` and `1.11.2`, so pushes to the analyzed `1.12.1` branch do not start this workflow. 🟢 [Codex cross-review]
- A new library version starts on a feature branch. Before commit/push, that exact version must be present in package/spec metadata and have a complete changelog entry explaining what and why changed. A feature branch is never published: a green complete platform matrix makes it merge-eligible only. After merge into `main`, CI/CD runs again on `main`; only a green `main` run is publish-eligible through the configured pipeline. 🟢 user-confirmed release policy; 🔴 current CI evidence
- `git2dart` owns the single cross-repository GitHub Actions release/build coordination point. Its feature CI receives the selected `git2dart` + `git2dart_binaries` version pair and must fully validate the pair as resolved and used by the client before it is merge-eligible; a separate green `main` CI/CD run remains required before publication. 🟢 user-confirmed coordination policy; 🔴 current workflow/run evidence
- Publication controls are operational in GitHub Actions, including a dedicated pub.dev publishing token. No additional publication/supply-chain controls are requested now; this is user-confirmed external configuration and not proof observable from repository files. 🟢 user-confirmed configuration; 🔴 repository-visible proof boundary

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| VRA-RF-01 | Run desktop, iOS-simulator, and Android-emulator validation against injected artifacts. | Must | Every required job succeeds before assembly. | 🟢 |
| VRA-RF-02 | Assemble the complete pub payload with bindings and native outputs. | Must | Expected files exist in the expanded package. | 🟢 |
| VRA-RF-03 | Enforce expanded-size and pub dry-run gates. | Must | Oversize or invalid packages cannot publish. | 🟢 |
| VRA-RF-04 | Separate PR inspection from push publication. | Must | PR events upload only; eligible non-PR runs may publish. | 🟢 |
| VRA-RF-05 | Gate version release through feature-branch merge eligibility and a subsequent `main` CI/CD publication run. | Must | Before commit/push, exact version metadata and changelog are verified; feature-branch green CI permits merge only; post-merge `main` green CI is required before publication. | 🟢 user-confirmed release policy; 🔴 current CI evidence |
| VRA-RF-06 | Use the configured publication controls, including the dedicated pub.dev token, without requiring additional supply-chain controls at this time. | Must | Publication uses the external configured control set; the specification records the user-confirmed boundary without inspecting or exposing secrets. | 🟢 user-confirmed external configuration; 🔴 repository-visible proof boundary |
| VRA-RF-07 | Make `git2dart` GitHub Actions the single cross-repository release/build coordinator for the selected `git2dart` + `git2dart_binaries` version pair. | Must | Feature CI receives and records the exact selected pair, resolves it as the client uses it, and passes the full `git2dart` integration suite before merge eligibility; after merge, a separate green `main` coordination run is required before publication. | 🟢 user-confirmed coordination policy; 🔴 current workflow/run evidence |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| Safety | Publication remains downstream of every required gate. | workflow `needs` and conditions | 🟢 |
| Compatibility | `git2dart` is the named coordinator and must fully validate each selected client/binaries version pair through its integration tests. | user-confirmed coordination policy; no current coordinator workflow/run inspected | 🟢 policy; 🔴 execution evidence |
| Security | Publication controls, including a dedicated pub.dev token, are configured externally; no additional supply-chain controls are requested now. | user-confirmed external configuration; secrets and external settings were not inspected | 🟢 user-confirmed configuration; 🔴 repository-visible proof boundary |

## Acceptance Scenarios
```gherkin
Given all platform artifacts and tests succeed
When the expanded package is assembled below 256 MiB and pub dry-run passes
Then a pull request receives an inspection artifact without publication

Given any required build, test, size, or dry-run gate fails
When release dependencies are evaluated
Then publication does not run
```

## MoSCoW
Must: complete DAG, artifact injection, platform tests, selected-pair `git2dart` coordination, size/dry-run gates, and event separation. Could: signed provenance. Won't assert: current CI success without run evidence. 🟢 user-confirmed coordination policy; 🔴 current CI evidence

## Code Traceability
`.github/workflows/build_package.yml`, `.actrc`, tests, `pubspec.yaml`, `CHANGELOG.md`. 🟢
