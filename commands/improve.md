---
name: improve
description: Run the full plugin quality improvement process — classify terrain, score against checklist, fix top failures, pressure test, iterate
argument-hint: "[path to plugin or skill directory]"
---

Determine the target directory: use `$ARGUMENTS` if provided, otherwise use the current working directory.

Read `${CLAUDE_PLUGIN_ROOT}/skills/sineya/SKILL.md` and follow its full improvement process exactly on the target directory.

The process covers:
1. Classify the plugin's constraint terrain (narrow mountain path vs. open field)
2. Score the plugin against the improvement checklist (Tier 1, Tier 2, Tier 3)
3. Fix the highest-impact failures first
4. Pressure test the fixes
5. Iterate until the plugin passes all Tier 1 and critical Tier 2 items

Make changes directly. Report what was fixed and what remains.
