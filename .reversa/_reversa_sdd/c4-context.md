# C4 Level 1 — System Context

```mermaid
C4Context
  title System Context — git2dart_binaries

  Person(dev, "Dart/Flutter Developer", "Builds an application or higher-level Git library")
  System(app, "Consumer Application", "Dart/Flutter process using Git functionality")
  System_Boundary(product, "git2dart product") {
    System(git2dart, "git2dart", "High-level Dart Git API; relationship inferred from this repository")
    System(binaries, "git2dart_binaries", "Generated FFI ABI, native loader, platform artifacts, release factory")
  }

  System_Ext(libgit2, "libgit2", "Native Git implementation")
  System_Ext(crypto, "libssh2 + OpenSSL", "SSH, TLS, and crypto dependencies")
  System_Ext(flutter, "Flutter Platform Tooling", "Bundles FFI plugins and assets")
  System_Ext(github, "GitHub Actions + Upstream Git", "Builds pinned native sources and stores artifacts")
  System_Ext(pubdev, "pub.dev", "Distributes the assembled Dart/Flutter package")

  Rel(dev, app, "Develops/runs")
  Rel(app, git2dart, "Uses high-level Git API", "Dart", "INFERRED")
  Rel(git2dart, binaries, "Consumes native package", "Dart dependency/import", "INFERRED")
  Rel(app, binaries, "May consume directly", "Dart/FFI")
  Rel(binaries, libgit2, "Calls", "C ABI")
  Rel(libgit2, crypto, "Links/loads", "Native ABI")
  Rel(flutter, binaries, "Bundles artifacts/assets", "pubspec/CMake/CocoaPods/Gradle")
  Rel(github, binaries, "Generates and validates release payload", "CI artifacts")
  Rel(binaries, pubdev, "Publishes validated package", "Dart package publisher")
```

🟢 All external systems except the exact `git2dart -> git2dart_binaries` consumer edge are directly evidenced locally. That cross-repository relation remains 🟡 INFERRED.

