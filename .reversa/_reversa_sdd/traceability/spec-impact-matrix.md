# Specification Impact Matrix

## Component-to-component impact

Legend: **H** high/direct contract, **M** meaningful indirect impact, **L** low/validation-only, `—` no material local impact.

The ratings describe change impact, not necessarily a direct code import. In particular, Android TLS ↔ loader/options and every `git2dart` consumer relationship cross an external orchestration boundary and remain 🟡/🔴 until consumer evidence is inspected.

| Change source ↓ / impacted component → | FFI facade | Loader/lifecycle | Global options | Android TLS | Platform packaging | Native builds/bindings | Validation/release |
|---|---:|---:|---:|---:|---:|---:|---:|
| FFI facade | H | M | M | M | L | M | M |
| Loader/lifecycle | M | H | M | M | H | H | H |
| Global options | M | M | H | H | L | H | H |
| Android TLS | M | H | H | H | H | M | H |
| Platform packaging | L | H | L | M | H | H | H |
| Native builds/bindings | H | H | H | M | H | H | H |
| Validation/release | L | L | L | L | M | H | H |

## Change scenarios

| Change | Required specification checks | Code/config surfaces | Required evidence |
|---|---|---|---|
| Upgrade libgit2 | ABI generation, options signatures/enums, artifact filenames, all platform builds | workflow pins, ffigen config, generated bindings, native actions | native tests, essential exports, Dart option tests, all platform jobs |
| Upgrade libssh2/OpenSSL | platform linkage/runtime dependencies, cache keys, packaging | native actions, podspec/CMake, loader preload | dependency inspection, loader tests, HTTPS/SSH platform tests |
| Rename a native artifact | loader target, package-manager manifest, build export, tests | `util.dart`, CMake/podspec, action export | packaged application launch/load test |
| Add a supported platform | public plugin declaration, loader branch, artifact builder, package integration | pubspec, loader, new platform directory/action | native build plus real/simulated app test |
| Change Android certificate asset | asset declaration/path, extraction behavior, consumer sequence | pubspec, asset files, helper | device HTTPS test after post-init application |
| Add/modify global option wrapper | discriminator/signature and ownership rules | `opts_bindings.dart`, generated enums/structs | targeted native integration test including error case |
| Change package-root resolution | transitive/plain-Dart loader contract | `util.dart`, package config parsing | cwd-independent consumer process tests on desktops |
| Change macOS linkage | install name, podspec, static/dynamic dependency policy | macOS action, podspec, loader | `otool`, symbol lookup, plain Dart and Flutter app tests |
| Change Windows OpenSSL version | generic runtime discovery and bundling | Windows action/CMake/loader | DLL inventory plus plain-Dart/Flutter loader tests |
| Change release payload contents | size gate and pub validation | workflow assembly paths | expanded size diagnostics and pub dry-run |
| Change workflow branch/event triggers | publication trust boundary and `git2dart` coordination gate | workflow `on`, step conditions, `git2dart` coordinator | dry-run of feature vs `main` behavior; selected-pair integration evidence; external permissions review |
| Change `git2dart_binaries` public API/version | major-line compatibility, libgit2 pin ownership, selected-pair release coordination | binaries pubspec/exports, `git2dart` consumer constraint, `git2dart` GitHub Actions coordinator | full `git2dart` integration suite after resolving the selected pair; feature-green merge gate and post-merge green `main` gate |

## Feature-to-artifact traceability

| Feature | Primary source evidence | Current Reversa analysis | Writer unit |
|---|---|---|---|
| `dart-ffi-facade` | `lib/git2dart_binaries.dart`, extensions, error | code analysis, data dictionary, C4 components | `_reversa_sdd/dart-ffi-facade/` |
| `native-loader-lifecycle` | `lib/src/util.dart` | code analysis, loader state machine, ADR-002/004 | `_reversa_sdd/native-loader-lifecycle/` |
| `libgit2-global-options` | `lib/src/opts_bindings.dart`, option tests | code analysis, option state machine, ADR-001 | `_reversa_sdd/libgit2-global-options/` |
| `android-tls-bootstrap` | helper, assets, Android packaging | TLS state machine, ADR-003 | `_reversa_sdd/android-tls-bootstrap/` |
| `platform-packaging` | pubspec, CMake, podspecs | architecture, ADR-004/005/006 | `_reversa_sdd/platform-packaging/` |
| `native-build-bindings-generation` | composite actions, manifest script | supply architecture, ADR-001/007 | `_reversa_sdd/native-build-bindings-generation/` |
| `validation-release-assembly` | workflow and tests | release state machine, ADR-008 | `_reversa_sdd/validation-release-assembly/` |

## Cross-repository impact boundary

Any change to public exports, package version/SDK constraints, generated libgit2 ABI, initialization semantics, or Android TLS contract potentially impacts `F:\git2dart`. Direct inspection confirms that `git2dart_binaries` owns/pins libgit2 and `git2dart` selects the compatible binaries major line; minor fixes within that selected libgit2 line do not redefine the boundary. `git2dart` owns the single GitHub Actions release/build coordination point: it receives the selected pair, resolves it as the client uses it, and runs the full client integration suite before feature-branch merge eligibility and again through the post-merge `main` publication gate. 🟢 user-confirmed coordination policy; 🔴 current workflow/run evidence

## Highest-risk coupled contracts

1. **libgit2 version ↔ generated bindings ↔ native platform binaries**.
2. **artifact filename ↔ Dart loader ↔ platform packaging manifest**.
3. **Android init order ↔ certificate extraction ↔ consumer applies native option**.
4. **all platform outputs/tests ↔ release assembler ↔ pub publication**.
5. **public package API/version ↔ external `git2dart` dependency** (major-line policy and `git2dart` coordination owner confirmed; fresh coordinator execution remains unobserved).
