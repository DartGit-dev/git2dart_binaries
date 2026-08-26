# `isValidRefName` Function

```mermaid
flowchart TD
  Start["Input String"] --> Empty{"Empty?"}
  Empty -- yes --> False["false"]
  Empty -- no --> Invalid{"Matches whitespace or ~ ^ : ? * [ ?"}
  Invalid -- yes --> False
  Invalid -- no --> Suffix{"Ends with . or / or ./ ?"}
  Suffix -- yes --> False
  Suffix -- no --> DoubleDot{"Contains .. ?"}
  DoubleDot -- yes --> False
  DoubleDot -- no --> DotSlash{"Contains ./ ?"}
  DotSlash -- yes --> False
  DotSlash -- no --> True["true"]
```

🟢 CONFIRMED: this diagram reproduces the handwritten predicate in source order. 🔴 GAP: no call to libgit2's native reference-name validator or hosted consumer execution proves that this subset is complete Git reference-name validation.
