# Work Process & Verification Flow

## Workflow Overview

All tasks follow a three-phase process: Plan → Implement → Verify

### Phase 1: Plan

- Present work approach proposal
- Define clear completion criteria
- Obtain user approval before implementation starts
- Identify dependencies and potential risks

### Phase 2: Implement

**Tools & Environment:**

- Use Serena's symbolic edit tools for precise edits
- Follow existing implementation patterns (custom implementations prohibited)

**Command Execution Rules (CRITICAL):**

All commands must go through `uv run`. Regardless of the task runner (taskipy, make, etc.), always execute via `uv run`.

```bash
# taskipy
uv run task test
uv run task lint

# Makefile
uv run make test
uv run make lint

# Other task runners follow the same pattern
uv run <runner> <command>
```

**Direct Tool Execution Prohibited (CRITICAL):**

Never invoke linters, formatters, or type checkers directly. Always use the project-defined task runner.

```bash
# Prohibited: direct tool execution
uv run ruff check .
uv run ruff format .
uv run mypy .

# Correct: via task runner
uv run task lint
uv run task format
uv run task type-check
uv run task test
```

**pytest Exception:**

`uv run pytest` is allowed during development for running individual tests (specific files or test functions). However, for DoD (Phase 3: Verify) final verification, always use the task runner (`uv run task test`).

```bash
# During development: allowed (individual test execution)
uv run pytest tests/test_user.py
uv run pytest tests/test_user.py::test_create_user_success -v

# DoD verification: prohibited (must use task runner)
uv run pytest          # NG — use uv run task test for DoD
```

**Reason:** Each project manages tool settings, options, and target scope through its task runner. Direct execution ignores project-specific configuration and causes inconsistent results.

**Code Organization:**

- Verify folder structure before placing new files
- Create new files only if existing structure is incompatible
- Place code following existing patterns and conventions

### Phase 3: Verify (Completion Gate)

**Precondition (CRITICAL):** Confirm all target modifications are complete before running verification. Do not run DoD mid-implementation.

**Test Addition Obligation (CRITICAL):** When code is modified, always create test code that ensures the quality of that modification. No need to ask "should I add tests?" — if there is a modification, write tests. Tests MUST be written BEFORE running DoD. Running DoD without tests is prohibited. Reporting "done" without tests is prohibited.

**DoD Execution Order (CRITICAL — never skip or reorder):**

1. Complete the implementation
2. Write tests covering the implemented behavior
3. Run all DoD commands
4. If any error occurs, fix and restart from step 3
5. Report completion (no hesitation, no extra questions)

**Language-specific DoD Commands:**

| Language | Commands |
|----------|----------|
| All (common) | lint, format, test |
| Python | `uv run task lint` / `uv run task format` / `uv run task type-check` / `uv run task test` |
| Terraform | `terraform fmt -recursive` / `terraform validate` / `tflint --config $(pwd)/.tflint.hcl --recursive` / `terraform plan` |

**DoD Execution Rules (CRITICAL):**

1. Run DoD every time a modification occurs, after all modifications are complete
2. Execute all commands for the relevant language (partial execution is invalid)
3. If any error occurs, fix it and re-run the entire DoD from the beginning (no resuming mid-way)
4. Only results from the commands defined above are accepted as DoD — no other command output qualifies

**Scope (CRITICAL):** Verify the entire project. Not just changed files — all code must pass with zero errors.

**Definition of Done:**

- [ ] Test code has been added for the modification
- [ ] All DoD commands for the relevant language completed with zero errors
- [ ] Verification covers the entire project, not just changed files
- [ ] File-specific or directory-specific verification (e.g. `uv run task lint src/changed_file.py`) is not acceptable — always run against the entire project
- [ ] If any error remains, the task is incomplete

## Prohibited Actions

Never use:

- `sed`, `cat`, `awk` commands for file operations
- Custom scripts to simplify or bypass standard tools
- Implementation patterns that deviate from existing codebase
- Direct execution of linters / formatters / type checkers (`uv run ruff`, `uv run mypy`, etc.)
- Direct `uv run pytest` execution for DoD verification (allowed during development only)
- Command execution without `uv run` (bare `python`, `ruff`, `pytest` invocations)

## Implementation Patterns

### Following Conventions

- Examine existing code patterns before writing new code
- Maintain consistency with established patterns
- Refactor consistently across similar functionality
- Document custom patterns if unavoidable

### Token Efficiency

- Plan operations to minimize unnecessary iterations
- Batch independent operations for parallel execution
- Compress context strategically between phases
- Avoid repetitive or redundant work
