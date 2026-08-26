# libgit2 Global Options, External Contract

## Native ABI boundary

| Contract | Caller obligation | Result | Confidence |
|---|---|---|---|
| 33 typed option methods | Supply exact-width values/pointers matching the method signature. | Unchanged native status. | 🟢 source |
| `git_buf`/`git_strarray` getters | Allocate outer value and call matching libgit2 disposer for populated contents. | Native-owned contents exposed to Dart. | 🟢 current tests; 🟡 full API |
| String/array setters | Retain every C allocation for the call duration. | Native reads caller-owned memory. | 🟢 |
| Pack max object-size setter | Supply non-negative integer. | Negative values fail locally. | 🟢 |
| W001 round trip | Provide a declared matching 64-bit payload. | Exact submitted/observed record or explicit unavailable. | 🟢 contract |

The contract is process-global libgit2 state, not an HTTP/RPC endpoint. 🟢
