# Native Loader and Lifecycle Flow

```mermaid
flowchart TD
  Access["First access to isolate-local libgit2Runtime"] --> Load["_loadLibrary"]
  Load --> Ready["DynamicLibrary handle"]
  Ready --> Views["Construct Libgit2 + Libgit2Opts"]
  Views --> State["Create uninitialized Libgit2RuntimeState"]

  State --> Entry{"Managed entry"}
  Entry -->|bindings/options/ensure| Ensure["ensureInitialized"]
  Entry -->|withCall| Call["Ensure + transient active-call pin"]
  Entry -->|acquireOwner| Owner["Ensure + persistent owner pin + Finalizer"]
  Entry -->|shutdown| Shutdown{"Pins are zero?"}

  Ensure --> Init{"git_libgit2_init > 0?"}
  Init -- yes --> Initialized["initialized; reuse one native lease"]
  Init -- no/throws --> Rollback["Attempt git_libgit2_shutdown rollback"]
  Rollback -->|success| Retryable["uninitialized + initialize exception"]
  Rollback -->|negative/throws| Faulted["faulted + rollback exception"]

  Call --> Finally["decrement in finally"] --> Initialized
  Owner --> Complete{"release / rollback / transfer succeeds?"}
  Complete -- yes --> Unpin["decrement owner count exactly once"] --> Initialized
  Complete -- no --> Pinned["retain pin; report finalizer error if fallback"]

  Shutdown -- no --> Reject["StateError; no native shutdown"]
  Shutdown -- yes --> NativeShutdown["shutdown uninitialized as 0, or call native once"]
  NativeShutdown -->|non-negative| Terminated["cache result; terminal and idempotent"]
  NativeShutdown -->|negative/throws| Faulted
```

🟢 CONFIRMED: production source implements the managed state and pin transitions above. 🔴 GAP: injected local tests do not establish cross-isolate native reference counts, deployed consumer cleanup, or hosted execution.
