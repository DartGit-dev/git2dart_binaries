# Independent cross-review

Scope: the 21 canonical documents in the seven feature folders and both traceability matrices, checked against the current `lib/src`, `pubspec.yaml`, platform manifests, and `.github/workflows/build_package.yml` at `680d914c8e2b87682f0b68318aee855838eb58e8`.

## Findings

1. **NLL / Windows dependency fallback — concrete runtime defect.**
   - **Unit/file/statement:** `_loadWindowsDependencies`, `lib/src/util.dart:95-100`, specifically the `!windowsDir.existsSync()` branch.
   - **Evidence:** The branch calls `DynamicLibrary.open(p.join(windowsDir.path, 'libssh2.dll'))` immediately after proving that `windowsDir` does not exist. This cannot load a system/search-path DLL and instead constructs a path under the missing directory.
   - **Correction:** In the missing-directory case, open `libssh2.dll` by bare name (or fail with an explicit, actionable error); reserve the package-local path for the existing-directory branch. Add a test for a foreign working directory with no package-local `windows` directory.

2. **DFF / object-type validation is over-permissive.**
   - **Unit/file/statement:** `IsValidGitObjectType.isValidGitObjectType`, `lib/src/extensions.dart:56-58`.
   - **Evidence:** The implementation returns `this >= GIT_OBJECT_COMMIT`, so every integer above `GIT_OBJECT_OFS_DELTA` is accepted. The canonical DFF contract enumerates only commit, tree, blob, tag, and ofs-delta as valid values (`dart-ffi-facade/design.md:8-10`; `requirements.md:17`).
   - **Correction:** Accept the finite set of five enum values (or compare through `git_object_t.fromValue` and reject unknown values), and add an out-of-range boundary test.

3. **DFF / ref-name validator does not enforce the documented Git safety subset.**
   - **Unit/file/statement:** `IsValidRefName.isValidRefName`, `lib/src/extensions.dart:75-85`.
   - **Evidence:** The regex/checks omit backslash, the `@{` sequence, the `.lock` component/suffix rule, and several component boundary rules. For example, `foo.lock`, `refs/@{bad`, and `refs\\heads\\x` are accepted by this implementation although they are invalid Git ref names. The SDD calls this a local subset risk but still states that invalid ref inputs are rejected (`dart-ffi-facade/design.md:19,31`).
   - **Correction:** Either implement the complete intended subset explicitly (including component checks) or downgrade the requirement/contract and label callers as responsible for full `git check-ref-format` validation; add negative cases to the boundary tests.

4. **PPK / package metadata divergence remains a release-integrity gap, confirmed in source.**
   - **Unit/file/statement:** `ios/git2dart_binaries.podspec:6`, `macos/git2dart_binaries.podspec:7`, versus `pubspec.yaml:3`.
   - **Evidence:** Both Apple podspecs declare `1.11.2`; the pub package declares `1.12.1`. This matches the red pending gap in `platform-packaging/requirements.md:25` and `tasks.md:23`, so the matrix should not treat metadata synchronization as complete.
   - **Correction:** Define one release-version source and make CI fail when podspec and pubspec versions differ before `dart pub publish --dry-run`.

5. **ATB / Android TLS integration is intentionally not present locally, so the must requirement is not implemented in this checkout.**
   - **Unit/file/statement:** `lib/src/android_ssl_helper.dart:68-93` only extracts/flushes/caches the asset; no call to `git_libgit2_opts_set_ssl_cert_locations` follows it in this repository.
   - **Evidence:** `android-tls-bootstrap/tasks.md:11` marks ATB-T-04 red, while `requirements.md:18` requires post-libgit2-init application. The helper documentation tells an external consumer to perform the call, but the traceability matrices still map this as a package feature boundary.
   - **Correction:** Keep the external boundary explicit in the package contract and compatibility matrix; do not mark ATB-RF-04 as locally satisfied without a consumer-side sequence/integration test.

## Matrix consistency note

The two matrices correctly record generated bindings/native artifacts and the external `git2dart` consumer as gaps. The findings above are source-level issues that should be added as explicit red/amber rows rather than left only as general risks.

## Reviewer incorporation

- Accepted and incorporated: all five findings. 🟢
- Additional independent-pass corrections incorporated: lazy Dart top-level initialization, unproven complete option ABI, Windows runner-discovered OpenSSL, reversed test/assembler C4 edge, per-feature matrix counts, current release branch triggers, and external Android CA application boundary. 🟢
- Rejected: none. 🟢
- Source changes: none; only Reversa documents were updated. 🟢
