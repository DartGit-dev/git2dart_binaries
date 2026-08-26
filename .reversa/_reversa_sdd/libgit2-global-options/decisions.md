# libgit2 Global Options, Decisions

| Decision | Consequence | Evidence | Confidence |
|---|---|---|---|
| Use typed adapters over one variadic native symbol. | Dart call sites encode the expected ABI tuple. | `opts_bindings.dart` | 🟢 |
| Use pointer-width `Size` and `IntPtr`. | Values are not truncated to 32 bits on 64-bit hosts. | ADR-001, W001 | 🟢 source; 🟢 bounded fixture |
| Return status codes unchanged. | Higher layers retain native error semantics. | 33 wrappers | 🟢 |
| Keep allocation/disposal with callers. | Wrapper stays allocation-free but consumers must honor libgit2 disposers. | source/tests | 🟢 |
| Require complete native coverage before declaring support. | Static method presence is insufficient for the 33-method set. | confirmed acceptance policy | 🟢 policy; 🔴 completion |
