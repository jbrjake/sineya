# Hook Patterns for Plugin Enforcement

Hooks are the only deterministic enforcement mechanism in Claude Code. CLAUDE.md and SKILL.md are advisory at ~80% compliance. Hooks are 100%. Read this when writing hook scripts or needing enforcement that prompts cannot provide.

---

## Critical: The Async Bootstrap Bug

**SessionStart hooks with `"async": true` silently fail.** The bootstrap injection either arrives after Claude has already started responding, or never arrives at all. This is not a race condition — it's a complete silent failure.

Jesse Vincent discovered this in February 2026 with JSON tool call traces. Superpowers was installed, configured, and completely inert. The entire skill system was non-functional because of one config flag.

**Fix:** In your `hooks.json` or `.claude/hooks/` configuration:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "command": "cat /path/to/your/bootstrap.md",
        "async": false
      }
    ]
  }
}
```

If you have ANY async SessionStart hook that injects skill bootstraps, it is silently broken right now. This is not negotiable. Change it.

---

## Hook Types and Their Enforcement Properties

### SessionStart (sync)
**Purpose:** Bootstrap injection, environment setup, state restoration
**Exit codes:** Output is injected into Claude's context. Non-zero skips.
**Use for:** Loading the master skill selector, restoring pipeline state from disk, running stack auto-detection

**Stack auto-detection recipe** (Compound Engineering pattern):
```bash
#!/bin/bash
# Detect project stack and inject relevant rules
if [ -f "package.json" ]; then
  echo "This is a Node.js project."
  if grep -q '"react"' package.json; then echo "React detected. Read references/react-patterns.md for component work."; fi
  if grep -q '"typescript"' package.json; then echo "TypeScript detected. All code must be .ts/.tsx."; fi
fi
if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  echo "This is a Python project."
  if [ -f "pytest.ini" ] || grep -q "pytest" pyproject.toml 2>/dev/null; then echo "Pytest detected. Use pytest for all tests."; fi
fi
```

### PreToolUse
**Purpose:** Intercept and block or modify tool calls BEFORE execution
**Exit codes:**
- Exit 0: allow the tool call
- Exit 1: warn but allow (output shown to Claude as warning)
- Exit 2: **BLOCK the tool call** (deterministic enforcement)
**The #1 practitioner mistake:** Using exit 1 when they mean exit 2. Exit 1 only warns — Claude can ignore it.

**Input:** JSON on stdin with `tool_name` and `tool_input`

**Recipe: Block writes to protected files**
```bash
#!/bin/bash
# Block edits to files that shouldn't be modified by agents
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ]; then
  FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
  case "$FILE" in
    *.lock|*package-lock.json|*.env|*secrets*)
      echo "BLOCKED: Cannot modify $FILE — protected file."
      exit 2
      ;;
  esac
