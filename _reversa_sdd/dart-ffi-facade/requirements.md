# Dart FFI Facade

## Overview
The package must expose the generated libgit2 ABI and the handwritten Dart helpers used to validate inputs and translate native errors. 🟢

## Responsibilities and Rules
- Export bindings, loader globals, option wrappers, Android TLS helper, errors, and extensions from one public library. 🟢
- Convert a null native string pointer to an empty Dart string; decode non-null pointers as UTF-8. 🟢
- Apply the local SHA-1, ref-name, and object-type predicates before native use where callers choose them. The ref predicate is incomplete relative to Git's full format rules, and the object predicate is only a lower-bound check. 🟢 implementation; 🔴 intended validation contract [Codex cross-review]
- The generated `bindings.dart` API is required but absent from the tracked source checkout. 🔴

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| DFF-RF-01 | Provide a single public export surface for native and helper APIs. | Must | Importing `git2dart_binaries.dart` makes all declared exports available. | 🟢 |
| DFF-RF-02 | Represent the last libgit2 error as nullable Dart data. | Must | Null native errors return null; present errors expose message and class. | 🟢 |
| DFF-RF-03 | Reproduce the current SHA-1, ref-name, and object-type predicates and decide whether they promise full Git validity. | Should | Current boundary behavior is tested; full Git validation remains a stakeholder decision. | 🟢 current behavior; 🔴 intended contract |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| ABI safety | Generated declarations and native binaries must derive from the same libgit2 version. | `ffigen.yaml`; workflow version pins | 🟢 |
| Ownership | Borrowed native error/string memory must not be freed by these wrappers. | `lib/src/error.dart`, `lib/src/extensions.dart` | 🟢 |
| Compatibility | The external `git2dart` consumer must compile against this export surface. | README only; consumer repository not inspected | 🟡 |

## Acceptance Scenarios
```gherkin
Given generated bindings and a loadable native library
When a consumer imports the public library
Then the generated ABI and handwritten helpers are available

Given a null native character pointer
When it is converted to a Dart string
Then the result is an empty string without dereferencing the pointer
```

## MoSCoW
Must: stable export barrel and error conversion. Should: validation helpers. Could: additional convenience validation. Won't infer: high-level Git domain operations, which are absent locally. 🟢

## Code Traceability
`lib/git2dart_binaries.dart`, `lib/src/error.dart`, `lib/src/extensions.dart`, `ffigen.yaml`. 🟢
