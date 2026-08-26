# Dart FFI Facade, Implementation Tasks

## Prerequisites
- [ ] Generate the ABI from the pinned libgit2 headers.
- [ ] Make a matching native library available to tests.

## Tasks
- [ ] DFF-T-01, Recreate the public export barrel. Origin: `lib/git2dart_binaries.dart:1`. Done when every locally declared public module and generated bindings are exported. Confidence: 🟢
- [ ] DFF-T-02, Recreate borrowed native-error conversion. Origin: `lib/src/error.dart:12`, `lib/src/extensions.dart:90`. Done when null and populated `git_error` pointers map correctly. Confidence: 🟢
- [ ] DFF-T-03, Recreate string and validation extensions. Origin: `lib/src/extensions.dart:7`. Done when boundary tables for SHA-1, complete Git-valid refs, finite object types, and null pointers pass. Confidence: 🟢 observed behavior; 🟢 user-confirmed validator contract

## Test Tasks
- [ ] DFF-TT-01, Compile a consumer importing only the public barrel.
- [ ] DFF-TT-02, Exercise null and non-null native errors/strings.
- [ ] DFF-TT-03, Add boundary-driven validation tests.
- [ ] DFF-TT-04, Add boundary-driven positive and negative cases for every valid finite object type, unknown high object values, `.lock`, `@{`, backslash, and ref-component boundaries; enforce complete Git-valid rules rather than preserve the current predicates. Confidence: 🟢 user-confirmed validator contract

## Suggested Order
Generate bindings, implement helpers, assemble exports, then run consumer compilation. 🟢

## Pending Gaps
🔴 Confirm which exported symbols are used by `F:\git2dart` before declaring compatibility complete.

## 2026-08-25 Completion Gates

- [ ] DFF-T-04, Generate the ABI only from pinned libgit2 1.9.6 headers and inject it from the same workflow run. Origin: `ffigen.yaml:1`, `.github/actions/generate-bindings/action.yml`. Done when checkout fallback is rejected and artifact origin is recorded. Confidence: 🟢 contract; 🔴 hosted observation.
- [ ] DFF-T-05, Run a disposable consumer through the public barrel without internal imports. Origin: `tool/package_consumer_bundle.dart:138`. Done when package-config resolves exactly to the injected bundle and public compilation succeeds. Confidence: 🟢 local mechanism; 🔴 current same-run run.
- [ ] DFF-T-06, Record borrowed-pointer lifetime boundaries. Origin: `lib/src/error.dart:73`, `lib/src/extensions.dart:41`. Done when tests cover null projections without freeing borrowed memory. Confidence: 🟢.
