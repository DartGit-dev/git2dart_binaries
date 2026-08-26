# Android TLS Bootstrap, Open Questions

| ID | Question / missing proof | Why it matters | Confidence |
|---|---|---|---|
| ATB-Q1 | Does the default asset and temporary-file route succeed on a current Android emulator/device? | Injected host operations do not prove Flutter/platform I/O. | 🔴 |
| ATB-Q2 | Is the returned path applied after managed initialization by the current external consumer? | Extraction alone cannot configure libgit2. | 🔴 |
| ATB-Q3 | Does libgit2 HTTPS succeed with the extracted CA? | No live network/device observation exists. | 🔴 |
| ATB-Q4 | Has the confirmed shared in-flight Android/iOS first-call policy been implemented and tested, including failure fan-out? | Current helper is unsynchronized and the external consumer was not re-inspected. | 🔴 |
| ATB-Q5 | How is a removed/corrupt cached file detected and recovered? | Current cache checks only fields, not filesystem validity. | 🔴 |
