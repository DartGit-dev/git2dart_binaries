# Domain Model and Implicit Rules

## Extraction boundary

This repository is a native-runtime distribution package and release factory, not an end-user business application. Its domain is the controlled production of a Dart FFI ABI, native artifact loading and lifecycle, platform payload construction, evidence qualification, and publication eligibility.

This re-extraction describes the **2026-08-25 working tree** on branch `1.12.2`, with `b372be1` as the checked-out commit and feature `005-behavior-proving-tests` present as uncommitted working-tree changes. Therefore:

- 🟢 **CONFIRMED** means directly supported by the current local source, configuration, tests, Git history, or a locally executed result recorded by the immediately preceding Archaeologist phase.
- 🟡 **INFERRED** means a likely intent or an evidence claim whose authority is narrower than its label suggests.
- 🔴 **GAP** means the claim needs a current hosted workflow, generated/native artifact, device, external service, or neighboring repository.

The separate `git2dart` repository was not inspected. Historical workflow run `32750817127` is useful evidence for revision `b372be1`, but it predates feature 005 and cannot prove the current working tree.

## Ubiquitous language

| Term | Meaning | Confidence |
|---|---|---|
| Source checkout | Tracked source and recipes; intentionally excludes the authoritative generated binding and native payload | 🟢 |
| Expanded package | Checkout content plus a generated binding and platform payloads assembled by CI | 🟢 |
| Generated binding | `lib/src/bindings.dart`, generated from pinned official libgit2 headers and forbidden as a tracked fallback | 🟢 policy; 🔴 current artifact absent |
| Native payload | Platform-specific libgit2 and required dependency files injected into tests and release assembly | 🟢 recipe; 🔴 current five-platform bytes absent |
| Managed runtime | `Libgit2Runtime` plus `Libgit2RuntimeState`, the supported isolate-local lifecycle owner | 🟢 |
| Native lease | At most one successful libgit2 initialization increment owned by one Dart isolate runtime | 🟢 local state; 🔴 process-wide cross-isolate count in current run |
| Owner lease | Exact-once logical pin preventing shutdown while a persistent native owner exists | 🟢 |
| Package fallback | Desktop retry from a resolved package root after bare-name loading fails | 🟢 |
| Evidence tier | Static, parsed, deterministic, fixture/native, hosted same-run, or external/publication authority | 🟢 |
| Unavailable | Declared prerequisite was not supplied; no behavior pass may be inferred | 🟢 |
| Same-run | Artifact routing within one GitHub workflow run; not a property proven by a caller-supplied string | 🟢 route; 🔴 cryptographic attestation |
| Cache manifest | Exact metadata and file hash/size contract used before native cache reuse | 🟢 |
| Platform release proof | Producer record of inventory, load/link check, versions, and optional Apple attestation | 🟢 schema; variable semantic strength |
| Release eligibility | Ordered local/hosted gates that must succeed before the credential-bearing publish step is reachable | 🟢 workflow model |
| Publication | External registry acceptance by pub.dev, distinct from a successful dry run or workflow step definition | 🟢 distinction; 🔴 current result |

## Rule catalogue

### Evidence authority (BR-001–BR-008)

1. **BR-001 — Match authority to the claim.** 🟢 A declaration proves presence or shape; it does not prove runtime reachability, native execution, hosted artifact transfer, or publication.
2. **BR-002 — Source text is not feature-005 acceptance.** 🟢 W001–W006 acceptance must use executable, AST, CLI, subprocess, bundle, or parsed-graph evidence; source substring checks may remain only for explicitly out-of-scope textual policies.
3. **BR-003 — Parsed facts are modeled facts.** 🟢 Analyzer/YAML parsers prove properties of their local model, not full Dart element semantics or GitHub Actions service evaluation.
4. **BR-004 — `unavailable` is not `passed`.** 🟢 Native prerequisites may be declared unavailable, but a green enclosing test must not be reported as the unavailable behavior having executed.
5. **BR-005 — Skips require an explicit prerequisite boundary.** 🟢 Host/platform absence may suppress only the corresponding native observation; same-run CI remains authoritative after required artifacts are injected.
6. **BR-006 — Same-run provenance comes from routing.** 🟢 In the current design it comes from `download-artifact` within the producing workflow run; `binding_origin: same-run` and `bundle-proof.json` are assertions, not independent attestations.
7. **BR-007 — Historical success is revision-scoped.** 🟢 A pre-feature-005 green workflow proves only that predecessor revision and cannot establish current W001–W006 gates.
8. **BR-008 — External behavior stays external.** 🟢 Local fixtures do not prove the neighboring `git2dart` consumer, pub.dev acceptance, GitHub secret authorization, or repository protections.

