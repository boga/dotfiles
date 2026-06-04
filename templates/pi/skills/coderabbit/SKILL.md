---
name: coderabbit
description: Run a CodeRabbit CLI (`cr`) code review. Use this skill only when the user explicitly says "Use CR", "Ask CodeRabbit", or during /implement (Step 3.5). Do not trigger on general review phrases.
---

# CodeRabbit CLI

The CodeRabbit CLI binary is `cr` (`coderabbit` is an alias — both work identically).

## Review commands

```bash
# Review all local changes vs base branch (default: main)
cr

# Review only uncommitted changes (staged + unstaged)
cr review uncommitted

# Review only committed changes (branch commits vs base)
cr review committed

# Specify a non-default base branch
cr review --base master
cr review --base develop

# Combine scope and base branch
cr review uncommitted --base master
cr review committed --base develop
```

## Workflow

### Review current branch before opening a PR

```bash
# 1. Confirm what will be reviewed
git status
git diff origin/main...HEAD --stat

# 2. Run the review
cr                   # all changes vs main
cr --base master     # if default branch is master, not main
```

### Review only staged changes

```bash
git add <files>
cr review uncommitted
```

### Review committed work on the branch

```bash
cr review committed --base main
```

## Tips

- Must run from inside a Git repository (`--dir` flag overrides the directory)
- Reviews stream results to the terminal as they complete
- Review duration: 7–30+ minutes depending on scope
- `cr` and `coderabbit` are interchangeable — prefer `cr` for brevity
