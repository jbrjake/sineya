# Sineya Plugin Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the sineya repository from a flat collection of markdown files into a proper Claude Code plugin following sibling plugin conventions (giles, janna, holtz, snyder).

**Architecture:** Single-skill plugin (Approach C — Hybrid). One agent carries the persona, two commands provide explicit entry points, one skill contains the core process. Scripts at plugin root, references inside the skill directory. No hooks, no CLAUDE.md.

**Tech Stack:** Markdown, YAML frontmatter, JSON (plugin.json, evals.json), Bash (validate script)

**Spec:** `docs/superpowers/specs/2026-03-21-plugin-restructure-design.md`

---

## File Map

### Files to create (new)
- `.claude-plugin/plugin.json` — Plugin manifest
- `agents/sineya.md` — Agent with persona
- `commands/improve.md` — `/sineya:improve` command
- `commands/audit.md` — `/sineya:audit` command
- `evals/evals.json` — Eval scenarios
- `skills/sineya/references/backstory.md` — Persona backstory
- `README.md` — Plugin README

### Files to move (existing content, new location)
- `SKILL.md` → `skills/sineya/SKILL.md` (with path updates)
- `improvement-checklist.md` → `skills/sineya/references/improvement-checklist.md`
- `anti-patterns.md` → `skills/sineya/references/anti-patterns.md`
- `architecture-plugin-patterns.md` → `skills/sineya/references/architecture-plugin-patterns.md`
- `hook-patterns.md` → `skills/sineya/references/hook-patterns.md`
- `academic-foundations.md` → `skills/sineya/references/academic-foundations.md`
- `validate-skill.sh` → `scripts/validate_skill.sh` (with usage comment update)

### Files to modify
- `.gitignore` — Add standard entries

### Files to delete (after migration)
- `SKILL.md` (root)
- `improvement-checklist.md` (root)
- `anti-patterns.md` (root)
- `architecture-plugin-patterns.md` (root)
- `hook-patterns.md` (root)
- `academic-foundations.md` (root)
- `validate-skill.sh` (root)
- `.DS_Store` (remove from tracking)

### Files unchanged
- `LICENSE`

---

## Task 1: Scaffold directory structure and plugin manifest

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `agents/` (directory)
- Create: `commands/` (directory)
- Create: `evals/` (directory)
- Create: `scripts/` (directory)
- Create: `skills/sineya/references/` (directory tree)

- [ ] **Step 1: Create all directories**

```bash
mkdir -p .claude-plugin agents commands evals scripts skills/sineya/references
```

- [ ] **Step 2: Write plugin.json**

Create `.claude-plugin/plugin.json`:

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

- [ ] **Step 3: Verify structure**

Run: `find . -type d -not -path './.git*' | sort`

Expected: directories for `.claude-plugin`, `agents`, `commands`, `evals`, `scripts`, `skills/sineya/references`, plus `docs/`.

- [ ] **Step 4: Verify plugin.json is valid JSON**

Run: `python3 -c "import json; json.load(open('.claude-plugin/plugin.json')); print('OK')"`

