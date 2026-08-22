# Dart FFI Facade, Technical Design

## Interface
| Symbol | Contract | Result | Confidence |
|---|---|---|---|
| `GetLastError.getLastError()` | no arguments | nullable `LibGit2Error` | 🟢 |
| `ToDartString.toDartString()` | native `char*` receiver | Dart `String` | 🟢 |
| `IsValidSHA1.isValidSHA1` | String receiver | boolean | 🟢 |
| `IsValidRefName.isValidRefName` | String receiver | boolean | 🟢 |
| `IsValidGitObjectType.isValidGitObjectType` | int receiver | boolean | 🟢 |

## Main Flow
1. The public barrel exports the generated ABI and handwritten modules. 🟢
2. A consumer calls generated libgit2 symbols or the typed helpers. 🟢
3. Native return codes may be contextualized through `git_error_last()`. 🟢

## Alternative Flows
- A null error pointer becomes `null`; a null string pointer becomes `''`. 🟢
- SHA/ref inputs failing the local predicates are rejected locally. The object-type helper only checks `value >= GIT_OBJECT_COMMIT` and therefore accepts undefined higher integers; it is a lower-bound predicate, not enum-membership validation. 🟢 [Codex cross-review]

## Dependencies and Decisions
- `dart:ffi` and `package:ffi` define the ABI and UTF-8 conversion boundary. 🟢
- Generated bindings are exported rather than wrapped completely, preserving low-level access. 🟢
- `LibGit2Error` borrows native memory; its lifetime is not independently stabilized. 🟡

## State and Observability
The facade owns no persistent state. It depends on loader globals initialized in `util.dart`. There are no logs or metrics in the facade; callers inspect return codes and last-error data. 🟢

## Risks and Gaps
- 🔴 The generated binding file is absent, so the full API cannot be enumerated from this checkout.
- 🟡 Ref-name validation is a local subset and may not exactly match every libgit2 rule.
- 🔴 The intended meaning of `isValidRefName` and `isValidGitObjectType` is unresolved: comments enumerate a stricter finite contract than the implementation enforces. [Codex cross-review]
- 🔴 Consumer usage and compatibility are outside this repository.
