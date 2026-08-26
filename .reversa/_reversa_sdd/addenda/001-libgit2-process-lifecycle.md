# Addendum: Process-global libgit2 lifecycle ownership

> Feature: `001-libgit2-process-lifecycle`
> Date: `2026-08-24`
> Scenario: `legacy`

## Vigência

Vigente desde 2026-08-24.

Superado pela re-extração de 2026-08-25.

## Resumo da entrega

`git2dart_binaries` now owns the public, managed libgit2 lifecycle: one checked
native lease per participating isolate, reusable logical call and owner leases,
exact-once cleanup, and guarded terminal shutdown. The breaking lifecycle API
replaces the legacy globals, while raw generated lifecycle methods remain an
unsupported escape hatch. All 17 of 17 feature actions are completed. Delivery
evidence is recorded in commits `ea87cf2` (`feat: manage libgit2 process
lifecycle`) and `774c06e` (`fix: harden native packaging and diagnostics`).

## Impacto por artefato da extração

| Artefato | Seção | Tipo de impacto | Delta |
|---|---|---|---|
| `_reversa_sdd/architecture.md` | Component responsibilities — Generated FFI layer | componente-novo | The selected 1.12.1 generated bindings are now present; their raw lifecycle methods are used by the runtime owner only. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Native loader/lifecycle | regra-nova | `Libgit2Runtime` adds checked isolate-local lease accounting, logical pins, rollback/transfer, exact-once owner cleanup, and guarded terminal shutdown. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Native loader/lifecycle | regra-alterada | Eager unchecked initialization and legacy globals are replaced by the managed runtime compatibility path. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Dart FFI facade | regra-nova | Stable lifecycle diagnostics now distinguish initialization, rollback, shutdown, and finalizer-cleanup failures. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Dart FFI facade | regra-alterada | The supported public lifecycle surface is `libgit2Runtime`, `Libgit2Runtime`, `Libgit2RuntimeState`, and `Libgit2OwnerLease`; `libgit2` and `libgit2Opts` source compatibility is intentionally removed. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Dart FFI facade | regra-alterada | Documentation now directs consumers to managed use, owner leases, terminal shutdown, and the unsupported raw-method escape hatch. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Validation/release assembly | regra-nova | Deterministic runtime tests cover 15 lifecycle state-machine scenarios. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Validation/release assembly | delta-de-contrato-externo | Public-surface tests lock runtime export, removal of legacy globals, and the supported raw-call boundary. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Validation/release assembly | regra-nova | Native integration tests verify real two-isolate process-count composition. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Validation/release assembly | regra-alterada | Global-options integration uses cached managed bindings/options and one exact isolate shutdown. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Platform packaging | regra-alterada | Windows packaging verifies managed package-root loading in a plain-Dart subprocess; the later packaging/diagnostics hardening is recorded by `774c06e`. |
| `_reversa_sdd/architecture.md` | Component responsibilities — Platform packaging | regra-alterada | macOS packaging removes manual lifecycle over-balancing and specifies managed package-root use; execution remains host-skipped pending its platform gate or CI. |

## Regras sob vigilância

- `W001` — `_reversa_forward/001-libgit2-process-lifecycle/regression-watch.md`
- `W002` — `_reversa_forward/001-libgit2-process-lifecycle/regression-watch.md`
- `W003` — `_reversa_forward/001-libgit2-process-lifecycle/regression-watch.md`
- `W004` — `_reversa_forward/001-libgit2-process-lifecycle/regression-watch.md`
- `W005` — `_reversa_forward/001-libgit2-process-lifecycle/regression-watch.md`

## Fontes

- `_reversa_forward/001-libgit2-process-lifecycle/legacy-impact.md`
- `_reversa_forward/001-libgit2-process-lifecycle/regression-watch.md`
- `_reversa_forward/001-libgit2-process-lifecycle/requirements.md`
- `_reversa_forward/001-libgit2-process-lifecycle/progress.jsonl`
- `_reversa_forward/001-libgit2-process-lifecycle/actions.md`

## Atualização 2026-08-24

- The targeted Flutter suite completed with **22 passed**.
- `libgit2_lifecycle_integration_test.dart` was skipped because it requires an expanded package containing native libgit2 artifacts; this is an unavailable-artifact validation boundary, not a product regression.
- `opts_bindings_integration_test.dart` could not load `F:/git2dart_binaries/windows/libssh2.dll` (Win32 error 126). Complete native ABI proof therefore remains a gap until an expanded package with the required native artifacts is available.

## Atualização 2026-08-24

- Four version-matched package 1.12.1 DLLs (`libcrypto-3-x64.dll`, `libssl-3-x64.dll`, `libssh2.dll`, and `libgit2.dll`) were copied into `windows/`; source and target SHA-256 values were checked.
- `flutter test -j 1 test/opts_bindings_integration_test.dart test/libgit2_lifecycle_integration_test.dart test/windows_packaging_test.dart` passed **16 tests**: all 12 shown native-options integration tests, the two-isolate lifecycle test, and three Windows packaging/package-root loader tests.
- This supersedes the preceding unavailable-artifact validation gap for that local test coverage: native ABI behavior is now locally evidenced there. It does not establish all 33 bindings, current CI or release evidence, or cross-repository consumer proof; those claims remain gaps.

## Atualizacao 2026-08-24

- E001 closes the generated-build and release-output boundary: `lib/src/bindings.dart` and platform-native artifacts are build/release outputs rather than source-checkout inputs. Checkout tests that require an expanded package must declare and supply its artifact-root precondition.
- The four untracked Windows runtime DLLs are removed from the feature's intended checkout scope. This is a `regra-alterada` delta for `_reversa_sdd/domain.md#Build, test, and publication rules`; it preserves the managed lifecycle contract while keeping generated artifacts out of source-checkout validation.
- All 18 of 18 actions, including E001, are now completed. OpenSSL source parity and strict Git validation remain separate, unmodified work.
