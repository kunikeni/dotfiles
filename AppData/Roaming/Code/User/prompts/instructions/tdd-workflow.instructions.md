---
name: tdd-workflow
description: すべての機能開発のためのカバレッジ要件、テストタイプ、TDDプロセスを備えたテスト駆動開発ワークフロー。
---

# Test-Driven Development Workflow

This skill ensures all code development follows TDD principles with comprehensive test coverage.

## When to Activate

- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints
- Creating new components

## Core Principles

### 1. Tests BEFORE Code

ALWAYS write tests first, then implement code to make tests pass.

### 2. Coverage Requirements

- Minimum 80% coverage (unit + integration + E2E)
- All edge cases covered
- Error scenarios tested
- Boundary conditions verified

### 3. Test Types

#### Unit Tests

- Individual functions and utilities
- Component logic
- Pure functions
- Helpers and utilities

#### Integration Tests

- API endpoints
- Database operations
- Service interactions
- External API calls

#### E2E Tests (Playwright)

- Critical user flows
- Complete workflows
- Browser automation
- UI interactions

## TDD Workflow Steps

### Step 1: Write User Journeys

```
As a [role], I want to [action], so that [benefit]

Example:
As a user, I want to search for markets semantically,
so that I can find relevant markets even without exact keywords.
```

### Step 2: Generate Test Cases

For each user journey, create comprehensive test cases:

```typescript
describe('Semantic Search', () => {
  it('returns relevant markets for query', async () => {
    // Test implementation
  })

  it('handles empty query gracefully', async () => {
    // Test edge case
  })

  it('falls back to substring search when Redis unavailable', async () => {
    // Test fallback behavior
  })

  it('sorts results by similarity score', async () => {
    // Test sorting logic
  })
})
```

### Step 3: Run Tests (They Should Fail)

```bash
npm test
# Tests should fail - we haven't implemented yet
```

### Step 4: Implement Code

Write minimal code to make tests pass:

```typescript
// Implementation guided by tests
export async function searchMarkets(query: string) {
  // Implementation here
}
```

### Step 5: Run Tests Again

```bash
npm test
# All tests should pass now
```

### Step 6: Refactor (Safely)

With passing tests as a safety net, refactor for clarity:

```typescript
// Refactored while tests ensure correctness
export async function searchMarkets(query: string) {
  const normalized = query.toLowerCase().trim()

  if (!normalized) {
    return []
  }

  try {
    return await semanticSearch(normalized)
  } catch {
    return substrSearch(normalized)
  }
}
```

### Step 7: Check Coverage

```bash
npm test -- --coverage
# Target: 80%+ coverage
```

## Test Structure

### Unit Test Template

```typescript
describe('calculateTotal', () => {
  it('sums items correctly', () => {
    const items = [10, 20, 30]
    expect(calculateTotal(items)).toBe(60)
  })

  it('handles empty array', () => {
    expect(calculateTotal([])).toBe(0)
  })

  it('handles negative values', () => {
    const items = [10, -5, 20]
    expect(calculateTotal(items)).toBe(25)
  })
})
```

### Integration Test Template

```typescript
describe('User API', () => {
  it('creates new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Test User' })

    expect(response.status).toBe(201)
    expect(response.body.id).toBeDefined()
  })

  it('returns 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid', name: 'Test User' })

    expect(response.status).toBe(400)
  })
})
```

### E2E Test Template (Playwright)

```typescript
test('user can search and view results', async ({ page }) => {
  await page.goto('http://localhost:3000')

  // User searches
  await page.fill('input[placeholder="Search"]', 'typescript')
  await page.click('button:has-text("Search")')

  // Results appear
  await page.waitForSelector('[data-testid="result-item"]')
  const results = await page.locator('[data-testid="result-item"]').count()
  expect(results).toBeGreaterThan(0)
})
```

## Coverage Targets

- **Critical paths**: 100% coverage
- **Happy paths**: 90%+ coverage
- **Edge cases**: 80%+ coverage
- **Overall target**: 80% minimum

## Best Practices

1. **Write tests first** - Define behavior before implementation
2. **Keep tests focused** - One assertion per test when possible
3. **Use descriptive names** - Test names describe what's being tested
4. **Test behavior, not implementation** - Focus on inputs/outputs
5. **Isolate tests** - Each test should be independent
6. **Mock external dependencies** - Don't hit real APIs/databases in tests
7. **Test error scenarios** - Don't just test the happy path
8. **Keep tests fast** - Unit tests should run in milliseconds

## Continuous Integration

Enforce TDD in CI/CD:

```yaml
# .github/workflows/ci.yml
- name: Run Tests
  run: npm test -- --coverage

- name: Check Coverage
  run: npx nyc check-coverage --lines 80 --functions 80
```

## Related Skills

- Use `verification-loop` to check coverage before PR
- Use `security-review` for security-focused tests
- Use `eval-harness` for evaluation-driven testing


