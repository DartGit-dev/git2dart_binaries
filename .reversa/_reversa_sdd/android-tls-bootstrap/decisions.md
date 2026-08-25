# Android TLS Bootstrap, Decisions

| Decision | Consequence | Evidence | Confidence |
|---|---|---|---|
| Extract the package CA explicitly. | Runtime receives a filesystem path suitable for native configuration. | ADR-003 | 🟢 |
| Commit cache only after successful write. | Failed attempts remain retryable. | helper source/tests | 🟢 |
| Inject directory/asset/write operations. | Host tests can prove state transitions without an Android device. | `AndroidSSLDependencies` | 🟢 |
| Leave native option application to the external bootstrap. | Extraction success is not TLS readiness. | helper documentation, HC-05 | 🟢 boundary; 🔴 integration |
| Require first-call serialization across platform bootstrap. | Concurrent callers should await one operation. | confirmed policy | 🟢 target; 🔴 implementation proof |
