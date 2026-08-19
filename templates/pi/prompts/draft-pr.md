---
description: Draft or update a PR title/description from the diff against upstream
---
Follow the `creating-pull-requests` skill to draft and apply a PR for the current branch.

1. Detect the upstream base branch dynamically (`develop`, `main`, or `master` — whichever
   `origin/HEAD` points to). Do not assume a specific name.
2. Gather the diff and commit log between the current branch and that base
   (`git log`, `git diff`, `git merge-base`) per the skill's "Gather context" step.
3. Determine whether PR management is even possible on this remote/host:
   ```bash
   command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && gh repo view >/dev/null 2>&1
   ```
   If any of those fail (no `gh` binary, not authenticated, or `gh repo view` rejects the
   remote — e.g. a GitLab/Bitbucket/self-hosted remote `gh` doesn't support), treat this as a
   **push-only site**: no PR create/edit is possible from here.
4. Check whether a PR already exists for the current branch — **only if the capability check
   in step 3 passed**:
   ```bash
   gh pr view --json number,title,body,url 2>/dev/null
   ```
   If one exists, use its current title/description as additional context when composing —
   keep any parts that are still accurate, replace what is stale or incomplete.
5. Compose a new title and description following the skill's title format and description
   structure (Why / Approach / How it works / Links).
6. Apply the result:
   - **Push-only site (step 3 failed)**: do not attempt `gh pr create`/`gh pr edit`. Push the
     branch if not already pushed, write the composed title/description to a local file
     (e.g. `/tmp/pr-body.md`), print the title and full body in the response, and tell the
     user to paste it manually into the host's web UI when opening the PR themselves.
   - **PR management available and no PR exists yet**: create one as a **draft**
     (`gh pr create --draft ...`) per repo policy — never open ready-for-review unless
     explicitly asked.
   - **PR management available and a PR already exists**: update it in place with
     `gh pr edit --title ... --body-file ...` rather than creating a duplicate.
7. If a PR was created/updated, verify with `gh pr view --json title,body,url` and report the
   PR URL, final title, and a summary of the description. If push-only, report the file path
   and confirm the branch was pushed.

`$@`
