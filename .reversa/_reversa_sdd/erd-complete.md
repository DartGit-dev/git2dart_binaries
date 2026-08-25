# Complete Conceptual Entity Model

## Applicability

The repository has no database, ORM, migrations, durable business records, or persistence keys. The diagrams therefore model the **49 extracted runtime, build, release, and evidence structures** with conceptual cardinalities. PK/FK labels are intentionally not invented; identifiers such as relative paths, job IDs, candidates, and watch IDs are ephemeral contract fields rather than database keys.

| Group | Entity count |
|---|---:|
| Dart FFI, managed runtime, options, Android TLS | 16 |
| Platform packaging, native build, cache | 14 |
| Release proof and workflow model | 11 |
| Behavior evidence model | 8 |
| **Total** | **49** |

## 1. Dart FFI, managed runtime, options, and Android TLS (16)

```mermaid
erDiagram
  LIFECYCLE_OPERATION ||--o{ LIFECYCLE_EXCEPTION : classifies
  LIBGIT2_RUNTIME ||--|| RUNTIME_STATE : owns
  LIBGIT2_RUNTIME ||--|| LIBGIT2_OPTS : exposes
  RUNTIME_STATE ||--|| RUNTIME_PHASE : occupies
  RUNTIME_STATE ||--o{ OWNER_LEASE : pins
  OWNER_LEASE ||--|| OWNER_CLEANUP : delegates
  LOADER_PLAN o|--o{ PACKAGE_CONFIG_ENTRY : may_resolve_through
  LIBGIT2_OPTS ||--o{ VARIADIC_SIGNATURE : dispatches
  LIBGIT2_OPTS ||--o{ ABI_PROBE_OPTION_RECORD : observed_by
  ANDROID_SSL_DEPENDENCIES ||--o{ ANDROID_TLS_ATTEMPT : supplies
  ANDROID_TLS_ATTEMPT }o--|| ANDROID_TLS_STATE : may_commit

  LIFECYCLE_OPERATION {
    string values
  }
  LIFECYCLE_EXCEPTION {
    string operation
    int nativeResult
    string cause
    string causeStackTrace
    string ownerLabel
  }
  LIBGIT2_ERROR {
    pointer errorPointer
    string message
    int errorClass
  }
  LIBGIT2_RUNTIME {
    object bindings
    object options
    object state
  }
  RUNTIME_STATE {
    string phase
    int activeCallCount
    int liveOwnerCount
    int shutdownResult
  }
  OWNER_LEASE {
    object cleanup
    object finalizer
  }
  OWNER_CLEANUP {
    object runtime
    string debugLabel
    function destructor
    bool isCompleting
    bool isCompleted
  }
  RUNTIME_PHASE {
    string values
  }
  LOADER_PLAN {
    string libraryName
    string packageSubdirectory
    bool hasPackageFallback
  }
  PACKAGE_CONFIG_ENTRY {
    string name
    string rootUri
  }
  LIBGIT2_OPTS {
    function lookup
    object pointerAdapters
    object dartAdapters
  }
  VARIADIC_SIGNATURE {
    string returnType
    string optionType
    string varArgs
    function dartFunction
  }
  ABI_PROBE_OPTION_RECORD {
    string availability
    int pointerWidth
    int submittedSize
    int observedSize
  }
  ANDROID_SSL_DEPENDENCIES {
    function temporaryDirectory
    function loadCertificateAsset
    function writeCertificate
  }
  ANDROID_TLS_STATE {
    bool initialized
    string certPath
  }
  ANDROID_TLS_ATTEMPT {
    object dependencies
    string temporaryDirectory
    string target
    bytes certificateBytes
  }
```

Entity name mapping: `LIFECYCLE_OPERATION=Libgit2LifecycleOperation`, `LIFECYCLE_EXCEPTION=Libgit2LifecycleException`, `LIBGIT2_ERROR=LibGit2Error`, `LIBGIT2_RUNTIME=Libgit2Runtime`, `RUNTIME_STATE=Libgit2RuntimeState`, `OWNER_LEASE=Libgit2OwnerLease`, `OWNER_CLEANUP=OwnerCleanup`, `RUNTIME_PHASE=RuntimePhase`, `LOADER_PLAN=NativeLoaderPlan`, `PACKAGE_CONFIG_ENTRY=PackageConfigEntry`, `LIBGIT2_OPTS=Libgit2Opts`, `VARIADIC_SIGNATURE=VariadicSignatureFamily`, `ABI_PROBE_OPTION_RECORD=AbiProbeRecord`, `ANDROID_SSL_DEPENDENCIES=AndroidSSLDependencies`, `ANDROID_TLS_STATE=AndroidTLSCompletionState`, and `ANDROID_TLS_ATTEMPT=AndroidTLSInitializationAttempt`.

## 2. Platform packaging, native build, and cache (14)