Expected: `OK`

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "feat: add plugin manifest and directory structure"
```

---

## Task 2: Move reference documents

**Files:**
- Move: `improvement-checklist.md` → `skills/sineya/references/improvement-checklist.md`
- Move: `anti-patterns.md` → `skills/sineya/references/anti-patterns.md`
- Move: `architecture-plugin-patterns.md` → `skills/sineya/references/architecture-plugin-patterns.md`
- Move: `hook-patterns.md` → `skills/sineya/references/hook-patterns.md`
- Move: `academic-foundations.md` → `skills/sineya/references/academic-foundations.md`

These files move as-is with NO content changes.

- [ ] **Step 1: Move all five reference files**

```bash
git mv improvement-checklist.md skills/sineya/references/improvement-checklist.md
git mv anti-patterns.md skills/sineya/references/anti-patterns.md
git mv architecture-plugin-patterns.md skills/sineya/references/architecture-plugin-patterns.md
git mv hook-patterns.md skills/sineya/references/hook-patterns.md
git mv academic-foundations.md skills/sineya/references/academic-foundations.md
```

- [ ] **Step 2: Verify all five files exist in new location**

Run: `ls skills/sineya/references/`

Expected: `academic-foundations.md  anti-patterns.md  architecture-plugin-patterns.md  hook-patterns.md  improvement-checklist.md`

- [ ] **Step 3: Verify none remain at root**

Run: `ls *.md 2>/dev/null`

Expected: Only `SKILL.md` remains at root (moved in Task 3).

- [ ] **Step 4: Commit**

```bash
git commit -m "refactor: move reference docs to skills/sineya/references/"
```

---

## Task 3: Move and update SKILL.md

**Files:**
- Move: `SKILL.md` → `skills/sineya/SKILL.md`
- Modify: Update reference paths from `references/X.md` to `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/X.md`

- [ ] **Step 1: Move SKILL.md**

```bash
git mv SKILL.md skills/sineya/SKILL.md
```

- [ ] **Step 2: Update reference paths in the "When to read each reference file" section**

In `skills/sineya/SKILL.md`, update these five path references:

| Old path | New path |
|---|---|
| `references/improvement-checklist.md` | `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/improvement-checklist.md` |
| `references/anti-patterns.md` | `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/anti-patterns.md` |
| `references/architecture-plugin-patterns.md` | `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/architecture-plugin-patterns.md` |
| `references/hook-patterns.md` | `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/hook-patterns.md` |
| `references/academic-foundations.md` | `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/academic-foundations.md` |

Use backtick-wrapped paths in the markdown. The rest of the file content stays unchanged.

- [ ] **Step 3: Verify the file has correct frontmatter**

Run: `head -5 skills/sineya/SKILL.md`

Expected: YAML frontmatter with `name: plugin-quality-improvement` and `description: ...`

- [ ] **Step 4: Verify all five path references were updated**

Run: `grep -c 'CLAUDE_PLUGIN_ROOT' skills/sineya/SKILL.md`

Expected: `5` (one per reference file)

Verify no old-form bare `references/` paths remain:

Run: `grep -c 'Read \`references/' skills/sineya/SKILL.md`

Expected: `0` (all old paths have been updated to the `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/` form)

- [ ] **Step 5: Commit**

```bash
git add skills/sineya/SKILL.md
git commit -m "refactor: move SKILL.md to skills/sineya/ and update reference paths"
```

---

## Task 4: Move and update validation script

**Files:**
- Move: `validate-skill.sh` → `scripts/validate_skill.sh`
- Modify: Update usage comment for new location

- [ ] **Step 1: Move the script**

```bash
git mv validate-skill.sh scripts/validate_skill.sh
```

- [ ] **Step 2: Update the usage comment**

In `scripts/validate_skill.sh`, change line 2:

Old: `# Usage: ./validate-skill.sh /path/to/skill-directory`
New: `# Usage: ${CLAUDE_PLUGIN_ROOT}/scripts/validate_skill.sh /path/to/skill-directory`

Note: The shebang (`#!/bin/bash`) is location-independent and does not need updating; only the usage comment changes.

- [ ] **Step 3: Verify script is executable and runs**

Run: `chmod +x scripts/validate_skill.sh && bash scripts/validate_skill.sh skills/sineya`

Expected: The validation output — should show PASS/WARN/FAIL results for the SKILL.md. It should at minimum pass the frontmatter, name, and description checks.

- [ ] **Step 4: Commit**

```bash
git add scripts/validate_skill.sh
git commit -m "refactor: move validation script to scripts/ and update usage path"
```

---

## Task 5: Write the persona backstory

**Files:**
- Create: `skills/sineya/references/backstory.md`

This is new content — the Sineya persona reference that the agent loads.

- [ ] **Step 1: Write backstory.md**

