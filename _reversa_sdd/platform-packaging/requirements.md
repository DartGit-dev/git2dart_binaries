# Platform Packaging

## Overview
The package must deliver native artifacts under filenames and package-manager declarations that match the Dart loader on Android, iOS, Linux, macOS, and Windows. 🟢

## Responsibilities and Rules
- Android bundles `libgit2.so` and runtime dependencies per ABI; iOS vendors and force-loads four XCFrameworks. 🟢
- Linux bundles `libgit2.so` and expects `libssh2.so`; macOS vendors `libgit2.dylib` with static libssh2/OpenSSL linkage. 🟢
- Windows bundles libgit2, libssh2, and versioned OpenSSL DLLs. 🟢
- Artifact names, install names, loader targets, and manifests must agree. 🟢

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| PPK-RF-01 | Declare all five FFI plugin platforms. | Must | Flutter recognizes each plugin target from `pubspec.yaml`. | 🟢 |
| PPK-RF-02 | Bundle each platform's required native artifacts. | Must | Recipes and destinations are confirmed; current assembled-app contents require CI/runtime evidence. | 🟢 recipe; 🔴 current artifact proof |
| PPK-RF-03 | Preserve iOS process-symbol visibility and macOS install-name compatibility. | Must | Force-load/install-name recipes are confirmed; current runtime resolution requires an observed build/test. | 🟢 recipe; 🔴 current runtime proof |
| PPK-RF-04 | Ship the CA bundle as a Flutter asset. | Must | Package-qualified asset lookup succeeds. | 🟢 |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| Portability | One pub package supports five platform families. | plugin declarations and manifests | 🟢 |
| Runtime compatibility | Packaged names equal loader names. | CMake/podspecs and `util.dart` | 🟢 |
| Metadata consistency | The intended synchronization policy for platform package versions is unknown; current podspecs are 1.11.2 while `pubspec.yaml` is 1.12.1. | podspecs and `pubspec.yaml` | 🔴 |

## Acceptance Scenarios
```gherkin
Given an assembled package for a supported platform
When a Flutter application is built and launched
Then the loader can resolve libgit2 and its required dependencies

Given a macOS package
When its dylib metadata is inspected
Then its id is @rpath/libgit2.dylib and no Homebrew dependency leaks remain
```

## MoSCoW
Must: plugin declarations, artifact sets, loader-name alignment, Apple linkage. Should: synchronized metadata versions. Could: remove unused method-channel samples. Won't infer: operating-system signing/notarization policy. 🔴

## Code Traceability
`pubspec.yaml`; `android/`, `ios/`, `linux/`, `macos/`, and `windows/` manifests and shims. 🟢
