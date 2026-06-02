---
name: eval-harness
description: グレーダー、メトリクス、継続的テスト機能を備えた評価駆動開発フレームワーク。
---

# Eval Harness - Evaluation-Driven Development

A comprehensive framework for defining, running, and grading evaluations to ensure feature quality.

## Core Concept

Test your features systematically before implementing:

```
1. Define requirements
2. Write evals (test specifications)
3. Run evals (should fail)
4. Implement feature
5. Grade evals (measure success)
6. Iterate based on results
```

## Eval Types

### Capability Evals

Test if a feature works as intended:

```typescript
const capabilityEval = {
  name: "semantic-search-relevance",
  description: "Search returns relevant results for queries",

  cases: [
    {
      input: { query: "typescript hooks" },
      expected: {
        results_count: { min: 3 },
        top_result_relevance: { min: 0.8 }
      }
    },
    {
      input: { query: "react authentication" },
      expected: {
        results_count: { min: 5 },
        top_result_relevance: { min: 0.75 }
      }
    }
  ]
}
```

### Regression Evals

Ensure existing features still work:

```typescript
const regressionEval = {
  name: "basic-crud-operations",
  description: "CRUD operations work after refactor",

  cases: [
    {
      name: "create-user",
      input: { action: "create", user: { name: "John" } },
      expected: { success: true, id: { exists: true } }
    },
    {
      name: "read-user",
      input: { action: "read", id: "123" },
      expected: { success: true, name: "John" }
    },
    {
      name: "update-user",
      input: { action: "update", id: "123", name: "Jane" },
      expected: { success: true, name: "Jane" }
    }
  ]
}
```

## Grader Types

### Code-Based Graders

Deterministic checks on output:

```typescript
const codeGrader = {
  type: "code",

  grade: (output: any, expected: any) => {
    const pass = JSON.stringify(output) === JSON.stringify(expected)
    return {
      pass,
      score: pass ? 1.0 : 0.0,
      details: `Output ${pass ? 'matches' : 'does not match'} expected`
    }
  }
}
```

### Model-Based Graders

Use Claude to evaluate quality:

```typescript
const modelGrader = {
  type: "model",

  prompt: `
    Evaluate if this response correctly implements the requirement.

    Requirement: {requirement}
    Response: {response}

    Score: 0.0-1.0
    Reasoning: Brief explanation
  `,

  scoring: "scale-0-to-1"
}
```

### Human Graders

Manual review for subjective criteria:

```typescript
const humanGrader = {
  type: "human",

  prompt: `
    Does this implementation look correct?

    Requirement: {requirement}
    Implementation: {code}

    Provide:
    - Pass/Fail
    - Score (0-1)
    - Feedback
  `,

  instructions: "Review for code quality and correctness"
}
```

## Metrics

### Pass@K

Percentage of eval cases that pass (K = number of attempts):

```typescript
// pass@1: First attempt succeeds
// pass@3: Succeeds within 3 iterations
// pass@10: Succeeds within 10 iterations

const pass_at_k = (successes: number, k: number) => {
  return successes / k
}
```

### Pass^K (Power K)

Weighted metric favoring early success:

```typescript
// Success on first try: weight 1.0
// Success on second try: weight 0.5
// Success on third try: weight 0.33

const pass_power_k = (results: boolean[]) => {
  return results.reduce((sum, success, i) => {
    return sum + (success ? 1 / (i + 1) : 0)
  }, 0)
}
```

## Eval Workflow

### Phase 1: Define

```typescript
// Write eval specification
const searchEval = {
  name: "semantic-search",
  description: "Semantic search finds relevant results",

  setup: async () => {
    await database.seed(testData)
  },

  cases: [
    // Test cases
  ],

  teardown: async () => {
    await database.clean()
  }
}
```

### Phase 2: Run

```bash
# Run evals (should mostly fail before implementation)
claude eval run semantic-search

# Run multiple evals
claude eval run --all

# Run with verbose output
claude eval run semantic-search --verbose
```

Output:

```
semantic-search:
  case-1: FAIL (expected 3+ results, got 0)
  case-2: FAIL (expected 5+ results, got 0)
  case-3: SKIP (setup incomplete)

Summary: 0/2 passed (0%)
```

### Phase 3: Implement

Implement feature to satisfy evals:

```typescript
export async function semanticSearch(query: string) {
  const embedding = await getEmbedding(query)
  return await database.search(embedding, { limit: 5 })
}
```

### Phase 4: Grade

```bash
# Run evals again (should pass)
claude eval run semantic-search --grade

# Detailed grading
claude eval run semantic-search --grade --detailed
```

Output:

```
semantic-search:
  case-1: PASS
    Score: 1.0
    Results: 5 items, top relevance 0.92

  case-2: PASS
    Score: 0.95
    Results: 5 items, top relevance 0.88

  case-3: PASS
    Score: 1.0
    Results: 4 items, top relevance 0.91

Summary: 3/3 passed (100%)
Performance: pass@3 = 1.0, pass^3 = 1.0
```

### Phase 5: Iterate

If evals don't pass:

1. Analyze failure patterns
2. Improve implementation
3. Potentially revise eval expectations
4. Re-run until satisfactory

## Eval Organization

```
evals/
├── capability/
│   ├── semantic-search.yaml
│   ├── user-management.yaml
│   └── ...
├── regression/
│   ├── crud-operations.yaml
│   ├── auth-flow.yaml
│   └── ...
└── performance/
    ├── query-response-time.yaml
    └── memory-usage.yaml
```

## Best Practices

1. **Define evals first** - Before implementing features
2. **Use varied graders** - Combine code, model, and human grading
3. **Cover edge cases** - Not just happy path
4. **Measure incrementally** - Track metrics over time
5. **Keep evals simple** - One thing per eval
6. **Update evals with code** - Keep in sync with implementation
7. **Use deterministic tests** - Make results reproducible

## Example Eval Suite

```yaml
name: user-authentication
description: Complete authentication flow

setup:
  - create test database
  - seed with test users

evals:
  - name: user-registration
    type: capability
    grader: code
    cases:
      - input: { action: register, email: "new@test.com" }
        expected: { success: true, user_id: exists }
      - input: { action: register, email: "duplicate@test.com" }
        expected: { success: false, error: "email_exists" }

  - name: user-login
    type: capability
    grader: model
    cases:
      - input: { action: login, email: "test@test.com", password: "correct" }
        expected: { success: true, token: exists }
      - input: { action: login, email: "test@test.com", password: "wrong" }
        expected: { success: false, error: "invalid_credentials" }

  - name: token-validation
    type: regression
    grader: code
    cases:
      - input: { action: validate, token: "valid_token" }
        expected: { valid: true, user_id: "123" }
      - input: { action: validate, token: "invalid_token" }
        expected: { valid: false }

teardown:
  - drop test database
```

## Related Skills

- See `tdd-workflow` for test-driven development
- See `verification-loop` for quality gates
- See `continuous-learning-v2` for tracking eval improvements


