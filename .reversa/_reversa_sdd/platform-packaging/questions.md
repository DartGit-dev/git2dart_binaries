# Platform Packaging, Open Questions

| ID | Question / missing proof | Why it matters | Confidence |
|---|---|---|---|
| PPK-Q1 | What exact files were emitted by the current five-platform workflow run? | Payload bytes are absent locally. | 🔴 |
| PPK-Q2 | Which path supplied each successful native handle? | Loader success does not currently identify origin. | 🔴 |
| PPK-Q3 | Do current Android/iOS app bundles execute the injected native payload? | Recipes and host tests do not prove device/simulator runtime. | 🔴 |
| PPK-Q4 | Who owns signing, notarization, and platform security acceptance? | These controls are external to repository recipes. | 🔴 |
| PPK-Q5 | What gate synchronizes pub/podspec versions and duplicate CA bytes? | Current metadata and asset copies can drift. | 🔴 |
