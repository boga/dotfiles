---
name: implement
description: Implement a task with context building, coding, and parallel review
---

Implement "$@" by following the decision tree below. Execute each step using the subagent tool.

## Step 1 — Determine execution mode

Check the user's request:

- **Background mode** — user says "background", "bg", or "if blocked, ask me":
  1. Run worker only (Step 3) with `async: true`.
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
  1. Skip the implement chain. Run worker directly with `plan.md` and `context.md` from that `chainDir`.
  2. Research artifacts (`research.md`, `gh-context.md`, `linear-context.md`, `env-context.md`) are available in the same `chainDir` — pass them to worker for additional context.
  3. After worker completes, run parallel reviewers (Step 4) using the same `chainDir`.
  4. Go to Step 5.

- **No prior context** — run the implement chain:

```json
{
  "chain": "implement",
  "task": "$@"
}
```

The chain runs: context-builder → worker → 3 parallel reviewers.
Go to Step 5.

## Step 3 — Implementation (background/plan-reuse mode only)

Only used when skipping the chain (background mode or prior plan reuse).

```json
{
  "agent": "worker",
  "task": "Implement the task using context and meta-prompt. Escalate unapproved decisions via contact_supervisor. No placeholders, no TODOs, no silent scope changes."
}
```

Worker reads: `context.md`, `meta-prompt.md` (or `plan.md` if from a prior plan chain).
If research artifacts exist in `chainDir` (`research.md`, `gh-context.md`, `linear-context.md`, `env-context.md`), worker may reference them for implementation details.
Output: `progress.md`.

## Step 4 — Parallel review (background/plan-reuse/review-only mode)

Only used when not running the full implement chain (chain includes reviewers).

```json
{
  "tasks": [
    {
      "agent": "reviewer",
      "task": "Review the implementation for CORRECTNESS and FEASIBILITY. Are the changes sound and logically complete? Do they match the requirements? Any missing steps or broken assumptions? Check against meta-prompt.md constraints and plan.md (if available). Do not edit files. Report: Correct → Blocker → Note.",
      "output": "review-correctness.md"
    },
    {
      "agent": "reviewer",
      "task": "Review the implementation for TEST COVERAGE and EDGE CASES. Are there gaps in validation or untested paths? Are edge cases handled? Is error handling adequate? Check against meta-prompt.md constraints and plan.md (if available). Do not edit files. Report: Correct → Blocker → Note.",
      "output": "review-tests.md"
    },
    {
      "agent": "reviewer",
      "task": "Review the implementation for CLEANUP and SIMPLICITY. Is there unnecessary complexity? Dead code, poor naming, or redundant logic? Simpler alternatives? Check against meta-prompt.md constraints and plan.md (if available). Do not edit files. Report: Correct → Blocker → Note.",
      "output": "review-cleanup.md"
    }
  ],
  "concurrency": 3
}
```

Each reviewer reads: `progress.md`, `context.md`, `meta-prompt.md`, `plan.md` (if available from prior plan chain).

## Step 5 — Present findings

After reviewers complete, present to the user:

1. Summary of what worker implemented (from `progress.md`).
2. Key findings per reviewer — blockers first, then fixes, then notes.
3. Paths to all artifacts: `context.md`, `meta-prompt.md`, `progress.md`, `review-correctness.md`, `review-tests.md`, `review-cleanup.md`.

**Stop and wait for user confirmation before proceeding to Step 6.**

## Step 6 — Apply fixes (only after user confirms)

```json
{
  "agent": "worker",
  "task": "Apply the reviewer fixes that make sense. Skip suggestions that conflict with meta-prompt constraints or expand scope. Report what was applied vs skipped with rationale."
}
```

Worker reads: `review-correctness.md`, `review-tests.md`, `review-cleanup.md`, `context.md`.

<!-- {{ ansible_managed }} --->
