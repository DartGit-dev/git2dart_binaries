# Inspection Evidence

## Required gate

- `_reversa_sdd/validation-release-assembly/requirements.md:16` requires expected files to exist in the complete pub payload.
- `_reversa_sdd/validation-release-assembly/design.md:10-13` places expected-inventory enforcement between artifact download and size/pub validation.

## Actual release path

- `.github/workflows/build_package.yml:598-650` downloads exact artifact names into platform paths but does not inspect their internal required file sets.
- Lines 652-675 sum whatever files exist under enumerated roots and enforce only an aggregate byte ceiling.
- Lines 686-691 run `flutter pub get` and `dart pub publish --dry-run` without a native inventory assertion.
- Lines 693-723 then upload the PR package or invoke publication.

The missing gate is statically confirmed. No incomplete remote payload is claimed; the defect is the deterministic acceptance path for a named but partial artifact.

