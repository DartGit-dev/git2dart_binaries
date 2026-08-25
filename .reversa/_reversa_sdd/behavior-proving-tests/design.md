# Behavior-Proving Tests, Technical Design

## Interface

| Component | Interface / record | Confidence |
|---|---|---|
| `BehaviorProofFixture` | Guarded temp root, `file`, `sanitize`, bounded process, cleanup. | 🟢 |
| ABI probe | JSON availability/pointer-width/submitted/observed record. | 🟢 |
| Loader probe | Fresh-process status, requested library/root, bounded diagnostics. | 🟢 |
| Architecture facts | Analyzer 8.2.0 AST-derived lifecycle ownership facts. | 🟢 local parser |
| Workflow facts | Parsed events/jobs/needs/conditions/steps. | 🟢 local simplified model |
| Artifact CLIs | Deterministic manifest/proof create/validate results. | 🟢 local fixture |
| Consumer bundle | Injected package plus clean compile/native/probe modes. | 🟢 mechanism |

## Evidence Ladder

1. Source/configuration facts prove declared shape only. 🟢
2. Parsed AST/YAML facts prove bounded structural relations only. 🟢
3. Injected deterministic tests prove local state transitions only. 🟢
4. Fixture/CLI/subprocess/native evidence proves the declared host/payload only. 🟢
5. Same-run hosted evidence requires the actual current workflow and artifacts. 🔴
6. Publication/external-consumer evidence requires pub.dev or `git2dart` observation. 🔴

## Main Flow

1. Declare prerequisites and expected watch observation. 🟢
2. Create guarded fixture or fresh process and apply a bounded timeout. 🟢
3. Capture structured output and sanitize volatile absolute paths. 🟢
4. Classify available/pass, failure, or unavailable without tier promotion. 🟢
5. Persist watch/replacement traceability and explicit proof boundaries. 🟢

## Risks and Gaps

- Positive loader records do not identify the successful handle path. 🔴
- Handwritten proof records can satisfy currently weak aggregate semantics. 🟢 defect
- AST facts are name-based and do not inspect parser diagnostics/resolved element identity. 🟢 limitation
- Current hosted five-platform, external consumer, and publication outcomes are absent. 🔴
