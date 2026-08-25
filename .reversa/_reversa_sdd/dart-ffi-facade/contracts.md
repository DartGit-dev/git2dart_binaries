# Dart FFI Facade, External Contract

## Consumer boundary

| Surface | Input | Output / obligation | Confidence |
|---|---|---|---|
| `git2dart_binaries.dart` | Dart import | Public generated and handwritten API exports. | 🟢 declaration; 🔴 external reachability |
| `GetLastError.getLastError()` | Initialized `Libgit2` view | Nullable borrowed `LibGit2Error`; caller must not free it. | 🟢 |
| `Pointer<Char>.toDartString()` | Borrowed pointer and optional byte length | Dart string; null maps to empty. | 🟢 |
| Validation extensions | SHA/ref/object values | Boolean local validation result. | 🟢 observed implementation |
| Generated `Libgit2` | Same-run binding plus native handle | Direct C ABI calls; caller must obey native ownership and lifecycle. | 🟢 contract; 🔴 current same-run proof |

No HTTP, RPC, queue, database, or webhook contract exists for this unit. 🟢

Compatibility with `git2dart` is an external selected-version-pair contract and remains unverified in this extraction. 🔴
