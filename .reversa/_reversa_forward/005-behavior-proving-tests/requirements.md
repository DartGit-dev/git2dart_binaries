# Requirements: Behavior-proving package validation

> Identifier: `005-behavior-proving-tests`
> Date: `2026-08-25`
> Reverse-extraction directory: `.reversa/_reversa_sdd/`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP / OPEN QUESTION

## 1. Executive summary

This feature replaces source-string assertions with executable, behavior-proving validation across the native FFI package and its release factory.
It gives package maintainers evidence that ABI values, loader fallback and errors, cache/release-proof tools, expanded package contents, Android TLS retry behavior, and release workflow contracts actually behave as required.
The feature keeps validation fail-closed: a malformed artifact, invalid cache, failed loader, or invalid release proof must produce an observable failure rather than an apparent success.
The feature serves maintainers and downstream package authors who need proof from a consumer-like process rather than confidence derived only from source text.

## 2. Context from the legacy system

| Source | Relevant excerpt | Confidence |
|-------|------------------|-------------|
| `.reversa/_reversa_sdd/architecture.md#Architectural purpose` | The released product is an expanded CI-assembled package; the tracked checkout contains source and recipes rather than the whole runtime product. | 🟢 |
| `.reversa/_reversa_sdd/architecture.md#Architectural invariants` | Bindings/artifacts must share a pinned version; release gates must precede publication; direct consumer evidence is required before cross-repository behavior becomes confirmed. | 🟢 |
| `.reversa/_reversa_sdd/domain.md#ABI and version rules` | Typed variadic option layouts must match their discriminator, and negative values must be rejected before native `size_t` conversion. | 🟢 |
| `.reversa/_reversa_sdd/domain.md#Loader and lifecycle rules` | Desktop loading tries the application loader before package fallback, while Android has no package-root fallback and failures are terminal. | 🟢 |
| `.reversa/_reversa_sdd/domain.md#Android TLS rules` | Certificate extraction succeeds only after the asset write and failed initialization remains retryable. | 🟢 |
| `.reversa/_reversa_sdd/domain.md#Build, test, and publication rules` | Cache reuse requires manifest validation; the expanded package must satisfy size and publish dry-run gates. | 🟢 |
| `.reversa/_reversa_sdd/code-analysis.md#Module 7: Validation and release assembly` | Existing tests include source-level workflow assertions and may skip artifact-dependent checks when generated inputs are absent. | 🟢 |
| `.reversa/_reversa_sdd/addenda/003-platform-release-proof.md#Resumo da entrega` | Same-run platform proof is a fail-closed release-eligibility prerequisite. | 🟢 |
| `.reversa/_reversa_sdd/addenda/004-all-branch-ci-main-publish.md#Resumo da entrega` | Validation runs broadly, but only the credential-bearing publication step may run for a push to `main`. | 🟢 |
| `.reversa/_reversa_sdd/addenda/005-ci-owned-generated-bindings.md#Acceptance Contract` | CI-generated bindings are authoritative, untracked, and transferred from the same run into validation and assembly. | 🟢 |

## 3. Personas and usage scenarios

| Persona | Goal | Key scenario |
|---------|----------|---------------|
| Package maintainer | Detect a regression before release eligibility. | Runs the validation suite and receives a concrete failing probe or fixture when a native/runtime contract changes. |
| Release engineer | Establish trustworthy assembled-package evidence. | CI creates a package bundle and runs a minimal consumer process that imports and uses the bundle. |
| Downstream package author | Verify that public API and loader behavior work without checkout-specific paths. | Compiles a small external-consumer fixture against the package's public surface. |

## 4. New or changed business rules

1. **BR-01:** A validation claim is acceptable only when it observes the relevant runtime, subprocess, tool, or parsed workflow behavior; matching source text alone is not acceptance evidence. 🟢
   - Legacy source: `.reversa/_reversa_sdd/architecture.md#Technical debt and risk register`
   - Type: changed
