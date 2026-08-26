# Dart FFI Facade, Open Questions

| ID | Question / missing proof | Why it matters | Confidence |
|---|---|---|---|
| DFF-Q1 | Which public symbols are used by the external `git2dart` repository at the current selected version pair? | Compatibility cannot be inferred from local exports. | 🔴 |
| DFF-Q2 | What exact generated binding bytes were paired with each current five-platform payload? | HC-01 requires same-run identity. | 🔴 |
| DFF-Q3 | Does a current clean consumer compile and execute only through public imports? | Local fixture availability is not hosted evidence. | 🔴 |
| DFF-Q4 | Are complete ref-name/object-type rules now exercised by the real consumer? | The observed predicates remain weaker than the intended contract. | 🔴 |
