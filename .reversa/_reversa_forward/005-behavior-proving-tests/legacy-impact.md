# Legacy impact — 005-behavior-proving-tests

Date: 2026-08-25

Execution status: all 34 actions implemented. Local host-independent and injected-fixture proof passed; same-run artifact provenance and cross-platform native execution remain hosted-CI evidence boundaries.

| Affected file | Component | Type | Severity | Rationale |
|---|---|---|---|---|
| `lib/src/android_ssl_helper.dart` | Android TLS bootstrap | regra-alterada | MEDIUM | Adds an internal injectable operation bundle while preserving the public static facade and cache-after-write behavior. |
| `lib/src/runtime.dart` | Native loader/lifecycle | regra-alterada | LOW | Exposes an internal testable loader plan; production platform selection and fallback behavior remain unchanged. |
| `.github/scripts/native_cache_manifest.py` | Native cache validation | regra-alterada | MEDIUM | Rejects unsafe recorded paths and sanitizes validation failures. |
| `.github/scripts/platform_release_proof.py` | Platform proof helper | regra-alterada | MEDIUM | Validates nested proof paths, distinguishes version mismatch, and sanitizes aggregate proof paths. |
| `tool/architecture_policy_facts.dart` | Validation/release assembly | componente-novo | HIGH | Adds mandatory exact-pinned analyzer AST ownership facts. |
| `tool/workflow_policy_facts.dart` | Validation/release assembly | componente-novo | HIGH | Adds fail-closed parsed workflow dependency, trigger, condition, and cache-input facts. |
| `tool/package_consumer_bundle.dart` | Expanded package assembly | componente-novo | HIGH | Assembles a disposable injected bundle and runs clean public/native consumer proof with sanitized categories. |
| `.github/workflows/build_package.yml` | Publication gate | regra-nova | HIGH | Adds same-run bundle assembly and public/native consumer steps before publish validation and publication. |
| `pubspec.yaml`, `pubspec.lock` | Validation dependencies | delta-de-contrato-externo | MEDIUM | Makes analyzer 8.2.0 and YAML 3.1.3 direct exact development dependencies. |
| `test/**` | Validation suite | regra-alterada | HIGH | Retires FR-01–FR-08 source-string acceptance and replaces it with executable, AST, CLI, subprocess, bundle, and parsed-graph evidence. |

## Conceptual delta by component

The runtime surface keeps its managed lifecycle and loader behavior; only narrow internal seams were added for executable observation. Artifact CLIs now reject unsafe paths and expose bounded failure categories. Release validation no longer accepts source text as proof for FR-01–FR-08: behavior is observed through real commands, processes, AST facts, workflow facts, and a disposable expanded package. The publication job now consumes same-run artifacts and proves the bundle before dry-run/publication eligibility.

## Preserved

- The package-owned runtime remains the only owner of raw `git_libgit2_init` and `git_libgit2_shutdown` transitions.
- Desktop loading remains bare-name first, then package-root fallback; Android retains no desktop package fallback.
- Android TLS success is cached only after the certificate write completes; failure remains retryable.
- Native cache and platform release proof remain fail-closed.
- Generated bindings remain CI-owned inputs rather than tracked checkout evidence.
- Credential-bearing publication remains reachable only for an exact push to `refs/heads/main`.

## Modified

- Acceptance evidence for FR-01–FR-08 changed from source-string matching to executable/structural facts.
- Cache and platform-proof path/version validation is stricter and diagnostics are sanitized.
- Publication eligibility now includes clean expanded-package consumer proof.
