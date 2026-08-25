# Dart FFI Facade, Decisions

| Decision | Consequence | Evidence | Confidence |
|---|---|---|---|
| Export the generated ABI instead of wrapping every symbol. | Low-level libgit2 remains directly reachable and ABI coherence becomes a release obligation. | `lib/git2dart_binaries.dart` | 🟢 |
| Generate bindings from pinned libgit2 headers. | Generated declarations and native bytes must share version and workflow identity. | ADR-001, `ffigen.yaml` | 🟢 contract; 🔴 current bytes |
| Keep generated bindings out of source control. | CI artifact injection is mandatory for validation and publication. | ADR-011, workflow | 🟢 policy |
| Borrow last-error/string memory. | Wrappers must not free native pointers and callers must respect native lifetime. | `error.dart`, `extensions.dart` | 🟢 |
| Manage lifecycle through the runtime facade. | Raw generated lifecycle calls remain possible but are outside the supported ownership route. | ADR-009 | 🟢 supported design; 🔴 external enforcement |
