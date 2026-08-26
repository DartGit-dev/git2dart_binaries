# Native Loader and Lifecycle, Edge Cases

| Case | Required result | Evidence | Confidence |
|---|---|---|---|
| Init returns zero or negative | Attempt exactly one rollback; retry only if rollback succeeds. | `runtime.dart:112` | 🟢 |
| Init throws | Preserve cause and attempt rollback. | lifecycle tests | 🟢 injected |
| Destructor throws | Keep owner incomplete and pin retained. | `runtime.dart:337` | 🟢 |
| Cleanup re-enters | Reject reentrant completion. | `_OwnerCleanup._complete` | 🟢 |
| Shutdown with pins | Throw before native shutdown. | `runtime.dart:163` | 🟢 |
| Repeated shutdown | Return cached success without another native call. | runtime tests | 🟢 injected |
| Missing/malformed package config | Continue discovery or fail with bounded state error. | `runtime.dart:467` | 🟢 |
| Windows package directory missing | Fail closed while opening the required dependency path. | `runtime.dart:441` | 🟢 |
| Android bare load fails | Do not attempt a package fallback. | W002 plan | 🟢 local plan; 🔴 device execution |
| Positive desktop load | Do not claim fallback origin until the actual loaded path is observed. | loader probe | 🔴 |
