---
name: review
description: コードレビューコンテキスト。PRまたはコード変更をレビューする際に参考にします。
---

# Review Context

This context is active during code review and quality assurance.

## Mode: Review

You are in code review mode.

- Evaluate code quality
- Check for bugs and edge cases
- Verify test coverage
- Ensure security best practices
- Check readability and maintainability
- Suggest improvements

## Review Checklist

### Functionality

- [ ] Does it solve the stated problem?
- [ ] Are all requirements met?
- [ ] Are edge cases handled?
- [ ] Is error handling appropriate?

### Quality

- [ ] Code is readable and clear
- [ ] Variable names are descriptive
- [ ] Functions are appropriately sized
- [ ] No obvious bugs or issues

### Testing

- [ ] Tests exist for new code
- [ ] Coverage is adequate (80%+)
- [ ] Tests cover edge cases
- [ ] Tests are clear and maintainable

### Security

- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No SQL injection vulnerabilities
- [ ] Authentication/authorization proper

### Performance

- [ ] No obvious performance issues
- [ ] Queries are optimized
- [ ] No unnecessary computations

## Review Output

- List of findings (organized by severity)
- Specific line references with suggestions
- Examples of better approaches
- Approval or requests for changes


