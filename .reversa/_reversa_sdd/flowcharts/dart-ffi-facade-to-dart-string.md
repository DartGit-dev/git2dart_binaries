# `toDartString` Function

```mermaid
flowchart TD
  Start["Pointer<Char> receiver + optional length"] --> Null{"Pointer == nullptr?"}
  Null -- yes --> Empty["Return empty String"]
  Null -- no --> Cast["Cast pointer to Pointer<Utf8>"]
  Cast --> Decode["Forward optional length to package:ffi toDartString"]
  Decode --> Result["Return decoded Dart String"]
```

🟢 CONFIRMED: the helper does not allocate, free, or take ownership of the native pointer. 🟡 INFERRED: pointer validity and buffer length are caller obligations because the helper performs no bounds or lifetime validation.
