# Inspection Evidence

## Ownership trace

1. `test/opts_bindings_integration_test.dart:168-178` allocates an outer `git_buf` and asks libgit2 to populate its contents.
2. Lines 190-192 overwrite the populated fields without calling `git_buf_dispose`.
3. Lines 195-198 populate the buffer again and dispose only the second contents.
4. `_reversa_sdd/libgit2-global-options/requirements.md:9,18` and `design.md:15` require matching disposal of libgit2-owned contents.

## Evidence status

The first native allocation becomes unreachable on the successful test path. This is a complete static ownership-deviation path.
