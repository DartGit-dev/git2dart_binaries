# Confidence Report — git2dart_binaries

> Final Reviewer refresh: 2026-08-25
> Count scope: explicit confidence-marker occurrences in all 64 current unit files. Global matrices are validated separately and are not mixed into the score.

## Overall Summary

| Level | Count | Percentage |
|---|---:|---:|
| 🟢 CONFIRMED | 681 | 74.1% |
| 🟡 INFERRED | 16 | 1.7% |
| 🔴 GAP | 222 | 24.2% |
| **Total** | **919** | **100%** |

**Overall weighted confidence: 75.0%**, calculated as `(681 + 16 × 0.5) / 919`.

The lower percentage versus the historical report is primarily a scope correction: this pass counts 64 files across eight units, including optional contracts, flows, edge cases, decisions, questions, and the Behavior-Proving Tests unit. Red evidence-boundary markers are retained instead of being treated as unanswered stakeholder questions.

## By Unit

| Unit | Files | 🟢 | 🟡 | 🔴 | Weighted confidence |
|---|---:|---:|---:|---:|---:|
| `dart-ffi-facade` | 8 | 78 | 4 | 21 | 77.7% |
| `native-loader-lifecycle` | 8 | 96 | 0 | 17 | 85.0% |
| `libgit2-global-options` | 8 | 81 | 5 | 14 | 83.5% |
| `android-tls-bootstrap` | 8 | 78 | 1 | 30 | 72.0% |
| `platform-packaging` | 8 | 81 | 2 | 30 | 72.6% |
| `native-build-bindings-generation` | 8 | 86 | 4 | 27 | 75.2% |
| `validation-release-assembly` | 8 | 102 | 0 | 53 | 65.8% |
| `behavior-proving-tests` | 8 | 79 | 0 | 30 | 72.5% |

## By Specification

| Specification | 🟢 | 🟡 | 🔴 | Weighted confidence |
|---|---:|---:|---:|---:|
| `dart-ffi-facade/requirements.md` | 18 | 1 | 3 | 84.1% |
| `dart-ffi-facade/design.md` | 19 | 2 | 4 | 80.0% |
| `dart-ffi-facade/tasks.md` | 9 | 0 | 3 | 75.0% |
| `dart-ffi-facade/contracts.md` | 6 | 0 | 3 | 66.7% |
| `dart-ffi-facade/flows.md` | 12 | 0 | 1 | 92.3% |
| `dart-ffi-facade/edge-cases.md` | 9 | 1 | 1 | 86.4% |
| `dart-ffi-facade/decisions.md` | 5 | 0 | 2 | 71.4% |
| `dart-ffi-facade/questions.md` | 0 | 0 | 4 | 0.0% |
| `native-loader-lifecycle/requirements.md` | 23 | 0 | 2 | 92.0% |
| `native-loader-lifecycle/design.md` | 24 | 0 | 2 | 92.3% |
| `native-loader-lifecycle/tasks.md` | 10 | 0 | 3 | 76.9% |
| `native-loader-lifecycle/contracts.md` | 8 | 0 | 2 | 80.0% |
| `native-loader-lifecycle/flows.md` | 16 | 0 | 0 | 100.0% |
| `native-loader-lifecycle/edge-cases.md` | 9 | 0 | 2 | 81.8% |
| `native-loader-lifecycle/decisions.md` | 6 | 0 | 1 | 85.7% |
| `native-loader-lifecycle/questions.md` | 0 | 0 | 5 | 0.0% |
| `libgit2-global-options/requirements.md` | 20 | 1 | 2 | 89.1% |
| `libgit2-global-options/design.md` | 20 | 2 | 1 | 91.3% |
| `libgit2-global-options/tasks.md` | 10 | 0 | 3 | 76.9% |
| `libgit2-global-options/contracts.md` | 6 | 1 | 0 | 92.9% |
| `libgit2-global-options/flows.md` | 12 | 1 | 0 | 96.2% |
| `libgit2-global-options/edge-cases.md` | 7 | 0 | 3 | 70.0% |
| `libgit2-global-options/decisions.md` | 6 | 0 | 1 | 85.7% |
| `libgit2-global-options/questions.md` | 0 | 0 | 4 | 0.0% |
| `android-tls-bootstrap/requirements.md` | 22 | 0 | 5 | 81.5% |
| `android-tls-bootstrap/design.md` | 20 | 1 | 4 | 82.0% |
| `android-tls-bootstrap/tasks.md` | 9 | 0 | 6 | 60.0% |
| `android-tls-bootstrap/contracts.md` | 5 | 0 | 2 | 71.4% |
| `android-tls-bootstrap/flows.md` | 10 | 0 | 3 | 76.9% |
| `android-tls-bootstrap/edge-cases.md` | 7 | 0 | 3 | 70.0% |
| `android-tls-bootstrap/decisions.md` | 5 | 0 | 2 | 71.4% |
| `android-tls-bootstrap/questions.md` | 0 | 0 | 5 | 0.0% |
| `platform-packaging/requirements.md` | 19 | 0 | 4 | 82.6% |
| `platform-packaging/design.md` | 19 | 2 | 4 | 80.0% |
| `platform-packaging/tasks.md` | 12 | 0 | 3 | 80.0% |
| `platform-packaging/contracts.md` | 6 | 0 | 5 | 54.5% |
| `platform-packaging/flows.md` | 10 | 0 | 5 | 66.7% |
| `platform-packaging/edge-cases.md` | 9 | 0 | 3 | 75.0% |
| `platform-packaging/decisions.md` | 6 | 0 | 1 | 85.7% |
| `platform-packaging/questions.md` | 0 | 0 | 5 | 0.0% |
| `native-build-bindings-generation/requirements.md` | 24 | 2 | 3 | 86.2% |
| `native-build-bindings-generation/design.md` | 20 | 1 | 6 | 75.9% |
| `native-build-bindings-generation/tasks.md` | 10 | 0 | 3 | 76.9% |
| `native-build-bindings-generation/contracts.md` | 7 | 0 | 4 | 63.6% |
| `native-build-bindings-generation/flows.md` | 11 | 0 | 3 | 78.6% |
| `native-build-bindings-generation/edge-cases.md` | 8 | 1 | 0 | 94.4% |
| `native-build-bindings-generation/decisions.md` | 6 | 0 | 3 | 66.7% |
| `native-build-bindings-generation/questions.md` | 0 | 0 | 5 | 0.0% |
| `validation-release-assembly/requirements.md` | 27 | 0 | 11 | 71.1% |
| `validation-release-assembly/design.md` | 26 | 0 | 11 | 70.3% |
| `validation-release-assembly/tasks.md` | 16 | 0 | 10 | 61.5% |
| `validation-release-assembly/contracts.md` | 6 | 0 | 6 | 50.0% |
| `validation-release-assembly/flows.md` | 12 | 0 | 5 | 70.6% |
| `validation-release-assembly/edge-cases.md` | 9 | 0 | 3 | 75.0% |
| `validation-release-assembly/decisions.md` | 6 | 0 | 2 | 75.0% |
| `validation-release-assembly/questions.md` | 0 | 0 | 5 | 0.0% |
| `behavior-proving-tests/requirements.md` | 13 | 0 | 4 | 76.5% |
| `behavior-proving-tests/design.md` | 18 | 0 | 4 | 81.8% |
| `behavior-proving-tests/tasks.md` | 10 | 0 | 4 | 71.4% |
| `behavior-proving-tests/flows.md` | 11 | 0 | 1 | 91.7% |
| `behavior-proving-tests/edge-cases.md` | 9 | 0 | 2 | 81.8% |
| `behavior-proving-tests/decisions.md` | 6 | 0 | 0 | 100.0% |
| `behavior-proving-tests/questions.md` | 0 | 0 | 6 | 0.0% |
| `behavior-proving-tests/tests.md` | 12 | 0 | 9 | 57.1% |

