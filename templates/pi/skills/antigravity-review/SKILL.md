---
name: antigravity-review
description: Use the Antigravity CLI (`antigravity`) to get an external opinion on a plan, architecture, code changes, or pull request. Use when the user asks to review a plan, review architecture, get a second opinion, review changes, or review a PR with Antigravity.
---

# Antigravity Review

Use the `antigravity` CLI for advisory reviews and second opinions.

## Critical Rules

- **MUST** run Antigravity in advisory mode with `--mode plan`.
- **MUST NOT** use Antigravity to apply edits unless the user explicitly asks for implementation.
- **MUST NOT** pass `--dangerously-skip-permissions`.
- **MUST** use `--sandbox` when reviewing repository content.
- **MUST** tell Antigravity to return findings, trade-offs, risks, and recommendations.
- Treat Antigravity output as advice. Verify important claims before acting.

## Command Pattern

Run one-shot review prompts with:

```bash
antigravity --print --mode plan --sandbox --effort high --prompt "<review prompt>"
```

Use `--add-dir` for additional repository directories:

```bash
antigravity --print --mode plan --sandbox --effort high --add-dir /path/to/repo --prompt "<review prompt>"
```

## Review Workflow

1. Identify the review target: plan, architecture, local changes, branch diff, or PR.
2. Gather only the context needed for the target.
3. Ask Antigravity for an opinion, not implementation.
4. Summarize Antigravity's strongest findings and note any claims that still need verification.
5. Ask the user before changing files based on the review.

## Prompt Template

```text
Review this <plan|architecture|change set|pull request> as an external advisor.

Focus on:
- correctness
- maintainability
- hidden risks
- missing alternatives
- operational or security concerns
- concrete recommendations

Return:
- executive summary
- strengths
- concerns
- recommended changes
- open questions
```

## Local Changes Review

Gather the branch base dynamically when reviewing a branch diff:

```bash
BASE_REF=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD | sed 's#^origin/##')
git merge-base HEAD "origin/$BASE_REF"
git diff "origin/$BASE_REF"...HEAD
```

Then include the diff summary or relevant excerpts in the Antigravity prompt.

## PR Review

When reviewing the current branch PR, gather PR context first:

```bash
gh pr view --json number,title,body,url,baseRefName,headRefName
gh pr diff
```

Then ask Antigravity to review the PR intent, implementation, and risks.

## Plan or Architecture Review

For plans and architecture, include:

- goal and non-goals
- constraints
- relevant files or components
- proposed design
- alternatives considered
- risks already known

Do not invent missing context. Ask the user for missing requirements when the review depends on them.
