# Agent Orchestration

## Core Agents (3-role pipeline)

Located in `~/.claude/agents/`:

| Agent | Model | Role | Tools |
|-------|-------|------|-------|
| planner | opus | Requirements analysis, design decisions, planning | Read, Write, Grep, Glob |
| generator | sonnet | TDD implementation, build error resolution | Read, Write, Edit, Bash, Grep, Glob |
| evaluator | sonnet | Quality, security, performance evaluation | Read, Grep, Glob, Bash |

## Utility Agents

| Agent | Role | When to Use |
|-------|------|-------------|
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code removal | Code maintenance |
| doc-updater | Documentation updates | Architecture docs |

## Pipeline Flow

```
[User Input] → [Planner] → [Generator] ⇄ [Evaluator] → [Deliverable]
                  ↑                           |
                  └──── feedback (REDESIGN) ──┘
```

Controlled by `/orchestrate` command. The main loop invokes each agent sequentially.

## Agent Constraints

Subagent limitations by design:

- Cannot see the parent's conversation context. All information must be passed via prompt
- Cannot invoke other subagents (no nesting)
- Return value is summary text only. Use format instructions in prompt for structure
- Large data exchange should go through files

## Invocation Rules

### Automatic (no user prompt needed)

| Trigger | Action |
|---------|--------|
| Complex feature implementation or refactoring | Run pipeline via `/orchestrate` |
| Simple code change review | Invoke **evaluator** standalone |

### Manual (user requests)

| Scenario | Action |
|----------|--------|
| E2E tests needed | **e2e-runner** |
| Dead code cleanup | **refactor-cleaner** |
| Documentation updates | **doc-updater** |

## Feedback Loop Rules

- Generator ⇄ Evaluator iteration limit: **3 rounds**
- Evaluator verdict is one of: PASS / REVISE / REDESIGN
- REVISE: Send back to Generator with specific fix instructions
- REDESIGN: Send back to Planner for design revision. Max 1 REDESIGN; second triggers user escalation
- If no PASS after 3 iterations, report remaining issues to user for decision
