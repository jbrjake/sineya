# Sineya Plugin Restructure Design

**Date:** 2026-03-21
**Status:** Approved
**Scope:** Restructure the sineya repository from a flat collection of markdown files into a proper Claude Code plugin.

---

## Context

Sineya is a meta-plugin: a plugin that improves other plugins. Its content is research-backed plugin quality improvement guidance distilled from 48 academic papers, 15+ production plugins, and Anthropic's official guidance. The current repository has excellent content but no plugin structure — just six markdown files and a shell script at the root.

The restructure follows patterns established by four sibling plugins: giles, janna, holtz, and snyder. All share the same author (Jon Rubin), license (MIT), and manifest conventions.

## Persona

Sineya is a mysterious, powerful, primordial force that manifests through dreams and imbues those who follow after her with the potential of great power to be unlocked when they connect with her spirit. She does not speak in her own voice but must be interpreted by the agent through her deeds. She is kind of scary, because she exudes magic stronger than anything anyone has ever experienced. Her sacred duty is to spark strength and power in other plugins, sharing her quintessence. She turns regular plugins into superheroes capable of superhuman feats.

## Architecture Decision: Approach C (Hybrid)

Single-skill plugin with one agent, two commands, no hooks. Scripts at plugin root (shared infrastructure), references nested inside the skill (knowledge that belongs to the process).

### Rationale

- **Single skill** — All content serves one workflow (plugin improvement). Breaking into multiple skills would fragment a coherent process.
- **Agent + commands** — The agent carries the persona and is dispatched automatically. Commands provide explicit entry points for users who want direct invocation.
- **No hooks** — Sineya is advisory, not enforcement. It activates when working on a plugin and guides the process. Unlike snyder (which enforces on every edit), Sineya's domain doesn't benefit from deterministic interception.
- **Scripts at root, references in skill** — The validation script is shared infrastructure invoked by both the `/sineya:audit` command and the skill itself. The reference docs are exclusively consumed by the skill's process. Note: holtz (also a single-skill plugin) places scripts inside the skill directory. We follow snyder's pattern instead because the commands invoke the validation script directly — it's a shared utility, not an internal skill implementation detail.
- **No CLAUDE.md** — janna and holtz don't have one. Sineya's content is self-contained in the skill and references. A CLAUDE.md would duplicate what the skill already provides and consume instruction budget for no benefit.
- **No `.claude/settings.local.json`** — Sineya has no hooks, no local permissions overrides, and no settings that need project-level configuration. The sibling plugins that include this file use it for hook configuration or plugin permissions — neither applies here.

## File Structure

```
sineya/
├── .claude-plugin/plugin.json
├── agents/sineya.md
├── commands/
│   ├── improve.md
│   └── audit.md
├── evals/evals.json
├── scripts/validate_skill.sh
├── skills/sineya/
│   ├── SKILL.md
│   └── references/
│       ├── backstory.md
│       ├── improvement-checklist.md
│       ├── anti-patterns.md
│       ├── architecture-plugin-patterns.md
│       ├── hook-patterns.md
│       └── academic-foundations.md
├── LICENSE
├── README.md
└── .gitignore
```

## Component Details

### Plugin Manifest — `.claude-plugin/plugin.json`

```json
{
  "name": "sineya",
  "description": "Primordial plugin quality engine. Distilled from 48 academic papers, 15+ production plugins, and one terrifying dream. She doesn't speak — she improves. Your plugin just doesn't know it's scared yet.",
  "version": "0.1.0",
  "author": {
    "name": "Jon Rubin",
    "email": "jb.rubin@gmail.com",
    "url": "https://github.com/jbrjake"
  },
  "repository": "https://github.com/jbrjake/sineya",
  "license": "MIT",
  "keywords": ["plugin-quality", "skill-improvement", "compliance", "anti-patterns", "hooks", "architecture", "meta-plugin"]
}
```

### Agent — `agents/sineya.md`

- YAML frontmatter with `name`, `description` (including `<example>` blocks for triggering), and `model: opus`
- Loads the persona from `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/backstory.md`
- Loads the skill process from `${CLAUDE_PLUGIN_ROOT}/skills/sineya/SKILL.md`
- The agent carries the voice; the skill carries the workflow
- Dispatched when someone needs deep plugin improvement work

### Commands

**`commands/improve.md`** — `/sineya:improve [path]`
- Full improvement process: classify terrain, score against checklist, fix top 3 failures, pressure test, iterate
- Optional argument: path to plugin/skill directory (defaults to cwd)
- Invokes the skill's full workflow

