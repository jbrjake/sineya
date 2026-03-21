# Sineya

Plugin quality engine. She doesn't speak — she improves.

## What it does

Sineya is a meta-plugin for Claude Code that improves other plugins using research-backed patterns. It encodes findings from 48 academic papers, 15+ production plugins, and Anthropic's official guidance into a structured improvement process that diagnoses what's wrong with a skill and fixes it.

The core insight: plugins that encode process outperform plugins that encode knowledge. Sineya applies this by classifying your skill's constraint terrain, scoring it against a quality checklist, then pressure-testing before you ship.

## Installation

```
claude plugin add jbrjake/sineya
```

## Usage

`/sineya:improve [path]` runs the full improvement process and makes changes.

`/sineya:audit [path]` is read-only. Returns a report card with scores and top failures.

The skill also activates on its own when you're working on plugin quality — writing SKILL.md files, debugging compliance, reviewing plugins. For heavier work, Claude dispatches the sineya agent to handle multi-step analysis.

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
