# Native Loader and Lifecycle

## Overview
The loader must select, locate, preload, and open the correct native libgit2 artifact. The package-owned isolate-local `libgit2Runtime` performs the raw lifecycle transitions; both its `bindings` and `options` accessors ensure initialization before use. 🟢 cross-repository lifecycle research

## Responsibilities and Rules
- iOS resolves symbols from the process; Android opens `libgit2.so`; desktops try the bare name then the package-local artifact. 🟢
- Windows preloads OpenSSL DLLs and libssh2; Linux preloads libssh2; macOS expects static dependency linkage. 🟢
- Unsupported platforms and exhausted resolution strategies fail closed. 🟢
- Importing/exporting the library alone does not prove that native loading or initialization ran; access through the managed runtime does. 🟢 cross-repository lifecycle research
- `git2dart_binaries` owns raw init/shutdown and option-access ordering. Its existing ready runtime and public shutdown behavior remain intentionally unchanged; no automatic teardown or isolate-lifetime policy is introduced. 🟢 current ownership; 🟢 user-confirmed compatibility decision

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| NLL-RF-01 | Select the native loading strategy by runtime platform. | Must | Each supported platform reaches its documented artifact target. | 🟢 |
| NLL-RF-02 | Resolve package-local desktop artifacts when name lookup fails, but fail immediately with an explicit incomplete-package error when the required Windows bundled-library directory is absent. | Must | Loading succeeds independently of current working directory; a missing Windows bundle directory never falls back to a bare system library name. | 🟢 observed package-path behavior; 🟢 user-confirmed missing-bundle policy |
| NLL-RF-03 | Initialize libgit2 through the package-owned managed runtime before bindings or options are returned. | Must | `libgit2Runtime.bindings` and `.options` ensure initialization; raw init/shutdown calls remain in the binaries runtime only. | 🟢 cross-repository lifecycle research |
| NLL-RF-04 | Reject unsupported or unresolvable environments. | Must | A typed exception is raised and no usable global is exposed. | 🟢 |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| Portability | Support Android, iOS, Linux, macOS, and Windows. | `lib/src/util.dart`, `pubspec.yaml` | 🟢 |
| Determinism | Dependency preload order must be stable. | sorted Windows DLL discovery | 🟢 |
| Diagnostics | Loader failures must retain both name and package-path attempts. | stderr writes in `util.dart` | 🟢 |

## Acceptance Scenarios
```gherkin
Given a desktop process where the bare libgit2 name is unavailable
When the package configuration resolves git2dart_binaries
Then dependencies and the package-local libgit2 artifact are opened

Given an unsupported operating system
When native bootstrap starts
Then loading fails with UnsupportedError
```

## MoSCoW
Must: platform selection, package resolution, managed initialization, fail-closed errors, and preservation of the existing public lifecycle API. Won't introduce: automatic teardown or an isolate-lifetime policy. 🟢 user-confirmed compatibility decision

## Code Traceability
`lib/src/runtime.dart`; `lib/src/util.dart`; `test/libgit2_runtime_test.dart`; `test/runtime_loader_process_test.dart`; `test/fixtures/loader_probe.dart`. 🟢

## 2026-08-25 Re-extraction Contract

- One isolate-local runtime owns the selected handle, generated bindings view, option view, phase, call pins, and owner pins. 🟢
- Initialization succeeds only on a positive native count; every other result attempts one compensating shutdown. 🟢
- Shutdown is blocked by active calls or live owners, becomes terminal after success/fault, and is idempotent after successful completion. 🟢
- Desktop loading is bare-name then package fallback; Android has no package fallback; iOS uses process symbols. 🟢
- W002 proves isolated failure stages and declared payload loading locally, but does not observe the origin of a successful handle or real Android loading. 🟢 local; 🔴 platform outcome
- W006 proves bounded source structure, not process-global coordination with external consumers. 🟢 local; 🔴 external lifecycle
