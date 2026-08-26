# Inspection Evidence

## Exact-state failures

- `test/opts_bindings_integration_test.dart:180-200` changes search path and never restores it.
- `test/opts_bindings_integration_test.dart:218-237` changes user agent and never restores it.
- `test/opts_bindings_integration_test.dart:142-163` never reads the incoming caching state and writes 1 as an assumed default.
- Restoration at lines 46-51, 88-94, 131-139, 273-279, and 349-355 occurs only on the successful path.
- Only lines 291-294 register a teardown restoration.

## Contract

`_reversa_sdd/libgit2-global-options/requirements.md:24` and `tasks.md:16` require mutable global values to be restored after tests and specifically require teardown restoration.
