# State Machines

## 1. Runtime library resolution

```mermaid
stateDiagram-v2
  [*] --> SelectingPlatform
  SelectingPlatform --> ProcessLibrary: iOS
  SelectingPlatform --> OpeningBareName: Android/Linux/macOS/Windows
  SelectingPlatform --> Unsupported: other platform
  OpeningBareName --> Ready: open succeeds
  OpeningBareName --> Failed: Android open fails
  OpeningBareName --> ResolvingPackageRoot: desktop open fails
  ResolvingPackageRoot --> PreloadingDependencies: root found
  ResolvingPackageRoot --> Failed: no root found
  PreloadingDependencies --> OpeningPackageLibrary: dependencies loaded
  PreloadingDependencies --> Failed: dependency error
  OpeningPackageLibrary --> Ready: open succeeds
  OpeningPackageLibrary --> Failed: open fails
  ProcessLibrary --> Ready
  Ready --> Initialized: construct bindings and call git_libgit2_init
  Unsupported --> [*]
  Failed --> [*]
  Initialized --> [*]
```

🟢 All transitions are directly encoded in `lib/src/util.dart`. 🔴 No production `Initialized -> Shutdown` transition is defined locally.

## 2. Android certificate extraction

```mermaid
stateDiagram-v2
  [*] --> NotInitialized
  NotInitialized --> Extracting: initialize called
  Extracting --> Initialized: asset loaded and file flushed
  Extracting --> NotInitialized: exception and retry remains possible
  Initialized --> Initialized: subsequent initialize returns cached path
```

State variables are `_initialized` and `_certPath`. The external `certificate applied to libgit2` state is not represented in this helper, so successful extraction does not by itself prove HTTPS readiness.

## 3. Native artifact cache

```mermaid
stateDiagram-v2
  [*] --> CacheLookup
  CacheLookup --> Validating: cache restored
  CacheLookup --> Rebuilding: cache miss
  Validating --> Reusing: manifest and export valid
  Validating --> Clearing: validation fails
  Clearing --> Rebuilding
  Rebuilding --> Testing: compile completed
  Testing --> Exporting: native tests and symbol checks pass
  Testing --> Failed: test or check fails
  Exporting --> Manifested: normalized export and manifest created
  Manifested --> Saved
  Reusing --> Uploaded
  Saved --> Uploaded
  Uploaded --> [*]
  Failed --> [*]
```

🟢 This is reconstructed from current composite actions. A cache hit is not trusted merely because it exists; validation is a distinct state.

## 4. Release qualification

```mermaid
stateDiagram-v2
  [*] --> Building
  Building --> PlatformTesting: bindings and native artifacts available
  Building --> Failed: any build fails
  PlatformTesting --> Assembling: all required tests/jobs succeed
  PlatformTesting --> Failed: any required test fails
  Assembling --> SizeCheck: all artifacts downloaded into package paths
  SizeCheck --> Failed: payload exceeds 256 MiB
  SizeCheck --> PubDryRun: payload accepted
  PubDryRun --> Failed: pub validation fails
  PubDryRun --> PRArtifact: pull_request event
  PubDryRun --> Publishing: non-pull_request event
  PRArtifact --> [*]
  Publishing --> Published: publisher action succeeds
  Publishing --> Failed: publisher action fails
  Published --> [*]
  Failed --> [*]
```

🟢 Publication is structurally downstream of every required platform job. 🟡 Whether branch protection separately enforces the workflow is outside repository evidence.

## 5. libgit2 global-option call

```mermaid
stateDiagram-v2
  [*] --> DartArguments
  DartArguments --> Rejected: local validation fails
  DartArguments --> SelectingDiscriminator: arguments accepted
  SelectingDiscriminator --> BindingSignature
  BindingSignature --> NativeCall: lazy symbol lookup/signature available
  BindingSignature --> Failed: lookup/signature error
  NativeCall --> Succeeded: status equals zero
  NativeCall --> NativeError: status is negative
  Rejected --> [*]
  Failed --> [*]
  Succeeded --> [*]
  NativeError --> [*]
```

Only pack maximum object size currently has explicit local range rejection. Other validity rules remain native-side.

## State gaps

- 🔴 No persisted release state or deployment record exists in the repository.
- 🔴 No explicit libgit2 lifecycle state tracks reference count or shutdown ownership.
- 🔴 No state connects `AndroidSSLHelper` extraction to successful application of certificate locations.
- 🔴 Runtime native-loader state is implicit in lazy top-level initialization and exceptions rather than represented by an enum/object; option access can occur without reading the initializing `libgit2` global.
