# First-run onboarding: OpenSSL source-build provenance parity

## Purpose

Use this procedure after the implementation exists to verify a first Windows
release-candidate artifact.  It is a release-factory verification procedure,
not a request to install or alter system OpenSSL.

## Preconditions

1. Start from the feature branch with the generated bindings and native-artifact
   workflow enabled.
2. Use the workflow's single `OPENSSL_VERSION` value; do not set a local
   runner OpenSSL path as an override.
3. Ensure the Windows runner can supply the documented OpenSSL build
   prerequisites (MSVC developer environment, Perl, `nmake`, and build tools).

## Normal source-build run

1. Trigger the package build workflow for a pull request.
2. Inspect the Windows job: it must report checkout/configure/build/test of the
   configured OpenSSL source tag and an isolated install prefix.
3. Confirm `libssh2` and `libgit2` are configured from that prefix, not from a
   discovered runner root.
4. Download the Windows artifact and its provenance sidecar.  Verify that its
   version equals `OPENSSL_VERSION`, provenance is `source-build`, the source
   reference is the expected tag, and file digests cover `libgit2.dll`,
   `libssh2.dll`, `libcrypto*.dll`, and `libssl*.dll`.
5. Confirm cache restore validates those fields and rejects a deliberately
   stale/legacy manifest in the focused validation test.
6. Run the Windows packaging and plain-Dart package-root loader checks against
   the expanded package artifact.
7. Confirm the release job records a passing provenance/parity verdict before
   its publish-eligibility boundary.

## Exceptional non-source route

1. Stop on source-build failure; do not substitute a runner OpenSSL manually.
2. Create the documented exception record with platform, configured version,
   concrete infeasibility evidence, approver, and expiry.
3. Produce the exception artifact sidecar and run release qualification against
   all required platform sidecars.
4. Continue only when every sidecar reports the exact configured version and
   the verdict identifies the approved exception.  Any absent, unequal, or
   unproven sidecar is a release failure.

## Expected failure signals

- A runner-installed OpenSSL is selected in the normal Windows path.
- Manifest/sidecar provenance or source reference is absent or differs from the
  configured policy.
- A legacy cache artifact is restored without rebuilding.
- Versioned OpenSSL DLLs are absent from the expanded Windows package.
- Exception evidence is missing, expired, or not exactly equal across platform
  artifacts.
