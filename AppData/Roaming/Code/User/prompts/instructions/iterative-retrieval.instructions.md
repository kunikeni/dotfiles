---
name: iterative-retrieval
description: サブエージェントのコンテキスト問題を解決するためにコンテキスト検索を段階的に改善するパターン。
---

# Iterative Retrieval Pattern

Solves the "context problem" in multi-agent workflows where subagents don't know what context they need until they start working.

## The Problem

Subagents are spawned with limited context. They don't know:

- Which files contain relevant code
- What patterns exist in the codebase
- What terminology the project uses

Standard approaches fail:

- **Send everything**: Exceeds context limits
- **Send nothing**: Agent lacks critical information
- **Guess what's needed**: Often wrong

## The Solution: Iterative Retrieval

A 4-phase loop that progressively refines context:

```
┌─────────────────────────────────────────────┐
│                                             │
│   ┌──────────┐      ┌──────────┐            │
│   │ DISPATCH │─────▶│ EVALUATE │            │
│   └──────────┘      └──────────┘            │
│        ▲                  │                 │
│        │                  ▼                 │
│   ┌──────────┐      ┌──────────┐            │
│   │   LOOP   │◀─────│  REFINE  │            │
│   └──────────┘      └──────────┘            │
│                                             │
│        Max 3 cycles, then proceed           │
└─────────────────────────────────────────────┘
```

### Phase 1: DISPATCH

Initial broad query to gather candidate files:

```javascript
// Start with high-level intent
const initialQuery = {
  patterns: ['src/**/*.ts', 'lib/**/*.ts'],
  keywords: ['authentication', 'user', 'session'],
  excludes: ['*.test.ts', '*.spec.ts']
};

// Dispatch to retrieval agent
const candidates = await retrieveFiles(initialQuery);
```

### Phase 2: EVALUATE

Assess retrieved content for relevance:

```javascript
function evaluateRelevance(files, task) {
  return files.map(file => ({
    path: file.path,
    relevance: scoreRelevance(file.content, task),
    reason: explainRelevance(file.content, task),
    missingContext: identifyGaps(file.content, task)
  }));
}
```

Scoring criteria:

- **High (0.8-1.0)**: Directly implements target functionality
- **Medium (0.5-0.7)**: Contains related patterns or types
- **Low (0.2-0.4)**: Tangentially related
- **None (0-0.2)**: Not relevant, exclude

### Phase 3: REFINE

Update search criteria based on evaluation:

```javascript
function refineQuery(evaluation, previousQuery) {
  return {
    // Add new patterns discovered in high-relevance files
    patterns: [...previousQuery.patterns, ...extractPatterns(evaluation)],

    // Add terminology found in codebase
    keywords: [...previousQuery.keywords, ...extractKeywords(evaluation)],

    // Exclude confirmed irrelevant paths
    excludes: [...previousQuery.excludes, ...evaluation
      .filter(e => e.relevance < 0.2)
      .map(e => e.path)
    ],

    // Target specific gaps
    focusAreas: evaluation
      .flatMap(e => e.missingContext)
  };
}
```

### Phase 4: LOOP OR PROCEED

- If evaluation shows gaps → Refine and loop (max 3 times)
- If high-relevance files found → Proceed with implementation
- After 3 loops → Accept current context set and proceed

## Stopping Conditions

Stop refining and proceed when:

1. ≥ 70% of high-relevance files retrieved
2. Gap analysis shows no critical missing pieces
3. Max 3 refinement loops reached
4. All keywords exhausted

## Implementation Tips

- **Start broad**: Initial query covers large patterns
- **Refine incrementally**: Each loop adds specificity
- **Track relevance**: Score files to identify patterns
- **Set limits**: 3-loop maximum prevents infinite loops
- **Document gaps**: Capture what's missing for subagent

## Example Flow

```
Initial Query:
  - patterns: src/**, lib/**
  - keywords: auth

Retrieved: 15 files
  - 3 high relevance (auth handlers)
  - 7 medium relevance (user types)
  - 5 low relevance (other features)

Evaluation: Missing session management patterns

Refined Query:
  - patterns: src/**, lib/**
  - keywords: auth, session, jwt
  - excludes: (low-relevance files)

Retrieved: 8 files (focused set)
  - 4 high relevance
  - 3 medium relevance
  - 1 low relevance

Proceed: Sufficient context for task

