---
name: strategic-compact
description: タスクフェーズ全体でコンテキストを保持するため、論理的な間隔で手動コンテキスト圧縮を提案します。
---

# Strategic Compact Skill

Suggests manual `/compact` at strategic points in your workflow rather than relying on arbitrary auto-compaction.

## Why Strategic Compaction?

Auto-compaction triggers at arbitrary points:

- Often mid-task, losing important context
- No awareness of logical task boundaries
- Can interrupt complex multi-step operations

Strategic compaction at logical boundaries:

- **After exploration, before execution** - Compact research context, keep implementation plan
- **After completing a milestone** - Fresh start for next phase
- **Before major context shifts** - Clear exploration context before different task

## How It Works

The `suggest-compact.sh` script runs on PreToolUse (Edit/Write) and:

1. **Tracks tool calls** - Counts tool invocations in session
2. **Threshold detection** - Suggests at configurable threshold (default: 50 calls)
3. **Periodic reminders** - Reminds every 25 calls after threshold

## Hook Setup

Add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "tool == \"Edit\" || tool == \"Write\"",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/strategic-compact/suggest-compact.sh"
      }]
    }]
  }
}
```

## Configuration

Environment variables:

- `COMPACT_THRESHOLD` - Tool calls before first suggestion (default: 50)
- `COMPACT_REMINDER_INTERVAL` - Reminder frequency (default: 25)

## Best Practices

1. **Compact after planning** - Once plan is finalized, compact to start fresh
2. **Compact after debugging** - Clear error-resolution context before continuing
3. **Don't compact mid-implementation** - Preserve context for related changes
4. **Read the suggestion** - The hook tells you *when*, you decide *if*
5. **Use checkpoints** - Save progress before compacting
6. **Preserve critical context** - Keep essential state across compaction

## When to Compact

✅ **Good times:**

- After completing planning/design phase
- After debugging and fixing errors
- Between independent feature implementations
- After reviewing and testing

❌ **Bad times:**

- During implementation of related features
- Mid-refactoring across multiple files
- While still debugging
- During complex multi-step operations

## Token Efficiency

Compaction helps by:

- Removing verbose exploration context
- Eliminating multiple failed attempts
- Clearing irrelevant information
- Starting fresh with a focused plan

## Related Skills

- See `continuous-learning-v2` for state persistence across compaction
- See `verification-loop` for checkpoints before compacting