2. **BR-02:** ABI validation must exercise a native-facing size value greater than the largest unsigned 32-bit value and preserve the expected value through the FFI boundary. 🟢
   - Legacy source: `.reversa/_reversa_sdd/domain.md#ABI and version rules`
   - Type: new
3. **BR-03:** A desktop loader must expose both successful package-root fallback and terminal failure semantics; Android must not acquire a desktop fallback. 🟢
   - Legacy source: `.reversa/_reversa_sdd/domain.md#Loader and lifecycle rules`
   - Type: changed
4. **BR-04:** Cache-manifest and platform-release-proof utilities accept valid fixtures and reject corrupt, unsafe, incomplete, mismatched, or unreadable inputs with non-success results. 🟢
   - Legacy source: `.reversa/_reversa_sdd/domain.md#Build, test, and publication rules`
   - Type: new
5. **BR-05:** Android TLS extraction may cache only a completed write; a failed first attempt must remain observable and a later attempt must be able to succeed. 🟢
   - Legacy source: `.reversa/_reversa_sdd/domain.md#Android TLS rules`
   - Type: changed
6. **BR-06:** Release/workflow validation must prove the reachable dependency graph and authorization rules, rather than asserting YAML substrings. 🟢
   - Legacy source: `.reversa/_reversa_sdd/addenda/004-all-branch-ci-main-publish.md#Resumo da entrega`
   - Type: changed

## 5. Functional requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|----|-----------|------------|--------------------|-------------|
| FR-01 | Provide an executable native FFI ABI probe that passes a `size_t`-represented value strictly greater than `4,294,967,295` through the relevant public/native option path. | Must | The probe observes the exact submitted value on a supported 64-bit native runtime; truncation, sign change, or an unavailable native prerequisite fails or is explicitly reported as unavailable. | 🟢 |
| FR-02 | Prove native-loader fallback and error semantics in isolated processes. | Must | One process succeeds only after desktop package-root fallback, while a separate missing-library case exits non-successfully with both failed attempts represented in diagnostics; Android behavior is not treated as having package fallback. | 🟢 |
| FR-03 | Exercise `native_cache_manifest` with executable valid and corrupt fixtures. | Must | A generated valid export/manifest validates successfully; independently corrupted metadata, file list, content digest/size, provenance fields, or JSON cause a non-zero validation result. | 🟢 |
| FR-04 | Exercise `platform_release_proof` with executable valid and corrupt fixtures. | Must | A valid platform fixture produces a schema-valid proof; missing expected payload, unsafe path, unexpected native payload, unreadable/mismatched version evidence, malformed proof, and unavailable loader/linkage conditions fail closed. | 🟢 |
| FR-05 | Prove the assembled package through an actual package bundle and a minimal consumer subprocess. | Must | The validation builds or receives the CI-owned generated binding plus required native payload, assembles a disposable package bundle, and runs a clean consumer process that resolves the bundle rather than the repository checkout. | 🟢 |
| FR-06 | Provide dependency-injected Android TLS helper tests for successful extraction, cached reuse, write/load failure, and retry after failure. | Should | Tests observe no cached success after a failed dependency call; a later successful invocation returns the extracted path and records initialized state only after the write completes. | 🟢 |
| FR-07 | Compile an external-consumer fixture against the public package API without reaching internal source paths. | Should | The fixture compiles in a separate temporary package context using only public imports; an internal-only import or absent generated binding must not be accepted as a valid consumer proof. | 🟡 |
| FR-08 | Validate architecture invariants using analyzer/AST-level facts and validate workflow behavior as a parsed dependency graph. | Could | Tests fail when raw lifecycle ownership escapes the designated runtime boundary, when prohibited source ownership reappears, when a required release dependency is disconnected, or when publication authorization is reachable outside an exact `push` to `main`. | 🟢 |

## 6. Non-functional requirements

