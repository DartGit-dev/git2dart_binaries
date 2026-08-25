# FR-01–FR-08 source-assertion replacement inventory

| Requirement | Retired source assertion | Replacement evidence | Action |
|---|---|---|---|
| FR-01 | `opts_bindings_source_contract_test.dart`: `ffi.VarArgs<(ffi.Int, ffi.Size)>` text | serialized native `size_t` option probe with value `0x100000011` | T004/T023 |
| FR-02 | `loader_diagnostic_test.dart`: fallback-stage/error substrings | isolated loader success, failure, and Android no-fallback process facts | T005/T024 |
| FR-03 | `native_cache_action_contract_test.dart` and provenance script strings | executable valid/corrupt manifest CLI matrix | T007/T025/T033 |
| FR-04 | `platform_release_proof_test.dart` and workflow proof substrings | executable proof CLI fixture matrix plus parsed workflow facts | T008/T027 |
| FR-05 | `release_inventory_workflow_test.dart`, `windows_packaging_test.dart`, and `linux_packaging_test.dart` payload strings | disposable expanded bundle and clean consumer process | T016/T028/T032/T034 |
| FR-06 | `android_ssl_helper_diagnostic_test.dart` source ordering/diagnostic strings | injected success, cached reuse, write/load failure, and retry transitions | T006/T029 |
| FR-07 | public/internal import source assumptions | clean consumer compilation using public imports and explicit internal-import rejection | T009/T016 |
| FR-08 | lifecycle regex scans and workflow/cache/provenance substrings | exact-pinned analyzer AST facts and parsed workflow graph/facts | T010/T011/T017/T026/T027/T028/T030/T031/T033 |

All rows are mandatory. A retired assertion is complete only after its replacement test passes; unavailable native prerequisites remain explicit evidence and never count as passing behavior.
