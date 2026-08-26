# Regression watch: Process-global libgit2 lifecycle ownership

> Feature: `001-libgit2-process-lifecycle`
> Created: `2026-08-22`
> Current round: Gate 2 binaries GREEN; consumer gate pending

## Active watch items

| ID | Origin (file, section) | Expected rule after change | Verification type | Violation signal |
|----|------------------------|----------------------------|-------------------|------------------|
| W001 | `_reversa_sdd/domain.md#Loader and lifecycle rules`, rules 7–10 | Platform selection and package-owned loading remain inside `git2dart_binaries`: iOS process image, Android app/system loader, desktop bare-name then package-root fallback. | presence + behavior | `DynamicLibrary`, platform target names, dependency paths, or package-root resolution move into `git2dart` or another consumer. |
| W002 | `_reversa_sdd/domain.md#Loader and lifecycle rules`, rule 11 | Loader and dependency failures remain fail-closed, logged, and rethrown. | behavior | A failed load leaves a usable/cached runtime or silently continues. |
| W003 | `_reversa_sdd/domain.md#Loader and lifecycle rules`, rule 12 | Windows fallback preloads matching OpenSSL DLLs, then `libssh2.dll`, before opening libgit2. | ordering | Dependency order changes or versioned OpenSSL discovery is removed. |
| W004 | `_reversa_sdd/domain.md#Android TLS rules`, rule 15 | Checked libgit2 initialization precedes Android certificate configuration and no transparent post-shutdown epoch replays global options. | ordering + absence | Certificate configuration can run before the managed lease, or managed access silently reinitializes after shutdown. |
| W005 | `_reversa_sdd/domain.md#ABI and version rules`, rules 1 and 3 | Generated bindings and native artifacts stay on the same pinned libgit2 version and retain required lifecycle exports. | identity + presence | Package/binding/native versions diverge, or init/shutdown symbols/signatures disappear. |
| W006 | `_reversa_sdd/domain.md#Build and test rules`, rule 35 | Generated bindings and platform-native artifacts remain build/release outputs rather than source-checkout inputs; any expanded-package test explicitly declares and supplies its artifact-root precondition. | boundary + precondition | A checkout test commits or silently relies on generated/assembled artifacts without declaring an expanded-package artifact root. |

## Observations

The following implemented feature rules originated as new requirements or a former 🔴 legacy gap, so they remain unweighted until a future `/reversa` re-extraction confirms them as 🟢:

- RF-01/RF-02: one checked positive native increment per participating isolate; repeated bindings/options/call/owner access reuses it.
- RF-03–RF-07: transient and persistent logical pins, exact-once cleanup, rollback/transfer, and failure retention.
- RF-08–RF-10: guarded, idempotent, calling-isolate-scoped, terminal shutdown; positive remaining process count is valid.
- RF-11/RF-12: legacy lifecycle globals are absent; the generated raw lifecycle methods remain an accepted unsupported escape hatch, while supported package and migrated-consumer code use the runtime owner.
- Gate 2 evidence is `dart analyze` clean plus `33 passed / 2 macOS-only skipped` on Windows, including real two-isolate native-count, options, and plain-Dart loader scenarios.
- The Gate 2 binding file is byte-identical to installed package 1.12.1: SHA-256 `C2C124AA68CD763CC219F92AB03852A96E03D1B8ECA88DAB28D059177D02E925`.
- Consumer integration remains unproved until the separate `git2dart` gate inventories ownership and migrates its call sites.

## Re-extraction history

### Re-extração 2026-08-25 17:46

| ID | Veredito | Observação |
|----|----------|------------|
| W001 | 🟢 verde | Platform selection and package-owned loading remain explicit in `_reversa_sdd/domain.md` BR-029–BR-034 and the runtime components. |
| W002 | 🟢 verde | BR-033 and BR-035 preserve terminal two-stage diagnostics, rethrow, and fail-closed loader behavior. |
| W003 | 🟢 verde | BR-034 preserves Windows preload order: version-agnostic crypto/SSL families, then `libssh2.dll`, then libgit2. |
| W004 | 🟢 verde | BR-037 preserves init-before-certificate ordering; the terminal lifecycle rules reject post-shutdown managed re-entry. |
| W005 | 🟢 verde | BR-009–BR-015 preserve the pinned libgit2 ABI/binary identity and required lifecycle surface. |
| W006 | 🟢 verde | BR-010/BR-011 and the evidence specs preserve generated bindings/native payloads as declared build/release inputs, not silent checkout prerequisites. |

None.

## Archived

None.
