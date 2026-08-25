# Feature-005 Pointer-Width ABI Probe

```mermaid
flowchart TD
  Start["Register integration test file"] --> Runtime["Read runtime.bindings and runtime.options"]
  Runtime --> Load{"Native runtime loads?"}
  Load -- no --> EarlyFail["File fails before unavailable classification"]
  Load -- yes --> Payload{"Declared package root present?"}
  Payload -- no --> UnavailablePayload["Report ABI evidence unavailable"]
  Payload -- yes --> Subprocess["Start bounded probe subprocess"]
  Subprocess --> Width{"IntPtr width == 64 bits?"}
  Width -- no --> UnavailableWidth["Emit unavailable record with pointer width"]
  Width -- yes --> Allocate["Allocate Pointer<Size>"]
  Allocate --> GetOriginal["try: GET_MWINDOW_FILE_LIMIT"]
  GetOriginal --> Set["SET_MWINDOW_FILE_LIMIT = 0x100000011"]
  Set --> GetObserved["GET_MWINDOW_FILE_LIMIT"]
  GetObserved --> Equal{"observed == submitted?"}
  Equal -- yes --> Emit["Emit available JSON record; exit 0"]
  Equal -- no --> Fail["Exit non-zero"]
  GetOriginal -->|throws/non-zero| Catch["Emit sanitized failure type; exit 1"]
  Set -->|throws/non-zero| Catch
  GetObserved -->|throws/non-zero| Catch
  Emit --> Finally
  Fail --> Finally
  Catch --> Finally["finally"]
  Finally --> Restore["Restore original value when captured"]
  Restore --> Free["Free Pointer<Size>"]
  Free --> Shutdown["Shutdown managed runtime if initialized"]
```

🟢 CONFIRMED: with a loadable 64-bit payload this is a real libgit2 set/get round trip above `uint32`, not a source-string assertion. 🔴 GAP: missing package-root classification occurs only after file-level runtime access succeeds, and this extraction did not inspect a same-run hosted execution.
