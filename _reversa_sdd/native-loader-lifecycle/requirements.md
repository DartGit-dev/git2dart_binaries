# Native Loader and Lifecycle

## Overview
The loader must select, locate, preload, and open the correct native libgit2 artifact. The lazy `libgit2` global initializes libgit2 when read; `libgit2Opts` can be read independently and does not itself force initialization. 🟢 [Codex cross-review]

## Responsibilities and Rules
- iOS resolves symbols from the process; Android opens `libgit2.so`; desktops try the bare name then the package-local artifact. 🟢
- Windows preloads OpenSSL DLLs and libssh2; Linux preloads libssh2; macOS expects static dependency linkage. 🟢
- Unsupported platforms and exhausted resolution strategies fail closed. 🟢
- Dart top-level globals are lazy: importing/exporting the library alone does not prove that native loading or initialization ran. 🟢 [Codex cross-review]
- Production shutdown ownership and any mandatory ordering before option calls are not locally defined. 🔴

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| NLL-RF-01 | Select the native loading strategy by runtime platform. | Must | Each supported platform reaches its documented artifact target. | 🟢 |
| NLL-RF-02 | Resolve package-local desktop artifacts when name lookup fails. | Must | Loading succeeds independently of current working directory. | 🟢 |
| NLL-RF-03 | Initialize libgit2 when the lazy `libgit2` global is first read. | Must | `_initializeLibgit2` constructs the binding, calls `git_libgit2_init()`, and only then returns the global value. | 🟢 |
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
Must: platform selection, package resolution, lazy `libgit2` initialization, fail-closed errors. Should: define option-call ordering. Could: explicit lifecycle owner. Won't assume: consumer shutdown policy. 🔴

## Code Traceability
`lib/src/util.dart`; packaging tests in `test/windows_packaging_test.dart` and `test/macos_dylib_packaging_test.dart`. 🟢
