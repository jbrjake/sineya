#!/bin/bash
# Validate a SKILL.md against plugin-quality-improvement recommendations.
# Usage: ${CLAUDE_PLUGIN_ROOT}/scripts/validate_skill.sh /path/to/skill-directory
#
# Checks structural requirements only — semantic quality requires human review.

SKILL_DIR="${1:-.}"
SKILL_FILE="$SKILL_DIR/SKILL.md"
ERRORS=0
WARNINGS=0

if [ ! -f "$SKILL_FILE" ]; then
  echo "ERROR: No SKILL.md found in $SKILL_DIR"
  exit 1
fi

echo "=== Plugin Quality Validation ==="
echo "Checking: $SKILL_FILE"
echo ""

# Check 1: YAML frontmatter exists
if ! head -1 "$SKILL_FILE" | grep -q "^---"; then
  echo "FAIL: Missing YAML frontmatter (name + description required)"
  ERRORS=$((ERRORS + 1))
else
  # Check for name field
  if ! sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | grep -q "^name:"; then
    echo "FAIL: Missing 'name' in frontmatter"
    ERRORS=$((ERRORS + 1))
  else
    echo "PASS: name field present"
  fi
  # Check for description field
  if ! sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | grep -q "^description:"; then
    echo "FAIL: Missing 'description' in frontmatter"
    ERRORS=$((ERRORS + 1))
  else
    echo "PASS: description field present"
  fi
fi

# Check 2: Line count
LINES=$(wc -l < "$SKILL_FILE")
if [ "$LINES" -gt 500 ]; then
  echo "FAIL: SKILL.md is $LINES lines (max 500 recommended)"
  ERRORS=$((ERRORS + 1))
elif [ "$LINES" -gt 300 ]; then
  echo "WARN: SKILL.md is $LINES lines (consider trimming, 500 max)"
  WARNINGS=$((WARNINGS + 1))
else
  echo "PASS: SKILL.md is $LINES lines"
fi

# Check 3: Word count
WORDS=$(wc -w < "$SKILL_FILE")
if [ "$WORDS" -gt 5000 ]; then
  echo "FAIL: SKILL.md is $WORDS words (max 5000 per Anthropic guidance)"
  ERRORS=$((ERRORS + 1))
else
  echo "PASS: SKILL.md is $WORDS words"
fi

# Check 4: Contains a flowchart
if grep -q "digraph" "$SKILL_FILE"; then
  echo "PASS: Contains Graphviz flowchart"
else
  echo "WARN: No Graphviz flowchart found (recommended for branching logic)"
  WARNINGS=$((WARNINGS + 1))
fi

# Check 5: Has companion references
if [ -d "$SKILL_DIR/references" ]; then
  REF_COUNT=$(find "$SKILL_DIR/references" -name "*.md" | wc -l)
  echo "PASS: references/ directory with $REF_COUNT files"
else
  echo "WARN: No references/ directory (consider progressive disclosure)"
  WARNINGS=$((WARNINGS + 1))
fi

# Check 6: Negative instruction check
NEG_COUNT=$(grep -ciE "(don't|do not|never|avoid|must not)" "$SKILL_FILE" || true)
POS_COUNT=$(grep -ciE "(always|use|prefer|ensure|require)" "$SKILL_FILE" || true)
if [ "$NEG_COUNT" -gt "$POS_COUNT" ] && [ "$NEG_COUNT" -gt 5 ]; then
  echo "WARN: More negative ($NEG_COUNT) than positive ($POS_COUNT) instructions. Consider flipping to positive framing."
  WARNINGS=$((WARNINGS + 1))
else
  echo "PASS: Instruction framing ratio OK (neg=$NEG_COUNT, pos=$POS_COUNT)"
fi

# Check 7: Skill type declaration (look for explicit "Skill type: RIGID/FLEXIBLE" pattern)
if grep -qiE "skill type:.*\b(rigid|flexible)\b" "$SKILL_FILE"; then
  echo "PASS: Skill type declared"
else
  echo "WARN: No skill type declaration (e.g., 'Skill type: RIGID')"
  WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "=== Results ==="
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"

if [ "$ERRORS" -gt 0 ]; then
  echo "STATUS: FAIL — fix errors before shipping"
  exit 1
else
  echo "STATUS: PASS (with $WARNINGS warnings)"
  exit 0
fi