### ABI and generated-binding integrity (BR-009–BR-016)

9. **BR-009 — One pinned libgit2 source controls ABI and binaries.** 🟢 Header generation and all platform native builds use workflow `LIBGIT2_VERSION=1.9.6`.
10. **BR-010 — Generated bindings are CI-owned.** 🟢 `lib/src/bindings.dart` must be generated from pinned official headers, remain untracked, and be transferred from the same workflow run into validation and release assembly.
11. **BR-011 — No local binding fallback.** 🟢 A tracked, stale, checkout-local, or ambient cached binding is not authoritative production input even when it compiles.
12. **BR-012 — Build flags affecting ABI must agree.** 🟢 Experimental SHA-256 support is enabled in generation and native builds.
13. **BR-013 — Essential exports must exist before artifact acceptance.** 🟢 Native builders check required libgit2 symbols before exporting payloads.
14. **BR-014 — Variadic discriminators and widths are inseparable.** 🟢 Each `git_libgit2_opts` discriminator must use its exact `Size`, `IntPtr`, pointer, buffer, string, or integer tuple.
15. **BR-015 — W001 requires an above-32-bit observation.** 🟢 On a declared 64-bit payload, `0x100000011` must cross the public/native `size_t` path unchanged and the original global option must be restored.
16. **BR-016 — Reject invalid signed-to-unsigned input locally.** 🟢 Negative pack maximum object size throws `RangeError` before native `size_t` conversion; other option validation generally remains native-side.

### Managed libgit2 lifecycle (BR-017–BR-028)

17. **BR-017 — The managed runtime is the supported lifecycle owner.** 🟢 Raw `git_libgit2_init`/`shutdown` transitions are structurally confined to `runtime.dart`, although generated raw methods remain technically callable.
18. **BR-018 — Runtime construction does not imply initialization.** 🟢 Loading the library and constructing binding views precede the first checked initialization request.
19. **BR-019 — Initialization succeeds only with a positive count.** 🟢 Zero, negative, or thrown initialization enters rollback handling.
20. **BR-020 — Failed initialization must be balanced.** 🟢 One shutdown rollback is attempted after every non-positive or throwing initialization.
21. **BR-021 — Successful rollback preserves retryability.** 🟢 The phase remains `uninitialized` and a checked initialize exception is raised.
22. **BR-022 — Failed rollback is terminal.** 🟢 A negative or throwing rollback moves the runtime to `faulted`; managed re-entry is rejected.
23. **BR-023 — Transient calls pin shutdown.** 🟢 `withCall` increments `activeCallCount` and decrements it in `finally`, including callback failure.
24. **BR-024 — Persistent owners pin shutdown exactly once.** 🟢 Acquire increments `liveOwnerCount`; release, rollback-construction, or transfer may complete the lease once.
25. **BR-025 — Destructor failure retains the pin.** 🟢 Owner completion is recorded only after its destructor succeeds; failure prevents unsafe shutdown.
26. **BR-026 — Finalizers report but do not throw across the boundary.** 🟢 Finalizer cleanup errors become `finalizerCleanup` diagnostics; deterministic release remains the consumer obligation.
27. **BR-027 — Shutdown is guarded and terminal.** 🟢 Active calls/owners reject it; successful shutdown caches a non-negative result; `terminated` and `faulted` reject reinitialization.
28. **BR-028 — Isolate-local accounting is not process-global proof.** 🟡 Each isolate intends at most one native increment, but current cross-isolate/native-count and external owner-drain behavior remain unobserved.

### Native loader behavior (BR-029–BR-036)

