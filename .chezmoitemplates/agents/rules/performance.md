# Performance Optimization

## Execution Strategy

Choose the role and execution path from the work itself and from the capabilities available in the active environment:

- Use a narrow, low-latency path for independent, well-specified tasks with bounded inputs and outputs
- Use a general implementation role for coding work that requires repository context, edits, and verification
- Allocate more reasoning time to architecture, ambiguous failure analysis, security decisions, and research with competing evidence
- Parallelize only independent work with non-overlapping ownership; keep dependent steps sequential
- Treat latency and cost as constraints after correctness, required context, permissions, and independent evaluation are satisfied

## Context Window Management

Avoid last 20% of context window for:

- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:

- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

## Planning and Reasoning Depth

For complex tasks requiring deep reasoning:

1. Write a structured plan before execution
2. Allocate additional reasoning time to decisions with high uncertainty or high reversal cost
3. Critique the plan from correctness, security, operability, and testability perspectives
4. Use independent specialist roles for distinct analyses when the execution environment supports them

## Build Troubleshooting

If build fails:

1. Delegate the fix to **generator**
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix
