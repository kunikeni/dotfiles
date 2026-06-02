---
name: continuous-learning
description: セッションパターンの抽出とインタラクションからの学習。セッション後の学習を自動的に抽出します。
---

# Continuous Learning

Automatically extract patterns and learnings from development sessions.

## How It Works

After each session:

1. **Extract patterns** - Identify recurring code patterns, tool usage, problem-solving approaches
2. **Categorize** - Group patterns by type (coding-style, testing, git, debugging, workflow, performance, security)
3. **Evaluate** - Assess pattern importance and confidence
4. **Archive** - Save for future reference and skill building

## Pattern Types

### Coding Style

- Variable naming patterns
- Function organization
- Module structure
- Code organization

### Testing

- Test organization
- Assertion patterns
- Mock strategies
- Coverage focus areas

### Git Workflow

- Commit patterns
- Branch organization
- PR structure
- Review practices

### Debugging

- Common error patterns
- Investigation strategies
- Tool usage
- Problem diagnosis

### Development Workflow

- Tool sequences
- Time management
- Context switching
- Planning approaches

### Performance

- Optimization techniques
- Bottleneck identification
- Caching strategies
- Profiling methods

### Security

- Vulnerability patterns
- Security checks
- Validation approaches
- Secret management

## Session Summary Structure

```
Session: YYYY-MM-DD HH:MM
Duration: X hours
Files Changed: N
Tools Used: [tool1, tool2, ...]

PATTERNS DISCOVERED:
1. Pattern name
   Type: coding-style | testing | git | debugging | workflow | performance | security
   Confidence: 0.0-1.0
   Description: What was learned
   Example: Code or scenario demonstrating pattern
   Impact: Why this matters

DECISIONS MADE:
1. Decision: What was decided?
   Rationale: Why?
   Alternative considered: What else could we have done?
   Outcome: How did it work out?

CHALLENGES FACED:
1. Challenge: What went wrong?
   Solution: How did we solve it?
   Prevention: How to avoid next time?

NEXT TIME:
- Action item
- Area for improvement
- Pattern to apply
```

## Pattern Confidence Scale

- **1.0 (Certain)**: Verified through multiple sessions, consistent results
- **0.8 (High)**: Used successfully multiple times, proven effective
- **0.6 (Medium)**: Used successfully once or twice, promising
- **0.4 (Low)**: Experimental, not fully tested
- **0.2 (Unproven)**: Interesting idea, needs validation

## Knowledge Organization

Learnings feed into:

- **Skills**: Patterns with 0.8+ confidence become documented skills
- **Prompts**: Common patterns become prompt additions
- **Commands**: Repeated tool sequences become automated commands
- **Guidelines**: Validated approaches become coding standards

## Using Learnings

When working on similar tasks:

1. **Reference patterns** - Check extracted patterns for relevant approaches
2. **Apply learnings** - Use high-confidence patterns from previous sessions
3. **Build on experience** - Adapt known patterns to new contexts
4. **Track improvements** - Monitor how learnings improve efficiency

## Example Session Extraction

```
Session: 2024-01-15 14:30
Duration: 3 hours
Files Changed: 12
Tools Used: [read_file, grep_search, replace_string, run_in_terminal]

PATTERNS DISCOVERED:
1. File Search Then Edit Strategy
   Type: workflow
   Confidence: 0.9
   Description: Always search for context before editing files
   Example: grep search found 3 uses of old pattern, updated all together
   Impact: Prevents incomplete refactoring and catches related code

2. Early Error Catching in Terminal
   Type: debugging
   Confidence: 0.85
   Description: Run commands in terminal immediately after file changes
   Example: Caught TypeScript error 2 minutes after change, not in PR review
   Impact: Faster feedback loop, fewer CI failures

DECISIONS MADE:
1. Decision: Use grep_search instead of semantic_search for known patterns
   Rationale: grep_search was 3x faster for specific string matching
   Alternative: semantic_search provides context, but slower
   Outcome: Saved 10 minutes on search phase

NEXT TIME:
- Use file search patterns to find all related changes
- Test TypeScript compilation immediately after changes
- Document pattern before moving to next feature

