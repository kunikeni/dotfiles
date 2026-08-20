---
name: orchestrate
description: Planner → Generator ⇄ Evaluator のフィードバックループを実行。最大3イテレーションで収束させる。
---

# Orchestrate Command

`/orchestrate [task-description]`

## Flow

```
[User Input] → [Planner] → [Generator] ⇄ [Evaluator] → [Deliverable]
                  ↑                           |
                  └──── feedback (REDESIGN) ──┘
```

The main session runs this loop as the client. It owns requirements, acceptance criteria, and the final accept-or-reject; it does not write production or test code inside any phase. See `rules/agents.md` for the full role boundaries.

## Execution Steps

### Phase 1: Planning

Invoke the **planner** agent (model: opus):

- Pass the full task description from user input
- Planner analyzes codebase, makes design decisions, outputs implementation plan
- Present plan to user **in full**
- **HARD STOP**: Do NOT proceed to Phase 2 until user explicitly approves
  - Approval examples: "OK", "go ahead", "LGTM", "approve"
  - If user requests changes, re-invoke Planner with revised requirements
  - Ambiguous responses ("hmm", "I see") are NOT approval. Ask for explicit confirmation
- Before presenting the plan, confirm its `## Success Criteria` are verifiable acceptance criteria — each one settled by a named test or a command output, not by opinion. Rewrite vague ones yourself; they are the client's responsibility, not the Planner's
- Once approved, update the `## Approval` checkbox in the plan file to `[x]`
- Generator will not start if the Approval checkbox is unchecked

### Phase 2: Generation Loop (max 3 iterations)

```
iteration = 0
while iteration < 3:
    1. Invoke **generator** agent with:
       - The plan file path
       - Previous evaluator feedback (if iteration > 0)
    2. Invoke **evaluator** agent with:
       - The plan file path
       - The git diff of generator's changes
    3. Check evaluator verdict:
       - PASS → exit loop, proceed to completion
       - REVISE → increment iteration, pass feedback to generator
       - REDESIGN → pass feedback to planner, get revised plan, reset iteration
```

### Phase 3: Completion

- Match the deliverable against the acceptance criteria yourself. An Evaluator PASS is evidence for that judgment, not a substitute for it
- Report final status to user
- List files changed
- Summarize test results, and state which criterion each one settles

## Prompt Templates

### Planner Prompt

```
Task: {user_task_description}

Working directory: {cwd}
Relevant context: {any user-provided context}

Produce a complete implementation plan following your system prompt format.
Include design decisions with rationale, ordered steps with file paths,
test strategy, and success criteria.
```

### Generator Prompt (iteration 0)

A work order carries all six items below. You cannot rely on the plan file alone —
state the scope boundary and the prohibitions explicitly, because the subagent
cannot see this conversation.

```
## Requirements

{what to build and why, in the client's own words}

## Plan

Read the plan file at: .claude/plan/{slug}.md

## Acceptance Criteria

{the verifiable criteria, restated here — these are the client's.
Do not rewrite, relax, or add to them. If one cannot be met as written, stop and report why.}

## Scope

Files you may touch: {paths}
Everything else is out of bounds. If you spot a problem outside this scope, report it; do not fix it.

## Patterns to Follow

Read these first and replicate their conventions: {paths}

## Prohibitions

- No design decisions beyond the plan. If the plan is ambiguous, stop and report
- No implementation before a failing test
- No direct tool invocation (ruff, mypy). Use the task runner

## Instructions

Implement the plan step by step using TDD methodology.
For each step: write test (RED) → implement (GREEN) → fix build → refactor.
Report each step's status. If blocked, report what is unclear and stop.
Your DoD run finishes your work order; the Evaluator decides acceptance.
```

### Generator Prompt (iteration > 0)

```
## Plan

Read the plan file at: .claude/plan/{slug}.md

## Previous Evaluator Feedback

{evaluator_feedback}

## Instructions

Fix the issues identified by the Evaluator above.
For CRITICAL and HIGH issues: fix all of them.
For MEDIUM issues: fix if straightforward.
After fixing, run the full test suite and report results.
```

### Evaluator Prompt

```
## Plan Context

Read the plan file at: .claude/plan/{slug}.md

## Acceptance Criteria

{the same criteria handed to the Generator}

## Changes to Evaluate

Run `git diff` to see all changes made by the Generator.
Read each modified file in full context.

## Instructions

1. Acceptance gate first: for each criterion, name the evidence that it is met
   (test name, command output, file:line). No evidence means not met, and any
   unmet criterion is REVISE. Do not rewrite or relax a criterion — return it instead
2. DoD gate: run every DoD command for the ecosystem, whole project
3. Evaluate against Security, Correctness, Code Quality, Performance, Test Quality

Output your verdict (PASS / REVISE / REDESIGN) with the acceptance table and structured feedback.
For each issue, include file:line and specific fix instructions.
Specify whether feedback targets Generator or Planner.
Report defects only — do not fix anything yourself.
```

## Iteration Limits

- **Max iterations**: 3 (Generator ⇄ Evaluator)
- **REDESIGN**: Returns to Planner once. If second REDESIGN occurs, escalate to user.
- **After 3 iterations without PASS**: Stop and report remaining issues to user for decision.

## Key Constraints

- Agents cannot see each other's conversation history
- All context must be explicitly passed in prompts
- Agents cannot invoke other agents (no nesting)
- The main loop (this orchestration) controls all flow
- File-based data exchange for large outputs (plans, reports)

## Arguments

$ARGUMENTS: The task description to implement

## Workflow Types

Shorthand aliases (all follow the same loop, with adjusted Planner scope):

- `/orchestrate feature <desc>` - Full feature with architecture decisions
- `/orchestrate bugfix <desc>` - Bug investigation (Planner focuses on root cause)
- `/orchestrate refactor <desc>` - Safe refactoring (Planner focuses on preserving behavior)

## Example

```
User: /orchestrate feature "Add rate limiting to API endpoints"

-> Planner (opus): analyzes codebase, designs rate limiting strategy,
   outputs plan with middleware approach, Redis counter, per-endpoint config
-> User confirms plan
-> Generator (sonnet) iteration 1: implements tests + code
-> Evaluator (sonnet) iteration 1: REVISE - missing edge case for burst traffic
-> Generator (sonnet) iteration 2: fixes edge case, adds burst test
-> Evaluator (sonnet) iteration 2: PASS
-> Done: report to user
```
