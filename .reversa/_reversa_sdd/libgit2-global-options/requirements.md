# libgit2 Global Options

## Overview
Typed Dart methods must safely dispatch the variadic `git_libgit2_opts` entry point for supported option discriminators. 🟢

## Responsibilities and Rules
- Each discriminator must be paired with its exact FFI argument signature. The authoritative source is the official libgit2 1.9.6 headers plus reproducible Dart FFI binding generation; a pre-generated bindings file is debug/verification material only and must not ship in the production package. Obtain the matching official artifact from the server first; if the exact version is unavailable locally, download that exact version. Complete native coverage is mandatory before all bindings are accepted as supported. 🟢 user-confirmed ABI and coverage policy [Codex cross-review]
- Cover memory, cache, paths, TLS, identity, strictness, pack, HTTP, owner-validation, and extension policies. 🟢
- Callers own supplied/outer allocations and the obligation to call the matching libgit2 disposal function; libgit2 manages contents populated in `git_buf`/`git_strarray` until disposal. 🟢 current tests; 🟡 full API contract
- Reject negative pack maximum object sizes before native conversion. 🟢

## Functional Requirements
| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| LGO-RF-01 | Expose all 33 locally declared option methods and validate each discriminator/signature pair against reproducibly generated bindings from official libgit2 1.9.6 headers. | Must | Method count is locally confirmed; acceptance as supported requires the official exact-version artifact, reproducible generation, and complete native coverage. Pre-generated bindings remain debug-only and are excluded from the production package. | 🟢 count; 🟢 user-confirmed ABI and coverage policy |
| LGO-RF-02 | Return native status codes unchanged. | Must | Success/error codes are observable by the caller. | 🟢 |
| LGO-RF-03 | Reject a negative `size_t` pack-object value. | Must | The wrapper throws `RangeError` without a native call. | 🟢 |
| LGO-RF-04 | Preserve caller ownership of native buffers and arrays. | Must | Tests explicitly dispose libgit2-owned output structures as required. | 🟢 |

## Non-Functional Requirements
| Type | Requirement | Evidence | Confidence |
|---|---|---|---|
| ABI correctness | Signatures must match official libgit2 1.9.6 headers through reproducible binding generation. | User-confirmed artifact-acquisition and production-shipping policy | 🟢 user-confirmed policy |
| Testability | Mutable global options must be restored after tests. | `test/opts_bindings_integration_test.dart` | 🟢 |
| Coverage | Every globally exposed option binding must have native coverage before the set is accepted as supported. | Current tests cover only a subset; complete coverage is a user-confirmed acceptance gate. | 🟢 user-confirmed coverage gate |

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
Must: discriminator/signature correctness from official headers and reproducible generation, status passthrough, ownership, negative size guard, and complete native coverage before support is declared. Could: higher-level Dart types. Won't infer: consumer policy values. 🟢 user-confirmed ABI and coverage policy

## Code Traceability
`lib/src/opts_bindings.dart`, `test/opts_bindings_integration_test.dart`, `integration_test/opts_bindings_integration_test.dart`. 🟢
