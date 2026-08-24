# Inspection Evidence

- `lib/src/error.dart:13-16` describes the constructor as internal-only but declares `LibGit2Error(...)` publicly.
- `lib/git2dart_binaries.dart:6` exports the class through the package barrel.
- `lib/src/error.dart:21` dereferences the stored pointer to read the native message.
- `lib/src/error.dart:24` dereferences it again to read the native class.
- `lib/src/extensions.dart:94-97` checks `nullptr` only in the intended `getLastError()` path; direct construction bypasses that check.

The unsafe public path is statically complete. The exact Dart/OS symptom of an invalid native dereference is not claimed without runtime replay.

