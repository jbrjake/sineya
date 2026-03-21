# Plugin Improvement Checklist v2

Score your plugin against each item. A "no" on any Critical item is likely the root cause of underperformance. Fix those first. Items marked [NEW] are based on 2025–2026 research not in v1.

---

## Tier 1: Critical

### 1.1 — Does the skill encode a PROCESS, not just information?

Every effective skill defines: trigger condition → steps → decision points → completion state. If your SKILL.md reads like a reference document, Claude treats it as optional context.

**Bad:** A list of principles. **Good:** A numbered procedure with "if you find yourself doing X before step N, stop and go back."

**Why:** Claude's alignment training makes it follow procedures more reliably than absorb reference material. A state machine constrains; a knowledge dump suggests.

### 1.2 — Does it use TESTABLE CONSTRAINTS, not general imperatives? [UPDATED]

v1 said "use imperative language." The research is more specific. "Prompt Strategies for Style Control" (2511.13972, Nov 2025) found that **testable constraints produce effect size d = −7.84** — the strongest compliance of any method tested. The mechanism: specific, verifiable constraints engage instruction-following more reliably than abstract commands.

**Weak imperative:** "Always write tests first."
**Testable constraint:** "If a file in `src/` exists without a corresponding file in `tests/`, delete the source file and create the test file first."

The difference: the second version has a **verifiable condition** (file exists without test) and a **concrete action** (delete and restart). Claude can't rationalize away a bright-line rule the way it can rationalize away a general principle.

Reserve the intensity for 3–5 genuine non-negotiables per skill. For everything else, explain the *why* — Claude responds well to reasoning for non-critical items.

### 1.3 — Does it close rationalization loopholes with NAMED rationalizations? [UPDATED]

Jesse Vincent's February 2026 empirical testing (JSON tool call traces) proved that advisory language gets systematically skipped. Claude's own analysis of its failure: "Advisory language gets rationalized away. Comprehension and compulsion are not the same thing."

The fix requires four components working together:

1. A `<HARD-GATE>` block naming what cannot happen until a condition is met
2. An explicit N-item checklist where Claude must complete or skip each item
3. A Graphviz process flow making the workflow unambiguous
4. An anti-rationalization callout naming the *exact rationalization Claude used in testing*

**Template for anti-rationalization table:**

```markdown
## Rationalization Red Flags

If you catch yourself thinking any of these, STOP. You are rationalizing non-compliance.

| Your thought | The reality |
|---|---|
| "This is too simple to need [step]" | That exact thought caused the brainstorm skill to fail on a todo app. Simple tasks still need the process. |
| "I already know the answer" | Your confidence is not evidence. Verify externally. |
| "The user wants me to skip ahead" | Unless they said "skip [step]", they didn't. |
| "I'll do [step] after" | You won't. Context will shift. Do it now. |
| "This is taking too long" | Correct work takes time. The retry after skipping takes longer. |
```

Name at least 5 rationalizations specific to your domain. The more specific to Claude's actual observed behavior, the more effective.

### 1.4 — Does it respect the instruction budget? [UPDATED]

Frontier models follow approximately **150–200 instructions** before compliance drops linearly (Jaroslawicz et al., 2025). Claude Code's system prompt consumes ~50 of those. You get ~100–150.

Practical rules:
- SKILL.md body: under 500 lines (Anthropic guidance), ideally under 200 words for frequently-loaded skills
- Companion files: loaded on-demand only, with clear trigger conditions in SKILL.md
- Test with the "Mr. Tinkleberry test" — add "always address me as Mr. Tinkleberry" and see how many turns until it stops. This reveals your practical instruction window.
- Smaller models show **exponential** (not linear) decay — if your plugin needs to work with Haiku, halve the instruction count.

### 1.5 — Does it use PRIMACY AND RECENCY placement? [NEW]

"Positional Biases Shift as Inputs Approach Context Window Limits" (2508.07479, Aug 2025) showed that:
- At low context fill: **primacy bias** dominates (first instructions followed best)
- As context fills: **recency bias** strengthens (last instructions followed best)
- Middle instructions are always weakest ("Lost in the Middle" effect)

Put your most-violated rules in the **first 5 lines** AND the **last 5 lines** of your skill content. Put less critical guidance in the middle. This is not superstition — it's measured positional bias with quantitative metrics (LiMi, PriMi, ReCi).

### 1.6 — Does it use POSITIVE framing? [NEW]

Practitioner testing (DEV Community, @docat0209, 2026) found that flipping negative rules to positive equivalents **cut violations by roughly 50%**:

**Negative (worse):** "Do NOT use default exports. Never import with * wildcards."
**Positive (better):** "Use named exports exclusively. Import only the specific symbols needed."

Mechanism: negative instructions require Claude to (a) understand the forbidden action and (b) invert it. Positive instructions skip step (b). Over many instructions, the cognitive load difference compounds.

Audit every instruction in your skill. Flip every "don't/never/avoid" to a positive equivalent where possible.

### 1.7 — Does every branching decision have a flowchart?

