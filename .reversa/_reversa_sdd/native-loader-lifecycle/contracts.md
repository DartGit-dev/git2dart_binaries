# Native Loader and Lifecycle, External Contract

## Managed runtime API

| Surface | Input | Output / obligation | Confidence |
|---|---|---|---|
| `libgit2Runtime.bindings` | First access | Initialized generated `Libgit2` view or checked exception. | 🟢 |
| `libgit2Runtime.options` | First access | Initialized `Libgit2Opts` view over the same handle. | 🟢 |
| `withCall<T>` | Synchronous callback | Result/throw propagation with exact transient pin cleanup. | 🟢 |
| `acquireOwner` | Optional label | Lease that must complete through release, rollback, transfer, or finalizer fallback. | 🟢 |
| `shutdown()` | No active call or owner | Cached non-negative native result; terminal runtime. | 🟢 |
| `GIT2DART_BINARIES_PACKAGE_ROOT` | Non-empty directory path | Highest-priority package-root override. | 🟢 |

## Native loader contract

The external payload must expose the expected libgit2 library name and platform dependencies at the package locations encoded by the loader and packaging metadata. 🟢 contract; 🔴 current same-run bytes

External consumers must not bypass the managed lifecycle if they expect pin and shutdown guarantees. 🟢 supported contract; 🔴 external enforcement
