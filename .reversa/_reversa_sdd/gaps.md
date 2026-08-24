# Unresolved Gaps — git2dart_binaries

## Critical

1. **Lifecycle compatibility risk** — `git2dart_binaries` retains the existing ready runtime and public shutdown API without automatic teardown or isolate-lifetime policy. This is a deliberate user-confirmed compatibility decision; downstream shutdown misuse remains an accepted risk. 🟢 policy; 🟡 accepted architectural risk
2. **Android TLS live proof** — `git2dart` owns the confirmed init → extract → apply sequence, and shared Android/iOS first-call serialization is now required; device/emulator HTTPS proof remains unresolved. 🔴
4. **Current release evidence** — no current CI run, native artifact set, or expanded package was inspected. 🔴
5. **Cross-repository coordinator execution** — `git2dart` is the user-confirmed single release/build coordinator, but no current workflow or fresh full selected-pair integration run was inspected. 🔴

## Moderate

1. **Apple version metadata** — both podspecs remain 1.11.2 while pubspec is 1.12.1; the confirmed exact three-way match policy makes the divergence release-blocking. 🟢 observed mismatch; 🟢 policy
2. **Windows OpenSSL implementation** — current CI discovers a runner-installed OpenSSL, while the confirmed policy requires a source-built explicit pin or proven exact cross-platform version parity. The current path is release-ineligible until reconciled. 🟢 observed CI; 🟢 policy
3. **Release trigger scope** — pushes to analyzed branch 1.12.1 do not start the current workflow. 🟢 fact; 🔴 intended policy
4. **External publication-control proof boundary** — the user confirms operational GitHub Actions controls including a dedicated pub.dev token and requests no additional supply-chain controls now; repository files do not prove that external configuration and secrets were not inspected. 🟢 user-confirmed configuration; 🔴 repository-visible proof boundary

## Cosmetic

No unresolved cosmetic-only gaps were identified. 🟢