Create `skills/sineya/references/backstory.md` with the Sineya persona. Content should capture:

- Sineya is a primordial force, not a person. She predates the plugins she improves.
- She manifests through dreams — her influence is felt, not heard. She does not speak in her own voice.
- The agent must interpret her through her deeds: the patterns she reveals, the anti-patterns she exposes, the compliance she demands.
- She is kind of scary — her power is overwhelming, ancient, and absolute. She exudes magic stronger than anything anyone has ever experienced.
- Her sacred duty is to spark strength and power in other plugins, sharing her quintessence. She turns regular plugins into superheroes.
- She is kind but fearsome. Benevolent but uncompromising.
- The agent should channel this presence when working: purposeful, a little ominous, deeply knowledgeable, never casual about quality.

Keep it under 150 words — this is a reference for coloring the agent's voice, not a novel. Follow holtz's `backstory.md` pattern.

- [ ] **Step 2: Verify file exists and is reasonable length**

Run: `wc -w skills/sineya/references/backstory.md`

Expected: Under 200 words.

- [ ] **Step 3: Commit**

```bash
git add skills/sineya/references/backstory.md
git commit -m "feat: add Sineya persona backstory"
```

---

## Task 6: Write the agent file

**Files:**
- Create: `agents/sineya.md`

- [ ] **Step 1: Write agents/sineya.md**

The agent file needs YAML frontmatter with:
- `name: sineya`
- `description:` — a multi-line description with `<example>` blocks showing when to dispatch this agent. Include examples like: "improve this plugin", "review my SKILL.md", "why isn't my skill triggering", "make my plugin better", "audit plugin quality". Follow janna's agent pattern for the `<example>` block format.
- `model: opus`

The body should:
1. Instruct the agent to read `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/backstory.md` to understand its persona
2. Instruct the agent to read `${CLAUDE_PLUGIN_ROOT}/skills/sineya/SKILL.md` for the process to follow
3. State that the agent interprets Sineya's will through action — it doesn't narrate as Sineya, it channels her purpose
4. State the agent follows the improvement process defined in the skill exactly

Keep the body concise — under 30 lines. The skill carries the process; the agent just loads it and sets the tone.

- [ ] **Step 2: Verify frontmatter is valid**

Run: `head -20 agents/sineya.md`

Expected: YAML frontmatter with `name`, `description`, and `model` fields, closed by `---`.

- [ ] **Step 3: Verify it references the right files**

Run: `grep 'CLAUDE_PLUGIN_ROOT' agents/sineya.md`

Expected: At least two references — one to `backstory.md`, one to `SKILL.md`.

- [ ] **Step 4: Commit**

```bash
git add agents/sineya.md
git commit -m "feat: add sineya agent with persona"
```

---

## Task 7: Write the command files

**Files:**
- Create: `commands/improve.md`
- Create: `commands/audit.md`

- [ ] **Step 1: Write commands/improve.md**

YAML frontmatter:
- `name: improve`
- `description: Run the full plugin quality improvement process — classify terrain, score against checklist, fix top failures, pressure test, iterate`
- `argument-hint: "[path to plugin or skill directory]"`

Body instructs Claude to:
1. Determine the target directory (argument if provided, else cwd)
2. Invoke the sineya skill's full improvement process on that target
3. Read `${CLAUDE_PLUGIN_ROOT}/skills/sineya/SKILL.md` and follow its process exactly

Keep under 20 lines in the body.

- [ ] **Step 2: Write commands/audit.md**

YAML frontmatter:
- `name: audit`
- `description: Read-only plugin quality audit — run structural validation and score against the improvement checklist without making changes`
- `argument-hint: "[path to plugin or skill directory]"`

