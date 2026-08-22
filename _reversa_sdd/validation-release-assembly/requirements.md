# Validation and Release Assembly

## Overview
The workflow must gate publication on generated bindings, all native builds, platform validation, package assembly, size control, and pub dry-run success. 🟢

## Responsibilities and Rules
- Build/test dependencies form an explicit DAG; release assembly waits for required jobs. 🟢
- Inject generated/native artifacts into an ephemeral expanded package. 🟢
- Reject expanded packages above 256 MiB and reject pub dry-run errors. 🟢
- Publish only on non-pull-request workflow runs; configured push triggers are limited to `main` and `1.11.2`, so pushes to the analyzed `1.12.1` branch do not start this workflow. 🟢 [Codex cross-review]

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| VRA-RF-01 | Run desktop, iOS-simulator, and Android-emulator validation against injected artifacts. | Must | Every required job succeeds before assembly. | 🟢 |
| VRA-RF-02 | Assemble the complete pub payload with bindings and native outputs. | Must | Expected files exist in the expanded package. | 🟢 |
| VRA-RF-03 | Enforce expanded-size and pub dry-run gates. | Must | Oversize or invalid packages cannot publish. | 🟢 |
| VRA-RF-04 | Separate PR inspection from push publication. | Must | PR events upload only; eligible non-PR runs may publish. | 🟢 |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| Safety | Publication remains downstream of every required gate. | workflow `needs` and conditions | 🟢 |
| Compatibility | Release should be validated with the external `git2dart` consumer. | no local consumer job | 🔴 |
| Security | Token scopes and repository protections must constrain publication. | external GitHub/pub.dev controls | 🔴 |

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
Must: complete DAG, artifact injection, platform tests, size/dry-run gates, event separation. Should: cross-repository compatibility. Could: signed provenance. Won't assert: current CI success without run evidence. 🔴

## Code Traceability
`.github/workflows/build_package.yml`, `.actrc`, tests, `pubspec.yaml`, `CHANGELOG.md`. 🟢