**`commands/audit.md`** — `/sineya:audit [path]`
- Read-only analysis: runs structural validation via `validate_skill.sh`, then scores against improvement checklist
- Returns a report card with findings and scores
- No fixes applied — diagnosis only

### Skill — `skills/sineya/SKILL.md`

The current SKILL.md content with these changes:
- Reference paths updated to use `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/X.md` for unambiguous resolution regardless of working directory. Relative paths like `references/X.md` resolve against the user's cwd, not the SKILL.md location — using `${CLAUDE_PLUGIN_ROOT}` avoids this gotcha (matches holtz/snyder agent conventions).
- No content changes to the process itself (classify, audit, fix, pressure test, iterate)
- Constraint terrain model, flowchart, priority list, and hard budget constraints preserved

### References (moved, not changed)

| Current location | New location |
|---|---|
| `improvement-checklist.md` | `skills/sineya/references/improvement-checklist.md` |
| `anti-patterns.md` | `skills/sineya/references/anti-patterns.md` |
| `architecture-plugin-patterns.md` | `skills/sineya/references/architecture-plugin-patterns.md` |
| `hook-patterns.md` | `skills/sineya/references/hook-patterns.md` |
| `academic-foundations.md` | `skills/sineya/references/academic-foundations.md` |
| *(new)* | `skills/sineya/references/backstory.md` |

### Script — `scripts/validate_skill.sh`

Current `validate-skill.sh` moved to `scripts/validate_skill.sh`. Underscore to match Python naming convention used in holtz/giles scripts. No functional changes — it already checks frontmatter, line count, word count, flowcharts, references, framing ratio, and skill type declaration.

### Evals — `evals/evals.json`

Following snyder's categorized eval format. Each test case has `id`, `query`, and `assertions` fields. Categories:

**`trigger_precision`** (~6 cases) — Skill activates on correct inputs:
- Casual plugin questions ("make this skill better", "why isn't my plugin working")
- Explicit improvement requests ("review my SKILL.md", "help me write a plugin")
- Should NOT trigger on non-plugin tasks ("write a REST API", "fix this React component")

**`command_behavior`** (~4 cases) — Commands produce correct outputs:
- `/sineya:improve` runs the full improvement process
- `/sineya:audit` returns findings without making changes
- Both handle missing/invalid paths gracefully

**`agent_dispatch`** (~3 cases) — Agent activates correctly:
- Dispatches for deep plugin improvement work
- Loads backstory and skill content
- Does not dispatch for unrelated tasks

**`process_fidelity`** (~4 cases) — The improvement process follows its own rules:
- Classifies terrain before proposing changes
- Scores against checklist before fixing
- Pressure tests after fixes

Target: ~17 eval cases total across 4 categories.

### README.md

Sections: name/tagline, what it does, installation, usage (commands + skill + agent), reference map, author, license. Following holtz/snyder README conventions.

### .gitignore

Standard entries: `.DS_Store`, `*.swp`, `node_modules/`, `.env`, `__pycache__/`, `*.pyc`. Any existing tracked `.DS_Store` files will be removed from git tracking during implementation.

## Files to Delete After Migration

These root-level files will be removed once their content has been moved to the proper plugin structure:

- `SKILL.md` → moved to `skills/sineya/SKILL.md`
- `improvement-checklist.md` → moved to `skills/sineya/references/`
- `anti-patterns.md` → moved to `skills/sineya/references/`
- `architecture-plugin-patterns.md` → moved to `skills/sineya/references/`
- `hook-patterns.md` → moved to `skills/sineya/references/`
- `academic-foundations.md` → moved to `skills/sineya/references/`
- `validate-skill.sh` → moved to `scripts/validate_skill.sh`

## What Is NOT Changing

- The content of the five reference documents (improvement checklist, anti-patterns, architecture patterns, hook patterns, academic foundations)
- The content of the validation script
- The core process in SKILL.md (classify, audit, fix, pressure test, iterate)
- The LICENSE file
- The overall mission: make plugins better using research-backed patterns

## Implementation Notes

- All new files (agent, commands, backstory, README, plugin.json, evals) need to be written from scratch
- SKILL.md needs path updates in its "When to read each reference file" section
- The validation script needs its shebang and usage comment updated for the new location
- Git history is preserved — this is a restructure, not a rewrite
