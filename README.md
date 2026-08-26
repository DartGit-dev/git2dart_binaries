# git2dart binaries

**Dart bindings to libgit2**

git2dart package provides ability to use [libgit2](https://github.com/libgit2/libgit2) in Dart/Flutter.

## Managed libgit2 lifecycle

The package owns native-library discovery and one checked libgit2 increment per
Dart isolate. Use `libgit2Runtime` instead of constructing a second loader or
calling the generated lifecycle methods directly:

```dart
import 'package:git2dart_binaries/git2dart_binaries.dart';

final features = libgit2Runtime.withCall(
  (bindings) => bindings.git_libgit2_features(),
);

final owner = libgit2Runtime.acquireOwner(debugLabel: 'repository');
owner.bindDestructor(() {
  // Destroy the native owner here.
});

owner.release(); // exact-once; fallback finalization uses the same token
final remainingNativeOwners = libgit2Runtime.shutdown();
```

`shutdown()` is synchronous, guarded by live calls/owners, idempotent after
success, and terminal for the calling isolate. A positive return value is valid
when another isolate or external native consumer still owns an increment.

The generated `Libgit2.git_libgit2_init()` and
`Libgit2.git_libgit2_shutdown()` methods remain available as raw ABI, but direct
consumer calls are unsupported because they bypass package accounting. The
former eager `libgit2` and `libgit2Opts` globals were removed intentionally;
backward source compatibility is not provided.

### Ffigen

To generate bindings with ffigen use (adjust paths to yours):

```bash
dart run ffigen --compiler-opts "-I/path/to/git2dart/libgit2/headers/ -I/lib64/clang/12.0.1/include"
```

## Validation evidence

The validation suite distinguishes evidence instead of treating an unavailable
native prerequisite as a pass:

- Host-independent tests execute the cache-manifest and platform-proof CLIs,
  Android TLS state transitions, the exact-pinned analyzer AST policy, and the
  parsed workflow graph.
- Native ABI, loader, and expanded-package tests require an explicitly injected
  binding and matching platform payload. A missing payload is reported as
  `unavailable`; it is not native success.
- The `build_package` workflow is authoritative for same-run evidence. It
  downloads the generated binding and Linux payload, assembles a disposable
  package bundle, compiles a clean public consumer, and loads the bundled native
  library before publish dry-run or publication can be eligible.

Focused local commands:

```bash
flutter test -j 1 test/native_cache_manifest_cli_test.dart test/platform_release_proof_test.dart
flutter test -j 1 test/android_ssl_helper_test.dart test/android_ssl_helper_diagnostic_test.dart
flutter test -j 1 test/architecture_policy_ast_test.dart test/workflow_policy_graph_test.dart
flutter test -j 1 test/package_consumer_bundle_test.dart
flutter analyze
```

Set `GIT2DART_FIXTURE_PACKAGE_ROOT` only to an explicit expanded fixture package
when running local consumer/native proof. CI does not use a global-cache or
checkout fallback: its bundle inputs come from artifacts produced by that run.

## Licence

MIT. See [LICENSE](LICENSE) file for more information.
