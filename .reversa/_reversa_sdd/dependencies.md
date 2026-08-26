# Dependency Inventory — Scout re-extraction (2026-08-25)

Evidence is limited to the current checkout. Confirmed values come from manifests/workflows; hosted publication and cross-repository consumers remain external evidence gaps.

## Dart/Flutter

`pubspec.yaml`: Dart `>=3.7.2 <4.0.0`, Flutter `>=3.29.3`; `ffi ^2.0.0`, `meta ^1.16.0`, `path ^1.8.1`, `path_provider ^2.1.0`, `pub_semver ^2.1.3`. Dev: analyzer `8.2.0`, ffigen `^18.1.0`, flutter_test, integration_test, lints `^5.1.1`, test `^1.26.2`, yaml `3.1.3`.

## Native/toolchain

Workflow pins libgit2 `1.9.6`, libssh2 `1.11.1`, OpenSSL `3.0.15`, Flutter `3.44.0`; platform actions build Android, iOS, Linux, macOS, and Windows payloads. CI generates bindings, injects artifacts for tests, proves payloads, assembles release output, and invokes publication gates.

## Tests and database

22 test files under `test/` cover loader processes, lifecycle, package-consumer bundle, release inventory, workflow policy graphs, native cache manifests, OpenSSL provenance, platform proofs, and packaging. This is a file-count inventory, not coverage. No DDL, migrations, schema, or ORM model files found.
