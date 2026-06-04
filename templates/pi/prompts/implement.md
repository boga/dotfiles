---
name: implement
description: Implement a task with context building, coding, and parallel review
---

Implement "$@" by following the decision tree below. Execute each step using the subagent tool.

## Step 0 — Establish chainDir

- **Prior `/plan` ran in this session** — reuse its `chainDir`. All research and plan artifacts are already there.
- **No prior plan** — compute a new one:

```bash
echo "$HOME/.pi/agent/sessions/--$(pwd | sed 's|^/||' | tr '/' '-')--/chain-runs/<slug>"
```

Replace `<slug>` with a short kebab-case label for the task. Use this same `chainDir` on **every** subagent call below.

## Step 1 — Determine execution mode

Check the user's request:

- **Background mode** — user says "background", "bg", or "if blocked, ask me":
  1. Run worker only (Step 3) with `async: true` and the chosen `chainDir`.
  2. Worker escalates blocked decisions via `contact_supervisor`.
  3. After worker completes, notify the user and offer to run reviewers (Step 4).
  4. Stop here until user responds.

- **Review-only mode** — user says "just review", "run reviewers", or "review what was done":
  1. Skip to Step 4 (parallel reviewers).
  2. `progress.md` must already exist from a prior worker run.

- **Standard mode** — everything else:
  1. Continue to Step 2.

## Step 2 — Determine context source

Check session state for a prior plan chain run:

- **Prior plan chain ran in this session** — reuse its `chainDir`:
  1. Skip context-builder.
  2. Worker reads existing `plan.md` and `context.md` from that `chainDir`.
  3. Go to Step 3.

- **No prior context**:
  1. Run context-builder (Step 2A), then continue to Step 3.

### Step 2A — Context building

```json
{
  "agent": "context-builder",
  "task": "Analyze the codebase for: $@",
  "chainDir": "<chainDir from Step 0>"
}
```

Outputs: `context.md`, `meta-prompt.md` in `{chain_dir}`.

## Step 3 — Implementation

```json
{
  "agent": "worker",
  "task": "Implement the task using context and meta-prompt. Escalate unapproved decisions via contact_supervisor. No placeholders, no TODOs, no silent scope changes.",
  "chainDir": "<chainDir from Step 0>",
  "output": "<chainDir from Step 0>/progress.md"
}
```

Worker reads: `context.md`, `meta-prompt.md` (or `plan.md` if from a prior plan chain).
Output: `progress.md` in `chainDir`.

## Step 3.5 — CodeRabbit review

*Skip in review-only and background modes (Step 1 gates those paths).*

```json
{
  "agent": "delegate",
  "task": "Detect the repo default branch: run `git symbolic-ref refs/remotes/origin/HEAD | sed 's|.*/||'`. Then run `cr review --plain --base <detected-branch> > <chainDir>/review-coderabbit.md 2>&1`. If cr is not found or exits non-zero, write `WARNING: CodeRabbit review skipped — cr not available or failed.` to `<chainDir>/review-coderabbit.md` and exit 0.",
  "chainDir": "<chainDir from Step 0>"
}
```

Output: `review-coderabbit.md` in `chainDir` (always written — warning line on failure).

## Step 4 — Parallel review

Run three reviewers in parallel. Each must **not** edit files — report findings only.

```json
{
  "tasks": [
    {
      "agent": "reviewer",
      "task": "If `review-coderabbit.md` exists in chainDir, CodeRabbit (CR) has already reviewed code-quality issues there — do not re-flag CR's code-quality findings. Assess intent and requirements alignment independently, including intent-level issues even if CR flagged a symptom, since CR cannot read plan.md or meta-prompt.md. Review the implementation for CORRECTNESS and FEASIBILITY. Are the changes sound and logically complete? Do they match the requirements? Any missing steps or broken assumptions? Check against meta-prompt.md constraints and plan.md (if available). Do not edit files. Report: Correct → Blocker → Note.",
      "output": "<chainDir from Step 0>/review-correctness.md"
    },
    {
      "agent": "reviewer",
      "task": "If `review-coderabbit.md` exists in chainDir, CodeRabbit (CR) has already reviewed code-quality issues there — do not re-flag CR's code-quality findings. Review the implementation for TEST COVERAGE and EDGE CASES. Are there gaps in validation or untested paths? Are edge cases handled? Is error handling adequate? Check against meta-prompt.md constraints and plan.md (if available). Do not edit files. Report: Correct → Blocker → Note.",
      "output": "<chainDir from Step 0>/review-tests.md"
    },
    {
      "agent": "reviewer",
      "task": "If `review-coderabbit.md` exists in chainDir, CodeRabbit (CR) has already reviewed code-quality issues there — do not re-flag CR's code-quality findings. Review the implementation for CLEANUP and SIMPLICITY. Is there unnecessary complexity? Dead code, poor naming, or redundant logic? Simpler alternatives? Check against meta-prompt.md constraints and plan.md (if available). Do not edit files. Report: Correct → Blocker → Note.",
      "output": "<chainDir from Step 0>/review-cleanup.md"
    }
  ],
  "concurrency": 3,
  "chainDir": "<chainDir from Step 0>"
}
```

Each reviewer reads: `progress.md`, `context.md`, `meta-prompt.md`, `plan.md` (if available), `review-coderabbit.md` (if available) from `chainDir`.

## Step 5 — Apply fixes and present findings

After reviewers complete:

1. **If blockers found** — stop and present to the user:
   - Summary of what worker implemented (from `progress.md`).
   - Blockers that need user decision.
   - Paths to all artifacts.
   - **Wait for user confirmation before applying any fixes.**

2. **If no blockers** — auto-apply non-blocker fixes:

```json
{
  "agent": "worker",
  "task": "Apply the reviewer fixes. Skip suggestions that conflict with meta-prompt constraints or expand scope. Report what was applied vs skipped with rationale.",
  "chainDir": "<chainDir from Step 0>"
}
```

Then present:
   - Summary of what worker implemented and what fixes were applied.
   - Key findings per reviewer — notes and suggestions that were skipped.
   - Paths to all artifacts: `context.md`, `meta-prompt.md`, `progress.md`, `review-coderabbit.md` (if present), `review-correctness.md`, `review-tests.md`, `review-cleanup.md`.

Worker reads: `review-correctness.md`, `review-tests.md`, `review-cleanup.md`, `context.md` from `chainDir`.

<!-- {{ ansible_managed }} --->
