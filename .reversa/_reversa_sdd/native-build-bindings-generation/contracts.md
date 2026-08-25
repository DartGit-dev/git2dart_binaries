# Native Build and Bindings Generation, External Contract

## Hosted producer boundary

| Contract | Input | Output / acceptance | Confidence |
|---|---|---|---|
| Binding generator | Pinned libgit2 1.9.6 headers, Flutter/ffigen | Untracked `bindings.dart` workflow artifact. | 🟢 recipe; 🔴 current artifact |
| Platform builders | Pinned versions plus platform toolchains | Normalized native payload and provenance per platform/ABI. | 🟢 recipe; 🔴 current outputs |
| Native cache manifest CLI | Export root and exact expected metadata | Deterministic JSON or sanitized non-zero failure. | 🟢 local behavior; one create error defect 🟢 |
| GitHub cache/artifact service | Validated keys/manifests | Reusable cache and same-run artifact transfer. | 🟢 configuration; 🔴 service execution |
| Upstream repositories | Declared version tags | Build source trees. | 🟢 recipe; 🔴 tag authenticity |

The external contract is CI artifact/provenance exchange, not an application API. 🟢
