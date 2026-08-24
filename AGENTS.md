# Reversa

> Reverse-engineering framework installed in this project.

## How to use

Use the appropriate workflow in the chat:

- `reversa` — discover and document an existing system
- `reversa-new` — create a PRD and specifications for a new project
- `reversa-forward` — implement or evolve code from specifications
- `reversa-migrate` — plan the migration of a legacy system
- `reversa-docs` — generate the visual documentation mini-site
- `reversa-agents-help` — view the complete agent catalog

## Activation behavior

When the user sends `reversa` as a standalone message:

1. Read `.agents/skills/reversa/references/codex-routing.md` and select the dispatch transport that the current runtime actually exposes.
2. If a native project custom-agent selector is available, delegate once to the exact profile for the workflow.
3. If only `spawn_agent` model and reasoning overrides are available, use the portable profile dispatch described in the routing reference; never start a nested `codex exec` process.
4. If dispatch is unavailable or fails, activate the corresponding skill at `.agents/skills/<workflow>/SKILL.md` locally.
5. Read the entire `SKILL.md` and follow the Reversa instructions exactly.

## Codex Compute Routing

Profiles in `.codex/agents/reversa-*.toml` are derived configuration and the source of their `model` and `model_reasoning_effort`. Installed `SKILL.md` files remain the source of truth for workflow behavior.

Every Reversa orchestrator must read `.agents/skills/reversa/references/codex-routing.md` before invoking another agent. When the runtime has no custom-profile selector, reproduce the profile with `spawn_agent`, `fork_turns: "none"`, and the model and reasoning overrides declared in its TOML. A valid `compute_escalation` may use only the generated `recommended_profile` for the next Compute Class and only once per logical task. Never select `max` automatically or create an escalation loop. If dispatch fails, use the local fallback without duplicating partial side effects.

## Non-negotiable rule

Never delete, modify, or overwrite pre-existing legacy project files.

Exception: files in `.agents/skills/reversa*/` may be edited solely to translate
human-facing text into English. Preserve all commands, paths, identifiers,
schemas, state literals, and behavior.

Reversa writes only inside `.reversa/`, including `.reversa/_reversa_sdd/`,
`.reversa/_reversa_docs/`, `.reversa/_reversa_forward/`, and
`.reversa/_reversa_bugs/`.
