# Commit Message Convention

Always use **Conventional Commits** format for all commit messages:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types

| Type       | When to use                                         |
| ---------- | --------------------------------------------------- |
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

## Rules

- Description is lowercase, imperative mood, no trailing period.
- Use a scope in parentheses when it adds clarity: `feat(auth): add OAuth2 support`.
- Breaking changes: append `!` after type/scope and add a `BREAKING CHANGE:` footer.
- If tied to a ticket, add it in the footer: `Refs: ENC-123`.

## Examples

```text
feat(auth): add OAuth2 login support
fix(cache): prevent stale entries after TTL expiry
chore: upgrade dependencies to latest
docs: update README with setup instructions
refactor(api): extract retry logic into separate module
```
