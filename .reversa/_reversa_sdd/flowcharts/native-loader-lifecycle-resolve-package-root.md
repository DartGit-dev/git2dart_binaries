# `_resolvePackageRoot` Function

```mermaid
flowchart TD
  Start["_resolvePackageRoot"] --> Override{"Non-empty GIT2DART_BINARIES_PACKAGE_ROOT?"}
  Override -- yes --> OverrideRoot["Return absolute override path"]
  Override -- no --> IsolateResolve["resolvePackageUriSync(public library)"]
  IsolateResolve -->|URI| UriRoot["Parent of public library"] --> Return["Absolute package root"]
  IsolateResolve -->|null/unsupported| ConfigUri["Find package-config URI"]
  ConfigUri -->|none| Fail["StateError"]
  ConfigUri --> Read["Read and parse JSON"]
  Read --> Valid{"Object with packages list?"}
  Valid -- no --> Fail
  Valid -- yes --> Scan["Find name=git2dart_binaries and String rootUri"]
  Scan -->|found| Resolve["Resolve rootUri against config URI"] --> Return
  Scan -->|not found/error| Fail
  OverrideRoot --> Cache["Cache first successful root"]
  Return --> Cache
```

🟢 CONFIRMED: package-config URI discovery tries isolate metadata, `DART_PACKAGE_CONFIG`, then `--packages=`. Malformed/missing config data collapses to no result before the final `StateError`.
