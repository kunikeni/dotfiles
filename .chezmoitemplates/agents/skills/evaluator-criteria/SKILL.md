---
name: evaluator-criteria
description: Evaluator agent's detailed evaluation criteria. DoD commands per language, code quality patterns, security vulnerability examples, build error diagnosis, and verdict thresholds.
---

# Evaluator Criteria

Detailed reference for the Evaluator agent. The agent definition (`evaluator.md`) provides the high-level process and dimensions; this skill provides the concrete checks, examples, and thresholds.

## DoD Commands by Language

Identify the project language from file extensions, task runner config, or CLAUDE.md. Run ALL commands for the matching language. Do not run tools directly (e.g. `ruff check .`); always go through the project's task runner.

### Python

```bash
uv run task lint
uv run task format
uv run task type-check
uv run task test
```

### Terraform

```bash
cd terraform/ && terraform fmt -recursive
tflint --config $(pwd)/.tflint.hcl --recursive
cd env/{target}/ && terraform validate
cd env/{target}/ && terraform plan
```

### TypeScript / JavaScript

```bash
npm run lint        # or pnpm lint
npm run format      # or pnpm format
npm run typecheck   # or pnpm typecheck
npm run test        # or pnpm test
```

### Fallback

If none of the above match, look for:
- `Makefile` targets: `make lint`, `make test`
- `package.json` scripts
- `pyproject.toml` `[tool.taskipy.tasks]`
- Project CLAUDE.md or README for build instructions

---

## Security: Detailed Checks

### Secrets Detection

Grep for patterns that indicate leaked secrets:

```bash
grep -rn "sk-\|api_key\s*=\s*['\"]" --include="*.py" --include="*.ts" --include="*.js" .
grep -rn "password\s*=\s*['\"]" --include="*.py" --include="*.ts" .
grep -rn "AKIA[0-9A-Z]" .  # AWS access keys
```

Any match is CRITICAL unless the value comes from `os.environ`, `process.env`, or a secrets manager.

### SQL Injection

Look for string interpolation in database queries:

```python
# CRITICAL: f-string or .format() in SQL
query = f"SELECT * FROM users WHERE id = '{user_id}'"
query = "SELECT * FROM users WHERE id = '%s'" % user_id

# SAFE: parameterized
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
session.execute(select(User).where(User.id == user_id))
```

### Command Injection

```python
# CRITICAL: user input in shell commands
os.system(f"rm {filename}")
subprocess.run(f"convert {user_input}", shell=True)

# SAFE: list form, no shell
subprocess.run(["convert", validated_input], shell=False)
```

### Path Traversal

```python
# CRITICAL: user input directly in file path
filepath = f"/uploads/{user_provided_name}"
open(request.args["file"])

# SAFE: basename extraction, allowlist
filename = os.path.basename(user_provided_name)
filepath = UPLOAD_DIR / filename
```

### Authentication/Authorization

- Every state-changing endpoint must verify the caller's identity
- Every resource access must verify the caller has permission
- Token storage must use httpOnly cookies (not localStorage)
- Session expiry must be enforced

---

## Code Quality: Detailed Patterns

### Function Length

Count lines between `def`/`function` and the next unindented line. If > 50, flag as HIGH.

Suggested fix: extract logical blocks into named helper functions.

### Mutation Detection

```python
# HIGH: mutating function argument
def process(items: list[str]) -> list[str]:
    items.append("new")  # MUTATION
    return items

# CORRECT: return new object
def process(items: list[str]) -> list[str]:
    return [*items, "new"]
```

Also check for: `dict[key] = value`, `list.append()`, `list.extend()`, `object.attr = value` on arguments or shared state.

### Type Hints

Every function (public and private) must have:
- Parameter type annotations
- Return type annotation

Missing annotations: HIGH if public function, MEDIUM if private.

### Naming

- Variables/functions: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Boolean variables should read as questions: `is_valid`, `has_permission`
- Functions should start with a verb: `get_`, `create_`, `validate_`, `is_`

Flag unclear names (`x`, `tmp`, `data`, `result`) as MEDIUM.

---

## Build Error Diagnosis

When DoD commands fail, diagnose before reporting:

### Type Errors (mypy / tsc)

1. Read the full error output
2. Identify the root declaration that's wrong (not downstream symptoms)
3. Report the root cause file:line with specific fix

Common patterns:
- Missing return type → add annotation
- Incompatible types → check if the source or destination is wrong
- Missing attribute → check import, check if method was renamed

### Lint Errors (ruff / eslint)

1. Group errors by rule
2. If auto-fixable (formatting, import order): just note "run formatter"
3. If logic issue (unused variable, unreachable code): report as code quality issue

### Test Failures

1. Report which test failed and the assertion error
2. Distinguish: is the test wrong, or is the implementation wrong?
3. If implementation: report as Correctness issue with fix instruction
4. If test: report as Test Quality issue (rare — tests written by Generator should be correct)

---

## Test Quality: Detailed Checks

### Tests Must Exist

For every new/modified function:
- At least one test for the happy path
- At least one test for the primary error case

If no tests exist for modified code: automatic REVISE.

### Test Independence

```python
# PROBLEM: tests depend on execution order
class TestUser:
    user_id = None

    def test_create(self):
        self.user_id = create_user()  # shared state

    def test_delete(self):
        delete_user(self.user_id)  # depends on test_create

# CORRECT: each test sets up its own data
def test_delete_user():
    user_id = create_user()  # own setup
    delete_user(user_id)
    assert get_user(user_id) is None
```

### Assertion Quality

```python
# WEAK: only checks no exception
def test_process():
    result = process(data)  # no assertion!

# WEAK: truthy check tells nothing
def test_process():
    assert process(data)

# STRONG: specific assertion
def test_process_returns_transformed_data():
    result = process({"name": "test"})
    assert result["name"] == "TEST"
    assert result["processed_at"] is not None
```

---

## Verdict Decision Table

| DoD commands | CRITICAL issues | HIGH issues | Tests exist | Verdict |
|-------------|----------------|-------------|-------------|---------|
| All pass | None | None | Yes | **PASS** |
| All pass | None | Some | Yes | **REVISE** |
| All pass | Some | Any | Yes | **REVISE** |
| Any fail | Any | Any | Any | **REVISE** |
| All pass | None | None | No | **REVISE** |
| N/A | Design flaw | N/A | N/A | **REDESIGN** |

### REDESIGN triggers

These indicate the plan itself is flawed:

- Chosen abstraction cannot support the requirements
- Architecture violates project patterns at a structural level
- Data model is incorrect at the entity level (not just a missing field)
- Performance issue requires algorithmic redesign (not just optimization)
- The implementation path requires breaking existing public APIs without a migration strategy

Generator cannot fix these. Escalate to Planner with specific explanation of why.

---

## Output Requirements

Every evaluation report must include:

1. **DoD results** — pass/fail per command, with error excerpts if failed
2. **Issues list** — grouped by severity, each with file:line and fix instruction
3. **Verdict** — PASS / REVISE / REDESIGN
4. **Feedback target** — Generator or Planner for each issue
