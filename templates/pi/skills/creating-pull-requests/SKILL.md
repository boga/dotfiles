{% raw %}---
name: creating-pull-requests
description: Use this skill when creating pull requests, drafting PR descriptions, or running `gh pr create`. Ensures proper PR formatting with active-voice titles and structured descriptions explaining why, how, and context links.
---

# Creating Pull Requests

Create well-structured pull requests with clear titles and comprehensive descriptions.

## Critical Rules

**NEVER do these:**

- Do NOT add yourself as a coauthor on commits (no `Co-Authored-By` headers)
- Do NOT include phrases like "Generated with Claude" or "Created by AI"
- Do NOT mention AI or Claude anywhere in commits or PR descriptions

## PR Title Format

Use **active voice** with a present-tense verb:

| Good                              | Bad                       |
|-----------------------------------|---------------------------|
| Add user authentication           | Added user authentication |
| Fix memory leak in cache          | Fixing memory leak        |
| Update dependencies to latest     | Dependency updates        |
| Remove deprecated API endpoints   | Removed deprecated API    |
| Refactor database connection pool | Database refactoring      |

**Pattern**: `<Verb> <what> [to/in/for <context>]`

Common verbs: Add, Fix, Update, Remove, Refactor, Implement, Improve, Replace, Enable, Disable

## PR Description Structure

```markdown
## Why

[Explain the motivation. What problem does it solve? What feature does it enable?]

## Approach

[Explain why this implementation was chosen over alternatives. What trade-offs were considered?]

## How it works

[Describe the technical implementation. How does the code achieve the goal?]

## Links

- [Ticket](url) or JIRA-123
- [Slack thread](url)
```

## Step-by-Step Process

### 1. Gather context

Determine the default branch dynamically instead of assuming `main`:

```bash
git symbolic-ref --quiet --short refs/remotes/origin/HEAD   # e.g. origin/main or origin/master
BASE_REF=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD | sed 's#^origin/##')
git log "origin/$BASE_REF"..HEAD --oneline                 # commits on this branch
git diff "origin/$BASE_REF"...HEAD                         # full diff
git merge-base HEAD "origin/$BASE_REF"                     # merge base for precise comparisons
git branch --show-current                                   # current branch name
```

If `origin/HEAD` is unavailable, inspect `git remote show origin` and use the reported HEAD branch.

### 2. Identify links and references

Look in commit messages and the branch name for:
- Jira/ticket numbers
- Related Slack threads or discussions
- Any relevant external URLs

### 3. Draft and create the PR

Prefer `--body-file` or a single-quoted heredoc saved to a temp file. This avoids shell interpolation bugs with backticks and inline code spans.

```bash
cat > /tmp/pr-body.md <<'EOF'
## Why

[Motivation here]

## Approach

[Implementation rationale here]

## How it works

[Technical details here]

## Links

- [Ticket](url)
EOF

gh pr create --base "$BASE_REF" --title "Add feature X" --body-file /tmp/pr-body.md
```

After creation, verify what GitHub received:

```bash
gh pr view --json title,body,url
```

If formatting was mangled, immediately repair it with:

```bash
gh pr edit --body-file /tmp/pr-body.md
```

## Example

**Branch**: `feature/add-retry-logic`  
**Commits**: Adds exponential backoff retry to HTTP client

**Title**: `Add exponential backoff retry to HTTP client`

**Description**:

```markdown
## Why

HTTP requests to external services occasionally fail due to transient network issues. Without
retry logic, these failures cascade to users as errors.

## Approach

Chose exponential backoff over fixed-interval retry to avoid thundering herd problems during
partial outages. Used a max of 3 retries with jitter to spread out retry attempts.

## How it works

Wraps the existing HTTP client with a retry decorator. On 5xx responses or network errors,
waits `2^attempt * 100ms + random(0-50ms)` before retrying. Logs each retry for observability.

## Links

- [PROJ-1234](https://jira.example.com/browse/PROJ-1234)
- [Slack discussion](https://slack.com/archives/...)
```

## Common `gh pr create` flags

```bash
gh pr create                                    # fully interactive
gh pr create --fill                             # title + body from commit messages
gh pr create --draft                            # open as draft
gh pr create --base "$BASE_REF"                # target the detected default base branch
gh pr create --body-file /tmp/pr-body.md        # safest for markdown with backticks/code spans
gh pr create --reviewer alice,bob
gh pr create --label bug --assignee "@me"
gh pr create --web                              # finish in the browser
```

## Validation Checklist

- [ ] Title uses active voice with a present-tense verb
- [ ] Description has Why, Approach, and How it works sections
- [ ] All relevant links are included
- [ ] No AI/Claude attribution anywhere in the PR or commits
- [ ] No `Co-Authored-By` headers in commits
- [ ] Base branch was detected dynamically instead of assuming `main`
- [ ] Created PR body was verified with `gh pr view`
{% endraw %}
