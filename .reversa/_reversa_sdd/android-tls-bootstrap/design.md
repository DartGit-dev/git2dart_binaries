# Android TLS Bootstrap, Technical Design

## Interface
`AndroidSSLHelper.initialize()` returns `Future<String>` containing the extracted CA path. Static `_initialized` and `_certPath` implement process-local sequential idempotence. 🟢

## Main Flow
1. Return the cached path when initialization previously completed. 🟢
2. Request the application temporary directory from `path_provider`. 🟢
3. Read the CA asset through Flutter's root bundle. 🟢
4. Write and flush bytes to `cacert.pem`. 🟢
5. Store the path, set initialized, and return it. 🟢
6. The external bootstrap is required to initialize managed libgit2 and apply the returned path through the certificate-location option; this refresh did not inspect or execute that repository. 🟢 contract; 🔴 current cross-repository proof

## Alternative Flows
- Any extraction error is written to stderr and rethrown; cached state remains incomplete. 🟢
- The current Android helper can duplicate the write because no mutex/future memoization exists. The required target is one shared in-flight platform-initialization operation for Android and iOS, with all concurrent callers awaiting it. 🟢 observed implementation; 🟢 user-confirmed required policy

## Dependencies and Decisions
- Flutter asset bundle supplies the certificate; `path_provider` supplies a native path. 🟢
- The bundle is shipped at both package asset and Android source-asset locations, but the helper reads the Flutter package asset. 🟢
- `git2dart_binaries` owns extraction while the external `git2dart` consumer is expected to own full platform-bootstrap orchestration. 🟢 user-confirmed boundary; 🔴 current consumer inspection
- The current iOS path is `PlatformSpecific.iosInitialize()` followed by `Libgit2.version`; it establishes no separate shared in-flight guard. Apply the same required serialization policy to iOS without claiming that it is already implemented. 🟢 current source evidence; 🟢 user-confirmed required policy

## State and Observability
State is two static fields. Observability is a short stderr error message only. No certificate version/hash is recorded at runtime. 🟢

## Risks and Gaps
- 🔴 Consumer-side application and ordering were not re-inspected or executed in this extraction.
- 🟢 Concurrent first calls are currently unsynchronized; the required Android-and-iOS shared in-flight policy is user-confirmed but unimplemented. 🟢 user-confirmed policy
- 🟡 Temporary-directory cleanup can invalidate the cached path during a long process.

## 2026-08-25 Evidence Boundary

R10/C05 contains only extraction and an isolate-local sequential cache. 🟢

The helper does not persist an in-flight operation, verify certificate digest/file existence on cache hit, clean partial files, initialize libgit2, invoke a native option, or perform HTTPS. 🟢 source absence; 🔴 external behavior
