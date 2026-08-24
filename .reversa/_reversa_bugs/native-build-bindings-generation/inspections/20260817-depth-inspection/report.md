# Depth Inspection Report: native-build-bindings-generation

## Inspection metadata

```yaml
feature: native-build-bindings-generation
context: native-build-bindings-generation
date: 2026-08-17
mode: read-only-diagnostic
closure_policy: package
source_modified: false
existing_feature_bugs: 0
runtime_replay: blocked
```

## Feature map

- Specifications: `_reversa_sdd/native-build-bindings-generation/{requirements,design,tasks}.md`.
- Binding generator: `.github/actions/generate-bindings/action.yml`, `ffigen.yaml`, and `pubspec.yaml`.
- Native builders: Android, iOS, Linux, macOS, and Windows composite actions.
- Cache contract: `.github/scripts/native_cache_manifest.py` plus platform cache keys and manifests.
- Assembly: `.github/workflows/build_package.yml` artifact downloads, tests, dry-run, and publication.
- Current generated bindings, native exports, manifests, and workflow-run evidence are absent locally.

## Findings by lens

### Spec conformity

- Library and Flutter version pins align across binding generation and all five native build paths.
- Exact file-set, SHA-256, size, platform, ABI, native-version, and toolchain validation is statically conformant.
- The binding cache omits the current ffigen contract and can accept stale generated declarations. Registered as bug #7.
- Final iOS XCFrameworks are assembled after slice manifests and uploaded without an aggregate post-transform manifest. No malformed artifact was observed, so this remains an integrity gap.

### Data flow

- Binding flow: libgit2 tag to headers to ffigen to `bindings.dart` to cache manifest to upload and final package.
- Native flow: pinned tags and runner toolchains to normalized exports, platform manifest, cache, artifact upload, platform tests, and package assembly.
- Mobile target inputs affect the build but do not enter cache identity. Registered as bug #8.
- Uploaded artifacts do not carry the manifests that established cache provenance; downstream revalidation remains unavailable.

### Contracts and integrations

- Downstream platform jobs compile or execute generated bindings before publication, but the binding artifact has no dedicated pre-upload analysis step.
- Android and iOS cross-builds check files and essential exports; Linux, macOS, and Windows also run upstream libgit2 tests.
- Upstream tags are versioned but not immutable commit identities. SBOM, signing, and provenance attestation are explicitly unsettled.

### Error states and edge cases

- A JSON-valid non-object manifest raises an uncaught `AttributeError`; the process still exits nonzero and rebuild logic remains fail-closed.
- Invalid exact-key caches rebuild locally, but replacement behavior for an immutable pre-existing cache key was not observed.
- Desktop caches validate export bytes but also restore build trees used by unconditional native-test steps. A partial tree can fail the job instead of selecting rebuild; cache-service atomicity and an actual partial restore are unobserved.

### Test coverage

- No dedicated manifest utility test covers valid, corrupt, file-set, digest, or version mismatch cases.
- No test proves binding cache invalidation after ffigen config or dependency changes.
- No uniform post-upload audit checks filenames, architecture, dependencies, and symbols for every artifact.
- Android and iOS lack upstream native-suite execution; their downstream runtime coverage is partial.

### Concurrency and consistency

- Platform, ABI/slice, toolchain, version, and action hashes prevent current matrix jobs from colliding.
- Binding cache identity is incomplete for configuration/dependency changes.
- Android and iOS cache identity is incomplete for three output-affecting target inputs.
- Version and experimental SHA-256 flags remain statically aligned at libgit2 1.9.6.

## Promotion and deduplication

| Candidate | Severity | Result |
|---|---|---|
| C-NBG-01, binding cache omits generator contract | High | `BUG-20260817-AACM` (#7) |
| C-NBG-02, mobile caches omit target inputs | High | `BUG-20260817-AAFK` (#8) |
| Desktop partial-cache validation | Medium risk | Not promoted, external cache behavior and occurrence unobserved |
| Final iOS post-assembly manifest | Medium gap | Not promoted, no malformed artifact observed |

The global registry and all existing canonical records were searched before registration. Bug #3 is related ABI evidence, not a duplicate of #7. No existing record covered mobile cross-configuration cache reuse.

## Confidence impact

- Confidence remains high for the manifest utility's exact metadata/file/digest comparison and the current version-pin alignment.
- Binding-cache freshness and mobile cross-configuration isolation drop to confirmed red defects.
- Current generated ABI and final artifact semantics remain red because outputs and CI evidence are absent.
- The completed core Reversa score was not rewritten.

## Residual blockers

- No current workflow run, restored cache, generated binding, native export, uploaded manifest, or final package is available.
- Immutable upstream identity, SBOM, signing, and provenance policy remain unsettled.
- `F:\git2dart` was not read. Cross-repository consumer behavior remains explicitly unverified.

No source, test, staged, committed, global-setting, or external-repository change was made.

