# Dart FFI Facade, Flows

## F1 — Public API resolution

1. A consumer imports `package:git2dart_binaries/git2dart_binaries.dart`. 🟢
2. The barrel exposes handwritten modules and the CI-owned generated ABI. 🟢
3. Reading a lazy runtime value may load and initialize libgit2; an import alone does not. 🟢
4. A clean consumer must resolve the package root to the injected bundle before compilation is accepted. 🟢 local mechanism; 🔴 current hosted bundle

## F2 — Last-error projection

1. `GetLastError.getLastError()` calls `git_error_last()`. 🟢
2. `nullptr` becomes `null`; a present pointer becomes `LibGit2Error`. 🟢
3. The message pointer is decoded without ownership transfer and must not be freed by Dart. 🟢

## F3 — Conversion and validation

1. A null `Pointer<Char>` becomes `''`; otherwise UTF-8 decoding uses the optional byte length. 🟢
2. SHA-1 validation checks hexadecimal text and generated length limits. 🟢
3. Ref-name and object-type helpers follow the observed local predicates; their stricter intended contract is recorded as a defect boundary. 🟢 observed source; 🟢 user-confirmed target

## Evidence

Source: `lib/git2dart_binaries.dart`, `lib/src/error.dart`, `lib/src/extensions.dart`, `tool/package_consumer_bundle.dart`. 🟢
