# Data Delta: Platform Release Artifact Proof

## Boundary

There is no persistent application database or package schema migration. The delta is
an ephemeral CI evidence model published as run-scoped workflow artifacts only.

## New conceptual records

### `PlatformProof`

| Field | Type | Required | Meaning |
|---|---|---:|---|
| `schema_version` | string | yes | Versioned report contract. |
| `candidate_id`, `run_id`, `run_attempt` | string/integer | yes | Same-run release identity; no Git metadata dump. |
| `platform`, `abi_or_architecture` | enum/string | yes | Platform and Android ABI or Apple slice/desktop architecture. |
| `status` | `pass` / `fail` / `unavailable` | yes | `unavailable` is failing when package proof is required. |
| `artifacts[]` | array | yes | Relative path, role, expected/present/unexpected state, SHA-256, size. |
| `loader_or_linkage` | object | yes | Actual platform-model probe, result, diagnostic code, sanitized detail. |
| `intended_dependencies` | object | yes | Release-configured libgit2, libssh2, OpenSSL versions/tags. |
| `observed_versions[]` | array | yes | Dependency, observed value or `unavailable`, extractor, evidence reference, comparison result. |
| `toolchain_sdk` | object | yes | Reproducibility identity appropriate to that platform. |
| `failures[]` | array | yes | Stable reason code and concise sanitized reviewer message. |

### `StaticLinkageAttestation` (iOS/macOS)

| Field | Type | Required | Meaning |
|---|---|---:|---|
| `schema_version`, `platform`, `slice` | string | yes | Attestation identity. |
| `intended_inputs[]` | array | yes | libgit2/libssh2/OpenSSL tag/version and input archive path/SHA-256. |
| `toolchain_sdk` | object | yes | Compiler, linker, SDK identity used for that slice. |
| `emitted_artifacts[]` | array | yes | Final archive/XCFramework slice path and SHA-256. |
| `compiled_metadata[]` | array | yes | Extractor/method, readable evidence, comparison result, or explicit `unavailable`. |
| `status` | `pass` / `fail` | yes | Fails when required readable version evidence is absent or mismatched. |

## Conceptual state transition

`Assembling → PlatformProof → SizeCheck → PubDryRun → PRArtifact | Publishing`.
Any absent expected proof, schema-invalid proof, terminal failure, or required
`unavailable` value transitions to `Failed`. A source-only local check may emit an
`unavailable` diagnostic but is never eligible to drive release qualification.

## Retention and placement rules

- Emit JSON and Markdown together in a named workflow artifact partitioned by
  candidate/platform/ABI.
- Keep reports outside checkout paths, expanded pub payload, Git metadata, and
  secret-bearing logs; paths in records are artifact-relative only.
- Retain intermediate build outputs under the current explicit short policy.
- Configure and document a bounded release/tag proof retention longer than the PR
  review window; the exact duration is an operational policy decision, constrained
  by Actions repository/organization limits.

## Compatibility and migration

No stored data migration is needed. Consumers of the new CI report must reject an
unknown schema version rather than treating it as a passing record. Existing native
cache manifests remain build/cache integrity data and are not upgraded into proof.
