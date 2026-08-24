# Permissions and Trust Boundaries

## Application authorization

No user accounts, roles, RBAC, ACL, database permissions, or per-feature authorization checks exist in this repository. This is a native library/package, not an authenticated application.

| Role | Application permissions |
|---|---|
| End user | Not represented |
| Application user/admin | Not represented |
| Package consumer | Can call any public Dart/FFI API exposed by dependency resolution; no runtime authorization layer is added here |

🟢 **CONFIRMED:** no authorization model was found in code or configuration.

## CI/CD operational access matrix

This is not application RBAC; it documents repository automation trust boundaries.

| Context | Build/test native artifacts | Upload temporary artifacts | Publish to pub.dev | Secrets referenced |
|---|---:|---:|---:|---|
| Pull request workflow | Yes | Yes (`release-package`) | No (`if: event != pull_request`) | Publisher step not executed |
| Push to configured branch | Yes | Native/cache artifacts | Yes after gates | `PUB_DEV_PUBLISH_ACCESS_TOKEN`, `PUB_DEV_PUBLISH_REFRESH_TOKEN` |
| Local developer | Possible with toolchains | Local only unless separately authenticated | Not defined by local scripts | Not stored in repository |

🟢 Workflow conditions prevent the explicit publisher action from running for pull requests. 🔴 Repository/organization settings controlling fork secrets, workflow approvals, branch protection, and token scopes are external and were not inspected.

## Native trust boundary

- The package exposes a broad generated C ABI to Dart; callers with code execution can invoke libgit2 operations and mutate global options.
- No sandbox or capability filter exists between the consumer and native library.
- Native artifacts are built from pinned upstream tags in CI, but this extraction did not verify provenance attestations, signatures, or a published artifact hash.

## Security-relevant gaps

1. 🔴 Exact scopes and rotation policy for pub.dev publishing tokens.
2. 🔴 Whether GitHub environments/manual approval protect publication.
3. 🔴 Whether upstream source tags are signature-verified before build.
4. 🔴 Whether release artifacts have SBOM, provenance, or signing.
5. 🔴 Consumer-side filesystem/network permission expectations of libgit2.