```mermaid
erDiagram
  PLUGIN_PLATFORM ||--o{ NATIVE_ARTIFACT_SET : declares
  ANDROID_PACKAGE_CONFIG ||--o{ NATIVE_ARTIFACT_SET : locates_android
  APPLE_POD_CONFIG ||--o{ NATIVE_ARTIFACT_SET : vendors_apple
  BUNDLE_EVIDENCE ||--o{ NATIVE_ARTIFACT_SET : records_payload
  BUNDLE_EVIDENCE ||--o{ CONSUMER_RUN_RESULT : qualifies
  NATIVE_VERSION_SET ||--o{ NATIVE_CACHE_KEY : versions
  TOOLCHAIN_FINGERPRINT ||--o{ NATIVE_CACHE_KEY : fingerprints
  NATIVE_CACHE_KEY ||--o| NATIVE_CACHE_MANIFEST : accepts
  NATIVE_CACHE_MANIFEST ||--|{ NATIVE_CACHE_FILE : inventories
  NATIVE_CACHE_MANIFEST ||--|| NATIVE_PROVENANCE : records
  NATIVE_VERSION_SET ||--o{ BINDING_GENERATION_CONFIG : configures
  NATIVE_VERSION_SET ||--o{ PLATFORM_BUILD_EXPORT : builds
  PLATFORM_BUILD_EXPORT ||--|| NATIVE_PROVENANCE : carries
  NATIVE_ARTIFACT_SET ||--o{ PLATFORM_BUILD_EXPORT : materializes_as

  PLUGIN_PLATFORM {
    string platform
    string pluginClass
    bool ffiPlugin
  }
  NATIVE_ARTIFACT_SET {
    string platform
    string abiOrSlice
    string artifacts
    string linkOrLoadMode
    string provenanceSidecar
  }
  ANDROID_PACKAGE_CONFIG {
    string namespace
    int compileSdkVersion
    int minSdkVersion
    string javaVersion
    string abis
  }
  APPLE_POD_CONFIG {
    string platform
    string version
    string minimumOs
    string vendoredArtifacts
    string linkFlags
  }
  BUNDLE_EVIDENCE {
    string bundleRoot
    string platform
    string bindingOrigin
    string payloadFiles
  }
  CONSUMER_RUN_RESULT {
    int exitCode
    string category
    string stdout
    string stderr
    bool succeeded
  }
  NATIVE_VERSION_SET {
    string libgit2
    string libssh2
    string openssl
    string flutter
  }
  TOOLCHAIN_FINGERPRINT {
    string platform
    string runnerOsArch
    string compiler
    string cmake
    string targetInputs
    string sha256
  }
  NATIVE_CACHE_KEY {
    string prefix
    string platformOrAbi
    string toolchainFingerprint
    string nativeVersions
    string recipeHash
  }
  NATIVE_CACHE_MANIFEST {
    string schema
    string platform
    string abi
    string libgit2
    string libssh2
    string openssl
    string toolchain
    string provenance
  }
  NATIVE_CACHE_FILE {
    string relativePath
    string sha256
    int size
  }
  NATIVE_PROVENANCE {
    string provenance
    string sourceRef
    string exceptionId
  }
  BINDING_GENERATION_CONFIG {
    string output
    string entryPoints
    string compilerOptions
    string className
  }
  PLATFORM_BUILD_EXPORT {
    string platform
    string abiOrSlice
    string files
    string provenanceSidecar
    string artifactName
  }
```

Entity name mapping: `PLUGIN_PLATFORM=FlutterPluginPlatformRecord`, `NATIVE_ARTIFACT_SET=NativeArtifactSet`, `ANDROID_PACKAGE_CONFIG=AndroidPackageConfiguration`, `APPLE_POD_CONFIG=ApplePodPackageConfiguration`, `BUNDLE_EVIDENCE=BundleEvidence`, `CONSUMER_RUN_RESULT=ConsumerRunResult`, `NATIVE_VERSION_SET=NativeVersionSet`, `TOOLCHAIN_FINGERPRINT=ToolchainFingerprint`, `NATIVE_CACHE_KEY=NativeCacheKey`, `NATIVE_CACHE_MANIFEST=NativeCacheManifest`, `NATIVE_CACHE_FILE=NativeCacheFileRecord`, `NATIVE_PROVENANCE=NativeProvenanceRecord`, `BINDING_GENERATION_CONFIG=BindingGenerationConfiguration`, and `PLATFORM_BUILD_EXPORT=PlatformBuildExport`.

## 3. Release proof and workflow model (11)

