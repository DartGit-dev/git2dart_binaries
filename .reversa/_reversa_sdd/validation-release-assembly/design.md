# Validation and Release Assembly, Technical Design

## Workflow Interface
The GitHub Actions workflow consumes the same-run CI-generated binding artifact and native artifacts from build jobs. `lib/src/bindings.dart` is never tracked; its only production source is the generating job's artifact. Workflow output is an expanded pub-package directory, a PR inspection artifact, or a pub.dev publication attempt. 🟢 user-confirmed binding-artifact policy

## Main Flow
1. Generate `lib/src/bindings.dart` from pinned headers in CI, upload it, and verify the generated path is not tracked. 🟢 user-confirmed binding-artifact policy
2. Download that same workflow run's binding artifact, inject it with the native outputs, and run Linux, macOS, Windows, iOS simulator, and Android emulator tests. Never fall back to a source-checkout copy. 🟢 user-confirmed binding-artifact policy
3. Wait for remaining Android ABIs and all validations. 🟢
4. Download every artifact into the release layout. 🟢
5. Enforce expected inventory and the 256 MiB expanded-size ceiling. 🟢
6. Run `dart pub publish --dry-run`. 🟢
7. `git2dart`, the single cross-repository coordinator, receives the selected `git2dart` + `git2dart_binaries` version pair, resolves that pair as the client uses it, and runs the full client integration suite. 🟢 user-confirmed coordination policy; 🔴 current workflow/run evidence
8. Upload PR inspection output or publish on an eligible non-PR event. 🟢
9. For each new library version, a feature branch carries the exact package/spec version and a complete changelog entry; pre-commit/push verification checks both. A green all-platform run including the coordinated `git2dart` integration run makes the branch merge-eligible only. After merge into `main`, CI/CD runs again through the same coordinator; a green `main` run is required before the configured pipeline may publish. 🟢 user-confirmed release and coordination policy; 🔴 current CI evidence

## Alternative Flows
- Any failed dependency prevents the downstream release job. 🟢
- PR events never execute the publication step. 🟢
- Branch pushes remain validation-reachable, while the publisher condition is exact main-branch push only. 🟢 current parsed workflow facts
- Cache misses change build cost, not the release contract. 🟢
- A tracked `lib/src/bindings.dart`, a missing or cross-run binding artifact, or a source-checkout fallback fails validation and release assembly. 🟢 user-confirmed binding-artifact policy
- A failed, unresolved, or mismatched selected version pair fails the `git2dart` integration gate and prevents merge eligibility and publication. 🟢 user-confirmed coordination policy; 🔴 current workflow/run evidence
- Feature branches are never publish-eligible. The current version becomes publish-eligible only through a post-merge green `main` CI/CD run; no local workflow log proves present merge or publication eligibility. 🟢 user-confirmed policy; 🔴 current CI evidence

## State and Observability
Job results and uploaded artifacts encode workflow state. Binding consumers record the generating workflow-run identity, and the tracked-file guard records source-control hygiene. The `git2dart` coordinator records the requested and resolved client/binaries version pair with the full client integration result; logs expose those values, artifact inventories, sizes, and pub validation. No local record proves the latest remote run. 🟢 user-confirmed coordination and binding-artifact policy; 🔴 current workflow/run evidence

## Risks and Gaps
- 🔴 Current CI completion and assembled payload were not observed.
- 🟢 The user confirms that GitHub Actions publication controls, including a dedicated pub.dev token, are operational and no additional supply-chain controls are required now. 🔴 This external configuration is not repository-visible proof, and secrets were not inspected.
- 🟢 `git2dart` is the required single coordinator for the two-repository compatibility job. 🔴 No current coordinator workflow or fresh integrated run was inspected.
- 🟢 Podspec/pub version divergence can enter the assembled package unless separately gated.
- 🟢 A committed binding or a consumer fallback to the checkout bypasses the CI-owned ABI handoff and is release-ineligible. 🟢 user-confirmed binding-artifact policy
- 🔴 Current workflows do not establish fresh evidence that version/changelog pre-push verification and every-platform green status have passed for the current version branch.

## 2026-08-25 Release-State Boundary

S04 owns the platform validation matrix; S05 owns proof/inventory/provenance/size/bundle/dry-run gates and PR/non-main/main routing. 🟢

`bundle-proof.json`, caller labels, and downloaded artifact names establish declared routing but do not cryptographically attest byte identity across producer, release payload, disposable bundle, and publication. 🟢 source; 🔴 HC-07 closure

An exact-main condition proves static reachability only; GitHub protections, token scopes, approvals, publisher execution, and registry acceptance remain external. 🟢 local fact; 🔴 external controls/outcome
