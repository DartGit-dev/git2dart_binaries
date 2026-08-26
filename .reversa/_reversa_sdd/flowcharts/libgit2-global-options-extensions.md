# Repository Extensions Option Flow

```mermaid
flowchart TD
  Getter["get_extensions"] --> AllocateOut["Caller allocates git_strarray"]
  AllocateOut --> GetAdapter["Pointer<git_strarray> variadic adapter"]
  GetAdapter --> NativeGet["Native fills array"]
  NativeGet --> Dispose["Caller calls git_strarray_dispose and frees wrapper"]

  Setter["set_extensions(array, len)"] --> Retain["Caller retains pointer array and every C string"]
  Retain --> SetAdapter["Pointer<Pointer<Char>>, Size adapter"]
  SetAdapter --> NativeSet["Native consumes values during call"]
  NativeSet --> CallerFree["Caller may free retained inputs after return"]
```

🟢 CONFIRMED: source declares both exact ownership shapes. 🟢 The getter has a native success/disposal test when payload prerequisites load. 🔴 The setter and pointer-width array length have no direct current behavior test.
