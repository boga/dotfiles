# Global Agent Rules

## Markdown Styleguide

Before writing or editing agent-facing Markdown, read and follow `STYLEGUIDE_MARKDOWN.md`.

## Project-local Rules

At the start of every session, check if `CLAUDE.local.md` exists in the repository root. If it does, read it and follow any instructions it contains.

## Worktree Policy — MANDATORY

**Run every check below once per session (or after a reset/compact). No exceptions unless the user explicitly says otherwise.**

Once verified, treat the result as valid for the rest of the session and skip re-checking before each subsequent edit — unless a drift signal appears (see "Re-verify on drift" below).

On first file edit of a session:
1. Verify the file is inside the current repository. If it is not, **stop and ask for explicit confirmation before making any edit** — this applies even if the user's message only implies or describes a fix, and regardless of how the worktree checks below resolve.
2. Check the current branch.
3. **If the current branch is NOT `develop`, `main`, or `master`, the directory you are already in IS the feature worktree.** Do not run `wt switch --create` or consult `wt list` to look for another one — just work here. This applies even if the branch name doesn't look like a typical feature-branch name.
4. Only if the current branch IS `develop`, `main`, or `master`: run `wt list` to check for an existing worktree for the change you intend to make.
   - If a relevant worktree already exists, switch to it instead of creating another one.
   - Otherwise, create one with `wt switch --create <branch-name>`.
5. If you are unsure whether an existing non-main branch/worktree is "relevant" to the current task, **stop and ask** before creating a second worktree.
6. Only then make changes, commit and push from the feature branch.
7. Create or update a PR. Only merge via `wt merge` if the user explicitly asks.

### Re-verify on drift

Skip steps 1-5 on later edits in the same session, except re-run them if any of these appear:
- The user references a different file, repo, or path than the one already verified.
- `git status`/`git branch` output (from any command you already ran) shows something unexpected — different branch, unstaged changes you didn't make, etc.
- A long gap or unrelated task happened since the last check.
- Anything matching the "Unexpected State" triggers below.

When in doubt, re-verify rather than assume.

### Question vs. Instruction

Before editing any file, classify the user's message:
- Questions ("why did...", "how do I...", "what would prevent...", "do X have...") → answer in text only. Make zero edits.
- Instructions ("do this", "fix this", "apply that", "propose" + explicit follow-up "yes") → edit only the file(s) named or clearly scoped by the instruction.

If unsure which one it is, treat it as a question and ask before editing.

The only exception is when the user explicitly says something like *"commit directly to main"*, *"skip the branch"*, or *"create another worktree"*.

## Commit Message Convention

Before composing commit messages, read and follow `COMMIT_MESSAGE_CONVENTION.md` (`~/.pi/agent/COMMIT_MESSAGE_CONVENTION.md`).

## Commit and Push

When the user says "commit and push" (or equivalent) — do exactly that and nothing else.
Do not edit files. If the working tree state is unclear or unexpected, ask the user before touching any files.

## File Operations

When the user references a specific file (e.g. `@AGENTS.md`, `src/foo.ts`), operate on **that exact file only**.

Do **not** use `find` or glob patterns to discover and act on other files with the same name. If you notice other related files that might also need the same change, **ask the user first** before touching them.

## Unexpected State — Stop and Ask

If you notice anything that does not match your expectations about the repository, filesystem, or environment, **STOP immediately**. Do not investigate, read further files, or run commands. Describe what you observed and ask the user how to proceed.

Treat the following as unexpected state triggers:

- Current branch is not what the task implies.
- Worktrees exist that you did not create and were not mentioned.
- Files are modified, staged, or untracked outside the scope of the current task.
- Working directory is outside the expected repository.
- Stale lock files, merge conflicts, or detached HEAD state.
- Directory structure or file names differ from what the task described.

Before every action, verify:

1. Is the current state consistent with what was described or agreed?
2. If not — **STOP** and ask before proceeding.

## CodeRabbit Policy

Run `coderabbit` (CodeRabbit CLI) **only** in two situations:

1. During `/implement` — as Step 3.5, after the worker and before the Pi reviewers.
2. When the user explicitly says so: "Use CodeRabbit" or "Ask CodeRabbit".

Never invoke `coderabbit` spontaneously during planning, exploration, or general code review.

---

## context-mode — MANDATORY routing rules

