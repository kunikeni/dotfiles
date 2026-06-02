---
name: plan
description: planner エージェントで要件分析・設計判断・実装計画を作成。ユーザーの明示的な承認を待ってから実装に進む。
---

# Plan Command

This command invokes the **planner** agent to create a comprehensive implementation plan before writing any code.

## What This Command Does

1. **Analyze Requirements** - Restate and clarify what needs to be built
2. **Read Codebase** - Identify existing patterns and affected components
3. **Make Design Decisions** - Document choices with rationale
4. **Output Plan File** - Write to `.claude/plan/<slug>.md`
5. **Wait for Approval** - MUST receive explicit user approval before Generator proceeds

## When to Use

Use `/plan` when:

- Starting a new feature
- Making significant architectural changes
- Working on complex refactoring
- Multiple files/components will be affected
- Requirements are unclear or ambiguous

## Plan Output Format

The plan is written to `.claude/plan/<slug>.md` with this structure:

```markdown
# Plan: [Title]

## Approval
- [ ] Reviewed and approved by user

## Overview
[2-3 sentences]

## Design Decisions
[Each decision with rationale]

## Steps (ordered)
1. [Step]: [file path]
   - What: specific action
   - Why: reason
   - Test: how to verify

## Test Strategy
## Risks
## Success Criteria
```

## Approval Flow

- The plan is presented to the user in full
- User must explicitly approve ("OK", "go ahead", "LGTM", "approve")
- Ambiguous responses are NOT approval
- Once approved, the Approval checkbox is updated to `[x]`
- Generator will not start if the checkbox is unchecked

## Integration with Other Commands

After planning:

- Use `/orchestrate` to run the full pipeline (plan is already done)
- Use `/tdd` to implement a single step with TDD
- Generator reads the plan file directly

## Related

This command invokes the `planner` agent (model: opus).

## Arguments

$ARGUMENTS: Description of what to plan