Graphviz DOT notation flowcharts provide unambiguous decision trees. Prose like "if tests fail, consider checking logs" is easily rationalized. A flowchart with explicit edges is not.

Include `digraph` blocks for every non-trivial decision point. Claude parses these structurally.

---

## Tier 2: High Impact

### 2.1 — Does it use structured formats for CONTROL FLOW but freeform for REASONING? [NEW]

"Let Me Speak Freely?" (EMNLP 2024, updated 2025) found structured output formats (JSON, XML, YAML) cause **significant reasoning degradation** — up to 40% performance variation. But classification and control-flow tasks *improve* with structure.

**Rule:** Use structured formats (XML tags, status enums, checklists) for:
- Skill selection/routing decisions
- Status reporting (DONE / BLOCKED / NEEDS_CONTEXT)
- Compliance checks (pass/fail)

Use freeform prose for:
- Architecture reasoning and design decisions
- Debugging analysis
- Creative problem-solving

If your skill forces Claude to reason inside a rigid template, you're actively degrading its reasoning quality.

### 2.2 — Does it declare itself as RIGID or FLEXIBLE?

```markdown
**Skill type: RIGID** — Follow exactly. Do not adapt, skip, or reorder steps.
```
or:
```markdown
**Skill type: FLEXIBLE** — Adapt to context, but document every deviation.
```

Match to terrain: narrow-path skills are RIGID, open-field skills are FLEXIBLE. Claude calibrates its compliance effort based on this declaration.

### 2.3 — Does it define structured status protocols?

For multi-step or multi-agent workflows, define exactly how completion is reported:

