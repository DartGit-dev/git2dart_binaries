# `isValidSHA1` Function

```mermaid
flowchart TD
  Start["Input String"] --> Hex{"One or more ASCII hex characters only?"}
  Hex -- no --> False["false"]
  Hex -- yes --> Min{"length >= GIT_OID_MINPREFIXLEN?"}
  Min -- no --> False
  Min -- yes --> Max{"length <= GIT_OID_SHA1_HEXSIZE?"}
  Max -- no --> False
  Max -- yes --> True["true"]
```

🟢 CONFIRMED: the function combines a Dart regular expression with generated libgit2 length constants. 🔴 GAP: `bindings.dart` is absent from the working tree, so the current generated constant values were not independently inventoried in this pass.
