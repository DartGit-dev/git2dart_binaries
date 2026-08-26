# Validation and Release Assembly, Edge Cases

| Case | Required result | Evidence | Confidence |
|---|---|---|---|
| Any required job fails | `publish_package` is ineligible. | workflow `needs` | 🟢 |
| Proof scope missing/duplicate/unsafe/failed | Aggregate gate fails. | proof validator | 🟢 |
| Passed proof has empty semantic inventory | Current aggregate may accept it; strengthened contract must reject. | proof test/script | 🟢 defect |
| Proof candidate differs from release candidate | Current aggregate does not enforce identity. | script:193 | 🟢 defect |
| Payload hash differs from proof record | Current release does not compare them. | HC-07 | 🟢 gap |
| Expanded selected paths exceed 256 MiB | Block before dry-run/publication. | workflow size gate | 🟢 |
| PR event | Upload inspection artifact; never publish. | W006 | 🟢 static; 🔴 hosted route |
| Non-main push | Validate but never publish. | W006 | 🟢 static; 🔴 hosted route |
| Main push lacks credential/approval | Publisher cannot establish external success. | external controls | 🔴 |
| Dry-run passes | Do not claim pub.dev acceptance. | evidence ladder | 🟢 boundary |
