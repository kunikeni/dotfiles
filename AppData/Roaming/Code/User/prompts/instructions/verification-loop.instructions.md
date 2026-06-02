---
name: verification-loop
description: ビルド、型、リント、テスト、セキュリティ、差分をカバーするClaudeコードセッション用包括的検証システム。
---

# Verification Loop Skill

A comprehensive verification system for Claude Code sessions.

## When to Use

Invoke this skill:

- After completing a feature or significant code change
- Before creating a PR
- When you want to ensure quality gates pass
- After refactoring

## Verification Phases

### Phase 1: Build Verification

```bash
# Check if project builds
npm run build 2>&1 | tail -20
# OR
pnpm build 2>&1 | tail -20
```

If build fails, STOP and fix before continuing.

### Phase 2: Type Check

```bash
# TypeScript projects
npx tsc --noEmit 2>&1 | head -30

# Python projects
pyright . 2>&1 | head -30
```

Report all type errors. Fix critical ones before continuing.

### Phase 3: Lint Check

```bash
# JavaScript/TypeScript
npm run lint 2>&1 | head -30

# Python
ruff check . 2>&1 | head -30
```

Fix style and code quality issues.

### Phase 4: Test Suite

```bash
# Run tests with coverage
npm run test -- --coverage 2>&1 | tail -50

# Check coverage threshold
# Target: 80% minimum
```

Report:

- Total tests: X
- Passed: X
- Failed: X
- Coverage: X%

### Phase 5: Security Scan

```bash
# Check for secrets
grep -rn "sk-" --include="*.ts" --include="*.js" . 2>/dev/null | head -10
grep -rn "api_key" --include="*.ts" --include="*.js" . 2>/dev/null | head -10

# Check for console.log
grep -rn "console.log" --include="*.ts" --include="*.tsx" src/ 2>/dev/null | head -10
```

### Phase 6: Diff Review

```bash
# Show what changed
git diff --stat
git diff HEAD~1 --name-only
```

Review each changed file for:

- Unintended changes
- Missing error handling
- Potential edge cases

## Output Format

After running all phases, produce a verification report:

```
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. Build error in src/utils.ts:45
2. 3 type errors in components/
3. 2 test failures in auth.test.ts
```

## Checklist Before PR

- [ ] All builds pass (npm run build)
- [ ] All type checks pass (no TS errors)
- [ ] All lints pass (code style ok)
- [ ] All tests pass (coverage ≥ 80%)
- [ ] No secrets exposed (API keys, tokens)
- [ ] No debugging code left (console.log, debugger)
- [ ] Diffs reviewed and intentional
- [ ] Git history clean (good commit messages)

## Best Practices

1. **Run verification before committing** - Catch issues early
2. **Fix in order** - Build → Types → Lint → Tests → Security
3. **Read error messages carefully** - They often hint at solutions
4. **Don't skip phases** - Each catches different issues
5. **Use automation** - Set up pre-commit hooks
6. **Track metrics** - Monitor coverage over time
7. **Fix failures immediately** - Don't let them accumulate

## Integration with CI/CD

Ensure your CI/CD runs same checks:

```yaml
# .github/workflows/verify.yml
- name: Build
  run: npm run build

- name: Type Check
  run: npx tsc --noEmit

- name: Lint
  run: npm run lint

- name: Test
  run: npm test -- --coverage

- name: Coverage Check
  run: npx nyc check-coverage --lines 80
```

## Related Skills

- Use `tdd-workflow` for test-driven development
- Use `security-review` for security checklist details
- Use `git-workflow` for commit and PR guidelines


