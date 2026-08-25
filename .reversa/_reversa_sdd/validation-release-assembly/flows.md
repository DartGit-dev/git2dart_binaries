# Validation and Release Assembly, Flows

## F1 — Validation DAG

1. Generate bindings and build Linux, macOS, iOS, Windows, and Android payloads. 🟢 graph; 🔴 current run
2. Inject same-run artifacts into desktop/mobile validation jobs. 🟢 graph; 🔴 current bytes
3. Required validation groups gate `publish_package`. 🟢 parsed workflow facts

## F2 — Release qualification

1. Download generated/native/proof/provenance artifacts into the expanded package. 🟢 recipe
2. Require eight unique passed proof scopes. 🟢
3. Check native inventory and five-platform OpenSSL provenance/approved exceptions. 🟢
4. Reject selected expanded payload above 256 MiB. 🟢
5. Assemble a disposable Linux consumer, compile public API, and load native libgit2. 🟢 recipe; 🔴 current same-run result
6. Run pub dry-run and fail on errors. 🟢 recipe

## F3 — Event route

1. Pull requests upload `release-package` for inspection. 🟢
2. Non-main branch pushes finish validated without publishing. 🟢 parsed facts; 🔴 hosted observation
3. Exact `refs/heads/main` push may invoke publisher only after all gates. 🟢 condition; 🔴 credentials/registry outcome
