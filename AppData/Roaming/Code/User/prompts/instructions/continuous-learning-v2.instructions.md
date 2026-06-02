---
name: continuous-learning-v2
description: フックとバックグラウンド観察を使用してエージェント機能を進化させる本能ベースの学習システム。
---

# Continuous Learning V2 - Instinct System

An advanced learning system that observes agent behavior and evolves instincts into skills and patterns.

## Core Concept

Rather than explicit pattern extraction, the system observes what the agent does through hooks and builds a probabilistic model of effective approaches:

```
Observation → Instinct → Cluster → Skill/Command/Agent
(Hook data)   (Scores)   (Grouping)  (Reusable)
```

## Instinct Model

An instinct is a probabilistic pattern:

```typescript
interface Instinct {
  id: string
  name: string                    // "early-error-detection"
  description: string
  triggers: TriggerCondition[]   // When this applies
  actions: RecommendedAction[]   // What to do
  confidence: number             // 0.3-0.9
  domains: string[]              // coding-style, testing, git, etc
  success_rate: number           // % of times it worked
  last_updated: Date
  observations: number           // How many times observed
  related_instincts: string[]    // Links to other instincts
}
```

## Hook Integration Points

### PreToolUse Hook

Fires before any tool is used. Captures:

```typescript
interface PreToolUseEvent {
  tool: string
  args: Record<string, any>
  context: {
    files_open: string[]
    previous_tools: string[]
    time_in_session: number
  }
}
```

Observer scores relevant instincts:

```typescript
// Instinct: "verify-early"
if (event.tool === 'run_in_terminal' &&
    event.previous_tools.includes('replace_string_in_file')) {

  // High-confidence instinct trigger
  score(instinct_id, 0.85, 'tool_sequence_match')
}
```

### PostToolUse Hook

Fires after tool completes. Captures:

```typescript
interface PostToolUseEvent {
  tool: string
  duration: number
  success: boolean
  output: string
  error?: string
}
```

Evaluates instinct effectiveness:

```typescript
// If terminal command caught error immediately
if (event.success && event.output.includes('error')) {
  reward(instinct_id, 0.9, 'error_caught_early')
}

// If terminal command failed
if (!event.success) {
  penalty(instinct_id, 0.2, 'tool_failed')
}
```

## Learning Pipeline

### 1. Observation Phase

Background observer (Haiku model) runs continuously:

```
Every tool execution →
  Haiku analyzes in background →
    Scores against known instincts →
      Updates instinct confidence
```

### 2. Confidence Scoring

Instincts maintain rolling confidence:

```typescript
// Bayesian update
const new_confidence =
  (old_confidence * observations +
   event_confidence * event_weight) /
  (observations + event_weight)

// Decay old observations
if (instinct.age > 30_days) {
  confidence *= 0.95  // Decay over time
}
```

### 3. Clustering Phase

Similar instincts group into patterns:

```typescript
// Group instincts by domain + trigger similarity
const clusters = groupBy(instincts, instinct => ({
  domain: instinct.domain,
  trigger_type: instinct.triggers[0].type
}))

// Merge if confidence > threshold
if (instinct1.confidence > 0.75 &&
    instinct2.confidence > 0.75 &&
    similarity(instinct1, instinct2) > 0.8) {
  merge(instinct1, instinct2)
}
```

### 4. Skill Evolution

High-confidence clusters become documented skills:

```typescript
// When cluster reaches stability
if (cluster.avg_confidence >= 0.80 &&
    cluster.observations >= 10 &&
    cluster.success_rate >= 0.75) {

  // Evolve to skill
  skill = createSkill({
    name: cluster.name,
    description: cluster.summary,
    patterns: cluster.instincts,
    confidence: cluster.avg_confidence
  })
}
```

## Configuration

In `~/.claude/settings.json`:

```json
{
  "learning": {
    "enabled": true,
    "observe_interval": 100,        // Observe every N tool uses
    "confidence_threshold": 0.75,   // Minimum to reward/penalty
    "cluster_threshold": 0.80,      // Similarity for clustering
    "skill_threshold": 0.80,        // Confidence to promote to skill
    "decay_rate": 0.95,             // Decay old observations
    "max_instincts": 500,           // Cap on stored instincts
    "background_observer": {
      "enabled": true,
      "model": "claude-haiku",      // Use lightweight model
      "batch_size": 5               // Batch observations
    }
  }
}
```

## Instinct Examples

### Instinct: Early Verification

```typescript
{
  id: "early-verify",
  name: "Verify Code Immediately",
  domains: ["testing", "workflow"],
  triggers: [
    {
      type: "tool_sequence",
      pattern: ["replace_string_in_file", "run_in_terminal"],
      distance: 1  // Immediately after edit
    }
  ],
  actions: [
    {
      type: "recommend",
      text: "Run type check or test immediately"
    }
  ],
  confidence: 0.87,
  success_rate: 0.92,
  observations: 47
}
```

### Instinct: Check Related Files

```typescript
{
  id: "check-related",
  name: "Search for Related Usages",
  domains: ["coding-style", "refactoring"],
  triggers: [
    {
      type: "pattern",
      pattern: "changing_function_signature"
    }
  ],
  actions: [
    {
      type: "recommend",
      text: "Search for other uses of this function"
    }
  ],
  confidence: 0.81,
  success_rate: 0.88,
  observations: 31
}
```

## Observing Your Own Patterns

The system learns your patterns automatically. You can:

1. **Check learned instincts**: `claude skills show-instincts`
2. **View instinct confidence**: `claude skills confidence <domain>`
3. **See evolution timeline**: `claude skills timeline`
4. **Adjust sensitivity**: Update `settings.json` thresholds

## Knowledge Persistence

Instincts survive across sessions:

- Stored in `~/.claude/instincts.json`
- Synchronized with remote if configured
- Backed up on each session
- Can be manually pruned or reset

## Evolution to Skills

When instincts reach maturity:

```
0.3-0.5: Experimental hypothesis
0.5-0.7: Validated pattern
0.7-0.8: High-confidence pattern
0.8+:    Promote to documented skill
```

Promoted skills become:
- Documented in `.md` files
- Referenced in prompts
- Available as `@skill-name` in contexts
- Shared with team

## Privacy & Control

- All learning is local by default
- No data sent to external services
- Instincts never contain sensitive code
- Can disable learning: `learning.enabled: false`
- Manual pruning available: `claude skills prune`

## Related Skills

- See `strategic-compact` for session boundaries
- See `tdd-workflow` for testing patterns
- See `verification-loop` for verification instincts


