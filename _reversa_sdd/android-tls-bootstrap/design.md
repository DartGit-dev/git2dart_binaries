# Android TLS Bootstrap, Technical Design

## Interface
`AndroidSSLHelper.initialize()` returns `Future<String>` containing the extracted CA path. Static `_initialized` and `_certPath` implement process-local sequential idempotence. 🟢

## Main Flow
1. Return the cached path when initialization previously completed. 🟢
2. Request the application temporary directory from `path_provider`. 🟢
3. Read the CA asset through Flutter's root bundle. 🟢
4. Write and flush bytes to `cacert.pem`. 🟢
5. Store the path, set initialized, and return it. 🟢
6. The external consumer must call the global option setter with this path. 🟡

## Alternative Flows
- Any extraction error is written to stderr and rethrown; cached state remains incomplete. 🟢
- Concurrent first calls can duplicate the write because no mutex/future memoization exists. 🟡

## Dependencies and Decisions
- Flutter asset bundle supplies the certificate; `path_provider` supplies a native path. 🟢
- The bundle is shipped at both package asset and Android source-asset locations, but the helper reads the Flutter package asset. 🟢
- Extraction and native configuration are intentionally separated. 🟢

## State and Observability
State is two static fields. Observability is a short stderr error message only. No certificate version/hash is recorded at runtime. 🟢

## Risks and Gaps
- 🔴 Consumer-side application of `git_libgit2_opts_set_ssl_cert_locations` is outside this checkout.
- 🟡 Concurrent writes are unsynchronized.
- 🟡 Temporary-directory cleanup can invalidate the cached path during a long process.