| Type | Requirement | Evidence or rationale | Confidence |
|------|-----------|----------------------------|-------------|
| Reliability | Every negative fixture must assert a non-success status and a bounded diagnostic category; validation must not convert a failure into a skip once its declared prerequisites are present. | `.reversa/_reversa_sdd/domain.md#Build, test, and publication rules` | 🟢 |
| Portability | Tests may skip only when the host cannot supply the declared platform/native prerequisite; CI remains authoritative after same-run artifacts are injected. | `.reversa/_reversa_sdd/domain.md#Build, test, and publication rules` | 🟢 |
| Isolation | Consumer and loader proofs must run from disposable directories/processes and must not depend on repository current working directory or a system-installed libgit2. | `.reversa/_reversa_sdd/domain.md#Loader and lifecycle rules` | 🟢 |
| Security | Corrupt and unsafe fixture paths must be rejected without traversing outside the fixture/package root, and diagnostics must not expose absolute payload paths. | `.reversa/_reversa_sdd/addenda/003-platform-release-proof.md#Resumo da entrega` | 🟢 |
| Traceability | Each behavior test must identify its proven contract and state whether it is source-only, host-native, assembled-package, or hosted-CI evidence. | `.reversa/_reversa_sdd/architecture.md#Technical debt and risk register` | 🟢 |

## 7. Acceptance criteria

```gherkin
Scenario: Preserve a 64-bit ABI size value
  Given a supported native runtime and a value greater than 4294967295
  When the package passes that value through the selected FFI option boundary
  Then the observed native value equals the submitted value exactly

Scenario: Resolve a desktop native library by package fallback
  Given the application loader cannot resolve the bare desktop library name
  And a disposable package root contains the required fallback payload
  When a clean consumer process loads the package
  Then the process succeeds through the package-root fallback

Scenario: Reject an invalid native cache manifest
  Given a cache export with a manifest whose recorded digest differs from its file
  When manifest validation runs
  Then it exits non-successfully and reports cache validation failure

Scenario: Reject corrupt platform proof input
  Given a release-payload fixture with an unsafe relative artifact path
  When platform proof validation runs
  Then it exits non-successfully without accepting the fixture

Scenario: Retry Android certificate extraction
  Given injected Android TLS dependencies fail before the certificate write completes
  When a subsequent call uses successful dependencies
  Then the subsequent call returns the certificate path and marks initialization complete

Scenario: Prevent publication outside authorized main push
  Given the parsed release workflow graph for a pull request or non-main push
  When publication reachability is evaluated
  Then the credential-bearing publication operation is unreachable while validation remains reachable
```

## 8. MoSCoW priority

| Item | MoSCoW | Rationale |
|------|--------|---------------|
| FR-01 through FR-04 | Must | P0 evidence covers ABI integrity, loader errors, and fail-closed artifact tooling. |
| FR-05 | Must | The delivered product is the expanded package, so source-checkout proof is insufficient. |
| FR-06 and FR-07 | Should | P1 closes retry and external-consumer proof gaps without changing public behavior. |
| FR-08 | Could | P2 hardens structural/workflow guarantees after executable release evidence is established. |

## 9. Clarifications

### Session 2026-08-25

- **Q:** Какой объём существующих source-string тестов должен быть заменён в feature `005`?
  **R:** Все source-string assertions, относящиеся к FR-01–FR-08, должны быть заменены executable-проверками поведения. Это устанавливает единый стандарт доказательств для всех требований feature.
- **Q:** Допустима ли прямая зависимость behavior-тестов от Dart analyzer для AST-инвариантов FR-08?
  **R:** Да. `analyzer` является обязательной тестовой зависимостью с зафиксированной версией в `dev_dependencies`; production-код от этой зависимости не зависит.
- **Q:** Что делать FR-08, если analyzer недоступен или его версия не совпадает с ожидаемой?
  **R:** Проверка завершается fail-closed с ошибкой; недоступность или несовместимость analyzer не может быть преобразована в skip или успешный результат.

## 10. Gaps

- The external-consumer proof is scoped to a disposable fixture inside this repository, not an uninspected neighboring repository; it therefore proves package consumption, not the behavior of `git2dart`. 🔴 external-repository boundary remains outside this feature.

## 11. Change history

| Data | Alteração | Autor |
|------|-----------|-------|
| 2026-08-25 | Initial version generated by `/reversa-requirements` | reversa |
