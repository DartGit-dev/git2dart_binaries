# Native Loader and Lifecycle, Open Questions

| ID | Question / missing proof | Why it matters | Confidence |
|---|---|---|---|
| NLL-Q1 | Which path supplied the successfully loaded desktop handle? | W002 currently cannot distinguish bare-name success from package fallback. | 🔴 |
| NLL-Q2 | How are libgit2 init counts coordinated across Dart isolates and the external consumer? | Native count is process-global while bookkeeping is isolate-local. | 🔴 |
| NLL-Q3 | Does production `git2dart` acquire, release, and drain every owner before shutdown? | HC-03 cannot be closed locally. | 🔴 |
| NLL-Q4 | Does Android load the bundled payload on a real device without fallback? | Host-side plan mapping is not device execution. | 🔴 |
| NLL-Q5 | Are generated binding and payload identity joined to the loaded handle? | A successful load may still use an unintended library. | 🔴 |
