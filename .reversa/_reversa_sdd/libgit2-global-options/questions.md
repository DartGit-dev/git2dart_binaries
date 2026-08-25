# libgit2 Global Options, Open Questions

| ID | Question / missing proof | Why it matters | Confidence |
|---|---|---|---|
| LGO-Q1 | Do same-run generated discriminator values match every typed wrapper? | The generated binding is absent locally. | 🔴 |
| LGO-Q2 | Has W001 passed on every required 64-bit platform payload? | One local declared fixture cannot prove the matrix. | 🔴 |
| LGO-Q3 | Which component serializes/restores process-global mutations in production? | Concurrent consumers can interfere. | 🔴 |
| LGO-Q4 | Are all 33 methods covered for success, error, ownership, and restoration? | Current native coverage is explicitly incomplete. | 🔴 |
