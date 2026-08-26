# Data Delta: OpenSSL source-build provenance parity

## Conceptual diff

The extracted model has no persistent business database.  Its affected records
are the native cache manifest and the platform artifact handoff described in
`.reversa/_reversa_sdd/architecture.md#Data model` and
`.reversa/_reversa_sdd/state-machines.md#Native artifact cache`.

| Record | Legacy fields | Delta | Compatibility / migration |
|---|---|---|---|
| Native cache manifest | `schema`, platform/ABI, libgit2, libssh2, `openssl`, toolchain, file hashes/sizes | Add `openssl_provenance` (`source-build` or `approved-exception`), `openssl_source_ref` for source builds, and `openssl_exception_id` only for exceptions. | Bump schema/key; legacy `native-v1` entries are invalid and rebuild rather than being interpreted. |
| Native artifact provenance sidecar | Not exported | Add a JSON sidecar containing the same identity fields, artifact-file digest set, and source-build/exception evidence. | Every release-platform artifact uploader emits one; release assembly downloads and validates all required sidecars. |
| Approved exception record | Not present | Add a versioned checked-in record: platform/ABI, exact configured version, infeasibility statement and evidence link, approver, expiry/review date, and exception ID. | Absence means source-build only.  Malformed, expired, non-matching, or unreferenced records fail qualification. |
| Release parity verdict | Not present | Add an ephemeral qualification result listing every platform sidecar and whether version equality plus the allowed provenance route passed. | Do not publish it as an authority for cache reuse; it is release evidence only. |

## Validation invariants

1. `openssl` equals the workflow's configured version for every manifest and
   sidecar.
2. A `source-build` record has the expected OpenSSL source reference and no
   exception ID.
3. An `approved-exception` record has a matching checked-in exception ID and a
   release-time exact-version comparison against every required platform
   sidecar.
4. File lists, SHA-256 values, and sizes continue to be validated by
   `native_cache_manifest.py`; provenance metadata does not replace content
   integrity checks.
5. Missing data is invalid.  No field may be inferred from `openssl version`, a
   runner path, or a DLL name.

## Data migration

No user data migration exists.  Existing native cache entries and artifacts
lack provenance fields, so they must be treated as incompatible and rebuilt or
re-uploaded under the new schema.  Release assembly must reject a mixed set of
legacy and new artifact evidence.
