# Validation and Release Assembly, Decisions

| Decision | Consequence | Evidence | Confidence |
|---|---|---|---|
| Gate publication on cross-platform validation. | Release assembly is downstream of every required platform group. | ADR-008 | 🟢 |
| Route all generated/native inputs from one workflow run. | Checkout fallback is forbidden and same-run identity is required. | ADR-011 | 🟢 policy; 🔴 byte join |
| Use layered evidence. | Static, injected, fixture, hosted, and publication claims remain distinct. | ADR-010 | 🟢 |
| Keep feature/non-main runs non-publishing. | Only exact main push is publisher-reachable. | workflow facts | 🟢 |
| Enforce explicit size and pub dry-run gates. | Oversized/invalid packages cannot reach publisher. | workflow | 🟢 |
| Coordinate selected pairs through external `git2dart`. | Product compatibility is not proven by this repository alone. | confirmed policy | 🟢 policy; 🔴 current run |
