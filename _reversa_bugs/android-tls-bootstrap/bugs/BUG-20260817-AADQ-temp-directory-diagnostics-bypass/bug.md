---
schema_version: 1
id: BUG-20260817-AADQ
display_number: 6
title: Temporary directory failures bypass TLS helper diagnostics
status: open
phase: triaging
severity: low
priority: P3
created: 2026-08-17
updated: 2026-08-17

origin:
  type: inspection
  external_ref: null

area: runtime
module: android-tls
feature: android-tls-bootstrap
labels:
  - diagnostics-loss
  - error-path

visibility: normal
security_suspected: false

reproduction:
  classification: deterministic
  rate: "1/1 static exception path"
  suspected_triggers:
    - getTemporaryDirectory throws before asset extraction begins

blocking: []
relationships: []

traceability:
  specs:
    - _reversa_sdd/android-tls-bootstrap/design.md#alternative-flows
    - _reversa_sdd/android-tls-bootstrap/design.md#state-and-observability
  affected_code:
    - "lib/src/android_ssl_helper.dart:68-77"
    - "lib/src/android_ssl_helper.dart:90-92"
  root_cause: null
  reproduction_tests: []
  regression_tests: []

spec_verdict: null
change_set: []

closure:
  policy: package
  satisfied: false
resolution_kind: null
---

# Temporary directory failures bypass TLS helper diagnostics

## Summary

`AndroidSSLHelper.initialize()` resolves the temporary directory before entering its diagnostic `try` block. A provider or path-resolution failure is rethrown by the Future but produces none of the helper stderr diagnostics promised for extraction errors.

## Expected Behavior

The effective Android TLS design states that any extraction error is written to stderr and rethrown. The helper observability contract provides a short stderr message for failure.

## Actual Behavior

`getTemporaryDirectory()` executes before the `try` statement. Only asset-load and file-write failures reach the catch that writes `Android cert initialization failed.`. Cached state remains retryable, but the helper diagnostic is absent for the directory failure path.

## Steps to Reproduce

1. Make `getTemporaryDirectory()` complete with an exception.
2. Call `AndroidSSLHelper.initialize()`.
3. Observe that the Future fails and cached state remains incomplete.
4. Confirm that the catch at lines 90-92 is not reached and no helper stderr message is emitted.

## Evidence

- `evidence/inspection-evidence.md`
- `../../inspections/20260817-depth-inspection/report.md`

## Suspected Area

The diagnostic boundary around temporary-directory resolution and asset extraction.

## Acceptance Criteria

1. Temporary-directory, asset-load, and file-write failures follow the same documented diagnostic and rethrow contract.
2. A failure-injection test proves directory-resolution diagnostics and retryable state.
3. No failed call marks `_initialized` or `_certPath` as successful.
4. The corrected package is merged and published under the package closure policy.

## Traceability

- Effective spec: Android TLS alternative flow and observability design.
- Affected code: `AndroidSSLHelper.initialize()`.
- Inspection finding: F-ATB-CONF-01, candidate C-ATB-01.

## Resolution

Not started. Root cause confirmation, specification verdict, regression tests, delivery, and publication evidence remain required.

## Agent Notes

- Registration did not modify source code or tests.
- Dedupe rejected `BUG-20260816-AAFR` as a match because it covers a different loader, spec, and diagnostic chain.
