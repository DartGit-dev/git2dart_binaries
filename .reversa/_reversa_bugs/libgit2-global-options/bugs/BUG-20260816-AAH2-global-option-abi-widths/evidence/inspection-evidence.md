# Inspection Evidence

## Authoritative contract

Official pinned header: `https://raw.githubusercontent.com/libgit2/libgit2/v1.9.6/include/git2/common.h`.

- Lines 270-295: six mwindow get/set operations use `size_t` or `size_t*`.
- Lines 318-342: cache object size uses `size_t`, cache maximum and cached memory use `ssize_t` or `ssize_t*`.
- Lines 487-494: pack maximum object count uses `size_t` or `size_t*`.

## Current declarations

- `lib/src/opts_bindings.dart:29-95` routes all six mwindow operations through `ffi.Int` families.
- `lib/src/opts_bindings.dart:150-188` routes cache size and cached-memory values through `ffi.Int` families.
- `lib/src/opts_bindings.dart:387-405` routes pack maximum object count through `ffi.Int` families.
- `lib/src/opts_bindings.dart:533-546,599-620` declares the mismatched variadic signatures.

## Evidence status

The current contract mismatch and the 64-bit output-width overwrite path are statically confirmed. Runtime symptoms are not claimed because native artifacts are absent.
