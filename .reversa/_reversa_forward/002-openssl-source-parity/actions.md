# Actions: OpenSSL source-build provenance parity

> Identifier: `002-openssl-source-parity`
> Date: `2026-08-24`
> Roadmap: `.reversa/_reversa_forward/002-openssl-source-parity/roadmap.md`

## Summary

| Metric | Value |
|--------|-------|
| Total actions | 18 |
| Parallelizable (`[//]`) | 9 |
| Longest dependency chain | 11 |

## Phase 1, Preparation

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|-------------|--------|
| [//] T001 | Specify `native-v2` OpenSSL identity fields and CLI contract: configured version, `source-build`/`approved-exception`, source ref, and exception ID; require mutually exclusive source/exception evidence. | - | `[//]` | `.github/scripts/native_cache_manifest.py` | 🟢 | `[X]` |
| [//] T002 | Define the checked-in exception-record format, including platform/ABI, exact version, infeasibility evidence, approver, expiry/review date, ID, and exact-parity verdict requirements. | - | `[//]` | `.github/openssl-exceptions/README.md` | 🟢 static schema and release-qualification audit (2026-08-24) | `[X]` |

## Phase 2, Tests

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| [//] T003 | Add focused CI-source contract tests for `native-v2` field presence and fail-closed rejection of missing, contradictory, or mismatched provenance metadata. | T001 | `[//]` | `test/openssl_provenance_workflow_test.dart` | 🟢 | `[X]` |
| [//] T004 | Extend Windows packaging tests to require the explicit OpenSSL input, tagged source checkout, isolated MSVC install prefix, source-derived DLL export, and absence of runner OpenSSL discovery. | - | `[//]` | `test/windows_packaging_test.dart` | 🟢 | `[X]` |
| [//] T005 | Extend release-workflow tests to require provenance sidecars for every release platform and a release-eligibility gate before assembly/publish steps. | - | `[//]` | `test/release_inventory_workflow_test.dart` | 🟡 | `[X]` |

## Phase 3, Core

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| T006 | Implement `native-v2` manifest creation and validation, retaining file digests while fail-closing on version, provenance, source-ref, and exception-ID violations; expose reusable sidecar create/validate commands. | T001, T003 | - | `.github/scripts/native_cache_manifest.py` | 🟢 | `[X]` |
| T007 | Add the required Windows OpenSSL version input, fail only on source-build prerequisites, and checkout `refs/tags/openssl-${openssl_version}` instead of locating runner OpenSSL. | T004, T006 | - | `.github/actions/build-windows/action.yml` | 🟢 | `[X]` |
| T008 | Build/test shared OpenSSL with the documented `VC-WIN64A` target into an isolated prefix, then route both libssh2/libgit2 CMake link inputs and exported runtime DLLs to that prefix. | T007 | - | `.github/actions/build-windows/action.yml` | 🟢 | `[X]` |
| T009 | Version the Windows cache identity, validate source-build manifest fields on restore, and include its provenance sidecar in the Windows artifact/cache output. | T006, T008 | - | `.github/actions/build-windows/action.yml` | 🟢 | `[X]` |
| [//] T010 | Give Linux an explicit OpenSSL version input and source-build install prefix; remove runner-version discovery and record source-build provenance in its cache manifest and artifact sidecar. | T006 | `[//]` | `.github/actions/build-linux/action.yml` | 🟢 | `[X]` |
| [//] T011 | Emit a validated source-build provenance sidecar from the macOS native action, bound to its existing tagged OpenSSL input and exported artifact digest set. | T006 | `[//]` | `.github/actions/build-macos/action.yml` | 🟡 | `[X]` |
| [//] T012 | Emit a validated source-build provenance sidecar from the Android native action for each ABI, bound to its existing tagged OpenSSL input and exported artifact digest set. | T006 | `[//]` | `.github/actions/build-android/action.yml` | 🟡 | `[X]` |
| [//] T013 | Emit a validated source-build provenance sidecar from each iOS slice, preserving the configured version and source reference for later aggregate qualification. | T006 | `[//]` | `.github/actions/build-ios/action.yml` | 🟡 | `[X]` |

## Phase 4, Integration

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| T014 | Pass `OPENSSL_VERSION` into Windows and Linux build actions and remove the Windows test job's runner-OpenSSL prerequisite. | T009, T010 | - | `.github/workflows/build_package.yml` | 🟢 | `[X]` |
| T015 | Download and carry per-platform provenance sidecars with native artifacts through package assembly, including an iOS aggregate sidecar. | T011, T012, T013, T014 | - | `.github/workflows/build_package.yml` | 🟡 | `[X]` |
| T016 | Add a fail-closed release-qualification step that validates all sidecars against `OPENSSL_VERSION` and accepts normal `source-build` evidence. | T006, T015 | - | `.github/workflows/build_package.yml` | 🟡 | `[X]` |
| T017 | Extend release qualification to resolve only valid checked-in exceptions and reject them unless exact parity is proven across every participating platform; publish the verdict in the job summary before eligibility. | T002, T016 | - | `.github/workflows/build_package.yml` | 🟡 | `[X]` |

## Phase 5, Polish

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| T018 | Complete focused acceptance/failure tests for source-build acceptance, stale-cache provenance rejection, missing/expired exception rejection, unequal-sidecar parity rejection, and the expanded-artifact Windows plain-Dart loader proof. | T017 | - | `test/openssl_provenance_workflow_test.dart` | 🟡 | `[ ]` |

## Execution notes

- Scope is limited to pinned, reproducible OpenSSL source provenance, Windows package compatibility, cache/artifact evidence, and the documented exact-parity exception route.
- Do not add strict Git validation, Git-policy checks, secrets, credentials, publication changes, or Dart loader API changes.
- The Windows source-build commands and current-run binary behavior remain implementation/CI validation work; static planning does not claim they have already passed on `windows-latest`.

## Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-24 | Initial version generated by `/reversa-to-do` | reversa |
