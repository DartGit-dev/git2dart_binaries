# Platform Packaging, External Contract

## Platform payloads

| Platform | Required external artifact contract | Confidence |
|---|---|---|
| Android | Four ABIs, each with `libgit2.so`, `libssh2.so`, `libssl.so`, and `libcrypto.so`. | 🟢 recipe; 🔴 current bytes |
| iOS | Four vendored XCFrameworks with libgit2 force-loaded for device/simulator. | 🟢 recipe; 🔴 current bytes |
| Linux | `libgit2.so` and package-local `libssh2.so`; compatible OpenSSL remains environmental. | 🟢 recipe; 🔴 current host matrix |
| macOS | `libgit2.dylib` with `@rpath` identity and no dynamic libssh2/OpenSSL dependency. | 🟢 recipe; 🔴 current bytes |
| Windows | `libgit2.dll`, `libssh2.dll`, and matched versioned crypto/TLS DLLs. | 🟢 recipe; 🔴 current bytes |

The consumer contract is package-layout and native-loading compatibility, not an HTTP/RPC interface. 🟢
