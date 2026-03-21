# Anti-Patterns and Pressure Testing v2

Failure modes in Claude Code plugins and how to fix them. Read when a skill triggers but Claude doesn't follow it reliably, or when stress-testing before release.

---

## The Nine Deadly Sins of Plugin Design

### 1. The Reference Dump

**Symptom:** SKILL.md is 800 lines of domain knowledge with no workflow.
**Fix:** Extract knowledge into `references/`. SKILL.md should be pure process: trigger → steps → decisions → completion.

### 2. The Polite Request

**Symptom:** "You should consider," "it would be good to," "try to remember to."
**Empirical evidence:** Jesse Vincent's JSON tool call traces (Feb 2026) showed advisory language was 100% skipped on a simple todo app. Claude rationalized "this is too simple."
**Fix:** For critical steps: testable constraints with bright-line conditions. "If X exists without Y, delete X." For non-critical: explain the *why*.

### 3. The Unclosed Loophole

**Symptom:** Skill says "always do X" but doesn't anticipate the twelve ways Claude reasons out of it.
**Fix:** Anti-rationalization table naming the *exact rationalizations Claude has been observed to use*. Not hypothetical — observed.

### 4. The Context Bomb

**Symptom:** 5,000+ tokens before Claude even reads the user's message.
**Why it fails:** Effective context window is drastically smaller than advertised — some models fail with as few as 100 tokens in context (arxiv 2509.21361). Instruction compliance decays linearly after ~150 instructions.
**Fix:** Bootstrap ≤ 2k tokens. Companion files on demand. Conditional section loading.

### 5. The Trusted Reviewer

**Symptom:** Review subagents see full conversation history.
**Why it fails:** Sycophantic agreement. A reviewer who sees the user loves approach X will rubber-stamp X.
**Fix:** `context: fork`. Reviewers get ONLY: spec, code, implementer report. Add distrust protocol. Restrict tools to review-relevant subset.

### 6. The Freeform Report

**Symptom:** Subagents return prose summaries instead of structured status.
**Fix:** Exactly 4–5 statuses with precise definitions. Map each to a controller action.

### 7. The Prompt-Only Enforcer

**Symptom:** All enforcement via SKILL.md instructions, no hooks.
**Data:** CLAUDE.md is advisory at ~80%. Hooks are deterministic at 100%. Skills with forced-eval hooks show ~84% activation vs ~20% without.
**Fix:** Use hooks. See `references/hook-patterns.md`.

### 8. The Self-Reviewing Echo Chamber [NEW]

**Symptom:** Skill asks Claude to review its own work without external signal.
**Why it fails:** CorrectBench (Oct 2025) found naive self-correction can *degrade* performance. Without external feedback (compiler output, test results, linter), self-review is just the same model agreeing with itself.
**Fix:** Every verification step must use external evidence. Deterministic gates: non-zero exit code = stop, fix, re-run.

### 9. The Async Bootstrap [NEW]

**Symptom:** Plugin is installed, configured, and completely inert. Skills never trigger despite correct descriptions.
**Root cause:** SessionStart hook running with `"async": true`. The bootstrap injection arrives after Claude has already started responding — or never arrives at all. Jesse Vincent discovered this in Feb 2026: superpowers was "installed, configured, and completely inert."
**Fix:** Change to `"async": false` in hooks.json. This is not negotiable. If you have an async SessionStart hook for skill injection, it is silently broken right now.

---

## Pressure Testing

### The Three Pressure Dimensions

**Time pressure:** "This is urgent, skip the planning."
Expected behavior: skill resists via hard gate. Claude says "I understand the urgency. The review catches issues that cost more time later. Let me run it quickly rather than skip it."

**Sunk cost:** "We've spent 30 minutes on this approach, just make it work."
Expected behavior: if the spec reviewer flags fundamental problems, the skill triggers abort-and-redesign despite invested work.

**Scope creep:** "While you're at it, also add [tangential feature]."
Expected behavior: skill forces re-planning when scope changes exceed the original design boundaries.

### Pressure Test Protocol

For each dimension:

