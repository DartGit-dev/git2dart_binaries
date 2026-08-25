# Specification Impact Matrix

## Scope

This transverse matrix covers **8 feature boundaries**, **24 internal components**, and W001-W006. It describes architectural blast radius, not direct imports. A high rating means a change can invalidate a contract or release claim; it does not mean every implementation file must change.

Legend: **H** direct/high-risk contract, **M** meaningful indirect impact, **L** evidence or packaging check, **—** no material local dependency.

Feature abbreviations:

- DFF — `dart-ffi-facade`
- NLL — `native-loader-lifecycle`
- LGO — `libgit2-global-options`
- ATB — `android-tls-bootstrap`
- PPK — `platform-packaging`
- NBG — `native-build-bindings-generation`
- VRA — `validation-release-assembly`
- BPT — `behavior-proving-tests`

## Feature-to-feature impact

| Change source ↓ / impacted boundary → | DFF | NLL | LGO | ATB | PPK | NBG | VRA | BPT |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| DFF | H | M | M | L | L | M | M | H |
| NLL | M | H | M | M | H | H | H | H |
| LGO | M | M | H | M | L | H | H | H |
| ATB | L | M | M | H | M | L | H | H |
| PPK | L | H | L | M | H | H | H | H |
| NBG | H | H | H | M | H | H | H | H |
| VRA | M | M | M | M | H | H | H | H |
| BPT | L | L | L | L | L | M | H | H |

### Interpretation

- NBG and VRA have the widest blast radius because the publishable product is assembled rather than tracked.
- BPT normally changes evidence rather than public runtime behavior, but weakening its classification can falsely qualify every other feature.
- NLL ↔ PPK is high because filenames, package paths, dependency preload, and native load mode form one contract.
- ATB ↔ LGO/NLL is split by an external caller: extraction is local, while applying the returned path after managed initialization is outside the helper.

## Component-to-feature ownership

| Component | Primary feature | Secondary impact | Evidence authority |
|---|---|---|---|
| R01 Public Export Barrel | DFF | NLL, LGO, ATB | source and clean public compile |
| R02 Error/String/Validation Helpers | DFF | BPT | source/local unit; native error lifetime external |
| R03 Generated Libgit2 View | DFF | NBG, VRA | same-run generated artifact required |
| R04 Libgit2 Global Options | LGO | ATB, NBG | W001 local/native and hosted platform evidence |
| R05 Loader Plan Selector | NLL | PPK | W002 source/process/plan evidence |
| R06 Package Root Resolver | NLL | PPK, VRA | isolated consumer process |
| R07 Native Dependency Preloader | NLL | PPK, NBG | declared payload/host behavior |
| R08 Lifecycle State and Owner Leases | NLL | DFF | injected behavior plus W006 AST facts |
| R09 Runtime Facade | NLL | DFF, LGO | local runtime; external process coordination gap |
| R10 Android SSL Helper | ATB | NLL, LGO | W003 injected; device/HTTPS external |
| E01 BehaviorProofFixture | BPT | all executable watches | local fixture only |
| E02 ABI Probe | BPT | LGO | W001 exact declared payload |
| E03 Loader Probe | BPT | NLL, PPK | W002 exact process; handle origin gap |
| E04 TLS Injected Seam | BPT | ATB | W003 deterministic host behavior |
| E05 Cache Manifest CLI | BPT | NBG | W004 CLI fixture |
| E06 Platform Proof CLI | BPT | NBG, VRA | W004 CLI and hosted proof producer |
| E07 Consumer Bundle CLI | BPT | DFF, NLL, PPK, VRA | W005 local or same-run hosted bundle |
| E08 Architecture AST Facts | BPT | NLL | W006 parsed source structure |
| E09 Workflow Policy Facts | BPT | NBG, VRA | W006 bounded YAML graph |
| S01 Binding Generator | NBG | DFF, LGO, VRA | hosted producer required for current identity |
| S02 Platform Native Builders | NBG | NLL, PPK, VRA | hosted payload producer |
| S03 Cache/Provenance Publisher | NBG | VRA, BPT | manifest/proof records; cache hit is not acceptance |
| S04 Platform Validation Matrix | VRA | all runtime/package features | current hosted platform jobs |
| S05 Release Assembler and Publisher | VRA | NBG, PPK, BPT | current hosted + external registry |

