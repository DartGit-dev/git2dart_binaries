# Addendum: CI-Owned Generated Bindings

> Feature: `005-ci-owned-generated-bindings`
> Date: `2026-08-25`
> Scenario: `legacy`

## Effective Date

Effective from 2026-08-25.

Superado pela re-extração de 2026-08-25.

## User-Confirmed Invariant

`lib/src/bindings.dart` is a generated CI artifact, not source code. It must never
be tracked or committed. Any tracked copy must be removed from the project and
the repository must reject future attempts to add it. The authoritative
production binding is generated from the pinned official libgit2 headers by CI
and transferred as an artifact from that same workflow run into validation and
release assembly. A local, stale, or source-controlled copy is never an allowed
fallback. 🟢 user-confirmed policy

The removal of an existing tracked copy is an implementation action outside the
Reversa write boundary; this addendum records the required end state and its
acceptance gates without modifying legacy project files.

## Acceptance Contract

- `git ls-files --error-unmatch lib/src/bindings.dart` fails because the path is
  not tracked.
- CI generates and uploads `lib/src/bindings.dart` from the pinned official
  libgit2 headers.
- Every validation and package-assembly consumer downloads the binding artifact
  produced by the same workflow run.
- CI fails if a tracked/source-checkout copy exists or if a consumer falls back
  to one.
- The expanded package contains the CI-generated binding artifact required by
  the Dart package; source control does not contain that generated file.

## Extraction Artifact Impact

| Artifact | Section | Impact type | Delta |
|---|---|---|---|
| `_reversa_sdd/native-build-bindings-generation/requirements.md` | Responsibilities and functional requirements | rule-added | Bindings are CI-owned, never tracked, and same-run artifact identity is authoritative. |
| `_reversa_sdd/native-build-bindings-generation/design.md` | Main flow and durable build state | rule-changed | CI generation and artifact transfer replace any source-checkout binding input. |
| `_reversa_sdd/native-build-bindings-generation/tasks.md` | Build and test tasks | task-added | Remove any tracked copy and add fail-closed source-control/artifact-origin checks. |
| `_reversa_sdd/libgit2-global-options/requirements.md` | ABI authority | rule-changed | The production ABI input is the same-run CI-generated artifact, never a committed file. |
| `_reversa_sdd/libgit2-global-options/design.md` | Dependencies and decisions | rule-changed | Source-controlled and stale local bindings are forbidden fallbacks. |
| `_reversa_sdd/validation-release-assembly/requirements.md` | Assembly source | rule-added | Validation and publication must consume only the same-run CI binding artifact. |
| `_reversa_sdd/validation-release-assembly/design.md` | Workflow flow | rule-changed | Assembly downloads the generating job's artifact and rejects source fallback. |
| `_reversa_sdd/validation-release-assembly/tasks.md` | Release tasks and tests | task-added | Enforce untracked source state and same-run artifact provenance. |
| `_reversa_sdd/questions.md` | Question 4 answer | decision-refined | Clarifies that the CI-generated artifact is authoritative and is assembled into the package, while committed copies are forbidden. |
| `_reversa_sdd/traceability/code-spec-matrix.md` | Generated evidence | traceability-refined | Records the CI-only authoritative path and the separate implementation proof boundary. |

## Source

- Direct user instruction on 2026-08-25.
