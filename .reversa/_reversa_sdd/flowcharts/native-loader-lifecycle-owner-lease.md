# Persistent Owner Lease Flow

```mermaid
flowchart TD
  Acquire["acquireOwner(debugLabel)"] --> Ensure["ensureInitialized"]
  Ensure --> Count["liveOwnerCount++"]
  Count --> Cleanup["Create _OwnerCleanup"]
  Cleanup --> Attach["Create lease and attach Finalizer"]
  Attach --> Use{"Owner outcome"}

  Use -->|bind destructor| Bind{"Completed or destructor already bound?"}
  Bind -- yes --> BindError["StateError"]
  Bind -- no --> Store["Store destructor"] --> Use

  Use -->|release / rollback| Complete["_complete(invokeDestructor: true)"]
  Use -->|transfer| Transfer["_complete(invokeDestructor: false)"]
  Use -->|unreachable owner| Finalizer["releaseFromFinalizer"]
  Finalizer --> FinalComplete["Try _complete(invokeDestructor: true)"]

  Complete --> Reentrant{"Already completed or completing?"}
  Reentrant -->|completed| NoOp["No-op"]
  Reentrant -->|completing| ReentrantError["StateError"]
  Reentrant -->|open| Destructor["Invoke optional destructor"]
  Destructor -->|throws| Retain["Keep incomplete + pin retained"]
  Destructor -->|success| Mark["Mark completed; liveOwnerCount--"]
  Transfer --> Mark
  FinalComplete -->|success| Mark
  FinalComplete -->|throws| Report["Report finalizerCleanup; keep pin; do not throw"]
  Mark --> Detach["Detach Finalizer"]
```

🟢 CONFIRMED: destructor success or transfer is required before unpinning. 🟡 INFERRED: consumers must choose the correct completion path for each native ownership contract; external call sites were not inspected.