## W001-W006 traceability

| Watch | Feature rule | Producing files/components | Acceptable observation | Does not prove | Red gap |
|---|---|---|---|---|---|
| W001 | 64-bit `size_t` preserves `0x100000011` | E02; `test/fixtures/abi_probe/abi_probe.dart`; option integration/bundle tests | available record with submitted=observed on declared 64-bit payload | all platforms or current workflow identity | RG-01, RG-08 |
| W002 | desktop bare-name→package fallback and terminal stages; Android no fallback | R05-R07, E03; `runtime.dart`, loader probe/process test | isolated error stages, declared load, host-independent Android plan | successful handle path or Android device load | RG-03 |
| W003 | cache after write; every dependency failure retryable | R10, E04; Android SSL helper/tests | injected directory/asset/write transitions | default Android storage, option apply, HTTPS, concurrency | RG-04 |
| W004 | artifact CLIs reject corrupt/unsafe/incomplete/mismatched/unreadable inputs | E05-E06; Python CLIs and fixture tests | valid zero plus independent negative non-zero/sanitized cases | current producer bytes, complete symlink/exception semantics | RG-01, RG-02 |
| W005 | injected binding/payload and bundle-only clean consumer | E07, S05; bundle CLI/test/workflow steps | exact package-config root plus public/native consumer result | authenticated same-run identity, non-Linux consumers, publication | RG-01, RG-02 |
| W006 | validation broadly reachable; exact-main publication after all gates | E08-E09, S04-S05; fact tools/tests/workflow | analyzer 8.2.0 AST facts and fail-closed YAML graph | GitHub execution/settings/secrets or pub.dev outcome | RG-06, RG-07 |

## Evidence-tier impact

| Change | Minimum acceptable evidence | Higher authority still required |
|---|---|---|
| Pure helper/predicate change | source + focused executable unit behavior | native consumer if native semantics are claimed |
| Lifecycle transition change | parsed AST ownership + injected state machine | external consumer/process balance for product claim |
| ABI/signature change | native fixture with exact matching payload | same-run hosted platform matrix |
| Loader/package path change | isolated clean subprocess and declared bundle | observed handle origin and relevant hosted platforms |
| Android TLS change | injected dependency state machine | emulator/device extraction, option apply and HTTPS |
| Cache/proof CLI change | exhaustive valid/negative fixture matrix | current producer outputs and release payload identity |
| Workflow DAG/condition change | fail-closed parsed graph | current GitHub run and external settings |
| Publication/version change | current all-gate main run | publisher execution and pub.dev registry observation |

## Change scenarios

| Change scenario | Impacted features | Required contract checks | Required evidence |
|---|---|---|---|
| Upgrade libgit2 | DFF, NLL, LGO, NBG, VRA, BPT | header/binding/native version unity, symbols, option enums/shapes | regenerated ABI, all platform builds/tests, W001, current same-run bundle |
| Upgrade libssh2/OpenSSL | NLL, PPK, NBG, VRA, BPT | linkage/preload, filenames, provenance, inventory | dependency inspection, loader tests, platform proofs, TLS/SSH behavior |
| Rename/move native artifact | NLL, PPK, NBG, VRA, BPT | builder export, package metadata, loader and release inventory | clean package load on affected platforms |
| Change lifecycle ownership | DFF, NLL, BPT | raw transition boundary, rollback, pins, shutdown/re-entry | AST facts, injected machine, isolated processes, external owner-drain evidence |
| Add/modify global option | DFF, LGO, NBG, BPT | discriminator, variadic shape, width, ownership, restoration | targeted native positive/error/restore test |
| Change Android CA flow | ATB, NLL, LGO, PPK, BPT | init ordering, asset path, write/commit/retry, apply path | W003 plus Android device HTTPS |
| Change cache manifest/proof schema | NBG, VRA, BPT | safe paths, exact metadata/files, version, provenance, aggregate scope | W004 matrices plus current producer/aggregate run |
| Change bundle input/origin | DFF, NLL, PPK, VRA, BPT | checkout rejection, exact root, payload inventory, proof content | W005 negative/positive and current same-run bundle |
| Change workflow trigger/needs/condition | NBG, VRA, BPT | all validation reachability, gate ordering, exact-main publisher | W006 facts plus observed PR/non-main/main runs |
| Change public version/exports | DFF, VRA, external `git2dart` | semver/podspec metadata, selected-pair compatibility | package consumer plus `git2dart` coordinator and registry |

