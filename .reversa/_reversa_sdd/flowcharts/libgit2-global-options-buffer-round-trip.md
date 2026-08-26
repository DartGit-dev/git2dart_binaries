# Buffer Option Round-Trip Pattern

```mermaid
flowchart TD
  Allocate["Allocate and initialize git_buf"] --> GetOriginal["Call getter"]
  GetOriginal --> Copy["Copy original native string into caller-owned UTF-8 memory"]
  Copy --> Dispose1["git_buf_dispose; reset fields"]
  Dispose1 --> Set["Call setter with new C string"]
  Set --> GetAgain["Call getter again"]
  GetAgain --> Finally["finally"]
  Finally --> Restore["Restore original string if mutation occurred"]
  Restore --> Dispose2["Dispose git_buf"]
  Dispose2 --> Free["Free wrapper and caller-owned strings"]
```

🟢 CONFIRMED: search-path and user-agent tests execute this native mutation/restoration pattern when the payload loads. 🟡 Evidence is status-based because the second buffer contents are not asserted against the requested value.

