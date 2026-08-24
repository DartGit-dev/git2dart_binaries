# Inspection Evidence

## Static causal path

1. `.github/actions/build-linux/action.yml:71-80` builds and exports shared `libssh2.so`.
2. `.github/actions/build-linux/action.yml:90-117` links libgit2 to that shared library and exports `libgit2.so`.
3. `linux/CMakeLists.txt:41-46` declares only `libgit2.so` as a Flutter bundled library.
4. `lib/src/util.dart:77-81` expects package-local `linux/libssh2.so` during desktop fallback.
5. `_reversa_sdd/platform-packaging/requirements.md:8,16` requires the Linux artifact set and complete platform bundling.

## Evidence status

The recipe omission and its dependency path are statically confirmed. Current native artifacts are absent, so this registration does not claim an observed clean-consumer runtime failure.
