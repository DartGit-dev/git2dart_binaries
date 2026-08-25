# Validation and Release Assembly Flow

```mermaid
flowchart TD
  Bindings["Generate bindings"] --> Desktop["Linux/macOS/Windows injected Flutter tests"]
  Linux["Build + prove Linux"] --> Desktop
  Mac["Build + prove macOS"] --> Desktop
  Windows["Build + prove Windows"] --> Desktop
  IOSBuild["Build two iOS slices"] --> IOSAssemble["Assemble XCFrameworks + proof"]
  Bindings --> IOSRun["Build/run arm64 simulator app"]
  IOSAssemble --> IOSRun
  AndroidX64["Build + prove Android x86_64"] --> AndroidRun["Run API-29 x86_64 emulator app"]
  Bindings --> AndroidRun
  AndroidOther["Build + prove three other Android ABIs"] --> Needs["publish_package needs gate"]
  Desktop --> Needs
  IOSRun --> Needs
  AndroidRun --> Needs
  Needs --> Download["Download bindings, native artifacts and eight proof scopes"]
  Download --> Proof["Aggregate platform-proof validation"]
  Proof --> Inventory["Native release inventory"]
  Inventory --> Provenance["OpenSSL provenance / exception gate"]
  Provenance --> Size["Explicit payload <= 256 MiB"]
  Size --> Consumer["Assemble Linux disposable consumer; compile + load"]
  Consumer --> DryRun["dart pub publish --dry-run"]
  DryRun --> Event{"Event/ref"}
  Event -- pull request --> PR["Upload release-package for 7 days"]
  Event -- main push --> Publish["Credentialed publisher action"]
  Event -- feature push --> Validated["Validation only"]
  Publish --> Gap["🔴 Current registry acceptance not observed"]
  Download -. "current-run service semantics" .-> Boundary["🟡 Same-run declaration is not local hosted proof"]
```
