# Investigation: OpenSSL source-build provenance parity

## Observed baseline

- `.github/workflows/build_package.yml` defines `OPENSSL_VERSION: "3.0.15"`,
  passes it to macOS/iOS/Android actions, but does not pass it to
  `build-windows`.
- `.github/actions/build-windows/action.yml` discovers `openssl`, finds an
  installation root, fingerprints the discovered version, directs CMake to that
  root, and copies its DLLs.  This is the specific divergence to remove.
- `.github/scripts/native_cache_manifest.py` validates a version, toolchain and
  exported file hashes, but has no provenance/source-reference field.
- `test/windows_packaging_test.dart` already protects version-agnostic runtime
  DLL globs and provides a conditional plain-Dart loader test.  It does not
  prove source provenance.

## Applicable external sources

1. [OpenSSL 3.0.15 build/install guide](https://github.com/openssl/openssl/blob/openssl-3.0.15/INSTALL.md)
   documents Windows Visual Studio builds through `perl Configure`, `nmake`,
   optional tests, `VC-WIN64A`, isolated prefixes, and the Windows locations of
   static import libraries versus shared DLLs.
2. [OpenSSL 3.0.15 Windows notes](https://github.com/openssl/openssl/blob/openssl-3.0.15/NOTES-WINDOWS.md)
   provide target-specific Windows prerequisites and constraints.
3. `.reversa/_reversa_sdd/native-build-bindings-generation/design.md#Platform Variants`
   is the local baseline: Windows currently uses runner discovery while the
   other source-build actions demonstrate checkout/install-prefix patterns.

## Alternatives considered

| Alternative | Result | Reason |
|---|---|---|
| Continue runner discovery, pin only the cache key | Rejected | A key cannot establish what produced the DLLs, and a runner installation remains an arbitrary dependency source. |
| Download a prebuilt OpenSSL archive | Rejected as normal path | It violates the required normal source-build policy and weakens provenance. |
| Build OpenSSL from `openssl-${{ inputs.openssl_version }}` on Windows | Selected | Aligns the declared release input, source provenance, CMake link inputs, and packaged DLL source. |
| Fall back automatically when a build prerequisite is missing | Rejected | It silently restores runner dependency selection. |
| Checked-in exception plus release-time sidecar equality proof | Selected only as exceptional route | Makes infeasibility explicit, reviewable, temporary, and fail-closed. |

## Implementation research to resolve during coding

- Confirm the exact OpenSSL 3.0.15 Windows target, shared-library options, Perl
  availability, and test command on `windows-latest` in the actual CI run.
- Decide the narrowest exception-record location and schema while keeping it
  distinct from secrets and workflow inputs.
- Reuse the existing manifest utility for sidecar generation/validation where
  practical; do not create a second divergent digest algorithm.
- Verify whether the Linux action's runner-derived OpenSSL observation needs a
  separate feature.  This feature must nevertheless compare all available
  release sidecars if an exception is invoked; it must not claim that static
  source inspection proves a completed cross-platform release.

## Evidence boundary

The plan is grounded in local workflow source and the pinned OpenSSL 3.0.15
documentation.  It does not prove a completed Windows source build, binary
dependencies, a current CI run, or a production publication; those are
explicit implementation/release-validation outcomes.
