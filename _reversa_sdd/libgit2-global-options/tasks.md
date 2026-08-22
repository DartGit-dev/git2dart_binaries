# libgit2 Global Options, Implementation Tasks

## Prerequisites
- [ ] Generated libgit2 enums and structs match the native binary.
- [ ] Loader initialization is complete.

## Tasks
- [ ] LGO-T-01, Define native/Dart typedefs for every argument shape. Origin: `lib/src/opts_bindings.dart:533`. Done when analyzer and native smoke tests validate all shapes. Confidence: 🟢
- [ ] LGO-T-02, Implement the 33 discriminator-specific public methods. Origin: `lib/src/opts_bindings.dart:29`. Done when each method maps to the pinned header constant. Confidence: 🟢
- [ ] LGO-T-03, Preserve status passthrough and pointer ownership. Origin: `lib/src/opts_bindings.dart:108`. Done when callers can inspect errors and dispose outputs. Confidence: 🟢
- [ ] LGO-T-04, Enforce non-negative pack object sizes. Origin: `lib/src/opts_bindings.dart:425`. Done when negative input throws without dispatch. Confidence: 🟢

## Test Tasks
- [ ] LGO-TT-01, Port existing memory, cache, path, user-agent, pack, owner, and extension tests.
- [ ] LGO-TT-02, Add one native round trip per currently untested signature/option family.
- [ ] LGO-TT-03, Restore all mutated global values in teardown.

## Suggested Order
Generate constants, define signature families, add wrappers, then run isolated state-restoring tests. 🟢

## Pending Gaps
🔴 Validate the untested wrappers against libgit2 1.9.6 and define consumer concurrency policy for global mutations.
