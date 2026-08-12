# Git Workflow

## Safety Rules (CRITICAL)

### Principle

Any git command that could change the diff in ways the user did not intend is **unconditionally prohibited**. No exceptions unless the user explicitly requests it.

### Responsibility Boundary

`git add`, `git commit`, `git push` are the user's responsibility. Claude does not execute these unless the user explicitly instructs it to do so in that specific context.

### Prohibited Operations

| Operation | Reason |
|-----------|--------|
| `git push` (all forms) | Prohibited unconditionally |
| `git reset` (all modes: `--hard`, `--mixed`, `--soft`) | Moves HEAD / changes index or working tree |
| `git checkout` (all forms) | Use `git switch` for branch changes. `checkout` is prohibited |
| `git restore .` | Discards working changes |
| `git clean` (all flags) | Deletes untracked files |
| `git stash` (all subcommands) | Changes working tree state |
| `git rebase` (all forms) | Rewrites commit history |
| `git cherry-pick` | Introduces commits the user did not author in this context |
| `git revert` | Creates inverse commits that change the diff |
| `git merge` (without user confirmation) | Alters branch state and working tree |
| `git branch -D` | Force-deletes unmerged branches |
| `git am` / `git apply` | Applies external patches |
| `git commit --amend` | Modifies the previous commit |
| `git tag` (all forms) | Prohibited unconditionally |

### Commit Principles

- **Always create new commits** (`--amend` only when user explicitly requests)
- After pre-commit hook failure, **retry with a new commit** (amend would modify the previous commit)
- Never use `--no-verify` or `--no-gpg-sign` (respect hooks)
- Do not create empty commits

### Staging

- Never use `git add -A` or `git add .` (prevents accidental inclusion)
- Stage files explicitly by name
- Never commit `.env`, credentials, or binary files

### Operations Requiring Confirmation

Always confirm with the user before:

- Branch deletion (`git branch -d`)

## Branching Strategy

### Branch Naming

Two formats allowed:

```
<issue-number>-<short-description>
<prefix>-<short-description>
```

| Format | Example |
|--------|---------|
| Issue number | `123-user-auth`, `456-fix-timeout` |
| Prefix | `feature-user-auth`, `fix-login-timeout`, `chore-update-deps` |

### Rules

- Branch names: **lowercase, hyphen-separated, English only**
- No direct commits to `main` / `master` (PR only)
- Feature branches branch off from `main`
- Keep branches short-lived (avoid long-running branches)

### Branch Flow

```
main ← Always deployable
 ├── 123-user-auth    ← Issue-based branch
 ├── feature-xxx      ← Prefix-based branch
 ├── fix-xxx
 └── chore-xxx
```

- Delete feature branches promptly after merge
- Resolve conflicts by merging `main` into feature branch (rebase only before first push)

## Commit Message Format

- One line only. What was done, briefly
- Written in Japanese
- No prefix, no type tag, no scope
- No HEREDOC (`cat <<'EOF'`). Always use `git commit -m "message"` directly

### Examples

```bash
git commit -m "OAuth2によるログイン機能を追加"
git commit -m "レート制限のカウント二重加算を修正"
git commit -m "依存パッケージを更新"
```

## Pull Request Workflow

When creating PRs:

1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Keep PR title under 70 characters
4. Read `.github/PULL_REQUEST_TEMPLATE.md` (and any locale variants) first; follow its section structure verbatim if present. Fall back to Summary + Test Plan only when no template exists.
5. Do not push (user handles push manually)

## Feature Implementation Workflow

1. **Plan First**
   - Use **planner** agent to create implementation plan
   - Identify dependencies and risks
   - Break down into phases

2. **TDD Approach**
   - Use **generator** agent (or `/tdd` command)
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review**
   - Use **evaluator** agent (or `/code-review` command) immediately after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

4. **Commit & Push**
   - One-line summary of what was done
   - Never push (user handles push manually)
