# Native Build and Bindings Generation, Edge Cases

| Case | Required result | Evidence | Confidence |
|---|---|---|---|
| Cache restored but metadata differs | Reject and rebuild. | manifest CLI/actions | 🟢 |
| Hash/size/file set differs | Reject and rebuild. | W004 | 🟢 local CLI |
| Unsafe relative path | Fail non-zero without leaking fixture root. | CLI tests | 🟢 |
| Empty/invalid export on create | Must return sanitized error; current handler can raise secondary `NameError`. | script:137 | 🟢 defect |
| iOS provenance added after manifest | Manifest/export exactness is broken. | build-ios:240 | 🟢 defect |
| Windows prefix hit from older recipe | Must not self-validate without recipe identity. | build-windows:48 | 🟢 defect |
| Upstream tag moves | Current tag pin is weaker than immutable commit identity. | checkout steps | 🟡 risk |
| Generated binding tracked locally | Fail closed; source fallback is forbidden. | ADR-011 | 🟢 policy |
| Host says cache hit | Do not count as acceptance before semantic validation. | ADR-007/W004 | 🟢 |
