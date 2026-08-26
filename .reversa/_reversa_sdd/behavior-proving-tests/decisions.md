# Behavior-Proving Tests, Decisions

| Decision | Consequence | Evidence | Confidence |
|---|---|---|---|
| Use layered behavior evidence. | Claims cannot exceed the strongest observed tier. | ADR-010 | 🟢 |
| Use fresh bounded processes for loader/ABI behavior. | Cached global/native state is isolated and hangs are bounded. | fixture/probes | 🟢 |
| Parse AST and workflow structure instead of source strings. | W006 facts are less formatting-sensitive but remain bounded models. | ADR-010/tools | 🟢 |
| Replace FR-01–FR-08 source assertions. | Acceptance points to behavior/parsed evidence and violation signals. | replacement inventory | 🟢 |
| Preserve explicit unavailable records. | Missing prerequisites are visible without becoming false passes. | tests | 🟢 |
| Require hosted/external evidence for high-tier claims. | Local cached 1.12.1 bytes and historical runs cannot prove current release identity. | evidence ladder | 🟢 |
