# Android TLS Bootstrap, External Contract

## Flutter and consumer boundary

| Surface | Input / prerequisite | Output / obligation | Confidence |
|---|---|---|---|
| `AndroidSSLHelper.initialize()` | Flutter bindings, package asset, temporary directory | Future path to flushed CA file. | 🟢 declaration; 🔴 default device execution |
| `initializeWith(dependencies)` | Injected async operations | Same cache/retry semantics with deterministic host evidence. | 🟢 |
| Package asset | `packages/git2dart_binaries/assets/certs/cacert.pem` | CA bytes copied to `cacert.pem`. | 🟢 configuration |
| External platform bootstrap | Managed libgit2 initialized first | Apply returned path through native certificate-location option. | 🟢 contract; 🔴 current external run |

The unit exposes no network endpoint; its external effect is a file-path handoff to libgit2 configuration. 🟢
