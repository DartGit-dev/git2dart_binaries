# Reproduction capsule

- Base commit: `d74f0f338a8a79a6313a8359e552fd78bae1b531`
- Branch: `1.12.2`
- Environment: GitHub-hosted Ubuntu, macOS, and Android/iOS runners
- Workflow: `Build package`, push run `32700476293`
- Classification: deterministic, 4 of 4 completed platform test jobs failed

## Observed evidence

`run_linux_tests` downloaded `cache-linux` successfully, then `flutter test -r expanded` failed because the native loader could not find `linux/libssh2.so`.

The downloaded artifact was inspected locally from the same workflow run. Its files were:

```
git2dart-linux-provenance.json
export/libgit2.so
export/libssh2.so
```

The sibling provenance file makes the archive retain `export/`; the test job expects the two libraries directly under `linux/`.
