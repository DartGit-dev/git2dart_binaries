# Reproduction capsule — BUG-20260817-AAGV

## Baseline

- Commit: `b372be1cc2a50e8d13a0ecaa5b4e61780ce92f17`
- Branch: `1.12.2`
- Environment: Windows desktop host; Flutter/Dart test runner and system Python.
- Command: `flutter test -j 1 test/platform_release_proof_test.dart`
- Exit code: `0`
- Determinism: deterministic (`1/1`).

## Observed result

The test fixture's passing aggregate set writes eight `status: passed` proof
records with empty `inventory.expected`, `inventory.present`,
`inventory.missing`, and `inventory.unexpected`; `versions: {}`; and
`attestation: null`. The aggregate CLI accepted that set:

```text
schema-valid complete proof set passes the aggregate CLI
...
All tests passed!
```

The current `validate` implementation only checks the top-level key set,
`status`, `failure_codes`, safe paths in any supplied `inventory.present`
entries, and unique required scopes. It has no payload-root input, so it cannot
compare a proof digest with the bytes downloaded into the final release layout.

## Boundary

This proves the local acceptance path, not a hosted GitHub Actions execution,
artifact download, publication attempt, or registry outcome.
