# C4 Level 3 — Components

```mermaid
C4Component
  title Runtime and Supply Components — git2dart_binaries

  Container_Boundary(runtime, "Dart Package Runtime") {
    Component(barrel, "Public Export Barrel", "Dart", "Exports generated and handwritten APIs")
    Component(errors, "Error and Validation Helpers", "Dart + ffi", "Converts pointers and validates Git identifiers")
    Component(opts, "Libgit2Opts", "Dart FFI", "33 typed wrappers over variadic global options")
    Component(selector, "Platform Target Selector", "dart:io", "Chooses filename and fallback subdirectory")
    Component(resolver, "Package Root Resolver", "dart:isolate + JSON", "Resolves package URI/config fallbacks")
    Component(preloader, "Dependency Preloader", "dart:ffi", "Loads Linux/Windows dependencies in required order")
    Component(initializer, "libgit2 Initializer", "Generated FFI", "Calls git_libgit2_init")
    Component(androidtls, "AndroidSSLHelper", "Flutter", "Extracts CA asset and returns a file path")
  }

  Container_Boundary(supply, "CI Build and Release") {
    Component(bindgen, "Binding Generator", "ffigen/libclang", "Creates bindings.dart from pinned headers")
    Component(builders, "Platform Native Builders", "CMake/Xcode/NDK/MSVC", "Create normalized native artifacts")
    Component(manifest, "Cache Manifest Validator", "Python", "Rejects stale/incoherent cache content")
    Component(tests, "Platform Test Matrix", "Flutter test + simulators", "Exercises ABI, loader, packaging")
    Component(assembler, "Release Assembler", "GitHub Actions", "Downloads all generated outputs")
    Component(gates, "Release Gates", "shell/pub", "Size check and pub dry-run")
    Component(publisher, "Package Publisher", "GitHub Action", "Uploads non-PR package to pub.dev")
  }

  Component_Ext(native, "libgit2 Platform Artifact", "Native C ABI")
  Component_Ext(asset, "CA Certificate Asset", "PEM")
  Component_Ext(registry, "pub.dev", "Package registry")

  Rel(barrel, errors, "Exports")
  Rel(barrel, opts, "Exports")
  Rel(barrel, selector, "Exports loader globals")
  Rel(selector, resolver, "Uses after bare-name failure")
  Rel(resolver, preloader, "Provides package root")
  Rel(preloader, native, "Loads dependencies for")
  Rel(initializer, native, "Calls init")
  Rel(opts, native, "Calls git_libgit2_opts")
  Rel(androidtls, asset, "Loads and writes")

  Rel(bindgen, tests, "Supplies bindings artifact")
  Rel(builders, manifest, "Supplies normalized exports")
  Rel(manifest, tests, "Allows validated native artifacts")
  Rel(tests, assembler, "Gates assembly after platform validation")
  Rel(assembler, gates, "Supplies expanded package")
  Rel(gates, publisher, "Allows publication")
  Rel(publisher, registry, "Publishes")
```

## Cross-component coupling

- `Platform Target Selector` is coupled by filename to native builders and packaging manifests.
- `Libgit2Opts` is coupled by discriminator/signature to generated libgit2 enums and the pinned native ABI.
- `AndroidSSLHelper` is coupled by asset path to `pubspec.yaml` and by ordering to consumer startup.
- `Release Assembler` is coupled to every artifact name and target directory produced upstream.
