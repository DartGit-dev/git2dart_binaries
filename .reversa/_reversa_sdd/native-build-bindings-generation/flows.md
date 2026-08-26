# Native Build and Bindings Generation, Flows

## F1 — Binding generation

1. Checkout pinned libgit2 1.9.6 headers. 🟢 recipe
2. Run ffigen with experimental SHA-256 definitions and output `lib/src/bindings.dart`. 🟢 recipe
3. Upload the binding as a workflow artifact without committing it. 🟢 policy/graph; 🔴 current artifact
4. Downstream jobs download only that same-run artifact. 🟢 graph; 🔴 authenticated byte join

## F2 — Native cache/build

1. Compute platform toolchain fingerprint and cache key. 🟢
2. Restore a candidate, then validate exact metadata/provenance/file hashes/sizes. 🟢
3. Invalid candidate is cleared and rebuilt from pinned sources. 🟢 recipe; 🔴 cache-service execution
4. Run native tests/symbol checks, normalize outputs, create manifest/provenance, and upload. 🟢 recipe

## F3 — W004 manifest CLI

1. `create` walks an export, rejects unsafe paths, and records deterministic file details. 🟢
2. `validate` recomputes the exact expected metadata and file map. 🟢
3. Malformed, unsafe, incomplete, mismatched, or unreadable inputs fail non-zero with sanitized diagnostics. 🟢 local fixture matrix
