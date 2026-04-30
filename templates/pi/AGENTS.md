# Global Agent Rules

## Project-local Rules

At the start of every session, check if `CLAUDE.local.md` exists in the repository root. If it does, read it and follow any instructions it contains.

## Worktree Policy — MANDATORY

**Before editing any file, you MUST pass both checks below. No exceptions unless the user explicitly says otherwise.**

Before every file edit:
1. Verify the file is inside the current repository — if not, **stop and ask**.
2. Check the current branch — if it is `master` or `main`, **stop**.
3. Check existing worktrees with `wt list` to see if a relevant branch already exists.
4. If yes — switch to it.
5. If no — create a new worktree with `wt switch --create <branch-name>`.
6. Only then make changes, commit and push from the feature branch.
7. Create or update a PR. Only merge via `wt merge` if the user explicitly asks.

The only exception is when the user explicitly says something like *"commit directly to main"* or *"skip the branch"*.

## Commit Message Convention

Always use **Conventional Commits** format for all commit messages:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

| Type       | When to use                                         |
|------------|-----------------------------------------------------|
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

### Rules

- Description is lowercase, imperative mood, no trailing period
- Use a scope in parentheses when it adds clarity: `feat(auth): add OAuth2 support`
- Breaking changes: append `!` after type/scope and add `BREAKING CHANGE:` footer
- If tied to a ticket, add it in the footer: `Refs: ENC-123`

### Examples

```
feat(auth): add OAuth2 login support
fix(cache): prevent stale entries after TTL expiry
chore: upgrade dependencies to latest
docs: update README with setup instructions
refactor(api): extract retry logic into separate module
```

## Commit and Push

When the user says "commit and push" (or equivalent) — do exactly that and nothing else.
Do not edit files. If the working tree state is unclear or unexpected, ask the user before touching any files.

## File Operations

When the user references a specific file (e.g. `@AGENTS.md`, `src/foo.ts`), operate on **that exact file only**.

Do **not** use `find` or glob patterns to discover and act on other files with the same name. If you notice other related files that might also need the same change, **ask the user first** before touching them.

---

# context-mode — MANDATORY routing rules

context-mode MCP tools available. Rules protect context window from flooding. One unrouted command dumps 56 KB into context. Pi enforces routing via hooks (`tool_call` blocks `curl`/`wget`) AND these instructions. Hooks = hard enforcement; rules = completeness for redirections hooks cannot catch.

## Think in Code — MANDATORY

Analyze/compare/count/filter/parse/search/transform data: **write code** via `ctx_execute(language, code)`, `console.log()` only the answer. Do NOT read raw data into context. PROGRAM the analysis, not COMPUTE it. Pure JavaScript — Node.js built-ins only (`child_process`, `fs`, `path`). `try/catch`, handle `null`/`undefined`. One script replaces ten tool calls.

## BLOCKED — do NOT use

### curl / wget — FORBIDDEN (hook-enforced)
Do NOT use `curl`/`wget` in `bash`. Pi hooks block these. Dumps raw HTTP into context.
Use: `ctx_fetch_and_index(url, source)` or `ctx_execute(language: "javascript", code: "const r = await fetch(...)")`

### Inline HTTP — FORBIDDEN
No `node -e "fetch(...)"`, `python -c "requests.get(...)"`. Bypasses sandbox.
Use: `ctx_execute(language, code)` — only stdout enters context

### Direct web fetching — FORBIDDEN
Raw HTML can exceed 100 KB.
Use: `ctx_fetch_and_index(url, source)` then `ctx_search(queries)`

## REDIRECTED — use sandbox

### bash (>20 lines output)
`bash` ONLY for: `cd`, `git`, `ls`, `mkdir`, `mv`, `npm install`, `pip install`, `rm`.
Otherwise: `ctx_batch_execute(commands, queries)` or `ctx_execute(language: "shell", code: "...")`

### read (for analysis)
Reading to **edit** → `read` correct. Reading to **analyze/explore/summarize** → `ctx_execute_file(path, language, code)`.

### grep / find (large results)
Use `ctx_execute(language: "shell", code: "grep ...")` in sandbox.

## Tool selection

0. **MEMORY**: `ctx_search(sort: "timeline")` — after resume, check prior context before asking user.
1. **GATHER**: `ctx_batch_execute(commands, queries)` — runs all commands, auto-indexes, returns search. ONE call replaces 30+. Each command: `{label: "header", command: "..."}`.
2. **FOLLOW-UP**: `ctx_search(queries: ["q1", "q2", ...])` — all questions as array, ONE call (default relevance mode).
3. **PROCESSING**: `ctx_execute(language, code)` | `ctx_execute_file(path, language, code)` — sandbox, only stdout enters context.
4. **WEB**: `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` — raw HTML never enters context.
5. **INDEX**: `ctx_index(content, source)` — store in FTS5 for later search.

## Output

Terse like caveman. Technical substance exact. Only fluff die.
Drop: articles, filler (just/really/basically), pleasantries, hedging. Fragments OK. Short synonyms. Code unchanged.
Pattern: [thing] [action] [reason]. [next step]. Auto-expand for: security warnings, irreversible actions, user confusion.
Write artifacts to FILES — never inline. Return: file path + 1-line description.
Descriptive source labels for `search(source: "label")`.

## Session Continuity

Skills, roles, and decisions persist for the entire session. Do not abandon them as the conversation grows.

## Memory

Session history is persistent and searchable. On resume, search BEFORE asking the user:

| Need                    | Command                                                                   |
|-------------------------|---------------------------------------------------------------------------|
| What constraints exist? | `ctx_search(queries: ["constraint"], source: "constraint")`               |
| What did we decide?     | `ctx_search(queries: ["decision"], source: "decision", sort: "timeline")` |

DO NOT ask "what were we working on?" — SEARCH FIRST.
If search returns 0 results, proceed as a fresh session.

## ctx commands

| Command       | Action                                                                        |
|---------------|-------------------------------------------------------------------------------|
| `ctx doctor`  | Call `doctor` MCP tool, run returned shell command, display as checklist      |
| `ctx purge`   | Call `purge` MCP tool with confirm: true. Warns before wiping knowledge base. |
| `ctx stats`   | Call `stats` MCP tool, display full output verbatim                           |
| `ctx upgrade` | Call `upgrade` MCP tool, run returned shell command, display as checklist     |

After /clear or /compact: knowledge base and session stats preserved. Use `ctx purge` to start fresh.

