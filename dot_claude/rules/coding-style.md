# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate:

```python
# WRONG: Mutation
def update_user(user: dict, name: str) -> dict:
    user["name"] = name  # MUTATION!
    return user

# CORRECT: Immutability
def update_user(user: dict, name: str) -> dict:
    return {
        **user,
        "name": name
    }
```

## File Organization

MANY SMALL FILES > FEW LARGE FILES:

- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large components
- Organize by feature/domain, not by type

## Error Handling

ALWAYS handle errors comprehensively:

```python
import logging

try:
    result = risky_operation()
    return result
except Exception as error:
    logging.error(f'Operation failed: {error}')
    raise ValueError('Detailed user-friendly message') from error
```

## Input Validation

ALWAYS validate user input:

```python
from pydantic import BaseModel, EmailStr, field_validator

class UserInput(BaseModel):
    email: EmailStr
    age: int

    @field_validator('age')
    @classmethod
    def age_valid(cls, v: int) -> int:
        if not (0 <= v <= 150):
            raise ValueError('Age must be between 0 and 150')
        return v

validated = UserInput(**input)
```

## Code Quality Checklist

Before marking work complete:

- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No print/logging statements (use logging module)
- [ ] No hardcoded values
- [ ] No mutation (immutable patterns used)
- [ ] Type hints on all functions
- [ ] Pass mypy type checking

## Language Specifications

### Python 3.12+

**Required:**

- Use Python 3.12+ syntax features
- Follow ruff and mypy rules
- Comply with PEP 8 standards
- NO full-width brackets or symbols (RUF003 compliance)

**Syntax Constraints:**

- NO `typing` module (only exception with explicit user approval)
- NO functions defined inside functions
- NO imports inside functions
- ALL imports must be at file top

### Documentation

**Documentation:**

- Write in Japanese

**Code:**

- NO Japanese in code
- Comments for functional logic only
- Implementation rationale belongs in session conversation, not code

## Design Patterns

**Following Conventions:**

- Always follow existing implementation patterns
- Custom implementations are prohibited
- Check folder structure before placing files
- Create new files only if existing structure incompatible

**Code Organization:**

- Organize by feature/domain, not by type (layer)
- One concern per file
- High cohesion, low coupling
- Related code should be colocated
