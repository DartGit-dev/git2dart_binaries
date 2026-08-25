# Android TLS Dependency Wiring

```mermaid
flowchart LR
  Public["initialize()"] --> Defaults["_defaultDependencies"]
  Defaults --> Temp["getTemporaryDirectory"]
  Defaults --> Asset["rootBundle.load(package-qualified asset)"]
  Defaults --> Writer["File.writeAsBytes(bytes, flush: true)"]
  TestFacade["initializeWith(dependencies)"] --> Injected["caller-supplied operations"]
  Temp --> Core["_initialize"]
  Asset --> Core
  Writer --> Core
  Injected --> Core
  Core --> State["shared static completion state"]
  Barrel["git2dart_binaries.dart exports helper library"] --> PublicNames["AndroidSSLDependencies,<br/>initializeWith, resetForTesting"]
  PublicNames --> Exposure["🔴 test seam is publicly reachable"]
```

🟢 Host tests select injected operations and therefore exercise the core transition logic. 🔴 They do not execute the default Flutter asset or Android path-provider wiring.
