# libgit2 Global Options

## Overview
Typed Dart methods must safely dispatch the variadic `git_libgit2_opts` entry point for supported option discriminators. 🟢

## Responsibilities and Rules
- Each discriminator must be paired with its exact FFI argument signature; complete correctness cannot be confirmed without the absent generated headers/bindings or full native coverage. 🔴 [Codex cross-review]
- Cover memory, cache, paths, TLS, identity, strictness, pack, HTTP, owner-validation, and extension policies. 🟢
- Callers own supplied/outer allocations and the obligation to call the matching libgit2 disposal function; libgit2 manages contents populated in `git_buf`/`git_strarray` until disposal. 🟢 current tests; 🟡 full API contract
- Reject negative pack maximum object sizes before native conversion. 🟢

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| LGO-RF-01 | Expose all 33 locally declared option methods and validate each discriminator/signature pair. | Must | Method count is locally confirmed; exact ABI correctness requires pinned-header comparison and native coverage. | 🟢 count; 🔴 complete ABI proof |
| LGO-RF-02 | Return native status codes unchanged. | Must | Success/error codes are observable by the caller. | 🟢 |
| LGO-RF-03 | Reject a negative `size_t` pack-object value. | Must | The wrapper throws `RangeError` without a native call. | 🟢 |
| LGO-RF-04 | Preserve caller ownership of native buffers and arrays. | Must | Tests explicitly dispose libgit2-owned output structures as required. | 🟢 |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| ABI correctness | Signatures must match pinned libgit2 1.9.6 headers. | wrappers exist, but generated bindings/headers are absent | 🔴 |
| Testability | Mutable global options must be restored after tests. | `test/opts_bindings_integration_test.dart` | 🟢 |
| Coverage | Every signature family needs at least one native test. | Current tests cover only a subset | 🟡 |

## Acceptance Scenarios
```gherkin
Given initialized libgit2 and a writable output pointer
When a get option wrapper is called
Then it returns the native status and writes the current value

Given a negative pack maximum object size
When the setter is called
Then RangeError is thrown before FFI dispatch
```

## MoSCoW
Must: discriminator/signature correctness, status passthrough, ownership, negative size guard. Should: full option-family tests. Could: higher-level Dart types. Won't infer: consumer policy values. 🟡

## Code Traceability
`lib/src/opts_bindings.dart`, `test/opts_bindings_integration_test.dart`, `integration_test/opts_bindings_integration_test.dart`. 🟢