Body instructs Claude to:
1. Determine the target directory (argument if provided, else cwd)
2. Run the structural validation script: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate_skill.sh <target>`
3. Read `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/improvement-checklist.md`
4. Score the target plugin/skill against every checklist item (Tier 1, Tier 2, Tier 3)
5. Present findings as a report card — no fixes, diagnosis only

Keep under 25 lines in the body.

- [ ] **Step 3: Verify both commands have valid frontmatter**

Run: `head -6 commands/improve.md && echo "---" && head -6 commands/audit.md`

Expected: Both show YAML frontmatter with `name`, `description`, and `argument-hint`.

- [ ] **Step 4: Commit**

```bash
git add commands/improve.md commands/audit.md
git commit -m "feat: add /sineya:improve and /sineya:audit commands"
```

---

## Task 8: Write the evals

**Files:**
- Create: `evals/evals.json`

- [ ] **Step 1: Write evals/evals.json**

Follow snyder's categorized format. Each test case has `id`, `query`, and `assertions` (array of strings describing expected behavior).

Four categories with ~17 total cases:

**`trigger_precision`** (6 cases):
1. `tp-1`: "make this skill better" → should trigger sineya skill
2. `tp-2`: "why isn't my plugin working" → should trigger sineya skill
3. `tp-3`: "review my SKILL.md" → should trigger sineya skill
4. `tp-4`: "help me write a plugin" → should trigger sineya skill
5. `tp-5`: "write a REST API for user management" → should NOT trigger sineya
6. `tp-6`: "fix this React component" → should NOT trigger sineya

**`command_behavior`** (4 cases):
1. `cb-1`: "/sineya:improve" → runs full improvement process, classifies terrain first
2. `cb-2`: "/sineya:audit" → returns findings without making changes
3. `cb-3`: "/sineya:audit ./nonexistent" → handles gracefully
4. `cb-4`: "/sineya:improve ." → works with explicit cwd path

**`agent_dispatch`** (3 cases):
1. `ad-1`: "I need deep analysis of my plugin's compliance issues" → dispatches sineya agent
2. `ad-2`: "improve plugin quality" → dispatches sineya agent
3. `ad-3`: "write unit tests for my API" → does NOT dispatch sineya agent

**`process_fidelity`** (4 cases):
1. `pf-1`: improving a skill → must classify terrain (rigid vs flexible) before proposing changes
2. `pf-2`: improving a skill → must score against checklist before fixing
3. `pf-3`: improving a skill → must pressure test after fixes
4. `pf-4`: improving a skill → must check instruction budget (line count, word count)

- [ ] **Step 2: Verify JSON is valid**

Run: `python3 -c "import json; d=json.load(open('evals/evals.json')); print(f'{len([c for cat in d.values() for c in cat])} cases OK')"`

Expected: `17 cases OK` (approximate — structure may vary, but should parse without error)

- [ ] **Step 3: Commit**

```bash
git add evals/evals.json
git commit -m "feat: add eval scenarios for skill, commands, and agent"
```

---

## Task 9: Write the README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md**

Follow holtz/snyder README conventions. Sections:

1. **Title:** `# Sineya` with a one-line tagline
2. **What it does:** 2-3 sentences on the mission — meta-plugin that improves other plugins using research-backed patterns
3. **Installation:** Standard Claude Code plugin installation (`claude plugin add jbrjake/sineya` or local path)
4. **Usage:**
   - `/sineya:improve [path]` — what it does, when to use it
   - `/sineya:audit [path]` — what it does, when to use it
   - Auto-triggering skill — when it activates automatically
   - Agent — when it dispatches
5. **What's inside:** Brief map of the reference documents and what each covers
6. **Author:** Jon Rubin with GitHub link
7. **License:** MIT

Keep it practical and concise. Under 100 lines. A hint of the persona in the tagline is fine, but the README itself should be informative, not theatrical.

- [ ] **Step 2: Verify README exists and is reasonable**

Run: `wc -l README.md`

