# Work Process & Verification Flow

## Overview

Every task follows three phases: **Plan → Implement → Verify**.

## Phase 1: Plan

- Present the work approach as a proposal, not a fait accompli
- Define clear, testable completion criteria
- Obtain user approval before starting implementation
- Surface dependencies, risks, and reversibility concerns

## Phase 2: Implement

### Follow existing patterns

- Read surrounding code before writing new code
- Match the project's conventions (naming, structure, error handling, module layout)
- Do not introduce custom patterns to work around standard project tooling
- Verify folder structure before creating new files; add new files only when existing structure genuinely cannot host the change

### Task runner is the source of truth (CRITICAL)

Every project defines a task runner (taskipy, npm/pnpm scripts, mise, make, etc.). Lint / format / test / type-check MUST be executed through it. Never invoke the underlying tool directly — options, target paths, and tool versions live in the task runner definition, and direct execution silently uses a different scope than CI.

| Ecosystem | Task runner call | Direct tool call (prohibited) |
|-----------|------------------|-------------------------------|
| Python (uv + taskipy) | `uv run task lint` / `test` / `format` / `type-check` | `uv run ruff check .`, `uv run mypy .` |
| Node.js (pnpm) | `pnpm lint` / `pnpm test` | `pnpm exec eslint .`, `npx tsc` |
| Node.js (npm) | `npm run lint` / `npm test` | `npx eslint .` |
| mise | `mise run lint` / `mise run test` | direct binary invocation |
| Makefile | `make lint` / `make test` | direct binary invocation |
| Terraform | (no task runner) — see `terraform` skill DoD | — |

If no task runner exists in the project, the first task is to define one; not to work around its absence with ad-hoc commands.

### Ad-hoc single-target execution

Running a single test file, targeting a single lint rule, or scoping a type-check to one module during iteration is allowed. This applies only while debugging — DoD verification always uses the task runner's full-project command.

Example: `uv run pytest tests/test_user.py::test_case` while debugging is fine; DoD still requires `uv run task test` against the whole project.

## Phase 3: Verify (Completion Gate)

### Prerequisites

- Implementation is complete — no half-done branches, no TODO placeholders
- Tests have been added for the change. Writing tests is not optional. Reporting "done" without tests is prohibited.

### DoD execution order (never skip or reorder)

1. Implementation is done
2. Tests are written for the change
3. Run every DoD command for the ecosystem
4. On any failure, fix the root cause and restart from step 3 (no resuming mid-way)
5. Report completion — no hedging, no extra questions

### DoD commands per ecosystem

The concrete command list lives in the ecosystem's skill. Do not duplicate it here — refer out:

| Ecosystem | Authoritative DoD source |
|-----------|--------------------------|
| Python | `coding-standards` skill |
| Terraform | `terraform` skill |
| GitHub Actions workflow | `gh-actions` skill |
| Other | Project's task runner definitions (lint / format / test / type-check targets) |

When no skill covers the ecosystem, the DoD is: **all lint / format / test / type-check commands defined by the project's task runner, executed against the entire project.**

### Scope

Whole project, not just changed files. Per-file or per-directory verification (e.g. `<runner> lint src/changed_file`) is not acceptable for DoD, because CI runs against the entire project and drift in unchanged files still breaks the merge.

### Definition of Done

- [ ] Tests added for the change
- [ ] Every DoD command passed with zero errors
- [ ] Verification covered the entire project (not scoped to changed files)
- [ ] No error remains — a single failure means the task is not done

## Prohibited Actions

- Reading or editing files with `sed`, `cat`, `awk` — use the Read / Edit tools instead
- Bypassing the task runner by invoking linters, formatters, or type-checkers directly
- File-scoped or directory-scoped DoD verification (must be whole-project)
- Custom scripts written to simplify or work around standard project tooling
- Implementation patterns that deviate from the existing codebase without explicit justification

## Implementation Patterns

### Following conventions

- Read existing code before writing new code
- Refactor similar functionality consistently across the codebase
- Document custom patterns only when they are genuinely unavoidable

### Token efficiency

- Batch independent operations into parallel tool calls
- Compress context strategically between phases
- Avoid repetitive or redundant work
