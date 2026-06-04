---
name: coderabbit
description: Run a CodeRabbit CLI (`coderabbit`) code review. Use this skill only when the user explicitly says "Use CodeRabbit", "Ask CodeRabbit", or during /implement (Step 3.5). Do not trigger on general review phrases.
---

# CodeRabbit CLI

The CodeRabbit CLI binary is `coderabbit`.

## Review commands

```bash
# Review all local changes vs base branch (default: main)
coderabbit

# Review only uncommitted changes (staged + unstaged)
coderabbit review uncommitted

# Review only committed changes (branch commits vs base)
coderabbit review committed

# Specify a non-default base branch
coderabbit review --base master
coderabbit review --base develop

# Combine scope and base branch
coderabbit review uncommitted --base master
coderabbit review committed --base develop
```

## Workflow

### Review current branch before opening a PR

```bash
# 1. Confirm what will be reviewed
git status
git diff origin/main...HEAD --stat

# 2. Run the review
coderabbit                   # all changes vs main
coderabbit --base master     # if default branch is master, not main
```

### Review only staged changes

```bash
git add <files>
coderabbit review uncommitted
```

### Review committed work on the branch

```bash
coderabbit review committed --base main
```

## Output modes

```bash
coderabbit review --plain --base main   # readable text output (default for human/LLM consumption)
coderabbit review --agent --base main   # structured JSON output (for machine parsing)
```

Prefer `--plain` when the output will be read by a person or an LLM. Use `--agent` only when a script needs to parse status or findings count.

## Tips

- Must run from inside a Git repository (`--dir` flag overrides the directory)
- Reviews stream results to the terminal as they complete
- Review duration: 7–30+ minutes depending on scope
- Must use the full `coderabbit` binary name (`cr` alias is not always available)
