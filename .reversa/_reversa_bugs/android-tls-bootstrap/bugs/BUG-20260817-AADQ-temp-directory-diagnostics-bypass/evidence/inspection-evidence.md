# Inspection Evidence

## Static exception path

1. `lib/src/android_ssl_helper.dart:74` awaits `getTemporaryDirectory()`.
2. The diagnostic `try` starts only at line 77.
3. The stderr catch at lines 90-92 can receive asset-load and file-write failures but not the earlier directory failure.
4. `_reversa_sdd/android-tls-bootstrap/design.md:15` states that any extraction error is written to stderr and rethrown.

## Evidence status

The missing diagnostic path is statically confirmed. The underlying exception still propagates and cached success remains unset.
