# Legacy Impact: 003-platform-release-proof

Date: 2026-08-24

| Affected file | Component | Type | Severity | Rationale |
|---|---|---|---|---|
| `.github/scripts/platform_release_proof.py` | Platform artifact set / release qualification | regra-nova | HIGH | Adds fail-closed final-payload inventory, digest, linkage, version, and Apple static-linkage evidence. |
| `.github/workflows/build_package.yml` | GitHub Actions supply path | regra-alterada | HIGH | Produces per-platform evidence and rejects incomplete or non-passing same-run proof before existing qualification transitions. |
| `test/platform_release_proof_test.dart` | Validation and release assembly | componente-novo | MEDIUM | Exercises sanitized schema and non-qualifying source-only/failure records. |
| `test/platform_release_proof_workflow_test.dart` | Validation and release assembly | componente-novo | MEDIUM | Locks proof producer matrix, seven-day retention, and ordering. |

## Conceptual diff by component

The release supply path now qualifies the assembled exports with independently named
platform/ABI records. The existing native inventory, OpenSSL provenance policy,
size gate, dry-run, PR handoff, and publisher remain present; platform proof is an
additional predecessor and does not alter their rules. Apple records attest static
inputs and emitted slices with hashes, toolchain/SDK identity, and observed metadata.

## Preserved

- **Rule 33 (CONFIRMED):** the expanded package remains bounded to 256 MiB and must
  pass `dart pub publish --dry-run`.
- **Rule 31 (CONFIRMED):** publication still waits for all platform tests and the
  remaining Android ABI builds.
- **Rule 26 (CONFIRMED):** the tracked source checkout remains an incomplete
  distribution; source-only proof is explicitly non-qualifying.
- **Rules 7–13 (CONFIRMED):** platform loader models and Windows dependency order
  are not changed; only their final-payload evidence is added.
- **OpenSSL provenance and strict Git validation:** untouched by this feature.

## Modified

- **Release qualification (Rule 31, CONFIRMED):** same-run platform proof is now a
  fail-closed predecessor before inventory, size, dry-run, PR release handoff, and
  publication eligibility.
- **Packaging observability (Rules 20–26, CONFIRMED):** each expected platform/ABI
  native inventory now has a sanitized JSON and Markdown proof artifact.