29. **BR-029 — Platform selection is explicit.** 🟢 iOS uses the process image; Android uses `libgit2.so` without package fallback; Linux/macOS/Windows use bare name then package fallback.
30. **BR-030 — Desktop bare-name loading comes first.** 🟢 Existing application-loader packaging remains the primary route.
31. **BR-031 — Desktop fallback is package-root based.** 🟢 Root resolution tries an explicit override, synchronous package URI, then package-config sources; current working directory alone is insufficient.
32. **BR-032 — Android fails after the first loader attempt.** 🟢 It logs the bare target and rethrows; it must not silently gain a desktop package directory.
33. **BR-033 — Desktop terminal diagnostics represent both stages.** 🟢 Final failure includes the bare attempt and the current fallback stage and rethrows the fallback error.
34. **BR-034 — Dependencies load before the package-local library.** 🟢 Linux preloads `libssh2.so`; Windows preloads sorted `libcrypto*.dll`, sorted `libssl*.dll`, then `libssh2.dll`; macOS expects static dependencies.
35. **BR-035 — Loader failure is fail-closed.** 🟢 Missing roots, dependencies, or libraries do not downgrade to native-disabled success.
36. **BR-036 — A successful probe needs origin evidence.** 🔴 Current probes report a supplied package root and successful status but not the actual opened handle path; ambient loader resolution can still mask fallback origin.

### Android TLS bootstrap (BR-037–BR-042)

37. **BR-037 — TLS configuration is explicitly ordered.** 🟢 libgit2 initialization precedes certificate extraction/application because early configuration can be overwritten.
38. **BR-038 — The CA bundle is a package asset.** 🟢 The helper loads `packages/git2dart_binaries/assets/certs/cacert.pem` and targets temporary `cacert.pem`.
39. **BR-039 — Cache only after the write completes.** 🟢 `_certPath` and `_initialized` are committed only after the injected/default writer finishes.
40. **BR-040 — Every pre-commit failure remains retryable.** 🟢 Directory, asset, and write failures rethrow and leave false/null state; a later call may succeed.
41. **BR-041 — Successful sequential reuse does no dependency work.** 🟢 A second call returns the cached path.
42. **BR-042 — Extraction is not HTTPS readiness.** 🔴 Default Android asset/storage execution, option application, HTTPS, concurrent first calls, and cached-file disappearance remain outside deterministic host tests.

### Platform packaging (BR-043–BR-048)

43. **BR-043 — Every declared Flutter platform needs its expected payload.** 🟢 Android, iOS, Linux, macOS, and Windows are FFI plugin targets.
44. **BR-044 — iOS is statically force-loaded.** 🟢 libgit2/libssh2/OpenSSL are supplied as XCFrameworks and libgit2 symbols are resolved from the process image.
45. **BR-045 — macOS ships one self-contained dylib identity.** 🟢 `libgit2.dylib`, `@rpath/libgit2.dylib`, podspec naming, and loader naming must agree; dynamic Homebrew/libssh2/OpenSSL leakage is rejected.
46. **BR-046 — Windows ships version-agnostic OpenSSL runtimes.** 🟢 Both `libcrypto*.dll` and `libssl*.dll` families plus `libssh2.dll` accompany `libgit2.dll`.
47. **BR-047 — Linux fallback includes libssh2.** 🟢 The package-local desktop route expects `linux/libgit2.so` and `linux/libssh2.so`.
48. **BR-048 — Android release inventory covers four ABIs.** 🟢 x86_64, arm64-v8a, x86, and armeabi-v7a each require libssl, libcrypto, libssh2, and libgit2.

### Cache and platform-proof qualification (BR-049–BR-054)

49. **BR-049 — Cache existence is never acceptance.** 🟢 A restored native cache is validated against exact metadata and current file set before reuse; invalid cache becomes a rebuild.
50. **BR-050 — Manifest paths and contents fail closed.** 🟢 Absolute/traversal/backslash paths, unknown/missing fields, mismatched metadata, file lists, hashes, sizes, provenance, malformed JSON, and unreadable inputs return non-success.
51. **BR-051 — Provenance shapes are mutually exclusive.** 🟢 `source-build` requires `source_ref`; `approved-exception` requires `exception_id`; contradictory fields are rejected.
52. **BR-052 — Platform proof strength is platform-specific.** 🟢 Desktop uses a child-process load, Android uses `readelf`, and iOS parses plist plus `nm`; these observations are not equivalent runtime authority.
53. **BR-053 — Aggregate proof requires eight scopes and passed status.** 🟢 Linux, macOS, Windows, iOS, and four Android ABI records must be unique, schema-shaped, path-safe, passed, and failure-free.
54. **BR-054 — Aggregate validation does not establish payload identity.** 🔴 It currently omits candidate equality, inventory completeness, linkage/version/attestation semantics, and hash comparison with downloaded release files; producer symlink containment and one manifest create-error path also remain gaps.

