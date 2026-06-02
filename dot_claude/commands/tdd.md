---
name: tdd
description: generator エージェントで TDD ワークフローを実行。テストを先に書き、最小限の実装で合格させ、リファクタリング。80%+ カバレッジを確保。
---

# TDD Command

This command invokes the **generator** agent to implement a feature using strict TDD methodology.

## What This Command Does

1. **Scaffold Interfaces** - Define types/interfaces first
2. **Generate Tests First** - Write failing tests (RED)
3. **Implement Minimal Code** - Write just enough to pass (GREEN)
4. **Refactor** - Improve code while keeping tests green (REFACTOR)
5. **Verify Coverage** - Ensure 80%+ test coverage

## When to Use

Use `/tdd` when:

- Implementing new features
- Adding new functions/components
- Fixing bugs (write test that reproduces bug first)
- Refactoring existing code
- Building critical business logic

## How It Works

The generator agent will:

1. Read existing code to understand patterns
2. Write tests that will FAIL (because code doesn't exist yet)
3. Run tests and verify they fail for the right reason
4. Write minimal implementation to make tests pass
5. Run tests and verify they pass
6. Refactor code while keeping tests green
7. Check coverage and add more tests if below 80%

## TDD Cycle

```
RED -> GREEN -> REFACTOR -> REPEAT
```

## Test Standards

- pytest only (no unittest)
- Test name format: `test_<function>_<scenario>_<expected>`
- Each test is independent (no shared state)
- Mock external dependencies only
- Target 80%+ coverage (100% for critical code)

## Coverage Requirements

- **80% minimum** for all code
- **100% required** for:
  - Financial calculations
  - Authentication logic
  - Security-critical code
  - Core business logic

## Integration with Other Commands

- Use `/plan` first to understand what to build
- Use `/tdd` to implement with tests
- Use `/orchestrate` for full pipeline (plan + implement + review)

## Related

This command invokes the `generator` agent with TDD-focused instructions.
Reference skill: `tdd-workflow`

## Arguments

$ARGUMENTS: Description of what to implement using TDD
