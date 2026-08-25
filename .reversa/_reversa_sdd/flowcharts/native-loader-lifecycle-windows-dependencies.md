# `_loadWindowsDependencies` Function

```mermaid
flowchart TD
  Start["_loadWindowsDependencies(packageRoot)"] --> Dir["windows package directory"]
  Dir --> Exists{"Directory exists?"}
  Exists -- no --> Missing["Attempt libssh2.dll in missing path"] --> MissingResult{"Open succeeds?"}
  MissingResult -- yes --> Return["Return"]
  MissingResult -- no --> Throw["Propagate loader error"]
  Exists -- yes --> Prefix["For prefix: libcrypto, then libssl"]
  Prefix --> List["List files matching prefix + .dll"]
  List --> Sort["Sort paths lexicographically"]
  Sort --> OpenEach["Open each matching DLL"]
  OpenEach --> Next{"More prefixes?"}
  Next -- yes --> Prefix
  Next -- no --> SSH["Open libssh2.dll"]
  SSH --> Return
```

🟢 CONFIRMED: OpenSSL matches are case-normalized by filename prefix and `.dll` extension before sorting. Any listing/open failure is logged by the caller and rethrown.
