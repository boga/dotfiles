# Global Agent Rules

## Worktree Policy — MANDATORY

**Before editing any file, you MUST be on a feature branch. Never edit files or commit on the default branch (`master`/`main`).**

Before every file edit:
1. Check the current branch — if it is `master` or `main`, **stop**.
2. Check existing worktrees with `wt list` to see if a relevant branch already exists.
3. If yes — switch to it.
4. If no — create a new worktree with `wt switch --create <branch-name>`.
5. Only then make changes, commit and push from the feature branch.
6. Merge via `wt merge` (or open a PR).

The only exception is when the user explicitly says something like *"commit directly to main"* or *"skip the branch"*.

## Commit Message Convention

Always use **Conventional Commits** format for all commit messages:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

| Type       | When to use                                         |
|------------|-----------------------------------------------------|
| `feat`     | A new feature                                       |
| `fix`      | A bug fix                                           |
| `refactor` | Code change that is neither a bug fix nor a feature |
| `chore`    | Maintenance tasks, dependency updates, tooling      |
| `docs`     | Documentation only changes                          |
| `test`     | Adding or updating tests                            |
| `ci`       | CI/CD configuration changes                         |
| `perf`     | Performance improvements                            |
| `style`    | Formatting, whitespace (no logic change)            |
| `revert`   | Reverts a previous commit                           |

### Rules

- Description is lowercase, imperative mood, no trailing period
- Use a scope in parentheses when it adds clarity: `feat(auth): add OAuth2 support`
- Breaking changes: append `!` after type/scope and add `BREAKING CHANGE:` footer
- If tied to a ticket, add it in the footer: `Refs: ENC-123`

### Examples

```
feat(auth): add OAuth2 login support
fix(cache): prevent stale entries after TTL expiry
chore: upgrade dependencies to latest
docs: update README with setup instructions
refactor(api): extract retry logic into separate module
```

## Commit and Push

When the user says "commit and push" (or equivalent) — do exactly that and nothing else.
Do not edit files. If the working tree state is unclear or unexpected, ask the user before touching any files.

## File Operations

When the user references a specific file (e.g. `@AGENTS.md`, `src/foo.ts`), operate on **that exact file only**.

Do **not** use `find` or glob patterns to discover and act on other files with the same name. If you notice other related files that might also need the same change, **ask the user first** before touching them.

## Scope

Only read or modify files inside the current repository unless the user explicitly says otherwise.
