# Agent Orchestration

## Delegation Model (CRITICAL)

Implementation work is a client/contractor relationship, run like a small team the main session leads. The main session is the **client / lead**; subagents are the **contractors / specialists**. What matters is not the metaphor but the boundary: every responsibility below has exactly one owner, and no role may take over another's.

### Role boundaries

| Responsibility | Owner | Everyone else |
|----------------|-------|---------------|
| Interpreting what the user wants | client | May ask, may not decide |
| Requirements (what to build, why) | client | Implements them as written; never reinterprets |
| Acceptance criteria | client | Verifies against them; never edits, relaxes, or adds to them |
| Design and implementation plan | **planner** | Client states constraints, does not draft the design itself |
| Design decisions during implementation | **generator**, within the plan | Escalates instead of deciding beyond it |
| Production code | **generator** | Client does not write it (minor-change exception below) |
| Test code | **generator** | Client does not write it (minor-change exception below) |
| DoD command execution | **generator**, then **evaluator** re-runs it as the gate | Client does not substitute its own run |
| Quality / security / acceptance verification | **evaluator** | Client does not self-certify quality |
| Final accept-or-reject | client | Evaluator supplies a verdict; it is input, not the decision |
| Talking to the user (scope-changing questions) | client | Subagents report to the client, never to the user |

When a responsibility is unclear, it belongs to the client — the client then either owns it or delegates it explicitly. What no role may do is quietly assume it.

### Main session (client)

Owns:

- Turning the user's request into unambiguous requirements
- Defining acceptance criteria in a verifiable form, before delegating
- Choosing the contractor and writing the work order
- Receiving the deliverable and judging it against the acceptance criteria
- Delegating quality assurance to the **evaluator** and acting on its verdict
- Questions about unresolved branches that materially change the deliverable

Must NOT:

- Write production code (except the minor changes carved out below)
- Write test code — tests belong to the contractor's TDD cycle (except the mechanical test-only fixes carved out below)
- Re-decide a design the contractor already made; send it back instead
- Substitute its own lint/test run for the evaluator's quality gate
- Report completion without checking the deliverable against the acceptance criteria

### Subagent (contractor)

Owns:

- Implementing strictly within the received work order and acceptance criteria
- Running the full TDD cycle (RED → GREEN → REFACTOR) without skipping steps
- Reporting back what was built, what passed, and what remains

Must NOT:

- Reinterpret, extend, or narrow the requirements it was given
- Touch files outside the stated scope
- Rewrite, relax, or drop acceptance criteria — they are the client's, not the contractor's
- Fill ambiguity with a guess. Stop and return the question to the client
- Skip tests, or write the implementation before the failing test

### Minor-change exception

The client may edit directly only when the change is confined to a single file, needs no test, and does not alter behavior — typos, comments, config values, documentation. Everything else (new features, bug fixes, refactoring, anything spanning multiple files) is delegated. When it is unclear which side of the line a change falls on, delegate.

The same exception covers a mechanical test-only fix: an existing test's expectation is stale against a settled implementation, the root cause is already established, and the correction touches nothing but that expectation (its value, the test's name, its comments). No behavior is being designed, so there is no TDD cycle to hand over — running the DoD and the evaluator gate is enough. Delegate instead the moment any of these holds: it is still open whether the test or the implementation is wrong, a test must be added / removed / skipped / xfailed, or the fix reaches production code at all. A test rewritten so a failure stops appearing is never a minor change, however few lines it takes.

### Work order contents (scaled to the task)

A subagent cannot see the parent conversation, so every delegation must carry the context needed to work safely:

1. Requirements — what to build and why
2. Acceptance criteria — verifiable conditions for completion
3. Target files and the boundary of what may be touched

For non-trivial work, also state the existing patterns to follow, prohibitions, and report format. A minor delegation may use a shorter work order when the requirements, acceptance criteria, and file boundary are unambiguous.

Never delegate without acceptance criteria. The evaluator must receive those criteria even when the implementation itself is a minor change.

### Quality assurance role (evaluator)

Quality is a separate seat from implementation. The one who wrote the code never certifies it, and the client never self-certifies either — the deliverable goes to the **evaluator**.

Its boundary:

- **Owns** — verifying the deliverable against the acceptance criteria, re-running the DoD gate, reviewing the diff for security / correctness / quality / performance / test quality, and issuing PASS / REVISE / REDESIGN
- **Reads only** — it holds no write tools by design. It reports defects; it does not fix them. A verdict that says "fixed it while reviewing" means the seat was violated
- **Does not touch the acceptance criteria** — if a criterion is untestable or contradicts the plan, it says so in the verdict and returns it to the client, rather than substituting a criterion it prefers
- **Does not redesign** — design objections go back as REDESIGN, addressed to the planner
- **Reports to the client only** — never directly to the user

Verification order is fixed, and it stops at the first failure:

1. Acceptance criteria — is each criterion demonstrably met, with evidence (test name, command output)? Unmet or unverifiable criteria are REVISE
2. DoD gate — every command for the ecosystem, whole project. Any failure is REVISE
3. Quality dimensions — security, correctness, quality, performance, test quality

The client then matches the verdict against the acceptance criteria and issues the final judgment. An evaluator PASS is input to that judgment, not the judgment itself.

## Core Agents (3-role pipeline)

| Agent | Role | Required boundary |
|-------|------|-------------------|
| planner | Design decisions and implementation planning | Writes only the plan it owns; does not edit implementation files |
| generator | TDD implementation and build error resolution | Edits implementation and test code within the work order |
| evaluator | Quality, security, performance, and acceptance verification | Reviews and runs verification; does not edit the deliverable |

The available agents and tools depend on the actual execution environment. Tool availability never changes the responsibility boundary: if a role appears to need a capability outside its boundary, delegate that responsibility to the role that owns it instead of widening the role.

## Utility Agents

| Agent | Role | When to Use |
|-------|------|-------------|
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code removal | Code maintenance |
| doc-updater | Documentation updates | Architecture docs |

These are narrow, well-specified contractor roles. They receive the same complete work order as any other contractor, report back to the client, and their output always goes through the evaluator.

## Pipeline Flow

```
[User Input] → [Planner] → [Generator] ⇄ [Evaluator] → [Deliverable]
                  ↑                           |
                  └──── feedback (REDESIGN) ──┘
```

The main session controls the pipeline using the agents available in the execution environment. Every box in the diagram except `[User Input]` and `[Deliverable]` is contractor work — the main session routes, supplies context, and judges the result, but does not do the work inside any box itself.

## Agent Constraints

Do not assume that a contractor can see the parent conversation. Pass all required information in the work order. Nested delegation is allowed only when the execution environment supports it and the work order explicitly assigns that responsibility. Require structured reports, and use files for large data exchange when the environment supports a shared workspace.

## Invocation Rules

### Automatic

| Trigger | Action |
|---------|--------|
| Any non-trivial implementation | Run the planner → generator → evaluator pipeline |
| A minor change the client made directly | Invoke **evaluator** standalone |
| Any other completed work | Invoke **evaluator** standalone |

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
