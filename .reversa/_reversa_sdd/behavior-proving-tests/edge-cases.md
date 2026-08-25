# Behavior-Proving Tests, Edge Cases

| Case | Required classification | Confidence |
|---|---|---|
| Missing native package root | Unavailable, never behavior success. | 🟢 |
| Non-64-bit ABI host | Unavailable for W001. | 🟢 |
| Probe timeout | Failure with bounded sanitized diagnostics. | 🟢 |
| Fixture traversal/symlink escape | Reject before external mutation; symlink completeness remains a gap. | 🟢 path guard; 🔴 full symlink semantics |
| Positive loader without path origin | Loaded for declared process only; fallback origin unproven. | 🟢/🔴 |
| Handwritten passed proof with empty fields | Current aggregate may accept; classify as validator defect, not strong evidence. | 🟢 |
| Caller label `same-run` | Declaration only until tied to workflow/run hashes. | 🟢 boundary |
| AST name match | Structural observation only, not resolved semantic identity. | 🟢 limitation |
| Green local suite | Local tier only; no hosted/platform/publication promotion. | 🟢 |
