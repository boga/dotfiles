# Global Agent Rules

## Worktree Policy

Before making any code or config changes in a git repository:
1. Check existing worktrees with `wt list` to see if a relevant branch already exists.
2. If yes — switch to it.
3. If no — create a new worktree with `wt switch --create <branch-name>`.

Never commit or make changes directly on the default branch (main, master, develop, etc.).
