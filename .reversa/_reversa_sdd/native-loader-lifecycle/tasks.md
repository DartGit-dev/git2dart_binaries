# Native Loader and Lifecycle, Implementation Tasks

## Prerequisites
- [ ] Platform artifacts use the names in `platform-packaging/design.md`.
- [ ] Package metadata is available to the runtime.

## Tasks
- [ ] NLL-T-01, Implement platform filename and strategy selection. Origin: `lib/src/util.dart:16`. Done when five platform families and unsupported platforms match the requirements. Confidence: 🟢
- [ ] NLL-T-02, Implement desktop package-root fallback. Origin: `lib/src/util.dart:123`. Done when synchronous and JSON package-config paths resolve absolute roots. Confidence: 🟢
- [ ] NLL-T-03, Implement platform dependency preloading. Origin: `lib/src/util.dart:77`. Done when Windows ordering, Linux libssh2, and macOS static policy are preserved. Confidence: 🟢
- [ ] NLL-T-04, Recreate the package-owned managed runtime. Origin: `lib/src/runtime.dart:13`. Done when bindings/options both ensure initialization, raw lifecycle calls remain in the binaries runtime, object leases block premature shutdown, and the existing public lifecycle API is preserved. Confidence: 🟢 cross-repository lifecycle research; 🟢 user-confirmed compatibility decision

## Test Tasks
- [ ] NLL-TT-01, Test bare-name and package-path desktop loads from a foreign working directory.
- [ ] NLL-TT-01A, Exercise Windows fallback when the package-local `windows` directory is absent; require an explicit incomplete-package error and verify that no bare-name `libssh2.dll` lookup is attempted. Confidence: 🟢 user-confirmed missing-bundle policy [Codex cross-review]
- [ ] NLL-TT-02, Test unsupported platform and malformed/missing package config failures.
- [ ] NLL-TT-03, Verify required symbols and balanced init/shutdown in isolated processes.

## Suggested Order
Implement artifact contracts, dependency preload, root resolution, then lazy globals and explicit lifecycle tests. 🟢

## Pending Gaps
🔴 Verify production owner drainage, cross-isolate balance, actual loaded-handle origin, and current Android device loading. 🟢 The managed runtime already rejects failed initialization and attempts one compensating rollback.

## 2026-08-25 Completion Gates

- [ ] NLL-T-07, Preserve the four-phase checked lifecycle and compensating rollback. Origin: `lib/src/runtime.dart:112`. Done when positive, zero, negative, thrown-init, rollback-failure, and retry transitions pass. Confidence: 🟢.
- [ ] NLL-T-08, Preserve exact transient and persistent pin accounting. Origin: `lib/src/runtime.dart:163`, `lib/src/runtime.dart:337`. Done when callback/destructor failures retain correct pins and shutdown blocks. Confidence: 🟢.
- [ ] NLL-T-09, Emit successful handle-origin evidence. Origin: `test/fixtures/loader_probe.dart:16`. Done when bare versus package path is observed, not inferred from a supplied root. Confidence: 🔴 current gap.
- [ ] NLL-T-10, Validate external owner drainage and cross-isolate shutdown. Origin: architectural HC-03. Done when the real `git2dart` consumer balances ownership and terminal shutdown. Confidence: 🔴.
