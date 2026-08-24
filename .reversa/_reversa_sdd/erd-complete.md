# Conceptual Artifact and Runtime Data Model

No database, ORM, schema migration, or persistent business entity exists. This ERD-style diagram models structured build/runtime data that crosses component boundaries.

```mermaid
erDiagram
  NATIVE_VERSION_SET ||--|| GENERATED_BINDING : generates
  NATIVE_VERSION_SET ||--|{ PLATFORM_ARTIFACT_SET : builds
  TOOLCHAIN_FINGERPRINT ||--|{ CACHE_MANIFEST : keys
  NATIVE_VERSION_SET ||--|{ CACHE_MANIFEST : records
  CACHE_MANIFEST ||--|| GENERATED_BINDING : validates
  CACHE_MANIFEST ||--|{ PLATFORM_ARTIFACT_SET : validates
  GENERATED_BINDING ||--|| RELEASE_PAYLOAD : included_in
  PLATFORM_ARTIFACT_SET }|--|| RELEASE_PAYLOAD : included_in
  RELEASE_PAYLOAD ||--|| PACKAGE_PUBLICATION : qualifies
  PACKAGE_CONFIG ||--|{ PACKAGE_CONFIG_ENTRY : contains
  PACKAGE_CONFIG_ENTRY ||--o| PACKAGE_ROOT : resolves
  PACKAGE_ROOT ||--|{ PLATFORM_ARTIFACT : locates
  ANDROID_TLS_STATE ||--o| CERTIFICATE_FILE : caches
  NATIVE_LIBRARY ||--o{ NATIVE_ERROR_POINTER : exposes

  NATIVE_VERSION_SET {
    string libgit2
    string libssh2
    string openssl
    string flutter
  }
  GENERATED_BINDING {
    string path
    string libgit2_version
    string generator_fingerprint
  }
  PLATFORM_ARTIFACT_SET {
    string platform
    string architecture
    string files
    string link_mode
  }
  TOOLCHAIN_FINGERPRINT {
    string runner_os
    string runner_arch
    string compiler
    string build_tools
    string recipe_hash
  }
  CACHE_MANIFEST {
    string export_root
    string versions
    string fingerprint
    string file_inventory
  }
  RELEASE_PAYLOAD {
    string package_version
    int expanded_bytes
    string platform_outputs
  }
  PACKAGE_PUBLICATION {
    string event_type
    bool dry_run_passed
    string destination
  }
  PACKAGE_CONFIG {
    string uri
  }
  PACKAGE_CONFIG_ENTRY {
    string name
    string rootUri
  }
  PACKAGE_ROOT {
    string absolute_path
  }
  PLATFORM_ARTIFACT {
    string filename
    string platform_subdir
  }
  ANDROID_TLS_STATE {
    bool initialized
    string certPath
  }
  CERTIFICATE_FILE {
    string temp_path
    binary pem_content
  }
  NATIVE_LIBRARY {
    string handle
    int init_reference_count
  }
  NATIVE_ERROR_POINTER {
    string message
    int klass
  }
```

## Classification

- 🟢 `NATIVE_VERSION_SET`, package config, Android TLS state, and native error fields are directly represented in local configuration/code.
- 🟢 Artifact sets, cache manifests, and release payload membership are represented by workflows/actions.
- 🟡 `PACKAGE_PUBLICATION` is a conceptual record of pipeline state; the repository does not persist it as a local entity.
- 🟡 `NATIVE_LIBRARY.init_reference_count` belongs to libgit2 semantics; local production code does not track it.

## Persistence statement

The only runtime file created by handwritten code is the Android temporary `cacert.pem`. CI artifacts/caches are external ephemeral storage managed by GitHub. No product database relationship or primary/foreign key exists.
