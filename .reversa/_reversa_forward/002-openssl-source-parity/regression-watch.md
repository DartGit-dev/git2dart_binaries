# Regression watch — 002-openssl-source-parity

| ID | Origin | Rule expected after change | Type | Violation signal |
|---|---|---|---|---|
| W001 | `domain.md`, rule 28 | Every normal platform path uses configured OpenSSL source tag. | presença | Runner OpenSSL discovery or absent `source_ref`. |
| W002 | `domain.md`, rule 29 | Cache restore validates native-v2 version and exclusive provenance. | presença | v1/missing/contradictory manifest accepted. |
| W003 | `domain.md`, rule 31 | Publish eligibility verifies Windows, Linux, macOS, Android, iOS sidecars. | presença | Missing/mismatched provenance reaches package eligibility. |
| W004 | `domain.md`, rules 12, 23 | Windows retains version-agnostic crypto/ssl DLL exports. | presença | Loader-compatible runtime DLLs absent from package artifact. |

## Observations

- Live proof remains open: the expanded Windows artifact and its plain-Dart loader were not available locally, so the focused loader test was skipped and no `windows-latest` CI build was run. Re-check W004 against a produced release artifact before treating this feature as fully accepted.

## Audit evidence — 2026-08-24

- T002 was reclassified 🟡 → 🟢 after a read-only local audit. `.github/openssl-exceptions/exception.schema.json` requires exactly the exception ID, platform, ABI, exact OpenSSL version, infeasibility evidence, approver, review date, and literal `exact_parity: "verified"`; the schema rejects additional fields. The release-qualification source additionally rejects an unknown ID, unequal platform/ABI/version/parity, missing evidence or approver, and expired review date.
- This is static contract evidence only. W004 remains open and is not reclassified: it requires a successful `windows-latest` run that uploads the expanded Windows package, its generated bindings, `libgit2.dll`, and the version-agnostic OpenSSL DLLs, followed by the plain-Dart loader test against that downloaded artifact.

## Re-extraction history

### Re-extração 2026-08-25 17:46

| ID | Veredito | Observação |
|----|----------|------------|
| W001 | 🟢 verde | The NBG requirements preserve the explicit OpenSSL 3.0.15 source pin; the current Windows action is documented as source-building that input. |
| W002 | 🟢 verde | BR-049–BR-051 preserve exact cache validation and mutually exclusive source-build/approved-exception provenance. |
| W003 | 🟢 verde | The release topology still qualifies Windows, Linux, macOS, Android, and iOS provenance before eligibility; current hosted execution remains a separate gap. |
| W004 | 🟢 verde | BR-046 preserves version-agnostic `libcrypto*.dll` and `libssl*.dll` package exports; current expanded bytes remain unobserved. |

None.

## Archived

None.
