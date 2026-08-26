# Data delta: Behavior-proving package validation

## Persistence impact

No database, durable runtime schema, or published Dart API data model changes are planned. All new data is ephemeral test/CI fixture input or evidence output. No migration is required.

## Conceptual fixture delta

| Descriptor | New fields | Producer | Consumer | Lifetime |
|------------|------------|----------|----------|----------|
| ABI probe case | `submitted_size`, `observed_size`, `pointer_width`, `availability` | native probe fixture | focused ABI test | process-local |
| Loader case | `bare_name`, `package_root`, `package_config`, `expected_stage`, `expected_exit_class` | fixture builder | fresh loader subprocess | temporary directory |
| Cache manifest case | `metadata`, `files[path].sha256`, `files[path].size`, `corruption_kind`, `expected_exit_class` | fixture builder / `native_cache_manifest` | CLI test | temporary directory |
| Platform proof case | `platform`, `abi`, `payload`, `version_evidence`, `failure_code`, `proof.schema/status` | fixture builder / `platform_release_proof` | CLI test and aggregate validator | temporary directory / CI artifact |
| Consumer bundle case | `package_root`, `binding_origin`, `native_payload`, `package_config`, `consumer_exit_class` | CI assembly step | clean consumer subprocess | disposable package |
| TLS operation case | `temporary_directory_result`, `asset_result`, `write_result`, `initialized`, `cert_path` | injected test dependencies | TLS helper unit test | process-local |
| Workflow graph fact | `job`, `needs`, `event`, `ref_condition`, `publication_reachable`, `validation_reachable` | workflow parser | policy test | test memory |
| Analyzer gate | `package`, `exact_version`, `resolved_version`, `api_compatible`, `failure_category` | package resolver / test bootstrap | AST validation | test memory |
| AST fact | `file`, `node_kind`, `symbol`, `owner_boundary`, `violation`, `analyzer_version` | analyzer visitor | architecture test | test memory |
| FR replacement ledger | `requirement`, `retired_assertion`, `replacement_type`, `case_id`, `status` | implementation test inventory | review / regression gate | tracked test metadata or generated report |

## Invariants

1. Fixture paths are relative to their temporary root; unsafe absolute, parent-traversal, or backslash-escaped payload paths must produce rejection, not normalization into acceptance.
2. Negative cases retain an observable non-success result and bounded category; absence of a host prerequisite is `unavailable`, never `passed`.
3. Package-bundle evidence records the source as same-run CI artifact; a tracked or checkout fallback is invalid evidence.
4. TLS state becomes cached only after the dependency write completes successfully; any failure leaves retry possible.
5. Proof diagnostics are sanitized and must not contain temporary or package-root absolute paths.
6. AST evidence is valid only when the direct exact-pinned analyzer dependency resolves to the intended compatible API; absent/incompatible analyzer produces non-success, not a skip.
7. Every retired FR-01–FR-08 source-string assertion maps one-to-one to a passing replacement proof; a missing mapping is a failing traceability gap.

## Migration

Not applicable. Existing manifests and release proof schema remain consumed by their public CLIs. New test fixtures must be generated at runtime and never committed as platform payloads or generated bindings.
