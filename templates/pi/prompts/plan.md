---
description: Research (web, GitHub, Linear, env), scout, plan, review, and challenge an implementation plan
argument-hint: "<task>"
---

Plan "$@" by following the steps below. Execute each step using the subagent tool.

## Step 1 — Conditional research

Check if these research artifacts already exist in the chainDir:
- `research.md`
- `gh-context.md`
- `linear-context.md`
- `env-context.md`

If **all 4 files exist**, skip to Step 2 — reuse cached research.

If **any are missing**, run only the missing research agents in parallel:

```json
{
  "tasks": [
    {
      "agent": "researcher",
      "task": "Research official docs, specs, benchmarks, and recent changes relevant to: $@\n\nFocus on primary sources. Drop stale or SEO-heavy results. Web research only — use web_search and fetch_content tools. If web tools are unavailable, write research.md noting no external research was available and exit successfully.",
      "output": "research.md"
    },
    {
      "agent": "gh-researcher",
      "task": "Gather GitHub repository state relevant to: $@\n\nFocus on open PRs, related issues, recent CI status, and releases. If gh CLI is unavailable or the repo has no remote, write gh-context.md noting that and exit successfully.",
      "output": "gh-context.md"
    },
    {
      "agent": "linear-researcher",
      "task": "Gather Linear project context relevant to: $@\n\nFocus on related tickets, milestones, blockers, and project status. If Linear is unreachable or no relevant issues exist, write linear-context.md noting that and exit successfully.",
      "output": "linear-context.md"
    },
    {
      "agent": "env-scout",
      "task": "Inventory local environment state relevant to: $@\n\nFocus on tool versions, running services, and package state that matter for the task. If nothing is relevant, write env-context.md noting a clean environment and exit successfully.",
      "output": "env-context.md"
    }
  ],
  "concurrency": 4
}
```

Only include tasks for agents whose output files are missing. Drop the rest.

Note the `chainDir` returned — use the same `chainDir` for Step 2.

## Step 2 — Scout, plan, and challenge

Run the plan chain using the same `chainDir`:

```json
{
  "chain": "plan",
  "task": "$@",
  "chainDir": "<chainDir from Step 1>"
}
```

## Step 3 — Present findings

After the chain completes, present:
1. Full path to plan.md
2. Key findings from each research source (web, GitHub, Linear, environment)
3. Oracle verdict and challenged assumptions
4. Paths to all artifacts (research.md, gh-context.md, linear-context.md, env-context.md, context.md, plan.md, oracle-verdict.md)

<!-- {{ ansible_managed }} --->