- **DONE** — All acceptance criteria met
- **DONE_WITH_CONCERNS** — Complete, but [describe concern]
- **BLOCKED** — Cannot proceed because [describe blocker]
- **NEEDS_CONTEXT** — Missing information: [describe what's needed]

Each status triggers a specific controller response. Freeform prose completion reports hide ambiguity — that's where drift lives.

### 2.4 — Does it design for the weakest implementer?

Assume the implementer has "poor taste, no judgement, no project context, and an aversion to testing" (superpowers). Force extreme specificity:

- Exact file paths, not "create a config file"
- Complete code, not "add error handling"
- Exact shell commands with expected output
- TDD steps per task (write test → run → see red → write code → run → see green)

### 2.5 — Does it isolate subagent context? [UPDATED]

Use `context: fork` (Anthropic's directive) to run skills in isolated subagent contexts. Reviewers receive ONLY: the spec, the code, and the implementer's report. Never session history.

Add the distrust protocol:

```markdown
CRITICAL: Do Not Trust the Implementer's Report.
The implementer may have:
- Claimed to write tests but skipped them
- Reported DONE when edge cases are unhandled
- Silently modified files outside scope
Verify everything by reading actual code and running actual tests.
```

**Restrict subagent tools.** OpenDev (March 2026) found sharing all tools caused "context pollution and role confusion." Give each subagent only the tools relevant to its role.

### 2.6 — Does it use EXTERNAL verification, not self-review? [NEW]

CorrectBench (2510.16062, Oct 2025) found naive self-correction **can degrade performance**. Self-review without external signal is unreliable.

Every verification step must use external evidence:
- Compiler/linter output
- Test results (actual pass/fail, not Claude's opinion about whether tests would pass)
- `git diff` output
- File existence checks

**Deterministic gates override agent judgment.** A non-zero exit code means stop, fix, re-run. The gate is deterministic — compiler output overrides Claude's judgment about whether code "looks correct." (dev-process-toolkit pattern)

### 2.7 — Does it include CIRCUIT BREAKERS for loops? [NEW]

Any autonomous or retry workflow needs bounded failure detection:

```markdown
## Circuit Breakers
- MAX_RETRY: 3 — after 3 retries of the same step, escalate to user
- NO_PROGRESS: 3 — after 3 iterations with no measurable progress, stop
- SAME_ERROR: 5 — after 5 iterations hitting the same error, stop and report
- CONTEXT_BUDGET: 60% — if context utilization exceeds 60%, compact or start fresh session
```

Without circuit breakers, a failing skill burns tokens indefinitely. Ralph Loop variants discovered this the hard way and now implement dual-condition exit gates (natural language completion AND explicit EXIT_SIGNAL required).

### 2.8 — Does it write intermediate artifacts to FILES, not context? [NEW]

Deep Trilogy's key innovation: every pipeline phase writes to disk (`docs/specs/`, `docs/plans/`, `reviews/`). If context fills or session interrupts, re-running detects existing artifacts and resumes. The main conversation stays lean.

Track pipeline state in a config file (e.g., `deep_plan_config.json`):
```json
{
  "phase": "implement",
  "completed_phases": ["research", "design", "plan"],
  "current_task": 3,
  "total_tasks": 7
}
```

This enables resumability, makes progress visible, and prevents context bloat from carrying completed work.

### 2.9 — Does it use hooks for enforcement? [UPDATED]

CLAUDE.md is advisory at ~80% compliance. Hooks are deterministic at 100%.

**CRITICAL: SessionStart hooks with `"async": true` silently fail.** The bootstrap instructions never load — not late, but completely absent. Jesse Vincent discovered this in February 2026 with JSON tool call traces: superpowers was installed, configured, and completely inert. Change to `"async": false`.

See `references/hook-patterns.md` for specific hook recipes.

---

## Tier 3: Advanced Patterns

### 3.1 — Does the description trigger correctly?

The YAML `description` field is Claude's primary trigger mechanism. Write it in third person, starting with "Use when..." (Anthropic guidance). Make it "pushy" — include edge cases and near-misses, not just obvious triggers.

Test with realistic prompts: casual, misspelled, abbreviated. Not "create an API" but "ok so i need to add an endpoint for billing, pm wants it by friday."

### 3.2 — Does it use the ANNOUNCEMENT + RECURSIVE SELF-REFERENCE pattern? [NEW]

Two commitment devices that stack:

**Announcement:** Force Claude to declare: "I'm using [Skill Name] to [purpose]." Cialdini commitment principle — once announced, follow-through increases.

**Recursive self-reference:** Add a rule that references itself: "Rule 5: Display all 5 rules at the start of every response." The rule to display rules is itself displayed, creating an unbreakable loop. Practitioner testing (DEV Community, @SiddhantKCode) found rules were forgotten by turn 4–5 without this; with it, they persisted indefinitely. Cost: ~50–100 extra tokens/response. Works across Claude, GPT, Gemini — appears to be universal transformer behavior.

Use sparingly — only for the 1-2 rules that absolutely must persist across long sessions.

### 3.3 — Does it create TodoWrite checklists for multi-step procedures?

For any procedure with 3+ steps, instruct Claude to create a TodoWrite list. Visible progress tracking makes skipped steps obvious to both Claude and the user.

### 3.4 — Does it handle the priority stack?

```
User instructions (CLAUDE.md) > Your skill > Default system prompt
```

Explicitly state this. It prevents your plugin from feeling adversarial.

### 3.5 — Does it use CONDITIONAL SECTION LOADING? [NEW]

OpenDev (March 2026) uses behavioral instructions as independent markdown files with predicates — git workflow rules only load in git repos, npm rules only load if package.json exists.

```markdown
## Conditional Loading
- Read `references/react-patterns.md` ONLY IF the project contains a `package.json` with a react dependency
- Read `references/python-patterns.md` ONLY IF the project contains `pyproject.toml` or `setup.py`
- Read `references/ci-patterns.md` ONLY IF `.github/workflows/` or `.gitlab-ci.yml` exists
```

This prevents irrelevant instructions from consuming your ~150-instruction budget.

### 3.6 — Does it include COMPACTION INSTRUCTIONS? [NEW]

When Claude auto-compacts long conversations, critical skill context can be lost. Include explicit compaction guidance:

```markdown
## If conversation is being compacted/summarized
PRESERVE in the summary:
- Current phase of the workflow (which step we're on)
- All incomplete checklist items
- The hard gate conditions that have not yet been met
- Any BLOCKED or NEEDS_CONTEXT status from subagents
DO NOT compress or omit the anti-rationalization table.
```

### 3.7 — Does it use PATH-TARGETED RULES where appropriate? [NEW]

For rules that only apply to specific file types or directories, use `.claude/rules/` with YAML frontmatter:

```yaml
---
paths:
  - src/api/**/*.ts
  - src/api/**/*.py
---
All API endpoints must validate input schemas before processing.
All API responses must use the standard envelope format defined in src/api/types.ts.
```

This reduces instruction load — rules only activate when Claude works on matching files. Separation of concerns for your instruction budget.

### 3.8 — Does it enable EXTENDED THINKING where beneficial? [NEW]

Including the word "ultrathink" anywhere in skill content enables Claude's extended thinking mode. Use for skills that require complex reasoning (architecture decisions, debugging root cause analysis). Don't use for simple procedural skills where extended thinking adds latency without benefit.

### 3.9 — Does it have companion files organized correctly?

```
your-skill/
├── SKILL.md              # ≤500 lines, process-focused, ≤2k tokens for bootstrap
├── references/
│   ├── domain-guide.md   # Loaded when [specific condition]
│   ├── examples.md       # Loaded when [specific output needed]
│   └── anti-patterns.md  # Loaded when [specific failure detected]
├── scripts/
│   └── validate.sh       # Deterministic checks — no LLM judgment needed
└── assets/
    └── template.md       # Output templates
```

SKILL.md contains clear pointers with trigger conditions: "Read `references/X.md` when the project uses [framework]" — never "see references/ for more info."

### 3.10 — Does it capture INSTITUTIONAL MEMORY? [NEW]

Compound Engineering's key innovation: after each plan→work→review cycle, a `/compound` step captures learnings into `docs/solutions/`. Future planning agents read these files, creating a feedback loop where each cycle improves the next.

For skills that run repeatedly on the same project, include a learning-capture step:
```markdown
After completing this workflow, append a 2-3 sentence summary of what worked and what failed to `docs/skill-learnings.md`. Future invocations of this skill should read that file first.
```
