# Interface: Expanded package consumer bundle

## Contract

The release factory provides a disposable expanded Dart/Flutter package bundle to a clean consumer subprocess. The consumer may use only the public `package:git2dart_binaries/...` surface and must resolve generated bindings and native payload from that bundle.

## Request

| Input | Required | Rules |
|-------|----------|-------|
| `bundle_root` | yes | Disposable assembled package directory containing same-run generated `lib/src/bindings.dart` and required platform payload. |
| `consumer_root` | yes | Separate temporary Dart package with a path dependency or generated package config pointing at `bundle_root`. |
| `platform_payload` | yes for native run | Must match target platform and pinned version set; must not be taken from repository checkout or system installation. |
| `mode` | yes | `compile-public-api` or `load-native`; the latter requires matching native host prerequisites. |

## Response

| Field | Meaning |
|-------|---------|
| exit status `0` | Consumer compiled/ran using the bundle public API and, when requested, observed the bundled native path. |
| non-zero + category | `bundle-invalid`, `binding-missing`, `internal-import`, `payload-missing`, `loader-failed`, or `unavailable`. |
| evidence record | Identifies evidence class, package-config/bundle identity, public import set, and sanitized diagnostic. |

## Error and safety rules

- A consumer using an internal source path, tracked fallback binding, repository current directory, globally cached package, or system-installed libgit2 is invalid even if it exits successfully.
- Absolute temporary/package paths must be sanitized from persisted diagnostics.
- Missing declared payload is `unavailable` only before a native proof is attempted; a CI assembly job with required same-run artifacts missing fails non-zero.

## Idempotency and timeouts

- Each run uses unique temporary bundle and consumer roots; rerun has no durable side effect.
- Compilation/load subprocesses use bounded timeouts and terminate as non-success on timeout.
- No retry may substitute a different package root or system library without recording a new isolated case.

## Compatibility

This contract proves direct package consumption only. It does not prove behavior of the separate `git2dart` repository or publication availability on pub.dev.

## Validation dependency boundary

The bundle-consumer contract itself does not require analyzer at runtime. Its accompanying FR-01–FR-08 validation suite does: analyzer is a direct exact-pinned development dependency, and a missing or incompatible analyzer is a non-successful validation result rather than a reason to retain source-string assertions.
