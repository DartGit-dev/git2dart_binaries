# Validation and Release Assembly, External Contract

## Hosted and registry interfaces

| External surface | Required input | Required outcome | Confidence |
|---|---|---|---|
| GitHub Actions artifact service | Same-run generated binding, native payloads, proofs, provenance | Downloaded artifacts bound to current run/candidate. | 🟢 configured route; 🔴 full identity |
| Platform runners/emulators | Injected payload and tests | Eight proof scopes plus desktop/mobile validation. | 🟢 recipe; 🔴 current run |
| Disposable consumer | Injected Linux binding/payload | Exact bundle resolution, public compile, native load. | 🟢 mechanism; 🔴 current same-run result |
| Publisher action | Exact main push after all gates and external credentials | Publication attempt. | 🟢 condition; 🔴 execution |
| pub.dev | Authenticated package payload | Registry acceptance for intended version. | 🔴 |
| External `git2dart` coordinator | Exact selected repository version pair | Full client integration result before merge/publication eligibility. | 🟢 policy; 🔴 current evidence |

No HTTP API is implemented by this repository; these are CI/artifact/registry contracts. 🟢
