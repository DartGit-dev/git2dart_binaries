# Regression watch — 005-behavior-proving-tests

All implementation actions completed. The following confirmed rules now carry stable regression watches.

| ID | Origin (file, section) | Expected rule after change | Verification type | Violation signal |
|---|---|---|---|---|
| W001 | `domain.md`, ABI and version rules | A supported 64-bit payload preserves a submitted native `size_t` value above `0xffffffff` exactly. | presence | ABI probe truncates, changes sign, or is reported passed without a declared payload. |
| W002 | `domain.md`, Loader and lifecycle rules | Desktop remains bare-name then package fallback with terminal two-stage diagnostics; Android has no package fallback. | presença | Fallback order changes, terminal diagnostics lose a stage, or Android gains a package subdirectory. |
| W003 | `domain.md`, Android TLS rules | Initialization caches only after a successful write and every pre-write failure remains retryable. | presença | Failed dependency call leaves initialized state or blocks a later successful call. |
| W004 | `domain.md`, Build, test, and publication rules | Cache manifests and platform proofs reject corrupt, unsafe, incomplete, mismatched, and unreadable inputs with sanitized non-success. | presença | Any negative fixture exits zero, traverses outside its root, or leaks an absolute fixture path. |
| W005 | `architecture.md`, Architectural invariants | Expanded-package evidence uses injected same-run bindings/payload and a bundle-only clean consumer. | presença | Checkout/global-cache/system fallback is accepted or the clean consumer resolves a non-bundle package root. |
| W006 | addendum `004-all-branch-ci-main-publish`, acceptance contract | Validation remains broadly reachable and credential-bearing publication only on exact main push, after proof/inventory/consumer gates. | presença | Publication is reachable for PR/non-main push or any required gate is disconnected/downstream. |

## Re-extraction history

### Re-extração 2026-08-25 17:46

| ID | Veredito | Observação |
|----|----------|------------|
| W001 | 🟢 verde | BR-015 and the BPT ABI contract preserve the exact `0x100000011` round trip with restoration; local native evidence is cached-package scoped, not current same-run proof. |
| W002 | 🟢 verde | BR-029–BR-035 preserve desktop bare-name→package fallback, two-stage terminal diagnostics, and Android no-fallback; successful handle origin remains an explicit gap. |
| W003 | 🟢 verde | BR-039–BR-041 preserve cache-after-write and retryable pre-commit failures; the fresh injected suite passed 4/4. |
| W004 | 🟢 verde | BR-050/BR-053 preserve fail-closed artifact inputs and sanitized non-success; the fresh CLI/AST/workflow suite passed 26/26. |
| W005 | 🟢 verde | BR-058/BR-059 preserve exact bundle-only consumer resolution; the fresh bundle suite passed 4/4, while current same-run identity remains unobserved. |
| W006 | 🟢 verde | BR-055–BR-058 preserve broad validation and exact-main publication after all gates; parsed local execution is not promoted to hosted GitHub/pub.dev evidence. |

_No re-extraction has been run for this feature._

## Archived

_None._

## Observations

Local fixture-native success does not establish same-run CI provenance or non-Windows native behavior; those remain hosted-CI observations, not weakened watches.
