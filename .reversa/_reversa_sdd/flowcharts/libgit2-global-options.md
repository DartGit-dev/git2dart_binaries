# libgit2 Global Options Flow

```mermaid
flowchart TD
  Caller["Typed Dart caller"] --> Options["libgit2Runtime.options"]
  Options --> Init["Ensure managed native lease"]
  Init --> Wrapper["One of 33 Libgit2Opts methods"]
  Wrapper --> Validate{"pack max object size < 0?"}
  Validate -- yes --> Range["Throw RangeError before FFI"]
  Validate -- no/not-applicable --> Discriminator["Hard-coded git_libgit2_opt_t value"]
  Discriminator --> Shape["Select one of 14 ffi.VarArgs shapes"]
  Shape --> Lazy["Lazy lookup + asFunction of git_libgit2_opts"]
  Lazy --> Native["Call native symbol with discriminator + args"]
  Native --> Status["Return native int status unchanged"]
  Native --> Output["Optionally fill caller-owned output"]
  Output --> Cleanup["Caller restores global value and disposes buffers"]
```

🟢 CONFIRMED: the source implements the dispatch and ownership boundary above. 🟢 Native evidence exists for selected shapes when a declared 64-bit payload loads. 🔴 GAP: no inspected hosted matrix proves all 33 discriminators on every supported platform.
