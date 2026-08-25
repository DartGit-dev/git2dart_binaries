# Native Build and Bindings Generation, Decisions

| Decision | Consequence | Evidence | Confidence |
|---|---|---|---|
| Generate ABI from pinned libgit2 headers. | Header/binding/native version unity is mandatory. | ADR-001 | 🟢 |
| Keep generated binding CI-owned and untracked. | Same-run artifact transfer is the production handoff. | ADR-011 | 🟢 policy; 🔴 current run |
| Validate cache content, not cache-hit status. | Corrupt/stale hits rebuild. | ADR-007 | 🟢 |
| Normalize exports and record SHA-256/size manifests. | Reuse can be checked deterministically. | manifest script | 🟢 |
| Pin libgit2/libssh2/OpenSSL/Flutter versions. | Builders share declared native inputs. | workflow env | 🟢 recipe; 🔴 current bytes |
| Require source-built OpenSSL or approved exact parity. | Windows now source-builds the declared pin; hosted artifacts must still prove parity. | `build-windows/action.yml:113`, confirmed policy | 🟢 source recipe; 🔴 current hosted parity |
