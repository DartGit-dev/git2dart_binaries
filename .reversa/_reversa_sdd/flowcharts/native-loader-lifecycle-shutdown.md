# `shutdown` Function

```mermaid
flowchart TD
  Start["shutdown"] --> Terminated{"phase == terminated?"}
  Terminated -- yes --> Cached["Return cached shutdown result"]
  Terminated -- no --> Faulted{"phase == faulted?"}
  Faulted -- yes --> FaultError["Throw terminal StateError"]
  Faulted -- no --> Pins{"activeCallCount or liveOwnerCount non-zero?"}
  Pins -- yes --> PinError["Throw StateError; no native call"]
  Pins -- no --> Uninitialized{"phase == uninitialized?"}
  Uninitialized -- yes --> Zero["Cache 0; phase = terminated; return 0"]
  Uninitialized -- no --> Native["Call injected native shutdown"]
  Native --> Result{"Returned non-negative?"}
  Result -- yes --> Commit["Cache result; phase = terminated; return result"]
  Result -- no --> NativeFault["phase = faulted; throw shutdown exception"]
  Native -->|throws| ThrowFault["phase = faulted; wrap cause"]
```

🟢 CONFIRMED: successful shutdown is isolate-terminal and idempotent, while positive remaining native counts are valid return values. 🔴 GAP: no current test traces two real isolates sharing one process-global libgit2 counter.
