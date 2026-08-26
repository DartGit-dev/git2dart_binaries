# Behavior-Proving Tests, Implementation Tasks

## Prerequisites

- [ ] Exact analyzer/YAML/tool dependencies are resolved. 🟢 current local configuration
- [ ] Native probes declare their binding/payload origin or emit unavailable. 🟢 contract

## Tasks

- [ ] BPT-T-01, Recreate guarded fixture lifecycle. Origin: `test/support/behavior_proof_fixture.dart:1`. Done when traversal is rejected, timeouts are bounded, roots are sanitized, and cleanup completes. Confidence: 🟢.
- [ ] BPT-T-02, Recreate W001-W003 runtime probes. Origin: `test/fixtures/`, Android/runtime tests. Done when ABI, loader, and TLS observations retain explicit prerequisites and boundaries. Confidence: 🟢 local; 🔴 platform matrix.
- [ ] BPT-T-03, Recreate W004 artifact CLI matrices. Origin: manifest/proof tests. Done when valid and independent negative families have deterministic exits and sanitized records. Confidence: 🟢 local.
- [ ] BPT-T-04, Recreate W005 disposable bundle consumer. Origin: `tool/package_consumer_bundle.dart:31`. Done when checkout binding, missing payload, wrong root, timeout, compile, and native modes are classified. Confidence: 🟢 mechanism; 🔴 same-run identity.
- [ ] BPT-T-05, Recreate W006 AST/workflow fact tools. Origin: `tool/architecture_policy_facts.dart`, `tool/workflow_policy_facts.dart`. Done when exact dependencies resolve and unsupported syntax fails closed. Confidence: 🟢 local parser.
- [ ] BPT-T-06, Maintain FR-01–FR-08 replacement and W001-W006 watch traceability. Origin: feature-005 Writer inputs. Done when every retired source assertion points to executable/parsed evidence and a violation signal. Confidence: 🟢.

## Test Tasks

- [ ] BPT-TT-01, Run safe local fixture/parser/injected tests. 🟢
- [ ] BPT-TT-02, Run native probes only with declared matching payloads. 🟢
- [ ] BPT-TT-03, Run current hosted matrix and retain same-run artifacts. 🔴

## Pending Gaps

Current same-run hosted artifacts, handle origin, real Android TLS, external `git2dart`, GitHub controls, and publication remain unproven. 🔴
