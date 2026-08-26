# Native Loader and Lifecycle, Flows

## F1 — Checked initialization

1. `ensureInitialized()` rejects `terminated` and `faulted`, and returns immediately when already initialized. 🟢
2. A positive `git_libgit2_init()` count commits `initialized`. 🟢
3. Zero, negative, or thrown initialization triggers one rollback shutdown. 🟢
4. Successful rollback returns to retryable `uninitialized`; failed rollback commits terminal `faulted`. 🟢

## F2 — Managed call and owner

1. `withCall` initializes, increments the call pin, invokes synchronously, and decrements in `finally`. 🟢
2. `acquireOwner` increments the owner pin and attaches finalizer fallback. 🟢
3. Release/rollback invokes a bound destructor; transfer completes without invoking it. 🟢
4. Destructor failure retains the pin; successful completion decrements exactly once. 🟢

## F3 — Load plan

1. iOS uses `DynamicLibrary.process()`. 🟢
2. Android/Linux/macOS/Windows attempt the platform library name. 🟢
3. Android stops on failure; desktop resolves the package root, preloads dependencies, and opens the package path. 🟢
4. Terminal diagnostics retain both bare-attempt and fallback-stage context. 🟢

## F4 — Shutdown

1. Any live call/owner blocks shutdown. 🟢
2. Uninitialized shutdown terminates with cached result zero and no native call. 🟢
3. Initialized shutdown accepts non-negative native result, caches it, and becomes terminal. 🟢
4. Negative/thrown shutdown commits `faulted`; re-entry remains forbidden. 🟢
