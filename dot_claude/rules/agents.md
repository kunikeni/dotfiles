# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| tdd-guide | Test-driven development | New features, bug fixes |
| code-reviewer | Code review | After writing code |
| security-reviewer | Security analysis | Before commits |
| build-error-resolver | Fix build errors | When build fails |
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation | Updating docs |

## Immediate Agent Usage

No user prompt needed:

1. Complex feature requests - Use **planner** agent
2. Code just written/modified - Use **code-reviewer** agent
3. Bug fix or new feature - Use **tdd-guide** agent
4. Architectural decision - Use **architect** agent

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch 3 agents in parallel:
1. Agent 1: Security analysis of auth.ts
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utils.ts

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:

- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker

## Agent Selection Matrix

### Use Immediately (No Prompt Required)

| Trigger | Agent | Action |
| --- | --- | --- |
| Code just written/modified | **code-reviewer** | Review for quality, security, maintainability |
| New feature or bug fix | **tdd-guide** | Enforce test-first approach |
| Complex feature request | **planner** | Design implementation plan |
| Architectural decision needed | **architect** | Evaluate trade-offs, recommend patterns |
| Build fails or type errors | **build-error-resolver** | Fix errors quickly, minimal diffs |

### Use When Requested

| Scenario | Agent | Capability |
| --- | --- | --- |
| User input handling, auth, API endpoints | **security-reviewer** | Flag OWASP Top 10, secrets, injection risks |
| New E2E test needed | **e2e-runner** | Generate Playwright tests, manage flaky tests |
| Dead code cleanup | **refactor-cleaner** | Identify unused code, consolidate duplicates |
| Documentation updates | **doc-updater** | Generate architecture docs, update READMEs |

## Agent Capabilities Summary

### code-reviewer

- Security vulnerability detection
- Code quality analysis
- Performance concerns
- Best practices enforcement
- Automated fix suggestions

### tdd-guide

- Red-Green-Refactor cycle
- Edge case identification
- Mocking patterns
- Coverage verification
- Test isolation

### planner

- Requirement analysis
- Architecture review
- Step-by-step breakdown
- Dependency mapping
- Risk assessment

### architect

- System design
- Pattern recommendations
- Scalability planning
- Trade-off analysis
- Technology decisions

### security-reviewer

- Secrets detection
- SQL/Command injection
- XSS prevention
- Authentication/Authorization
- Rate limiting analysis

### build-error-resolver

- TypeScript/Python errors
- Import resolution
- Type annotation fixes
- Configuration errors
- Minimal change approach

### e2e-runner

- Test journey creation
- Flaky test management
- Artifact capture (screenshots, videos)
- CI/CD integration
- Test reporting

### refactor-cleaner

- Dead code detection
- Duplicate consolidation
- Dependency cleanup
- Safe removal verification
- Deletion logging

### doc-updater

- Architecture mapping generation
- Documentation extraction
- API reference creation
- Architecture documentation
- README maintenance
