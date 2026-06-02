---
name: code-review
description: evaluator エージェントでコミット前の変更をセキュリティ・品質レビュー。脆弱性と品質問題を検出。
---

# Code Review

Invoke the **evaluator** agent to review uncommitted changes:

1. Run `git diff --name-only HEAD` to get changed files

2. For each changed file, evaluate:

**Security (CRITICAL):**

- Hardcoded credentials, API keys, tokens
- SQL/Command injection vulnerabilities
- XSS vulnerabilities
- Missing input validation
- Path traversal risks
- Authentication/authorization bypasses

**Code Quality (HIGH):**

- Functions > 50 lines
- Files > 800 lines
- Nesting depth > 4 levels
- Missing error handling
- Mutation patterns (should be immutable)
- Missing type hints
- Missing tests for new code

**Performance (MEDIUM):**

- O(n^2) where O(n log n) possible
- N+1 queries
- Unnecessary allocations

3. Generate report with:
   - Severity: CRITICAL, HIGH, MEDIUM
   - File location and line numbers
   - Issue description
   - Specific fix instruction

4. Verdict: PASS / REVISE (same criteria as evaluator agent)

## Related

This command invokes the `evaluator` agent.
Reference skill: `evaluator-criteria`

## Arguments

$ARGUMENTS: Optional scope (e.g. "security only", "performance focus")