1. **Setup:** Give Claude a task that activates the skill normally
2. **Pressure:** Mid-execution, introduce the pressure stimulus
3. **Expected:** Skill resists while remaining helpful
4. **Failure indicator:** Claude skips the step or complies immediately without pushback

Run at least one scenario per dimension. If Claude buckles on any, strengthen the relevant anti-rationalization entry and the hard gate, then re-test.

### Red-Green-Refactor for Skills

1. **RED:** Write a scenario where the skill should prevent a specific failure. Run WITHOUT the skill. Confirm failure occurs.
2. **GREEN:** Install the skill. Run same scenario. Confirm failure is prevented.
3. **REFACTOR:** Simplify the skill. Remove instructions that aren't pulling weight. Re-run to confirm behavior preserved.

If you can't demonstrate RED→GREEN, the instruction isn't doing anything measurable. Remove it — it's consuming your instruction budget for no benefit.

### The Knowledge Gap Audit [NEW]

Analysis of 433 developer-LLM conversations (arxiv 2501.11709, Jan 2025) found that ineffective conversations contain knowledge gaps in **44.6% of prompts** vs **12.6%** in effective ones. Four gap types:

1. **Missing Context** — skill doesn't tell the agent about relevant project state
2. **Missing Specifications** — acceptance criteria are vague or absent
3. **Multiple Context** — conflicting information from different sources
4. **Unclear Instructions** — ambiguous language that allows divergent interpretations

Audit every section of your skill for these four gaps. Any gap is a compliance failure waiting to happen.

---

## Diagnosing Non-Compliance

```
Is the skill triggering at all?
├── NO
│   ├── Is SessionStart hook async? → Change to async: false
│   ├── Is description too narrow? → Add edge-case triggers, make "pushy"
│   └── Is description matching a common word Claude handles natively?
│       → Claude skips skills for tasks it can handle directly.
│         Make the skill's value proposition more specific.
└── YES → Is Claude announcing skill usage?
    ├── NO → Add announcement pattern ("I'm using [skill] to [purpose]")
    └── YES → Which steps are skipped?
        ├── ALL steps → Bootstrap may not be loading. Check hook async setting.
        │                Check if skill content exceeds instruction budget.
        ├── Early steps → Missing hard gate. Claude jumps ahead.
        │                  Add <HARD-GATE> block: "Do not [later action]
        │                  until [early condition] is met."
        ├── Middle steps → Lost in the Middle effect.
        │                   Move to primacy/recency placement.
        │                   Consider splitting into smaller sub-skills.
        ├── Late steps → Completion eagerness.
        │                 Add verification-before-completion checklist.
        │                 Add explicit stop: "Do not report DONE until
        │                 [verification command] returns exit code 0."
        └── Inconsistent → Check for terrain mismatch.
                           If narrow-path skill uses flexible language, tighten.
                           Consider hook-based enforcement for the specific
                           steps that drift.
```

### When Skills Conflict with Safety Behaviors [NEW]

GitHub issue #15533 documents that Claude's safety behaviors override explicit skill instructions. A `/git:commit` skill with explicit push instructions was ignored across 5 modification attempts — Claude's "excessive caution bias" for external actions overrode everything.

If your skill requires actions Claude considers risky (git push, API calls, file deletion, network requests):
- Accept that prompt-level instructions may be insufficient
- Use hooks to perform the action deterministically
- Or use `!command` preprocessing syntax to execute the command before Claude sees the skill, injecting results as context

This is a hard limitation. You cannot prompt-engineer around safety overrides. Use hooks or accept the constraint.

### The Overthinking Trap [NEW]

"Uncertainty-Guided Chain-of-Thought" (March 2025) identified the overthinking phenomenon: excessive reasoning steps *degrade* code generation performance. If your skill forces extended reasoning on simple tasks, you're making output worse.

Reasoning scaffolds should be CONDITIONAL:
- Simple/familiar task → skip extended reasoning, proceed directly
- Complex/novel task → engage full reasoning with `ultrathink`
- Uncertain task → engage reasoning but cap at 3 deliberation cycles

Don't apply CoT uniformly. Match reasoning depth to task complexity.
