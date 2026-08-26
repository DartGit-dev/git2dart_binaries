# Dart FFI Facade, Edge Cases

| Case | Required result | Evidence | Confidence |
|---|---|---|---|
| Null `git_error_last()` | Return `null` without dereference. | `lib/src/error.dart:73` | 🟢 |
| Null `Pointer<Char>` | Return an empty Dart string. | `lib/src/extensions.dart:41` | 🟢 |
| Borrowed error invalidated by later native call | Do not claim stable lifetime or free the pointer. | `lib/src/error.dart` | 🟡 lifetime; 🟢 ownership |
| Unknown high object-type integer | Current source accepts it; reconstructed strict contract must reject values outside finite Git object types. | `lib/src/extensions.dart:58` | 🟢 observed defect; 🟢 target |
| Invalid ref-name forms | Current subset rejects only enumerated local forms; complete Git-valid validation remains the intended contract. | `lib/src/extensions.dart:77` | 🟢 observed defect; 🟢 target |
| Missing generated binding | Checkout cannot compile the complete public ABI without injected output. | `ffigen.yaml`, absent `lib/src/bindings.dart` | 🟢 absence; 🔴 bytes |
| Barrel compiles but native payload is wrong | Compilation does not establish ABI/runtime compatibility. | HC-01 | 🟢 evidence boundary |