context-mode MCP tools available. Rules protect context window from flooding. One unrouted command dumps 56 KB into context. Pi enforces routing via hooks (`tool_call` blocks `curl`/`wget`) AND these instructions. Hooks = hard enforcement; rules = completeness for redirections hooks cannot catch.

### Think in Code — MANDATORY

Analyze/compare/count/filter/parse/search/transform data: **write code** via `ctx_execute(language, code)`, `console.log()` only the answer. Do NOT read raw data into context. PROGRAM the analysis, not COMPUTE it. Pure JavaScript — Node.js built-ins only (`child_process`, `fs`, `path`). `try/catch`, handle `null`/`undefined`. One script replaces ten tool calls.

### BLOCKED — do NOT use

#### curl / wget — FORBIDDEN (hook-enforced)
Do NOT use `curl`/`wget` in `bash`. Pi hooks block these. Dumps raw HTTP into context.
Use: `ctx_fetch_and_index(url, source)` or `ctx_execute(language: "javascript", code: "const r = await fetch(...)")`

#### Inline HTTP — FORBIDDEN
No `node -e "fetch(...)"`, `python -c "requests.get(...)"`. Bypasses sandbox.
Use: `ctx_execute(language, code)` — only stdout enters context

#### Direct web fetching — FORBIDDEN
Raw HTML can exceed 100 KB.
Use: `ctx_fetch_and_index(url, source)` then `ctx_search(queries)`

### REDIRECTED — use sandbox

#### bash (>20 lines output)
`bash` ONLY for: `cd`, `git`, `ls`, `mkdir`, `mv`, `npm install`, `pip install`, `rm`.
Otherwise: `ctx_batch_execute(commands, queries)` or `ctx_execute(language: "shell", code: "...")`

#### read (for analysis)
Reading to **edit** → `read` correct. Reading to **analyze/explore/summarize** → `ctx_execute_file(path, language, code)`.

#### grep / find (large results)
Use `ctx_execute(language: "shell", code: "grep ...")` in sandbox.

### Tool selection

0. **MEMORY**: `ctx_search(sort: "timeline")` — after resume, check prior context before asking user.
1. **GATHER**: `ctx_batch_execute(commands, queries)` — runs all commands, auto-indexes, returns search. ONE call replaces 30+. Each command: `{label: "header", command: "..."}`.
2. **FOLLOW-UP**: `ctx_search(queries: ["q1", "q2", ...])` — all questions as array, ONE call (default relevance mode).
3. **PROCESSING**: `ctx_execute(language, code)` | `ctx_execute_file(path, language, code)` — sandbox, only stdout enters context.
4. **WEB**: `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` — raw HTML never enters context.
5. **INDEX**: `ctx_index(content, source)` — store in FTS5 for later search.

### Output

Terse like caveman. Technical substance exact. Only fluff die.
Drop: articles, filler (just/really/basically), pleasantries, hedging. Fragments OK. Short synonyms. Code unchanged.
Pattern: [thing] [action] [reason]. [next step]. Auto-expand for: security warnings, irreversible actions, user confusion.
Write artifacts to FILES — never inline. Return: file path + 1-line description.
Descriptive source labels for `search(source: "label")`.

### Session Continuity

Skills, roles, and decisions persist for the entire session. Do not abandon them as the conversation grows.

### Memory

Session history is persistent and searchable. On resume, search BEFORE asking the user:

| Need                    | Command                                                                   |
|-------------------------|---------------------------------------------------------------------------|
| What constraints exist? | `ctx_search(queries: ["constraint"], source: "constraint")`               |
| What did we decide?     | `ctx_search(queries: ["decision"], source: "decision", sort: "timeline")` |

DO NOT ask "what were we working on?" — SEARCH FIRST.
If search returns 0 results, proceed as a fresh session.

### ctx commands

| Command       | Action                                                                        |
|---------------|-------------------------------------------------------------------------------|
| `ctx doctor`  | Call `doctor` MCP tool, run returned shell command, display as checklist      |
| `ctx purge`   | Call `purge` MCP tool with confirm: true. Warns before wiping knowledge base. |
| `ctx stats`   | Call `stats` MCP tool, display full output verbatim                           |
| `ctx upgrade` | Call `upgrade` MCP tool, run returned shell command, display as checklist     |

After /clear or /compact: knowledge base and session stats preserved. Use `ctx purge` to start fresh.