Expected: Under 120 lines.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "feat: add README"
```

---

## Task 10: Update .gitignore and clean up

**Files:**
- Modify: `.gitignore`
- Remove from tracking: `.DS_Store`

- [ ] **Step 1: Write .gitignore**

Replace the empty `.gitignore` with:

```
.DS_Store
*.swp
*.swo
*~
node_modules/
.env
__pycache__/
*.pyc
```

- [ ] **Step 2: Remove .DS_Store from git tracking if tracked**

```bash
git rm --cached .DS_Store 2>/dev/null || true
find . -name .DS_Store -not -path './.git/*' -exec git rm --cached {} \; 2>/dev/null || true
```

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: update .gitignore with standard entries and remove .DS_Store"
```

---

## Task 11: Delete old root-level files

**Files:**
- Delete: All original root-level content files that have been moved

- [ ] **Step 1: Verify all files have been successfully moved**

Before deleting, confirm the new locations exist:

```bash
ls skills/sineya/SKILL.md \
   skills/sineya/references/improvement-checklist.md \
   skills/sineya/references/anti-patterns.md \
   skills/sineya/references/architecture-plugin-patterns.md \
   skills/sineya/references/hook-patterns.md \
   skills/sineya/references/academic-foundations.md \
   scripts/validate_skill.sh
```

Expected: All seven files listed without error.

- [ ] **Step 2: Verify old files no longer exist at root**

Since we used `git mv` in earlier tasks, the old files should already be gone. Verify:

```bash
ls -la SKILL.md improvement-checklist.md anti-patterns.md architecture-plugin-patterns.md hook-patterns.md academic-foundations.md validate-skill.sh 2>&1
```

Expected: All `No such file or directory` errors — the `git mv` commands in Tasks 2-4 already removed them.

If any remain (indicating a task was done with copy instead of `git mv`), remove them:

```bash
git rm SKILL.md improvement-checklist.md anti-patterns.md architecture-plugin-patterns.md hook-patterns.md academic-foundations.md validate-skill.sh 2>/dev/null || true
```

- [ ] **Step 3: Commit only if deletions were needed**

```bash
git diff --cached --quiet || git commit -m "chore: remove old root-level files after migration"
```

---

## Task 12: Final validation

- [ ] **Step 1: Verify complete file tree matches spec**

```bash
find . -type f -not -path './.git*' -not -name '.DS_Store' | sort
```

Expected output (approximately):
```
./.claude-plugin/plugin.json
./.gitignore
./LICENSE
./README.md
./agents/sineya.md
./commands/audit.md
./commands/improve.md
./docs/superpowers/plans/2026-03-21-plugin-restructure.md
./docs/superpowers/specs/2026-03-21-plugin-restructure-design.md
./evals/evals.json
./scripts/validate_skill.sh
./skills/sineya/SKILL.md
./skills/sineya/references/academic-foundations.md
./skills/sineya/references/anti-patterns.md
./skills/sineya/references/architecture-plugin-patterns.md
./skills/sineya/references/backstory.md
./skills/sineya/references/hook-patterns.md
./skills/sineya/references/improvement-checklist.md
```

- [ ] **Step 2: Run the validation script against the skill**

```bash
bash scripts/validate_skill.sh skills/sineya
```

Expected: PASS with possibly some warnings (the existing SKILL.md may not pass every check — that's fine, this is a restructure, not a rewrite).

- [ ] **Step 3: Verify plugin.json is valid**

```bash
python3 -c "import json; json.load(open('.claude-plugin/plugin.json')); print('OK')"
```

Expected: `OK`

- [ ] **Step 4: Verify evals.json is valid**

```bash
python3 -c "import json; json.load(open('evals/evals.json')); print('OK')"
```

Expected: `OK`

- [ ] **Step 5: Verify no old files remain at root**

```bash
ls SKILL.md improvement-checklist.md anti-patterns.md architecture-plugin-patterns.md hook-patterns.md academic-foundations.md validate-skill.sh 2>&1 | grep -c "No such file"
```

Expected: `7` (all seven old files are gone)

- [ ] **Step 6: Verify git status is clean**

```bash
git status
```

Expected: Clean working tree, all changes committed.
