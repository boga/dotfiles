# Global Agent Rules

## Worktree Policy

Before making any code or config changes in a git repository:
1. Check existing worktrees with `wt list` to see if a relevant branch already exists.
2. If yes — switch to it.
3. If no — create a new worktree with `wt switch --create <branch-name>`.

Never commit or make changes directly on the default branch (main, master, develop, etc.).

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
