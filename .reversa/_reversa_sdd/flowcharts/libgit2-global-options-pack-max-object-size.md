# `git_libgit2_opts_set_pack_max_object_size` Function

```mermaid
flowchart TD
  Start["Input Dart int value"] --> Negative{"value < 0?"}
  Negative -- yes --> Range["Throw RangeError; no native call"]
  Negative -- no --> Op["Select GIT_OPT_SET_PACK_MAX_OBJECT_SIZE"]
  Op --> Adapter["Use ffi.Size variadic adapter"]
  Adapter --> Native["Call git_libgit2_opts"]
  Native --> Status["Return native status unchanged"]
```

🟢 CONFIRMED: this is the only explicit Dart-side range check in the 33-wrapper surface. Other size/int wrappers delegate validation to FFI/native behavior.

