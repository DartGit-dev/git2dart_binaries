# libgit2 Global Options, Edge Cases

| Case | Required result | Evidence | Confidence |
|---|---|---|---|
| Negative pack max object size | Throw `RangeError` before native conversion. | `opts_bindings.dart:425` | 🟢 |
| Value above `0xffffffff` on 64-bit | Preserve exact value through set/get. | W001 ABI probe | 🟢 mechanism; 🔴 current matrix |
| Non-64-bit probe host | Emit unavailable; never count as ABI pass. | ABI probe | 🟢 |
| Wrong discriminator/shape | Treat as release-blocking ABI defect. | HC-04 | 🟢 contract; 🔴 exhaustive proof |
| Null/invalid pointer arguments | Most wrappers pass them through; native status/FFI behavior decides. | `opts_bindings.dart` | 🟢 |
| Mutable global not restored | Test/consumer state can leak across calls. | integration tests | 🟢 risk |
| Missing generated binding | Numeric discriminator conformance cannot be checked locally. | absent `bindings.dart` | 🔴 |
| Libgit2-filled buffer not disposed | Native contents leak even if Dart outer allocation is freed. | ownership contract | 🟢 |
