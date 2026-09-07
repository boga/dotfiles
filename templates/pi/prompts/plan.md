---
description: Research (web, GitHub, Linear, env), scout, plan, review, and challenge an implementation plan
argument-hint: "<task>"
---

Plan "$@" by following the steps below. Execute each step using the subagent tool.

## Step 0 — Pick a chainDir

Compute and create a repository-local directory for all artifacts:

```bash
chainDir="$(pwd)/tmp/agents_chain/<slug>"
mkdir -p "$chainDir"
printf '%s\n' "$chainDir"
```

Replace `<slug>` with a short kebab-case label for the task (e.g. `add-nr-skill`). Use this same absolute `chainDir` on every subagent call below. The `<slug>` prevents concurrent workflows from overwriting each other's artifacts.

## Step 1 — Validate and gather research

Define the required research artifacts as absolute paths beneath `chainDir`:

- `<chainDir>/research.md`
- `<chainDir>/gh-context.md`
- `<chainDir>/linear-context.md`
- `<chainDir>/env-context.md`

Before launching work:

1. Confirm every requested output resolves to an absolute descendant of `chainDir`. If an output escapes `chainDir`, STOP and report its requested path, resolved path, and expected directory.
2. Confirm the required research agents are available.
3. Confirm the `researcher` agent lists both `web_search` and `fetch_content` capabilities. If either capability is unavailable, run a `delegate` task that writes the web-research diagnostic below to `<chainDir>/research.md` instead of launching the researcher.

If **all 4 files exist**, skip to Step 2 — reuse cached research.

If **any are missing**, run only the missing research agents in parallel:

```json
{
  "tasks": [
    {
      "agent": "researcher",
      "task": "Research official docs, specs, benchmarks, and recent changes relevant to: $@\n\nFocus on primary sources. Use the required web_search and fetch_content tools. If either tool is unavailable, write <chainDir from Step 0>/research.md with exactly this diagnostic and exit successfully:\n\n# Web Research Diagnostic\n\nStatus: UNAVAILABLE\nReason: Required web-search or content-fetch capability is unavailable.",
      "chainDir": "<chainDir from Step 0>",
      "output": "<chainDir from Step 0>/research.md"
    },
    {
      "agent": "gh-researcher",
      "task": "Gather GitHub repository state relevant to: $@\n\nFocus on open PRs, related issues, recent CI status, and releases. If gh CLI is unavailable or the repo has no remote, write <chainDir from Step 0>/gh-context.md noting that and exit successfully.",
      "chainDir": "<chainDir from Step 0>",
      "output": "<chainDir from Step 0>/gh-context.md"
    },
    {
      "agent": "linear-researcher",
      "task": "Gather Linear project context relevant to: $@\n\nFocus on related tickets, milestones, blockers, and project status. If Linear is unreachable or no relevant issues exist, write <chainDir from Step 0>/linear-context.md noting that and exit successfully.",
      "chainDir": "<chainDir from Step 0>",
      "output": "<chainDir from Step 0>/linear-context.md"
    },
    {
      "agent": "env-scout",
      "task": "Inventory local environment state relevant to: $@\n\nFocus on tool versions, running services, and package state that matter for the task. If nothing is relevant, write <chainDir from Step 0>/env-context.md noting a clean environment and exit successfully.",
      "chainDir": "<chainDir from Step 0>",
      "output": "<chainDir from Step 0>/env-context.md"
    }
  ],
  "concurrency": 4,
  "chainDir": "<chainDir from Step 0>"
}
```

Only include tasks for agents whose output files are missing. Drop the rest.

After the fan-out completes, verify every requested artifact exists beneath `chainDir`. Retry each missing task once. If an artifact remains absent, STOP, report its exact path, and do not invoke the plan chain. Preserve successful artifacts for the next run.

## Step 2 — Scout, plan, and challenge

Run the plan chain only after all required research artifacts exist. Reuse the exact `chainDir` from Step 0:

```json
{
  "chain": "plan",
  "task": "$@",
  "chainDir": "<chainDir from Step 0>"
}
```

## Step 3 — Present findings

After the chain completes, present:

1. Full path to `plan.md`.
2. Key findings from each research source: web, GitHub, Linear, and environment.
3. The web-research diagnostic when web research was unavailable.
4. Oracle verdict and challenged assumptions.
5. Paths to all artifacts in `chainDir`: `research.md`, `gh-context.md`, `linear-context.md`, `env-context.md`, `context.md`, `plan.md`, and `oracle-verdict.md`.

<!-- {{ ansible_managed }} --->
