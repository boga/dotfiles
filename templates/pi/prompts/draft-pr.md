---
description: Draft or update a PR title/description from the diff against upstream
---
Follow the `creating-pull-requests` skill to draft and apply a PR for the current branch.

1. Detect the upstream base branch dynamically (`develop`, `main`, or `master` — whichever
   `origin/HEAD` points to). Do not assume a specific name.
2. Gather the diff and commit log between the current branch and that base
   (`git log`, `git diff`, `git merge-base`) per the skill's "Gather context" step.
3. Check whether a PR already exists for the current branch:
   ```bash
   gh pr view --json number,title,body,url 2>/dev/null
   ```
   If one exists, use its current title/description as additional context when composing —
   keep any parts that are still accurate, replace what is stale or incomplete.
4. Compose a new title and description following the skill's title format and description
   structure (Why / Approach / How it works / Links).
5. Apply the result:
   - If no PR exists yet, create one as a **draft** (`gh pr create --draft ...`) per repo
     policy — never open ready-for-review unless explicitly asked.
   - If a PR already exists, update it in place with `gh pr edit --title ... --body-file ...`
     rather than creating a duplicate.
6. Verify with `gh pr view --json title,body,url` and report the PR URL, final title, and a
   summary of the description.

`$@`
