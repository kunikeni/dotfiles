# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):

1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (Playwright)

## Test-Driven Development

MANDATORY workflow:

1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first
- **e2e-runner** - Playwright E2E testing specialist

## Test Framework & Tools

**Framework:**

- pytest (REQUIRED)
- pytest_mock

**Prohibited:**

- unittest
- unittest.mock
- pytest.skip
- Exceptions require explicit user approval with documented reason

**Verification Commands:**

```bash
uv run task test     # Run all tests
uv run task lint     # Check linter rules
uv run task format   # Verify formatting
uv run task mypy     # Run type checking
```

## Test Quality Standards

### Isolation

- Tests must be completely independent
- No shared state between tests
- Setup data in each test as needed
- Teardown/cleanup explicit and automatic

### Naming

- Test names describe exactly what is tested
- Use format: `test_<function>_<scenario>_<expected_outcome>`
- Example: `test_calculate_similarity_with_identical_vectors_returns_one`

### Assertions

- Each test should focus on one logical concept
- Assertions must be specific and meaningful
- Use assertion messages for clarity
- Avoid testing implementation details, test behavior instead

### Mocking

- Mock external dependencies clearly
- Document why mocks are needed
- Keep mock setup focused and minimal
- Verify mock behavior matches real system expectations

### Coverage

- Minimum 80% coverage required
- High-risk code requires 100% coverage:
  - Authentication/Authorization
  - Financial operations
  - Data validation
  - Security-critical paths
