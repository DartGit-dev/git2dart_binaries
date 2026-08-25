# Android TLS Bootstrap, Flows

## F1 — Successful extraction

1. Return the cached path only when initialized and the path is non-null. 🟢
2. Resolve the temporary directory. 🟢
3. Load `packages/git2dart_binaries/assets/certs/cacert.pem`. 🟢
4. Write/flush the bytes to `<temporary>/cacert.pem`. 🟢
5. Commit the path and initialized flag only after write completion. 🟢

## F2 — Retry after failure

1. Directory, asset, or writer failure emits a bounded stderr message. 🟢
2. The original failure is rethrown. 🟢
3. Completion state stays unset, so a later sequential call retries. 🟢

## F3 — External application

1. External bootstrap initializes managed libgit2. 🟢 required contract; 🔴 current external proof
2. It awaits extraction and applies the returned file path through the native certificate-location option. 🟢 required contract; 🔴 current external proof
3. HTTPS behavior must be observed on Android before TLS readiness is claimed. 🔴
