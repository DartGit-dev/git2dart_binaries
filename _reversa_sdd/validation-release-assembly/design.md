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
7. Upload PR inspection output or publish on an eligible non-PR event. 🟢

## Alternative Flows
- Any failed dependency prevents the downstream release job. 🟢
- PR events never execute the publication step. 🟢
- Only pushes to configured branches `main` and `1.11.2` start a non-PR run; `1.12.1` is not a trigger. 🟢
- Cache misses change build cost, not the release contract. 🟢

## State and Observability
Job results and uploaded artifacts encode workflow state. Logs expose test results, artifact inventories, sizes, and pub validation. No local record proves the latest remote run. 🟢

## Risks and Gaps
- 🔴 Current CI completion and assembled payload were not observed.
- 🔴 External token scopes, branch protections, and pub.dev authorization are unknown.
- 🔴 No two-repository compatibility job exists locally.
- 🟢 Podspec/pub version divergence can enter the assembled package unless separately gated.
