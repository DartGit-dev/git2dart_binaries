# Platform Packaging, Flows

## F1 — Platform artifact mapping

1. CI injects normalized native outputs into platform-specific package paths. 🟢 recipe; 🔴 current bytes
2. Gradle/CMake/CocoaPods carry those files into an application bundle. 🟢 recipe
3. Flutter registers the FFI plugin shim. 🟢 declaration; 🔴 current app run
4. The Dart loader resolves process/bare/package symbols according to platform. 🟢 source; 🔴 full platform matrix

## F2 — Disposable consumer bundle

1. Reject a binding from the checkout, a non-empty destination, missing payload, or origin label other than `same-run`. 🟢
2. Copy package source while replacing the generated binding and injecting selected payload files. 🟢
3. Write `bundle-proof.json` and resolve a clean consumer path dependency exactly to the bundle. 🟢
4. Compile the public API or load native libgit2 in a bounded subprocess. 🟢 local mechanism; 🔴 authenticated same-run identity

## F3 — Mobile validation

1. Artifact-populated checkout is consumed by Android emulator and iOS simulator integration apps. 🟢 workflow recipe
2. Platform proof and runtime tests must pass before release assembly. 🟢 graph; 🔴 current hosted execution
