# Sineya

Plugin quality engine. She doesn't speak — she improves.

## What it does

Sineya is a meta-plugin for Claude Code that improves other plugins using research-backed patterns. It encodes findings from 48 academic papers, 15+ production plugins, and Anthropic's official guidance into a structured improvement process that diagnoses what's wrong with a skill and fixes it.

The core insight: plugins that encode process outperform plugins that encode knowledge. Sineya applies this systematically — classifying constraint terrain, scoring against a quality checklist, and pressure-testing before ship.

## Installation

```
claude plugin add jbrjake/sineya
```

## Usage

**Improve a plugin:**
```
/sineya:improve [path]
```
Runs the full improvement process and makes changes.

**Audit a plugin:**
```
/sineya:audit [path]
```
Read-only diagnosis. Returns a report card with scores and top failures.

**Auto-triggering:** Sineya activates automatically when you're working on plugin quality — writing SKILL.md files, debugging compliance, reviewing plugins, or asking why a skill isn't being followed.

**Agent:** For deep improvement work, Claude dispatches the sineya agent automatically to handle multi-step analysis and revision.

## What's inside

Reference documents live in `skills/sineya/references/`:

| File | Purpose |
|------|---------|
| `improvement-checklist.md` | Score your plugin against 20+ quality criteria |
| `anti-patterns.md` | The nine deadly sins of plugin design and how to fix them |
| `architecture-plugin-patterns.md` | Multi-phase pipeline patterns for complex workflows |
| `hook-patterns.md` | Deterministic enforcement recipes (SessionStart, Pre/PostToolUse) |
| `academic-foundations.md` | Research citations backing every recommendation |

## Author

Jon Rubin — [github.com/jbrjake](https://github.com/jbrjake)

## License

MIT
