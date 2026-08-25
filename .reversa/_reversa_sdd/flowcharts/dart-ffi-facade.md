# Dart FFI Facade Flow

```mermaid
flowchart TD
  Consumer["Dart consumer"] --> Import["Import public git2dart_binaries.dart"]
  Import --> Barrel["Export barrel"]
  Barrel --> Generated["Generated Libgit2 ABI"]
  Barrel --> Runtime["Checked runtime + compatibility loader globals"]
  Barrel --> Options["Libgit2Opts wrappers"]
  Barrel --> AndroidTLS["AndroidSSLHelper"]
  Barrel --> Errors["Lifecycle and borrowed native-error diagnostics"]
  Barrel --> Helpers["Conversion and validation extensions"]

  Errors --> Lifecycle["Operation enum + structured exception"]
  Errors --> LastError{"git_error_last() is null?"}
  LastError -- yes --> NoError["Return null"]
  LastError -- no --> Borrowed["Return privately constructed LibGit2Error"]

  Helpers --> SHA["SHA-1 hex + inclusive length predicate"]
  Helpers --> Ref["Handwritten ref-name subset predicate"]
  Helpers --> ObjectType["Integer >= COMMIT threshold"]
  Helpers --> UTF8["Null-safe UTF-8 pointer decode"]

  Generated -. "export/import declaration" .-> Missing["bindings.dart absent from working tree"]
  Missing -. "requires" .-> CI["Same-run CI binding + native payload injection"]
  CI -. "not inspected in this pass" .-> HostedGap["Hosted provenance/publication gap"]
```

🟢 CONFIRMED: the public entry, helper branches, and private native-error construction follow the local source shown above. 🟡 INFERRED: a higher-level Dart package uses the facade in production because no external consumer call sites were inspected. 🔴 GAP: source exports and local tests do not prove a same-run hosted package assembly, runtime execution, or publication.