fi
exit 0
```

**Recipe: Enforce architecture boundaries**
```bash
#!/bin/bash
# Block writes that violate module boundaries
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
if [ "$TOOL" = "Write" ] || [ "$TOOL" = "Edit" ]; then
  FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
  # Prevent UI code from importing backend modules
  if [[ "$FILE" == src/ui/* ]]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_str // ""')
    if echo "$CONTENT" | grep -q "from.*src/backend"; then
      echo "BLOCKED: UI modules cannot import from src/backend/. Use the API layer."
      exit 2
    fi
  fi
fi
exit 0
```

**Recipe: Prompt hook for semantic classification** [NEW]
For checks too complex for regex but not worth a full agent, use a single-turn Claude evaluation:

```bash
#!/bin/bash
# Semantic check: does this edit touch authentication logic?
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_str // ""')
  if [ ${#CONTENT} -gt 50 ]; then
    RESULT=$(echo "Does this code change touch authentication, authorization, or session management logic? Answer only YES or NO: $CONTENT" | claude -p --model claude-haiku-4-5-20251001 2>/dev/null)
    if echo "$RESULT" | grep -qi "YES"; then
      echo "WARNING: This edit appears to touch auth logic. Ensure security review."
      exit 1
    fi
  fi
fi
exit 0
```

**PreToolUse input modification** (available since v2.0.10+): Hooks can intercept tool calls, modify the JSON input, and let execution proceed with corrected parameters — invisible to Claude. Use for:
- Automatic secret redaction from file writes
- Path correction (rewriting relative to absolute)
- Transparent sandboxing

### PostToolUse
**Purpose:** Validate results AFTER tool execution, before Claude sees them
**Exit codes:** Same as PreToolUse (0=ok, 1=warn, 2=block)

**Recipe: Auto-run tests after code changes (Builder/Validator pattern)**
```bash
#!/bin/bash
# After any file write in src/, run related tests
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
if [ "$TOOL" = "Write" ] || [ "$TOOL" = "Edit" ]; then
  FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
  if [[ "$FILE" == src/* ]]; then
    # Find corresponding test file
    TEST_FILE=$(echo "$FILE" | sed 's|src/|tests/test_|')
    if [ -f "$TEST_FILE" ]; then
      RESULT=$(python -m pytest "$TEST_FILE" --tb=short 2>&1)
      if [ $? -ne 0 ]; then
        echo "Tests failed after editing $FILE:"
        echo "$RESULT"
        exit 1  # Warn Claude, don't block
      fi
    fi
  fi
fi
exit 0
```

**Recipe: Enforce test existence before completion claim**
```bash
#!/bin/bash
# When Claude tries to create a commit, verify tests exist
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
if [ "$TOOL" = "Bash" ]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
  if echo "$CMD" | grep -q "git commit"; then
    # Check that staged files in src/ have corresponding tests
    STAGED=$(git diff --cached --name-only | grep "^src/")
    for f in $STAGED; do
      TEST=$(echo "$f" | sed 's|src/|tests/test_|')
      if [ ! -f "$TEST" ]; then
        echo "BLOCKED: $f has no corresponding test at $TEST. Write the test first."
        exit 2
      fi
    done
  fi
fi
exit 0
```

---

## Hook Architecture Patterns

### The Layered Enforcement Stack

```
Layer 1: SKILL.md instructions (advisory, ~80%)
  ↓ (for anything that leaks through)
Layer 2: PreToolUse hooks (deterministic blocking, 100%)
  ↓ (for post-hoc validation)
Layer 3: PostToolUse hooks (deterministic verification, 100%)
  ↓ (for session-level invariants)
Layer 4: SessionStart hooks (bootstrap + state restoration)
```

Design enforcement top-down: start with SKILL.md. For any instruction Claude fails to follow >10% of the time in testing, add a corresponding hook.

### The Builder/Validator Pattern [NEW]

Pair two agents: Builder (Claude main session) creates code, Validator (PostToolUse hook) automatically verifies quality. The hook runs a lightweight check after every edit — linting, type checking, test execution. If the validator fails, Claude sees the failure output and self-corrects with external signal (which works, unlike pure self-review).

This "increases compute to increase trust" — you spend more tokens on validation but get dramatically fewer rework cycles.

### Circuit Breaker Hooks [NEW]

For autonomous/loop workflows, implement circuit breakers as hooks:

```bash
#!/bin/bash
# Track consecutive failures. Stop after 3.
COUNTER_FILE="/tmp/claude-failure-count"
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
if [ "$TOOL" = "Bash" ]; then
  EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_output.exit_code // 0')
  if [ "$EXIT_CODE" != "0" ]; then
    COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
    COUNT=$((COUNT + 1))
    echo "$COUNT" > "$COUNTER_FILE"
    if [ "$COUNT" -ge 3 ]; then
      echo "CIRCUIT BREAKER: 3 consecutive failures. Stop and ask the user for help."
      echo "0" > "$COUNTER_FILE"
      exit 1
    fi
  else
    echo "0" > "$COUNTER_FILE"
  fi
fi
exit 0
```

---

## Common Hook Gotchas

1. **async: true on SessionStart** — silently fails. Always use `false`.
2. **Exit 1 vs Exit 2** — 1 warns, 2 blocks. Using 1 when you mean 2 is the most common mistake.
3. **Hook timeout** — long-running hooks (like the semantic classification recipe) can timeout. Keep hooks under 5 seconds. Use Haiku for any LLM-in-hook calls.
4. **jq dependency** — hooks that parse JSON need `jq` installed. Check availability or use Python fallback.
5. **Hook ordering** — multiple hooks on the same event run sequentially. Any exit 2 blocks regardless of others.
6. **Subagent hooks** — hooks apply to the main session. Subagents spawned with `context: fork` run in their own context and may not inherit hooks. Test this explicitly.
