{% raw %}---
name: worktrunk
description: Manage git worktrees using the worktrunk CLI (`wt`). Use this skill when creating, switching, listing, merging, or removing git worktrees; running per-branch steps (commit, squash, rebase, push, diff); or configuring worktrunk hooks, aliases, and worktree path templates.
---

# Worktrunk — Git Worktree Management

Worktrunk's CLI binary is `wt` (not `worktrunk`). Always use `wt` when running commands.

## Core commands

### Create and switch to a new worktree / branch

```bash
wt switch --create <branch>          # create worktree + branch from default branch
wt switch --create <branch> -b <base># create from a specific base branch
wt switch <branch>                   # switch to existing worktree (interactive picker if no arg)
wt switch -                          # switch to previous worktree
wt switch ^                          # switch to default branch worktree
```

Launch an editor or agent immediately after creating:

```bash
wt switch --create <branch> --execute claude
wt switch --create <branch> -x 'code {{ worktree_path }}'
```

### List worktrees

```bash
wt list                  # table view: branch, path, status vs main, remote, CI
wt list --branches       # also include branches without worktrees
wt list --full           # include CI status, diffstats, LLM summaries
wt list --format=json    # machine-readable JSON
```

Useful JSON queries:

```bash
# Current worktree path
wt list --format=json | jq -r '.[] | select(.is_current) | .path'

# Branches ahead of main (need merging)
wt list --format=json | jq '.[] | select(.main.ahead > 0) | .branch'

# Safe-to-delete integrated branches
wt list --format=json | jq '.[] | select(.main_state == "integrated") | .branch'

# Worktrees with uncommitted changes
wt list --format=json | jq '.[] | select(.working_tree.modified)'
```

### Merge a branch into the default branch

`wt merge` runs: commit → squash → rebase → pre-merge hooks → fast-forward → cleanup.

```bash
wt merge                 # merge current branch into default branch
wt merge develop         # merge into a different target branch
wt merge --no-squash     # preserve individual commits
wt merge --no-remove     # keep the worktree after merging
wt merge --no-ff         # create a merge commit (semi-linear history)
wt merge -y              # skip approval prompts (automation)
```

### Remove a worktree

```bash
wt remove                        # remove current worktree (deletes merged branch)
wt remove <branch>               # remove specific worktree/branch
wt remove <branch> --no-delete-branch  # keep the branch
wt remove <branch> -D            # force-delete unmerged branch
wt remove <branch> -f            # force-remove worktree with untracked files
wt remove <branch> -f -D         # both force flags
wt remove -y                     # skip approval prompts
```

### Individual pipeline steps (`wt step`)

Use these when you need fine-grained control instead of `wt merge`.

```bash
wt step commit       # stage all changes + commit with LLM-generated message
wt step squash       # squash all branch commits into one with LLM message
wt step rebase       # rebase onto target branch
wt step push         # fast-forward target to current branch
wt step diff         # show all changes since branching (committed + staged + unstaged)
wt step copy-ignored # copy gitignored files to another worktree
wt step prune        # remove all worktrees/branches already merged into default
```

Custom alias (defined in `.config/wt.toml` or `~/.config/worktrunk/config.toml`):

```bash
wt step <alias-name>             # run a configured alias
wt step <alias-name> --dry-run   # preview the expanded command
```

### Configuration

```bash
wt config show               # show config file paths and effective settings
wt config create             # create user config (~/.config/worktrunk/config.toml)
wt config create --project   # create project config (.config/wt.toml)
wt config shell install      # install shell integration
```

## Configuration reference

**User config** — `~/.config/worktrunk/config.toml` (personal, not committed):

```toml
# Worktree location template (default: sibling directory)
worktree-path = "{{ repo_path }}/../{{ repo }}.{{ branch | sanitize }}"
# Inside the repo:  worktree-path = ".worktrees/{{ branch | sanitize }}"

# LLM commit message generation (using pi / Claude Code)
[commit.generation]
command = "CLAUDECODE= MAX_THINKING_TOKENS=0 claude -p --no-session-persistence --model=haiku --tools='' --disable-slash-commands --setting-sources='' --system-prompt=''"

# Persistent defaults
[list]
full = false
branches = false

[merge]
squash = true
remove = true
ff    = true
```

**Project config** — `.config/wt.toml` (shared with team, committed to repo):

```toml
[pre-start]
deps = "npm ci"

[pre-merge]
test = "npm test"
lint = "npm run lint"

[list]
url = "http://localhost:{{ branch | hash_port }}"

[aliases]
deploy = "make deploy BRANCH={{ branch }}"
```

## Typical workflows

### Start a new task (AI agent workflow)

```bash
wt switch --create my-feature -x claude   # create worktree + launch Claude Code
# work happens here...
wt list                                   # check status from another terminal
wt merge -y                               # merge and clean up when done
```

### Manual step-by-step merge

```bash
wt step commit    # commit work-in-progress
wt step squash    # squash into one clean commit
wt step rebase    # rebase onto main
wt step push      # fast-forward main to this branch
```

### Clean up merged branches

```bash
wt step prune        # remove all integrated worktrees at once
wt list --branches   # verify what remains
```

### Query worktrees in scripts

```bash
# cd into current worktree from a script
cd "$(wt list --format=json | jq -r '.[] | select(.is_current) | .path')"

# Loop over branches ahead of main
wt list --format=json | jq -r '.[] | select(.main.ahead > 0) | .branch' | while read b; do
  echo "Needs merge: $b"
done
```

## Status symbols in `wt list`

| Symbol | Meaning |
|--------|---------|
| `_`    | Same commit as default branch (clean, safe to delete) |
| `⊂`    | Content integrated into default branch (safe to delete) |
| `↑`    | Ahead of default branch (needs merging) |
| `↓`    | Behind default branch (needs rebase) |
| `↕`    | Diverged from default branch |
| `\|`    | In sync with remote |
| `⇡`    | Ahead of remote (needs push) |
| `⇣`    | Behind remote (needs pull) |
| `!`    | Uncommitted changes |
| `?`    | Untracked files |

## Tips

- `wt remove` runs in the **background** by default; use `--foreground` to wait.
- Use `-y` / `--yes` in automation to skip interactive prompts.
- Use `--format=json` with `jq` for scripting.
- `wt switch` opens an **interactive picker** when called with no branch argument.
- All user config keys can be overridden via env vars with `WORKTRUNK_` prefix (nested keys use `__`, e.g., `WORKTRUNK_COMMIT__GENERATION__COMMAND`).
{% endraw %}
