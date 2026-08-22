# Exploration Plan — git2dart_binaries

> Created by Reversa on 2026-08-16.
> Mark each task with ✅ when completed.

---

## Phase 1: Discovery 🔍

- [x] ✅ **Scout** — Map folder structure and technologies
- [x] ✅ **Scout** — Analyze dependencies and package managers
- [x] ✅ **Scout** — Identify entry points, CI/CD, and configuration

## Specification organization decision 🗂️

> Reversa records the selected specification layout in `.reversa/config.toml` before excavation begins.

## Phase 2: Excavation 🏗️

> Modules identified by Scout:

- [x] ✅ **Archaeologist** — Analyze `dart-ffi-facade`
- [x] ✅ **Archaeologist** — Analyze `native-loader-lifecycle`
- [x] ✅ **Archaeologist** — Analyze `libgit2-global-options`
- [x] ✅ **Archaeologist** — Analyze `android-tls-bootstrap`
- [x] ✅ **Archaeologist** — Analyze `platform-packaging`
- [x] ✅ **Archaeologist** — Analyze `native-build-bindings-generation`
- [x] ✅ **Archaeologist** — Analyze `validation-release-assembly`

## Phase 3: Interpretation 🧠

- [x] ✅ **Detective** — Git archaeology and retrospective ADRs
- [x] ✅ **Detective** — Implicit rules and state machines
- [x] ✅ **Detective** — Permission matrix (not applicable; CI trust boundary documented)
- [x] ✅ **Architect** — C4 diagrams (Context, Containers, Components)
- [x] ✅ **Architect** — Data/integration model
- [x] ✅ **Architect** — Specification impact matrix

## Phase 4: Generation 📝

- [x] ✅ **Writer** — SDD specifications by component (7 feature folders, 21 canonical files)
- [x] ✅ **Writer** — OpenAPI (not applicable; no HTTP API found)
- [x] ✅ **Writer** — User stories (not applicable; package behavior is specified as technical feature acceptance scenarios)
- [x] ✅ **Writer** — Code/specification matrix (47/47 tracked files mapped)

## Phase 5: Review ✅

- [x] ✅ **Reviewer** — Cross-review specifications (independent Codex pass incorporated)
- [x] ✅ **Reviewer** — Record unresolved gaps (10 questions; awaiting user validation)
- [x] ✅ **Reviewer** — Final confidence report (80.5% weighted confidence; 10 decisions retained as lacunae)

---

## Independent agents

> Run only when their required evidence exists.

- [ ] **Visor** — Screenshot interface analysis (not applicable in current evidence)
- [ ] **Data Master** — Database analysis (not applicable; no database found)
- [ ] **Design System** — Design token extraction (not applicable)
- [ ] **Tracer** — Dynamic analysis (requires an accessible built system)

---

## Subsequent flows

After discovery and specification generation, Reversa can run migration, reconstruction, or forward flows when explicitly requested.

- `/reversa-migrate`: generate migration specifications.
- `/reversa-reconstructor`: generate a bottom-up reconstruction plan.