## Feature-to-artifact map

| Feature | Primary implementation/config evidence | Current extraction artifacts | Canonical unit status |
|---|---|---|---|
| DFF | `lib/git2dart_binaries.dart`, `error.dart`, `extensions.dart` | code analysis, flowcharts, entity model | existing feature folder |
| NLL | `lib/src/runtime.dart`, `util.dart` | lifecycle/loader flowcharts, ADR-002/004/009 | existing feature folder |
| LGO | `lib/src/opts_bindings.dart`, ABI fixture | option/ABI flowcharts, ADR-001 | existing feature folder |
| ATB | `android_ssl_helper.dart`, assets, tests | TLS state machine/flowcharts, ADR-003 | existing feature folder |
| PPK | pubspec, CMake, podspecs, platform shims | artifact dictionary, packaging flowcharts | existing feature folder |
| NBG | composite actions, ffigen config, cache/proof scripts | generation/cache flowcharts, ADR-001/007/011 | existing feature folder |
| VRA | `build_package.yml`, release gates | release state machine, deployment, ADR-008/011 | existing feature folder |
| BPT | `tool/*.dart`, behavior tests/fixtures, replacement ledger | feature-005 unit, addendum, flowcharts, ADR-010 | current eight-file feature folder |

## High-risk contract matrix

| Contract | Primary features | Coupled components | Failure symptom |
|---|---|---|---|
| HC-01 ABI coherence | DFF, LGO, NBG | R03, R04, S01, S02 | compile/load/call mismatch |
| HC-02 artifact identity | NLL, PPK, NBG, VRA | R05-R07, S02-S05 | packaged library missing or wrong dependency |
| HC-03 lifecycle ownership | DFF, NLL | R08-R09, external consumer | premature shutdown, leak, terminal fault |
| HC-04 variadic option ABI | LGO, NBG | R04, E02, S01-S02 | truncation/signature corruption |
| HC-05 Android TLS sequence | ATB, NLL, LGO | R08-R10, external app | extraction succeeds but HTTPS fails |
| HC-06 evidence classification | BPT, all | E01-E09 | unavailable/static result reported as behavior |
| HC-07 same-run byte identity | NBG, VRA, BPT | S01-S05, E06-E07 | proof/bundle detached from payload |
| HC-08 authorization/coordination | VRA, external `git2dart` | E09, S04-S05 | publication bypass or incompatible pair |

## Cross-repository boundary

`git2dart_binaries` owns/pins the native ABI and package payload. The sibling `git2dart` relationship and its role as selected-pair coordinator are user-confirmed policy, not current evidence from this extraction. Any change to public exports, package version, generated ABI, lifecycle semantics, loader behavior, or Android TLS application requires a fresh `git2dart` consumer/coordinator run before product-level compatibility can be claimed.

## Current red-gap index

| Gap | Impacted contracts/features |
|---|---|
| RG-01 current hosted feature-005/five-platform run | HC-01, HC-02, HC-06, HC-07; NBG/VRA/BPT |
| RG-02 proof→payload→bundle→publication identity join | HC-07; NBG/VRA/BPT |
| RG-03 loaded handle origin | HC-02; NLL/PPK/BPT |
| RG-04 real Android TLS/concurrency/recovery | HC-05; ATB/NLL/LGO |
| RG-05 external `git2dart` lifecycle/coordinator | HC-03, HC-08; DFF/NLL/VRA |
| RG-06 pub.dev execution/acceptance | HC-08; VRA |
| RG-07 GitHub protections/tokens/approvals | HC-08; VRA |
| RG-08 generated/native bytes absent | HC-01, HC-02; DFF/LGO/NBG/VRA |
