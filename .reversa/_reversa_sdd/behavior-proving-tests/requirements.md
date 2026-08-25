# Behavior-Proving Tests

## Overview

The unit must classify and produce executable evidence for W001-W006 without promoting source presence, unavailable prerequisites, fixtures, or historical runs beyond their authority. 🟢

## Responsibilities and Rules

- Guard disposable roots, bound subprocesses, sanitize diagnostics, and clean fixtures. 🟢
- Replace source-string acceptance for FR-01–FR-08 with behavior, parsed AST, parsed workflow, or explicit unavailable records. 🟢
- Preserve the six-watch contract and evidence ladder from source through publication. 🟢
- Treat the recorded 39/39 safe local cases and cached Windows 1.12.1 fixture as tier-3/4 evidence only. 🟢 historical/local; 🔴 current hosted identity

## Functional Requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|---|---|---|---|---|
| BPT-RF-01 | Prove W001 exact 64-bit size round trip when a matching payload exists. | Must | `0x100000011` is observed exactly and original state is restored. | 🟢 mechanism; 🔴 current matrix |
| BPT-RF-02 | Prove W002 loader failure stages and Android no-fallback plan in fresh processes. | Must | Bounded records distinguish stages; positive origin remains explicit. | 🟢 local failure/plan; 🔴 handle origin |
| BPT-RF-03 | Prove W003 cache-after-write and all retry edges through injected operations. | Must | Directory, asset, and write failure each remain retryable. | 🟢 |
| BPT-RF-04 | Prove W004 artifact CLI success and independent corruption failures. | Must | Invalid inputs exit non-zero with sanitized evidence. | 🟢 local CLI |
| BPT-RF-05 | Prove W005 bundle-only resolution and clean public/native consumer. | Must | Exact package root plus available success or explicit unavailable is recorded. | 🟢 mechanism; 🔴 same-run identity |
| BPT-RF-06 | Prove W006 lifecycle/workflow structure with exact dependency versions. | Must | Analyzer 8.2.0 resolves and fail-closed facts enforce broad validation/exact-main publication. | 🟢 local structural |
| BPT-RF-07 | Never classify unavailable/static/local evidence as hosted or publication success. | Must | Every result states prerequisites, tier, proves, and does-not-prove. | 🟢 policy |

## Acceptance Scenarios

```gherkin
Given a required native prerequisite is absent
When a behavior probe runs
Then it records unavailable and no higher-tier success is claimed

Given a fixture path appears in an error
When diagnostics are persisted
Then the guarded root is sanitized and the process exits non-zero
```

## Code Traceability

`test/support/behavior_proof_fixture.dart`, `test/fixtures/`, behavior tests, and `tool/*.dart`. 🟢
