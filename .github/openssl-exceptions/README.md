# OpenSSL release exceptions

`source-build` is the only normal route. An exception is an explicit, reviewed
opt-in for a platform where the configured OpenSSL source build is infeasible.
It never authorizes runner discovery or a version-only assertion.

Each checked-in `*.json` record must contain exactly these fields:

```json
{
  "id": "EXC-YYYY-NNN",
  "platform": "windows",
  "abi": "X64",
  "openssl": "3.0.15",
  "infeasibility_evidence": "issue or CI run URL",
  "approver": "GitHub handle or team",
  "review_by": "YYYY-MM-DD",
  "exact_parity": "verified"
}
```

Records fail closed unless the ID, platform/ABI, exact configured version,
non-empty infeasibility evidence and approver, unexpired review date, and the
literal `exact_parity: "verified"` all match release qualification. Qualification
also requires every participating platform sidecar to report the same version;
an exception cannot be used as a silent fallback.
