---
name: plugin-quality-improvement
description: Improve Claude Code plugins and skills using research-backed patterns from the most effective plugins in the ecosystem. Use this skill whenever you are creating, reviewing, editing, or improving a Claude Code plugin or skill — including writing SKILL.md files, designing subagent prompts, writing hook scripts, structuring plugin directories, or debugging why a skill isn't triggering or being followed. Also use when the user says things like "make this skill better", "why isn't my plugin working", "review my SKILL.md", "help me write a plugin", "skill compliance", or mentions writing CLAUDE.md rules, .claude/rules/ files, or hook configurations. Use even if the user just mentions working on a plugin and asks a tangential question — check this skill first.
---

# Plugin Quality Improvement v2

Make Claude Code plugins that get followed. Distilled from obra/superpowers (101k stars), 48 academic papers (2025–2026), 15+ production plugins, Anthropic's official guidance, and practitioner compliance reports.

**The core insight has not changed:** plugins that encode process outperform plugins that encode knowledge. But v2 adds a sharper formulation from Jesse Vincent's empirical JSON traces: **comprehension and compulsion are not the same thing.** Claude can perfectly understand an instruction while systematically not following it. Every recommendation below addresses this gap.

## Constraint terrain model

Before writing anything, classify your skill's terrain (per Anthropic's official guidance):

- **Narrow mountain path** — one correct approach, high stakes → RIGID skill, imperative language, hard gates, hook enforcement
- **Open field** — many valid paths, low stakes → FLEXIBLE skill, explain the *why*, document deviations

Mismatching terrain to constraint level is the #1 design error. Over-constraining open fields creates friction. Under-constraining narrow paths creates drift.

## When to read each reference file

Read `references/improvement-checklist.md` when:
- Creating a new plugin or reviewing an existing one
- Debugging poor compliance (Claude ignores or partially follows the skill)
- Designing subagent prompts for orchestrated workflows

Read `references/anti-patterns.md` when:
- A skill triggers but Claude rationalizes skipping steps
- Subagents drift from specs or rubber-stamp reviews
- You need pressure-test scenarios before release

Read `references/architecture-plugin-patterns.md` when:
- Building plugins for system design, plan→implement→review pipelines, or multi-phase dev workflows

Read `references/hook-patterns.md` when:
- Writing hook scripts (SessionStart, PreToolUse, PostToolUse)
- Needing deterministic enforcement that prompts cannot provide
- Debugging silent hook failures

Read `references/academic-foundations.md` when:
- You want the research citations backing a specific recommendation
- Deciding between competing approaches and need empirical evidence
- Designing evaluation criteria for skill quality

## The improvement process

```dot
digraph {
  rankdir=LR
  node [shape=box]
  classify [label="Classify terrain\n(rigid vs flexible)"]
  audit [label="Score against\nchecklist"]
  fix [label="Fix top 3\nfailures"]
  pressure [label="Pressure test\n(3 scenarios)"]
  iterate [label="Iterate on\nfailures"]
  ship [label="Ship"]

  classify -> audit -> fix -> pressure
  pressure -> iterate [label="failures found"]
  pressure -> ship [label="all pass"]
  iterate -> pressure
}
```

### Priority of changes (highest impact first)

1. **Fix async SessionStart hooks** — if `"async": true`, your bootstrap silently never loads. Change to `false`.
2. **Add hard gates** for critical steps — `<HARD-GATE>` blocks with explicit stop conditions
3. **Convert suggestions to testable constraints** — "consider writing tests" → "If a production file exists without a test file, delete the production file and write the test first." (d = −7.84 effect size)
4. **Flip negative rules to positive** — "Do NOT use default exports" → "Use named exports exclusively" (~50% violation reduction)
5. **Add anti-rationalization table** — name the exact rationalizations Claude will use (Meincke et al.: 33% → 72% compliance)
6. **Apply primacy/recency placement** — critical rules in first 5 lines AND last 5 lines of SKILL.md
7. **Add decision flowchart** in DOT notation for branching logic
8. **Isolate subagent context** with `context: fork` — reviewers never see session history
9. **Add circuit breakers** for any autonomous/loop workflow
10. **Keep bootstrap under 2k tokens** — you have a budget of ~150 instructions total before compliance decays linearly

## Hard budget constraints

- **~150 effective instructions** before compliance drops (Jaroslawicz et al., 2025). System prompt uses ~50. You get ~100.
- **SKILL.md under 500 lines / 5,000 words** (Anthropic guidance). Frequently-loaded skills: under 200 words.
- **60% context utilization max** — quality degrades past this. Each MCP server permanently consumes context. Cap at 5–8 servers.
- **CLAUDE.md is advisory at ~80% compliance.** Hooks are deterministic at 100%. If it must happen, use a hook.
