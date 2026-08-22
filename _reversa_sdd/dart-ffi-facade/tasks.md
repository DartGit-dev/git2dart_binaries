# Dart FFI Facade, Implementation Tasks

## Prerequisites
- [ ] Generate the ABI from the pinned libgit2 headers.
- [ ] Make a matching native library available to tests.

## Tasks
- [ ] DFF-T-01, Recreate the public export barrel. Origin: `lib/git2dart_binaries.dart:1`. Done when every locally declared public module and generated bindings are exported. Confidence: 🟢
- [ ] DFF-T-02, Recreate borrowed native-error conversion. Origin: `lib/src/error.dart:12`, `lib/src/extensions.dart:90`. Done when null and populated `git_error` pointers map correctly. Confidence: 🟢
- [ ] DFF-T-03, Recreate string and validation extensions. Origin: `lib/src/extensions.dart:7`. Done when boundary tables for SHA-1, refs, object types, and null pointers pass. Confidence: 🟢

## Test Tasks
- [ ] DFF-TT-01, Compile a consumer importing only the public barrel.
- [ ] DFF-TT-02, Exercise null and non-null native errors/strings.
- [ ] DFF-TT-03, Add boundary-driven validation tests.
- [ ] DFF-TT-04, Add negative cases for unknown high object values, `.lock`, `@{`, backslash, and ref-component boundaries; decide whether tests preserve current behavior or enforce full Git rules. Confidence: 🔴 intended contract

## Suggested Order
Generate bindings, implement helpers, assemble exports, then run consumer compilation. 🟢

## Pending Gaps
🔴 Confirm which exported symbols are used by `F:\git2dart` before declaring compatibility complete.
