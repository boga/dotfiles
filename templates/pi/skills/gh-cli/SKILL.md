{% raw %}---
name: gh-cli
description: Work with GitHub using the gh CLI. Use this skill for pull requests (create, review, merge, checks), issues (create, list, edit), GitHub Actions runs (list, view logs, rerun), repository management, and GitHub API queries.
---

# GitHub CLI (`gh`)

## Pull Requests

### Create

```bash
gh pr create                                      # interactive prompt
gh pr create --fill                               # title + body from commit messages
gh pr create --title "Fix bug" --body "Details"
gh pr create --draft
gh pr create --base main --reviewer alice,bob
gh pr create --label bug --assignee "@me"
```

### View & list

```bash
gh pr status                        # PRs relevant to you (current branch, review requests)
gh pr view                          # current branch's PR
gh pr view 123
gh pr view 123 --comments
gh pr view 123 --web
gh pr list                          # open PRs in current repo
gh pr list --author "@me"
gh pr list --state merged
gh pr list --label bug --label "priority 1"
gh pr list --search "status:success review:required"
```

### Review

```bash
gh pr review --approve
gh pr review --request-changes --body "Needs tests"
gh pr review --comment --body "Nice approach"
gh pr review 123 --approve
```

### CI checks

```bash
gh pr checks                        # checks for current branch's PR
gh pr checks 123
gh pr checks --watch                # stream until all checks complete
gh pr checks --watch --fail-fast    # exit on first failure
gh pr checks --json name,state,bucket --jq '.[] | select(.bucket=="fail")'
```

### Merge

```bash
gh pr merge                         # interactive: current branch's PR
gh pr merge 123 --squash --delete-branch
gh pr merge 123 --rebase
gh pr merge 123 --merge             # merge commit
gh pr merge 123 --auto --squash     # auto-merge when checks pass
```

### Edit & manage

```bash
gh pr edit 123 --title "New title" --body "New body"
gh pr edit 123 --add-label bug --remove-label wip
gh pr edit 123 --add-reviewer alice --add-assignee "@me"
gh pr ready 123                     # mark draft as ready for review
gh pr close 123
gh pr reopen 123
gh pr update-branch 123             # rebase/merge base branch into PR branch
gh pr diff 123
gh pr checkout 123                  # check out PR branch locally
```

## Issues

### Create & view

```bash
gh issue create --title "Bug: crash on startup" --body "Steps to reproduce..."
gh issue create --label bug --assignee "@me"
gh issue view 123
gh issue view 123 --web
```

### List

```bash
gh issue list
gh issue list --assignee "@me"
gh issue list --label bug --state open
gh issue list --search "error no:assignee sort:created-asc"
gh issue list --state all
```

### Edit & manage

```bash
gh issue edit 123 --title "Updated title"
gh issue edit 123 --add-label "help wanted" --remove-label bug
gh issue close 123
gh issue reopen 123
gh issue comment 123 --body "Working on this"
gh issue develop 123                # create a linked branch for the issue
```

## GitHub Actions

### Runs

```bash
gh run list                         # recent runs
gh run list --branch main --status failure
gh run list --workflow ci.yml
gh run view                         # interactive picker
gh run view 12345
gh run view 12345 --log             # full log
gh run view 12345 --log-failed      # logs for failed steps only
gh run view 12345 --verbose         # show job steps
gh run watch 12345                  # stream progress until complete
gh run rerun 12345                  # rerun entire run
gh run rerun 12345 --failed         # rerun only failed jobs
```

### Get job IDs for targeted reruns

```bash
gh run view 12345 --json jobs --jq '.jobs[] | {name, databaseId}'
gh run rerun 12345 --job <databaseId>
```

### Workflows

```bash
gh workflow list
gh workflow view ci.yml
gh workflow run ci.yml
gh workflow run ci.yml --ref my-branch
gh workflow disable ci.yml
gh workflow enable ci.yml
```

## Repositories

```bash
gh repo view                        # current repo summary
gh repo view owner/repo --web
gh repo clone owner/repo
gh repo create my-new-repo --public
gh repo fork owner/repo --clone
gh repo set-default owner/repo      # set default repo for current directory
gh repo edit --description "New description" --visibility public
```

## Search

```bash
gh search prs "fix login" --state open
gh search issues "memory leak" --label bug --repo owner/repo
gh search repos "cli tool" --language go --sort stars
gh search code "TODO" --repo owner/repo
```

## API queries

```bash
# REST API
gh api repos/{owner}/{repo}/pulls --jq '.[].title'
gh api repos/{owner}/{repo}/issues/123
gh api --method POST repos/{owner}/{repo}/issues \
  --field title="Bug report" --field body="Details" --field labels[]="bug"

# Paginate through all results
gh api --paginate repos/{owner}/{repo}/issues --jq '.[].number'

# GraphQL
gh api graphql -f query='
  query($owner:String!, $repo:String!) {
    repository(owner:$owner, name:$repo) {
      pullRequests(first:5, states:OPEN) {
        nodes { number title }
      }
    }
  }' -f owner="{owner}" -f repo="{repo}"
```

## JSON output & filtering

All list/view commands support `--json fields --jq expression`:

```bash
# PR numbers and titles
gh pr list --json number,title --jq '.[] | "\(.number) \(.title)"'

# Failed check names for current PR
gh pr checks --json name,bucket --jq '.[] | select(.bucket=="fail") | .name'

# Run IDs that failed on main
gh run list --branch main --json databaseId,conclusion \
  --jq '.[] | select(.conclusion=="failure") | .databaseId'

# Open issues assigned to me with their labels
gh issue list --assignee "@me" --json number,title,labels \
  --jq '.[] | {number, title, labels: [.labels[].name]}'
```

## Tips

- Most commands default to the current repo; use `-R owner/repo` to target another.
- Use `@me` as a shorthand for your own GitHub username in filters.
- `--web` on almost any command opens the relevant GitHub page in the browser.
- `GH_REPO=owner/repo gh ...` sets the repo for a single command without `-R`.
- `gh status` gives a cross-repo overview of your open PRs, review requests, and mentions.
{% endraw %}
