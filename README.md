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

## Licence

MIT. See [LICENSE](LICENSE) file for more information.
