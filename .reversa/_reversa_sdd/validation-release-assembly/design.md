# Validation and Release Assembly, Technical Design

## Workflow Interface
The GitHub Actions workflow consumes generated bindings and native artifacts from composite build jobs. Its output is an expanded pub-package directory, a PR inspection artifact, or a pub.dev publication attempt. 🟢

## Main Flow
1. Generate bindings and native outputs. 🟢
2. Inject relevant files and run Linux, macOS, Windows, iOS simulator, and Android emulator tests. 🟢
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
- Only pushes to configured branches `main` and `1.11.2` start a non-PR run; `1.12.1` is not a trigger. 🟢
- Cache misses change build cost, not the release contract. 🟢
- A failed, unresolved, or mismatched selected version pair fails the `git2dart` integration gate and prevents merge eligibility and publication. 🟢 user-confirmed coordination policy; 🔴 current workflow/run evidence
- Feature branches are never publish-eligible. The current version becomes publish-eligible only through a post-merge green `main` CI/CD run; no local workflow log proves present merge or publication eligibility. 🟢 user-confirmed policy; 🔴 current CI evidence

## State and Observability
Job results and uploaded artifacts encode workflow state. The `git2dart` coordinator records the requested and resolved client/binaries version pair with the full client integration result; logs expose those values, artifact inventories, sizes, and pub validation. No local record proves the latest remote run. 🟢 user-confirmed coordination policy; 🔴 current workflow/run evidence

## Risks and Gaps
- 🔴 Current CI completion and assembled payload were not observed.
- 🟢 The user confirms that GitHub Actions publication controls, including a dedicated pub.dev token, are operational and no additional supply-chain controls are required now. 🔴 This external configuration is not repository-visible proof, and secrets were not inspected.
- 🟢 `git2dart` is the required single coordinator for the two-repository compatibility job. 🔴 No current coordinator workflow or fresh integrated run was inspected.
- 🟢 Podspec/pub version divergence can enter the assembled package unless separately gated.
- 🔴 Current workflows do not establish fresh evidence that version/changelog pre-push verification and every-platform green status have passed for the current version branch.