### Release and publication eligibility (BR-055–BR-060)

55. **BR-055 — Validation is broad; publication is narrow.** 🟢 Workflow validation is reachable for PRs and all branch pushes, while credential-bearing publication is reachable only for exact `push` to `refs/heads/main`.
56. **BR-056 — Publication depends on all platform jobs.** 🟢 `publish_package` needs Linux, macOS, Windows, iOS, Android x86_64 tests and the other Android ABI build matrix.
57. **BR-057 — Release gates are ordered before dry-run/publication.** 🟢 Proof aggregation, inventory, OpenSSL provenance, 256 MiB size ceiling, disposable Linux bundle compilation/native load, and `dart pub publish --dry-run` precede the publisher action.
58. **BR-058 — The disposable consumer must resolve the bundle.** 🟢 Offline package resolution must point exactly to the temporary bundle; internal imports, checkout bindings, undeclared origin labels, missing payload families, and non-empty output roots fail.
59. **BR-059 — Local bundle proof is fixture-scoped.** 🟡 Fresh Windows results used cached published package 1.12.1 while accepting the default `same-run` label; they prove clean resolution/native behavior for that fixture, not current workflow provenance.
60. **BR-060 — Dry-run and publisher definition are not publication.** 🔴 Current feature-005 hosted execution, token scope, publisher action integrity, pub.dev package identity, registry acceptance, and downstream availability are unobserved.

## Git archaeology: decision signals

| Period / commit | Signal | Reconstructed decision |
|---|---|---|
| 2025-05 to 2025-06, repeated binding/FFI fixes | Header coverage, platform paths, allocation, and variadic signatures changed repeatedly | ABI shape and native payload are one coupled product |
| `b7f474f`, `3ec5df2`, `4e2ab6d` | Android eager initialization crashed; transitive consumers could not find package binaries | Keep bootstrap ordered and make desktop fallback package-aware |
| `dd2b068`, `fc80f9f` | macOS install-name and transitive dylib failures | Normalize one dylib identity and statically link dependencies |
| `1acc02c` | Windows consumer missed OpenSSL runtime names | Bundle wildcard OpenSSL runtime families |
| `ea87cf2` | Lifecycle feature introduced checked init/shutdown, owner pins, and finalizer fallback | Give the package an explicit managed native-lifecycle owner |
| `774c06e` | ABI widths, diagnostics, cache fingerprints, and release inventory were hardened | Fail closed at native/package boundaries |
| `9af8df2`, `cedc8af`, `8a33ca3` | Platform proof and provenance sidecars became release inputs, including cache-hit paths | Release evidence must survive artifact reuse and assembly |
| `b372be1` | Generated binding dirtied the CI checkout during pub dry-run | Generated output is assembly input, not durable source state |
| feature 005 working tree | Source assertions were retired for W001–W006 and replaced by layered behavior evidence | Acceptance authority must be explicit and observable |

No reachable commit with a `revert` subject was found in the inspected history. Incremental fixes, not formal reverts, reveal most decisions.

## Logs and operational observations

No tracked application runtime log stream exists. Observable events are process stderr/stdout, test records, and workflow logs: lifecycle failures, loader stages, certificate bootstrap failure, cache validation, proof failure codes, package inventory/size, disposable consumer categories, dry-run output, and publisher status. These are operational evidence, not persisted domain records.

## Red gaps

1. 🔴 Current feature-005 GitHub run and same-run generated/native artifacts for all supported platforms.
2. 🔴 Cryptographic or hash join from producer proof/provenance to the exact downloaded release payload.
3. 🔴 Actual loaded-library handle origin for successful desktop fallback.
4. 🔴 Default Android certificate extraction, native option application, HTTPS, concurrency, and cached-file recovery.
5. 🔴 Production `git2dart` import sites, owner-lease draining, shutdown invocation, and version compatibility.
6. 🔴 Current pub.dev credential authorization, publisher execution, registry acceptance, and package availability.
7. 🔴 External GitHub environment, branch protection, fork-secret, token-scope, and approval controls.
8. 🔴 Generated enum/discriminator inventory and native payload bytes are absent from the source checkout.

