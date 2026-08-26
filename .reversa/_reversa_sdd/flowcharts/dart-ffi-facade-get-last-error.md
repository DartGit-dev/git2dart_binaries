# `getLastError` Function

```mermaid
flowchart TD
  Start["Libgit2 receiver"] --> Native["Call git_error_last()"]
  Native --> Null{"Pointer == nullptr?"}
  Null -- yes --> None["Return null"]
  Null -- no --> Wrap["Call private LibGit2Error._(pointer)"]
  Wrap --> Borrowed["Return borrowed wrapper"]
  Borrowed --> Message{"message pointer == nullptr?"}
  Message -- yes --> Empty["message returns empty String"]
  Message -- no --> Decode["Decode zero-terminated UTF-8"]
  Borrowed --> Klass["errorClass = git_error_t.fromValue(klass)"]
```

🟢 CONFIRMED: public callers cannot construct the wrapper from arbitrary native addresses. 🟡 INFERRED: the wrapper remains valid only while libgit2's borrowed last-error storage remains valid. 🔴 GAP: the local source-contract test does not exercise this native lifetime.
