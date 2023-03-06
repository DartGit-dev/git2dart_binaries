# git2dart binaries

**Dart bindings to libgit2**

git2dart package provides ability to use [libgit2](https://github.com/libgit2/libgit2) in Dart/Flutter.

### Ffigen

To generate bindings with ffigen use (adjust paths to yours):

```bash
dart run ffigen --compiler-opts "-I/path/to/git2dart/libgit2/headers/ -I/lib64/clang/12.0.1/include"
```

## Licence

MIT. See [LICENSE](LICENSE) file for more information.