## Matrix Validation

- Current code-spec section: 59 rows, numbered 1–59, 59 unique paths, all present; primary scope is 59/59.
- Writer artifact scope: 24 canonical + 40 optional + 1 global code-spec matrix = 65/65.
- Historical code-spec section: retained at 47 files/seven units and explicitly superseded by the dated 2026-08-25 section.
- Spec-impact matrix: eight features, 24 components, W001-W006, evidence tiers, high-risk contracts, and the current eight-file Behavior-Proving Tests ownership are consistent with source relationships.
- Open matrix findings: none.

## Evidence Validation

- W003 injected Android cache/retry behavior: 4/4 focused tests passed.
- W004/W006 cache/proof CLI, AST, workflow graph, trigger, and release-inventory facts: 26/26 focused tests passed.
- W005 disposable bundle mechanism: 4/4 focused tests passed.
- W001/W002/runtime compilation is unavailable in the tracked checkout because the CI-owned `lib/src/bindings.dart` is absent. This is classified as a red prerequisite/identity gap, not a local native pass.
- No current hosted five-platform run, device HTTPS result, external `git2dart` run, publisher execution, or pub.dev acceptance was promoted from local evidence.

## Corrections and Reclassifications

| Type | Count | Detail |
|---|---:|---|
| 🔴 → 🟢 | 1 | Current Windows OpenSSL source-recipe compliance: the action now checks out and source-builds the declared pin. |
| Stale confidence-scope split | 5 | Obsolete runner-installed/current-noncompliant claims were corrected to 🟢 current source recipe plus 🔴 current hosted payload/parity evidence. |
| Consistency wording correction | 2 | ATB-T-08 and ATB-Q4 now preserve the already confirmed shared in-flight policy without asking for an alternative policy. |
| Other upgrades/downgrades | 0 | No external/runtime claim exceeded its observed evidence tier. |

Marker totals changed from the pre-correction inventory by **−3 🟢 and +5 🔴** because corrected sentences now separate source-recipe confirmation from missing hosted evidence.

## Questions and Gaps

- Previous validation questions: 10 generated, 10 answered, all revalidated.
- New questions generated: 0.
- Questions awaiting user input: 0.
- Detailed unresolved gaps are categorized in `gaps.md`; none requires another stakeholder preference to complete this review.

## Completion

- Unit files reviewed: 64/64 across 8/8 units.
- Current Writer artifacts reviewed: 65/65, including the global code-spec matrix.
- Additional global impact matrix reviewed: 1.
- Input required: no.
