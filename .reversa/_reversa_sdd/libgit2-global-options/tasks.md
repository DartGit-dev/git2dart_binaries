# libgit2 Global Options, Implementation Tasks

## Prerequisites
- [ ] Acquire the matching official libgit2 1.9.6 artifact from the server, downloading that exact version when it is not available locally; reproducibly generate the Dart FFI bindings from its headers. Keep any pre-generated bindings file debug/verification-only and exclude it from the production package. Confidence: 🟢 user-confirmed ABI artifact policy
- [ ] Loader initialization is complete.

## Tasks
- [ ] LGO-T-01, Define native/Dart typedefs for every argument shape from the reproducibly generated official-header bindings. Origin: `lib/src/opts_bindings.dart:533`. Done when analyzer and native smoke tests validate all shapes. Confidence: 🟢 user-confirmed ABI artifact policy
- [ ] LGO-T-02, Implement the 33 discriminator-specific public methods. Origin: `lib/src/opts_bindings.dart:29`. Done when each method maps to the pinned header constant. Confidence: 🟢
- [ ] LGO-T-03, Preserve status passthrough and pointer ownership. Origin: `lib/src/opts_bindings.dart:108`. Done when callers can inspect errors and dispose outputs. Confidence: 🟢
- [ ] LGO-T-04, Enforce non-negative pack object sizes. Origin: `lib/src/opts_bindings.dart:425`. Done when negative input throws without dispatch. Confidence: 🟢

## Test Tasks
- [ ] LGO-TT-01, Port existing memory, cache, path, user-agent, pack, owner, and extension tests.
- [ ] LGO-TT-02, Add complete native coverage for every exposed global-options binding; do not accept the full option set as supported until all coverage passes. Confidence: 🟢 user-confirmed coverage gate
- [ ] LGO-TT-03, Restore all mutated global values in teardown.

## Suggested Order
Generate constants, define signature families, add wrappers, then run isolated state-restoring tests. 🟢

## Pending Gaps
🔴 Validate every exposed wrapper with complete native coverage and define consumer concurrency policy for global mutations. The ABI artifact source and production-shipping boundary are confirmed. 🟢 user-confirmed policy
