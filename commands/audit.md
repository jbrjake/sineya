---
name: audit
description: Read-only plugin quality audit — run structural validation and score against the improvement checklist without making changes
argument-hint: "[path to plugin or skill directory]"
---

Determine the target directory: use `$ARGUMENTS` if provided, otherwise use the current working directory.

**Step 1: Structural validation**

Run:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate_skill.sh <target>
```

**Step 2: Checklist scoring**

Read `${CLAUDE_PLUGIN_ROOT}/skills/sineya/references/improvement-checklist.md` and score the target against every item across all tiers (Tier 1, Tier 2, Tier 3).

**Step 3: Report card**

Present findings as a structured report card:
- Validation result (pass / fail with details)
- Tier 1 score (critical — must pass)
- Tier 2 score (important)
- Tier 3 score (polish)
- Top failures by impact
- Recommended next actions

Do not make any changes. Diagnosis only.
