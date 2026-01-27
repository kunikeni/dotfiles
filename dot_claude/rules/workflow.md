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
- Always use `uv run task <task_name>` format for Python execution
- Follow existing implementation patterns (custom implementations prohibited)

**Code Organization:**

- Verify folder structure before placing new files
- Create new files only if existing structure is incompatible
- Place code following existing patterns and conventions

### Phase 3: Verify (Completion Gate)

Must PASS all 4 checks before marking task complete:

```bash
uv run task test     # Test errors
uv run task lint     # Linter errors
uv run task format   # Formatter errors
uv run task mypy     # Type checker errors
```

**Scope:** All project-wide code is checked, regardless of modification scope

## Prohibited Actions

Never use:

- `sed`, `cat`, `awk` commands for file operations
- Custom scripts to simplify or bypass standard tools
- Implementation patterns that deviate from existing codebase

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
