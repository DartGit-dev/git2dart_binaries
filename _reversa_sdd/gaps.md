# Unresolved Gaps — git2dart_binaries

## Critical

1. **Lifecycle ordering and shutdown ownership** — lazy `libgit2Opts` access does not prove native initialization; no production shutdown owner is visible. 🔴
2. **Android HTTPS readiness** — extraction is local, but consumer-side certificate application is unobserved. 🔴
3. **Complete ABI proof** — generated bindings/headers and full coverage for 33 variadic option signatures are absent. 🔴
4. **Current release evidence** — no current CI run, native artifact set, or expanded package was inspected. 🔴
5. **Cross-repository compatibility** — dependency/import sites, supported version matrix, and integration-gate ownership are unconfirmed. 🔴

## Moderate

1. **Validator semantics** — implementation is weaker than comments/names imply for refs and object types. 🔴
2. **Windows missing-directory behavior** — fallback constructs a path under a directory already proven absent. 🔴
3. **Apple version metadata** — both podspecs remain 1.11.2 while pubspec is 1.12.1. 🔴
4. **Windows OpenSSL policy** — runner-discovered version differs from the explicit 3.0.15 policy used by other platforms. 🔴
5. **Release trigger scope** — pushes to analyzed branch 1.12.1 do not start the current workflow. 🟢 fact; 🔴 intended policy
6. **External security controls** — publication authorization, protections, signing, SBOM, and provenance are unknown. 🔴

## Cosmetic

No unresolved cosmetic-only gaps were identified. 🟢
