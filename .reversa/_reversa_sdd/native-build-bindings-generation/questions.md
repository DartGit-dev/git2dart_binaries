# Native Build and Bindings Generation, Open Questions

| ID | Question / missing proof | Why it matters | Confidence |
|---|---|---|---|
| NBG-Q1 | What hashes bind current generated ABI and each native payload to one workflow run? | HC-01/HC-07 remain open. | 🔴 |
| NBG-Q2 | Have all platform builders emitted and validated current artifacts? | Recipes do not prove hosted outputs. | 🔴 |
| NBG-Q3 | How will the iOS manifest/provenance file-set mismatch be resolved? | Current cache export can fail exactness. | 🔴 |
| NBG-Q4 | How will Windows cache fallback include recipe identity? | Older recipe outputs may self-validate. | 🔴 |
| NBG-Q5 | Are immutable commits, SBOMs, signatures, or attestations required? | Current tags/manifests do not provide full supply-chain identity. | 🔴 |
