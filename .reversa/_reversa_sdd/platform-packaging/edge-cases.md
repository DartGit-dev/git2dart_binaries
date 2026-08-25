# Platform Packaging, Edge Cases

| Case | Required result | Evidence | Confidence |
|---|---|---|---|
| Missing required platform basename | Reject bundle/release inventory. | bundle tool/workflow | 🟢 |
| Binding originates inside checkout | Reject disposable assembly. | `package_consumer_bundle.dart:31` | 🟢 |
| Consumer resolves another package root | Reject before compile/load claim. | `runCleanConsumer` | 🟢 |
| macOS install name is not `@rpath/libgit2.dylib` | Reject artifact. | build-macos action | 🟢 recipe; 🔴 current bytes |
| macOS has dynamic libssh2/OpenSSL dependency | Reject artifact. | ADR-005 | 🟢 contract; 🔴 current bytes |
| Windows OpenSSL DLL version varies | Package all matched required runtimes but release must prove approved parity. | CMake/workflow | 🟢 recipe; 🔴 current proof |
| CA asset copies drift | Current package has two copies without an explicit digest equality gate. | asset paths | 🟢 observation |
| Metadata versions differ | Block release. | current 1.12.1/1.11.2 mismatch | 🟢 |
| `bundle-proof.json` says same-run | Do not treat caller label alone as provenance. | bundle tool | 🟢 boundary |
