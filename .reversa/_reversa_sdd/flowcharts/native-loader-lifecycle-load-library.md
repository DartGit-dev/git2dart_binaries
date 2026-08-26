# `_loadLibrary` Function

```mermaid
flowchart TD
  Start["_loadLibrary"] --> IOS{"Platform.isIOS?"}
  IOS -- yes --> Process["Return process library"]
  IOS -- no --> Platform["Map OS to NativeLoaderPlan"]
  Platform --> Open1["DynamicLibrary.open(name)"]
  Open1 -->|success| Return["Return handle"]
  Open1 -->|throws| Subdir{"subDir is null?"}
  Subdir -- yes --> Log1["Log bare attempt + system-path hint"] --> ThrowFirst["Rethrow first error"]
  Subdir -- no --> StageRoot["fallbackStage = package root resolution"]
  StageRoot --> Resolve["Resolve cached package root"]
  Resolve --> StageDeps["fallbackStage = dependency preload"]
  StageDeps --> Preload["Load platform dependencies"]
  Preload --> StagePath["fallbackStage = package-local path"]
  StagePath --> Open2["DynamicLibrary.open(root/subDir/name)"]
  Open2 -->|success| Return
  Resolve -->|throws| Log2["Log bare attempt + current fallback stage"]
  Preload -->|throws| Log2
  Open2 -->|throws| Log2
  Log2 --> ThrowFallback["Rethrow fallback error"]
```

🟢 CONFIRMED: iOS bypasses plan selection; Android has a null subdirectory and therefore no package fallback. 🔴 GAP: the feature-005 success probe does not emit the loaded handle path, so process success alone cannot distinguish bare-name success from package fallback success.
