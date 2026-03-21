# Sineya

Plugin quality engine. She doesn't speak — she improves.

## What it does

Sineya is a meta-plugin for Claude Code that improves other plugins. It tells you why your skill isn't being followed and fixes the reasons.

The problem it solves: Claude can perfectly understand a skill's instructions while systematically not following them. Comprehension and compulsion are not the same thing. Sineya closes that gap using patterns distilled from 48 academic papers (2025-2026), 15+ production plugins, Anthropic's official guidance, and Jesse Vincent's empirical compliance traces from superpowers.

## What it knows about

**Why skills fail.** Your SKILL.md says "always write tests first" and Claude skips it. Why? Because "always write tests first" is a general imperative, not a testable constraint. Sineya would rewrite it as: "If a file in `src/` exists without a corresponding file in `tests/`, delete the source file and create the test file first." That version has a verifiable condition and a concrete action. Claude can rationalize away a principle; it can't rationalize away a bright-line rule.

Jesse Vincent's JSON tool call traces (Feb 2026) showed that advisory language like "you should consider" and "it would be good to" was skipped 100% of the time on a simple todo app. Claude's own analysis of its failure: "Advisory language gets rationalized away. Comprehension and compulsion are not the same thing." That finding shaped everything in this plugin.

**The nine deadly sins.** The Reference Dump (800 lines of knowledge, no workflow). The Polite Request ("you should consider..." — 100% skip rate). The Unclosed Loophole (says "always do X" but doesn't name the twelve ways Claude reasons out of it). The Context Bomb (5,000 tokens before Claude reads the user's message). The Trusted Reviewer (subagent sees conversation history and rubber-stamps). The Freeform Report (prose summaries instead of structured status). The Prompt-Only Enforcer (no hooks, so 80% compliance ceiling). The Self-Reviewing Echo Chamber (self-correction without external signal degrades performance). The Async Bootstrap (SessionStart hook with `"async": true` silently never loads — your plugin is installed, configured, and completely inert).

**Specific numbers.** Testable constraints produce effect size d = -7.84 versus general imperatives. Positive framing ("use named exports exclusively" instead of "do NOT use default exports") cuts violations ~50%. Naming the exact rationalizations Claude will use raises compliance from 33% to 72%. You have a budget of ~150 effective instructions before compliance decays linearly, and your system prompt already uses ~50 of them. The "Mr. Tinkleberry test" reveals your practical instruction window: add "always address me as Mr. Tinkleberry" and see how many turns until Claude stops doing it.

**Constraint terrain.** Not every skill should be written the same way. A narrow-path skill (one correct approach, high stakes) needs rigid language, hard gates, and hook enforcement. An open-field skill (many valid paths) needs the *why* explained. Over-constraining open fields creates friction. Under-constraining narrow paths creates drift. Mismatching terrain to constraint level is the number one design error.

**Positional effects.** Put your most-violated rules in the first 5 lines AND the last 5 lines of your skill. Middle instructions are always weakest — that's the "Lost in the Middle" effect, and it shifts as context fills. At low fill, primacy bias dominates. As the window fills, recency bias takes over. This is measured, not folklore.

**Hook enforcement.** SKILL.md instructions are advisory at ~80% compliance. Hooks are deterministic at 100%. The difference matters. Exit 1 warns but Claude can ignore it. Exit 2 blocks — and most plugin authors use exit 1 when they mean exit 2. Sineya knows the hook recipes for SessionStart bootstrap injection, PreToolUse blocking (protected files, architecture boundaries, semantic classification via Haiku), PostToolUse validation (auto-run tests after edits, enforce test existence before commits), and circuit breakers for autonomous loops.

**Architecture patterns.** How to build plugins with multi-phase pipelines. How to isolate subagent context with `context: fork` so reviewers don't see conversation history and rubber-stamp. Why you need a distrust protocol ("CRITICAL: Do Not Trust the Implementer's Report"). How to restrict subagent tools — OpenDev (March 2026) found sharing all tools caused "context pollution and role confusion." Circuit breakers: after 3 consecutive failures, stop and ask the human.

**The research.** 48 papers, all cited with arxiv IDs. Structured output formats degrade reasoning by up to 40% (EMNLP 2024) — so use structured formats for control flow but freeform prose for reasoning. Multi-agent orchestration hits 100% actionable rate versus 1.7% for single-agent (Drammeh, Nov 2025). Graph-structured agent interactions outperform trees (Puppeteer, May 2025). Naive self-correction can make things worse without external signal (CorrectBench, Oct 2025). The citations are there when you need to justify a design decision to your team.

## Installation

```
claude plugin add jbrjake/sineya
```

## Usage

`/sineya:improve [path]` runs the full improvement process and makes changes. It classifies terrain, scores against the checklist, fixes the top failures, pressure-tests, and iterates.

`/sineya:audit [path]` is read-only. Runs structural validation and scores against every checklist item across three tiers. Returns a report card.

The skill also activates on its own when you're working on plugin quality — writing SKILL.md files, debugging compliance, reviewing plugins. For heavier work, Claude dispatches the sineya agent to handle multi-step analysis.

## What's inside

Reference documents in `skills/sineya/references/`:

| File | What's in it |
|------|-------------|
| `improvement-checklist.md` | 20+ quality criteria across three tiers (critical, high impact, advanced) |
| `anti-patterns.md` | Nine failure modes with symptoms, root causes, and fixes. Pressure testing protocol. Compliance diagnostic tree. |
| `architecture-plugin-patterns.md` | Eight-phase lifecycle state machine. Subagent dispatch patterns. Adversarial review. Anti-rationalization tables. |
| `hook-patterns.md` | SessionStart, PreToolUse, PostToolUse recipes. Builder/validator pattern. Circuit breakers. Common gotchas. |
| `academic-foundations.md` | 48 papers covering instruction compliance, context windows, multi-agent orchestration, self-correction, and meta-prompting. |

## Author

Jon Rubin — [github.com/jbrjake](https://github.com/jbrjake)

## License

MIT
