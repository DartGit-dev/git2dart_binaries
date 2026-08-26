# Native Loader and Lifecycle, Decisions

| Decision | Consequence | Evidence | Confidence |
|---|---|---|---|
| Use one isolate-local managed runtime. | Bindings, options, lifecycle phase, and pins share one epoch. | ADR-009, `runtime.dart` | 🟢 |
| Compensate failed initialization with shutdown. | A clean rollback permits retry; rollback failure is terminal. | ADR-009 | 🟢 |
| Pin active calls and persistent owners. | Shutdown cannot race managed work or owned native objects. | ADR-009 | 🟢 local; 🔴 external owners |
| Resolve desktop package-local binaries after bare-name failure. | Transitive consumers can load packaged payloads. | ADR-002 | 🟢 |
| Keep platform-specific loading contracts. | iOS/process, Android/bare-only, desktop/fallback remain distinct. | ADR-004 | 🟢 |
| Preload Windows crypto, TLS, then SSH dependencies. | Package fallback has deterministic dependency order. | `runtime.dart:441`, ADR-006 | 🟢 |
