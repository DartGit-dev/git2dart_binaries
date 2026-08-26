# libgit2 Global Options, Flows

## F1 — Typed variadic dispatch

1. `Libgit2Opts` receives the selected `DynamicLibrary`. 🟢
2. First use lazily looks up `git_libgit2_opts` through one of 14 FFI shapes. 🟢
3. The public method supplies a fixed generated discriminator and shape-specific arguments. 🟢
4. The native integer status is returned unchanged. 🟢

## F2 — Buffer getter

1. The caller allocates an outer `git_buf` or `git_strarray`. 🟢
2. Libgit2 populates inner storage when status permits. 🟢
3. The caller invokes the matching libgit2 disposer, then frees the outer allocation. 🟢 source/tests; 🟡 full wrapper matrix

## F3 — W001 probe

1. Require a declared matching payload and 64-bit process. 🟢
2. Save the original mwindow file limit. 🟢
3. Set and read `0x100000011` through `Size`/`Pointer<Size>`. 🟢
4. Compare exact equality, restore the original, and shut down the managed runtime. 🟢
5. Report missing prerequisites as unavailable rather than behavior success. 🟢
