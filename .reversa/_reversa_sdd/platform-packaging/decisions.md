# Platform Packaging, Decisions

| Decision | Consequence | Evidence | Confidence |
|---|---|---|---|
| Use platform-specific native loading contracts. | Payload names and linkage differ by OS family. | ADR-004 | 🟢 |
| Force-load iOS static libgit2. | `DynamicLibrary.process()` can resolve symbols. | podspec, ADR-004 | 🟢 recipe |
| Set macOS install name and static dependencies. | Avoid Homebrew/runtime transitive dylib leakage. | ADR-005 | 🟢 recipe; 🔴 current payload |
| Bundle version-agnostic Windows OpenSSL DLL matches. | CMake copies detected versioned runtime DLLs. | ADR-006 | 🟢 |
| Resolve package-local desktop binaries. | Transitive/plain-Dart consumers need not rely on cwd. | ADR-002 | 🟢 |
| Prove packaging through disposable consumer. | Declaration and file presence alone are insufficient. | ADR-010/011 | 🟢 evidence policy |
