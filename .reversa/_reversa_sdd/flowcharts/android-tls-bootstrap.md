# Android TLS Bootstrap Flow

```mermaid
flowchart TD
  Caller["Caller"] --> Order["Documented prerequisite:<br/>managed libgit2 initialized"]
  Order --> Init["AndroidSSLHelper.initialize()"]
  Init --> Default["Select default dependencies"]
  Test["Host behavior test"] --> Injected["initializeWith(injected dependencies)"]
  Default --> Core["_initialize(dependencies)"]
  Injected --> Core
  Core --> Cached{"_initialized &&<br/>_certPath != null?"}
  Cached -- yes --> ReturnCached["Return cached path<br/>without dependency calls"]
  Cached -- no --> Temp["Await temporary directory"]
  Temp --> Target["Target temp/cacert.pem"]
  Target --> Asset["Await certificate bytes"]
  Asset --> Write["Await certificate writer"]
  Write --> Commit["Set certPath, then initialized=true"]
  Commit --> Return["Return extracted path"]
  Temp -->|throws| Failure["stderr marker + rethrow;<br/>no success commit"]
  Asset -->|throws| Failure
  Write -->|throws| Failure
  Failure --> Retry["Later call may retry"]
  Return --> Apply["External caller must apply path<br/>to libgit2 certificate options"]
  ReturnCached --> Apply
  Apply --> HTTPS["Android HTTPS behavior"]
  Order -. "not enforced by helper" .-> Gap1["🔴 runtime ordering gap"]
  Apply -. "not called by helper" .-> Gap2["🔴 external-consumer boundary"]
  HTTPS -. "no inspected device/hosted run" .-> Gap3["🔴 live proof gap"]
```

🟢 The solid extraction path is source-confirmed; feature-005 host tests execute the injected state edges. Dotted nodes identify obligations that the helper and those host tests do not execute.
