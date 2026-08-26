# Native Build and Bindings Generation Flow

```mermaid
flowchart TD
  Pins["Pinned inputs: libgit2 1.9.6, libssh2 1.11.1, OpenSSL 3.0.15, Flutter 3.44.0"] --> Split{"Generation route"}
  Split --> Bindings["Generate Dart bindings"]
  Split --> Android["Build Android ABIs"]
  Split --> IOS["Build iOS SDK slices"]
  Split --> Linux["Build Linux shared libraries"]
  Split --> MacOS["Build macOS dylibs"]
  Split --> Windows["Build Windows DLLs"]
  Bindings --> Common["Fingerprint toolchain and recipe inputs"]
  Android --> Common
  IOS --> Common
  Linux --> Common
  MacOS --> Common
  Windows --> Common
  Common --> Restore["Restore exact or permitted prefix cache"]
  Restore --> Validate["Validate native-v2 manifest and exported bytes"]
  Validate --> Valid{"Manifest valid?"}
  Valid -- yes --> Reuse["Reuse validated export"]
  Valid -- no --> Clear["Clear partial or invalid cache"]
  Clear --> Source["Fetch pinned upstream sources"]
  Source --> Build["Configure and build with platform toolchain"]
  Build --> Qualify["Run configured tests, load/link and symbol checks"]
  Qualify --> Manifest["Create provenance manifest"]
  Manifest --> Save["Save cache"]
  Reuse --> Artifact["Upload normalized export / bindings artifact"]
  Save --> Artifact
  Artifact --> HostedGap["🟡 Current same-run hosted artifact and publication remain external evidence"]
```