```mermaid
erDiagram
  RELEASE_PAYLOAD ||--|{ PLATFORM_RELEASE_PROOF : requires
  PLATFORM_RELEASE_PROOF ||--|| PLATFORM_PROOF_INVENTORY : contains
  PLATFORM_PROOF_INVENTORY ||--o{ PLATFORM_PROOF_FILE : lists
  PLATFORM_RELEASE_PROOF ||--|{ DEPENDENCY_VERSION_OBSERVATION : reports
  PLATFORM_RELEASE_PROOF ||--o| APPLE_ATTESTATION : may_include
  APPLE_ATTESTATION ||--o{ DEPENDENCY_VERSION_OBSERVATION : compiles
  WORKFLOW_POLICY_FACTS ||--|{ WORKFLOW_JOB_FACT : models
  WORKFLOW_JOB_FACT ||--|{ WORKFLOW_STEP_FACT : contains
  WORKFLOW_CONDITION ||--o{ WORKFLOW_JOB_FACT : guards
  WORKFLOW_CONDITION ||--o{ WORKFLOW_STEP_FACT : guards
  WORKFLOW_JOB_FACT o|--o| RELEASE_PAYLOAD : assembles
  OPENSSL_EXCEPTION_RECORD o|--o{ DEPENDENCY_VERSION_OBSERVATION : authorizes_exception

  RELEASE_PAYLOAD {
    string bindings
    string desktopArtifacts
    string androidAbis
    string iosFrameworks
    string provenanceSidecars
    string metadata
  }
  PLATFORM_RELEASE_PROOF {
    string schema
    string candidate
    string platform
    string abi
    string status
    string linkage
    string failureCodes
  }
  PLATFORM_PROOF_INVENTORY {
    string expected
    string present
    string missing
    string unexpected
  }
  PLATFORM_PROOF_FILE {
    string path
    string sha256
    int size
  }
  DEPENDENCY_VERSION_OBSERVATION {
    string intended
    string observed
    string comparison
    string evidence
  }
  APPLE_ATTESTATION {
    string inputSha256
    string emittedSha256
    string toolchain
    string sdk
    string compiledMetadata
  }
  WORKFLOW_CONDITION {
    string kind
    string source
  }
  WORKFLOW_STEP_FACT {
    string name
    string uses
    string run
    string withValues
  }
  WORKFLOW_JOB_FACT {
    string id
    string needs
    string steps
  }
  WORKFLOW_POLICY_FACTS {
    string events
    string jobs
  }
  OPENSSL_EXCEPTION_RECORD {
    string id
    string platform
    string abi
    string openssl
    string infeasibilityEvidence
    string approver
    date reviewBy
    string exactParity
  }
```

Entity names correspond directly to `ReleasePayload`, `PlatformReleaseProof`, `PlatformProofInventory`, `PlatformProofFileRecord`, `DependencyVersionObservation`, `ApplePlatformAttestation`, `WorkflowCondition`, `WorkflowStepFact`, `WorkflowJobFact`, `WorkflowPolicyFacts`, and `OpenSSLExceptionRecord`.

## 4. Behavior evidence model (8)

```mermaid
erDiagram
  BEHAVIOR_FIXTURE ||--o{ ABI_PROBE_RECORD : hosts
  BEHAVIOR_FIXTURE ||--o{ LOADER_PROBE_RECORD : hosts
  ANALYZER_RESOLUTION ||--o{ ARCHITECTURE_FACT : authorizes_parser
  EVIDENCE_CLASSIFICATION ||--o{ ABI_PROBE_RECORD : qualifies
  EVIDENCE_CLASSIFICATION ||--o{ LOADER_PROBE_RECORD : qualifies
  BEHAVIOR_REGRESSION_WATCH ||--o{ SOURCE_ASSERTION_REPLACEMENT : guarded_by
  EVIDENCE_CLASSIFICATION ||--o{ SOURCE_ASSERTION_REPLACEMENT : qualifies

  BEHAVIOR_FIXTURE {
    string root
    duration defaultTimeout
  }
  ABI_PROBE_RECORD {
    string availability
    int pointerWidth
    int submittedSize
    int observedSize
  }
  LOADER_PROBE_RECORD {
    string status
    string packageRoot
    string library
    bool packageFallback
  }
  ANALYZER_RESOLUTION {
    string version
    string root
  }
  ARCHITECTURE_FACT {
    string file
    string kind
    string symbol
    bool allowed
  }
  BEHAVIOR_REGRESSION_WATCH {
    string id
    string origin
    string expectedRule
    string verificationType
    string violationSignal
  }
  SOURCE_ASSERTION_REPLACEMENT {
    string requirement
    string retiredAssertion
    string replacementEvidence
    string actionIds
  }
  EVIDENCE_CLASSIFICATION {
    string tier
    string prerequisites
    string observable
    string proves
    string doesNotProve
  }
```

Entity names correspond to `BehaviorProofFixture`, `ABIProbeRecord`, `LoaderProbeRecord`, `AnalyzerResolution`, `ArchitectureFact`, `BehaviorRegressionWatch`, `SourceAssertionReplacement`, and `EvidenceClassification`.

## Cardinality and lifecycle notes

- Runtime relations are isolate-local and in-memory; `OwnerLease` multiplicity is logical pin accounting, not persisted ownership.
- Cache/proof/payload relations exist as files and hosted artifacts during a workflow run.
- One release candidate expects eight unique proof scopes: Linux, macOS, Windows, iOS, Android x86_64, and three other Android ABIs.
- A bundle may produce several consumer-run results, but those results prove only their exact bundle/host/mode.
- Evidence classification is analytical: it prevents a source, parser, injected, or local fixture record from claiming hosted/publication authority.

## Persistence statement

The only handwritten runtime file is the extracted Android `cacert.pem`. CI caches/artifacts and disposable bundles are external or temporary filesystem state. There is no schema migration and no durable referential integrity engine; hash, path, candidate, and job relationships must be checked by code/workflow gates.
