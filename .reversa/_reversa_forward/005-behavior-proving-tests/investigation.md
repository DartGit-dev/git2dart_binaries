# Investigation: Behavior-proving package validation

## Evidence baseline

| Concern | Observed legacy evidence | Planning consequence |
|---------|--------------------------|----------------------|
| ABI | `Libgit2Opts` maps option discriminators to variadic FFI signatures; `ffi.Size` is used for size-bearing paths. | Prove a real native round trip, not declaration text. |
| Loader | `Libgit2Runtime._load()` calls `_loadLibrary()`; desktop retries from package root, Android rethrows initial failure. | Use clean processes to avoid an already-open library masking a branch. |
| Tooling | `native_cache_manifest.py` and `platform_release_proof.py` return process status and stable failure categories. | Treat their CLI as the contract and test generated fixture matrices. |
| Release | `publish_package` downloads same-run bindings/payload and gates proof, inventory, provenance, size, and dry-run. | Add consumer proof after download/assembly and before eligibility for publication. |
| TLS | `AndroidSSLHelper` marks cached state only after a flushed write. | Internal dependency injection is sufficient to observe retry without changing the public API. |
| Current tests | Loader/TLS/workflow/proof tests contain source-string assertions. | Inventory and replace every assertion mapped to FR-01–FR-08 with behavior, CLI, analyzer-AST, or parsed-workflow evidence; do not retain a source-string acceptance check in that scope. |
| Analyzer | FR-08 requires Dart analyzer AST/element facts. | Add `analyzer` as a direct exact-pinned `dev_dependency`; missing or incompatible resolution is a failing prerequisite. |

## Alternatives evaluated

| Area | Selected | Rejected | Why |
|------|----------|----------|-----|
| ABI | Native executable echo/probe | Wrapper source assertion | Only execution detects truncation at the actual FFI boundary. |
| Loader | Fresh subprocess fixtures | In-process environment mutation | Dynamic-library state and package resolution can be cached in the current isolate. |
| Python tools | CLI subprocess fixture tests | Unit-import private functions | The CLI exit/result is the release contract. |
| Bundle proof | Disposable bundle + consumer process | `path: .` checkout consumer | Checkout paths do not prove assembled published contents. |
| TLS | Internal injected operations | Device-only integration test | Unit seam covers all state edges deterministically; mobile integration remains complementary. |
| Architecture/workflow | Direct pinned analyzer AST facts and YAML graph facts | `contains()`/regex checks; optional analyzer | Formatting/comments must not determine policy, and dependency/API drift must fail visibly. |

## External references

- Dart documents `ffi.Size` as the C `size_t` representation and describes native C interop: [dart:ffi API](https://api.dart.dev/dart-ffi/) and [C interop](https://dart.dev/interop/c-interop).
- Dart exposes `sizeOf<T>()` for checking native type width when deciding whether a host can run the >32-bit probe: [sizeOf](https://api.dart.dev/dart-ffi/sizeOf.html).
- Flutter’s supported integration-test setup and device/desktop execution boundaries: [Flutter integration testing](https://docs.flutter.dev/testing/integration-tests).
- GitHub documents `github.event_name`, fully formed `github.ref`, and conditional expressions used to model publication authorization: [Contexts](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts) and [Variables](https://docs.github.com/en/actions/reference/workflows-and-actions/variables).
- The analyzer package and its supported SDK constraints must be selected directly and pinned in the repository rather than relied upon transitively: [analyzer package](https://pub.dev/packages/analyzer).

## Investigation steps before implementation

1. Confirm the selected libgit2 option safely accepts an above-32-bit value and can be restored without destabilizing the test runner; otherwise provide a tiny CI-built native probe whose sole ABI is `size_t -> size_t`.
2. Inspect the native artifact layout delivered to Linux and Windows test jobs; define the minimal package fixture and environment scrub list from that actual layout.
3. Define fixture builders that create each corruption independently, including unsafe path, metadata, file list, digest/size, provenance, JSON, proof schema/status/scope, and unreadable-version cases.
4. Choose parser dependencies already available transitively or add only a small dev dependency if Dart’s installed toolchain cannot expose YAML structure; document unsupported expression handling as failure.
5. Select an analyzer version compatible with the pinned Flutter/Dart SDK, add it as a direct exact-pinned `dev_dependency`, and assert at test startup that the expected analyzer API is usable. Resolution failure or mismatch must exit non-zero rather than skip AST coverage.
6. Build an FR-01–FR-08 replacement ledger before editing: source assertion location, requirement, replacement proof type, executable fixture/process, and acceptance result. Do not remove any entry until its replacement is active.

## Constraints and non-goals

- This feature does not prove uninspected `git2dart` behavior, production Android HTTPS application, or arbitrary system-installed libgit2 behavior.
- It does not make a source-only checkout equivalent to a CI-expanded package.
- It must not create a tracked `lib/src/bindings.dart` fallback; that violates the effective CI-owned generated-bindings addendum.
- It does not permit retained source-string assertions as an FR-01–FR-08 acceptance fallback, including when analyzer installation or compatibility fails.
