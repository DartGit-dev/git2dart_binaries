# `git_libgit2_opts_*` Dispatch Pattern

```mermaid
flowchart TD
  Method["Public typed wrapper"] --> Op["Hard-coded option discriminator"]
  Method --> Args{"Argument family"}
  Args --> Int["Int / Pointer<Int>"]
  Args --> Width["Size / Pointer<Size> / IntPtr outputs"]
  Args --> Buffer["git_buf / Char pointers"]
  Args --> Composite["level+pointer / two pointers / array+Size"]
  Op --> Call["Matching signature-specific late function"]
  Int --> Call
  Width --> Call
  Buffer --> Call
  Composite --> Call
  Call --> Symbol["Single native symbol: git_libgit2_opts"]
  Symbol --> Native["libgit2 interprets variadic arguments by discriminator"]
  Native --> Result["Integer status returned unchanged"]
```

🟢 CONFIRMED: all 14 adapters use `ffi.Int` for the leading discriminator and exact tuple types for the remaining variadic arguments. 🔴 GAP: generated discriminator numbers and pinned-header equivalence are external to the current working tree.
