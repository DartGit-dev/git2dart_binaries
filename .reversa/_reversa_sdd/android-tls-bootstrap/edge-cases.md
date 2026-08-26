# Android TLS Bootstrap, Edge Cases

| Case | Required result | Evidence | Confidence |
|---|---|---|---|
| Temporary-directory failure | Rethrow; leave state retryable. | W003 injected test | 🟢 |
| Asset-load failure | Rethrow; leave state retryable. | W003 injected test | 🟢 |
| Write/flush failure | Do not cache path or initialized state. | `android_ssl_helper.dart:110` | 🟢 |
| Sequential second call | Reuse path without dependency calls. | helper test | 🟢 |
| Concurrent first calls | Current helper may duplicate work because no in-flight state exists. | `android_ssl_helper.dart:96` | 🟢 gap |
| Cached file removed later | Current helper does not revalidate existence/content. | source absence | 🟢 observation; 🔴 recovery policy |
| Extraction succeeds but native option is not applied | Do not claim HTTPS readiness. | HC-05 | 🟢 boundary; 🔴 live proof |
| Default device asset/path behavior | Injected host tests are insufficient. | evidence tier model | 🔴 |
