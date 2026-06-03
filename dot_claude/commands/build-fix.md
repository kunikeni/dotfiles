---
name: build-fix
description: ビルド・型エラーを段階的に修正。エラーを解析し、根本原因を特定し、最小限の修正を適用して検証。
---

# Build and Fix

Invoke the **generator** agent to incrementally fix build errors:

1. Run the project's build/type-check commands (determine from task runner)

2. Parse error output:
   - Group by file
   - Identify root cause vs downstream symptoms

3. For each error (starting from root):
   - Read error context
   - Apply minimal fix
   - Re-run build
   - Verify error resolved
   - If fix introduces new errors, revert and try alternative

4. Stop if:
   - Same error persists after 3 attempts
   - User requests pause

5. Show summary:
   - Errors fixed
   - Errors remaining (if any)

Fix one error at a time. Start from the root cause, not symptoms.

## Related

This command invokes the `generator` agent in build-fix mode.
Reference skill: `evaluator-criteria` (for error diagnosis patterns)

## Arguments

$ARGUMENTS: Optional specific error to focus on
