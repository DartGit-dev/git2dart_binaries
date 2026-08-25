# C4 Level 1 — System Context

## Diagram

```mermaid
C4Context
  title System Context — git2dart_binaries

  Person(maintainer, "Package Maintainer", "Changes runtime, native build, packaging, and evidence contracts")
  Person(releaseEngineer, "Release Engineer", "Interprets hosted gates and controls package eligibility")
  Person(downstream, "Downstream Dart/Flutter Author", "Consumes the public package or the higher-level Git package")

  System_Boundary(scope, "git2dart_binaries boundary") {
    System(system, "git2dart_binaries", "Dart FFI runtime, five-platform native payload factory, behavior evidence, and pub release assembly")
  }

  System_Ext(consumer, "Dart/Flutter Consumer Process", "Imports the package and executes native Git behavior")
  System_Ext(git2dart, "git2dart", "Sibling high-level consumer and user-confirmed compatibility coordinator")
  System_Ext(libgit2, "libgit2 1.9.6", "Native Git implementation")
  System_Ext(nativeDeps, "libssh2 1.11.1 and OpenSSL 3.0.15", "SSH, TLS, and crypto dependencies")
  System_Ext(tooling, "Flutter/Dart and Platform Toolchains", "pub, assets, CMake, NDK/Gradle, Xcode/CocoaPods, clang/MSVC")
  System_Ext(upstream, "Upstream Git Repositories", "Pinned native source tags")
  System_Ext(github, "GitHub Actions", "Hosted runners, artifacts, cache, proofs, secrets, and workflow execution")
  System_Ext(pubdev, "pub.dev", "External package registry")

  Rel(maintainer, system, "Changes and validates", "Git, Dart, Python, YAML")
  Rel(releaseEngineer, system, "Qualifies an assembled revision", "workflow evidence")
  Rel(downstream, consumer, "Builds and runs")
  Rel(consumer, system, "Imports and calls", "Dart package API and native ABI")
  Rel(git2dart, system, "Consumes selected compatible version", "Dart dependency; external evidence gap")
  Rel(system, libgit2, "Generates declarations for and calls", "C ABI")
  Rel(libgit2, nativeDeps, "Links or loads", "native ABI")
  Rel(system, tooling, "Builds, bundles, tests, and resolves", "Flutter/pub/platform metadata")
  Rel(github, upstream, "Checks out pinned tags", "Git")
  Rel(github, system, "Generates, builds, tests, assembles", "same-run artifacts and logs")
  Rel(system, pubdev, "Publishes only after exact-main gates", "publisher action")
  Rel(git2dart, github, "Expected selected-pair coordination", "user-confirmed policy; current run absent")
```

## Relationship qualification

| Relationship | Protocol/format | Confidence and boundary |
|---|---|---|
| Consumer → public package | Dart imports, FFI calls | 🟢 public surface; 🔴 current external consumer outcome |
| Package → libgit2 | generated and handwritten C ABI | 🟢 source/fixture; 🔴 current hosted bytes |
| libgit2 → libssh2/OpenSSL | native linkage/load | 🟢 build recipes; 🔴 current five-platform artifact inspection |
| Package ↔ Flutter/platform tooling | pubspec, assets, CMake, CocoaPods, Gradle | 🟢 checked-in configuration |
| GitHub Actions → package product | jobs, artifacts, caches, proofs | 🟢 checked-in graph; 🔴 current feature-005 run |
| Package → pub.dev | publisher action and tokens | 🟢 configured route; 🔴 execution/registry acceptance |
| `git2dart` ↔ package | version selection, managed runtime, CI coordination | 🟡 policy/context only in this extraction; 🔴 current workflow/run |

## Nine external integrations

The context model counts nine integrations: libgit2, libssh2, OpenSSL, Flutter/Dart tooling, platform toolchains, GitHub Actions, upstream Git repositories, pub.dev, and external `git2dart`. libssh2 and OpenSSL share one diagram node for readability but remain separate native contracts.

## Evidence boundary

The system context distinguishes configured relationships from observed outcomes. Local fixtures can establish exact host behavior; only a current GitHub run can establish same-run artifacts, and only pub.dev/`git2dart`/real-device observation can establish external outcomes.
