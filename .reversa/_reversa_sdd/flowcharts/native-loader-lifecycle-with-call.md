# `withCall` Function

```mermaid
flowchart TD
  Start["withCall(callback)"] --> Ensure["ensureInitialized"]
  Ensure --> Increment["activeCallCount++"]
  Increment --> Callback["Run synchronous callback"]
  Callback -->|returns| Finally["finally: activeCallCount--"]
  Callback -->|throws| Finally
  Finally --> Result{"Callback returned?"}
  Result -- yes --> Return["Return callback value"]
  Result -- no --> Rethrow["Propagate callback error"]
```

🟢 CONFIRMED: the transient count always balances through `finally`. Shutdown attempted from inside the callback sees a non-zero active count and fails before native shutdown.

