---
description: Research (web, GitHub, Linear, env), scout, plan, review, and challenge an implementation plan
argument-hint: "<task>"
---

Plan "$@" by following the steps below. Execute each step using the subagent tool.

## Step 1 — Parallel research

Run all 4 research agents in parallel to gather external context:

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

Note the `chainDir` returned — all subsequent steps must use the same `chainDir`.

## Step 2 — Scout, plan, and challenge

Run the plan chain using the same `chainDir` from Step 1:

```json
{
  "chain": [
    { "agent": "scout", "task": "Analyze the codebase for: $@\n\nRead the research artifacts from {chain_dir} for additional context.", "output": "context.md", "reads": ["research.md", "gh-context.md", "linear-context.md", "env-context.md"] },
    { "agent": "planner", "task": "Create an implementation plan. Context: {chain_dir}/context.md. Save to plan.md.", "output": "plan.md", "reads": ["context.md", "research.md", "gh-context.md", "linear-context.md", "env-context.md"] },
    { "agent": "oracle", "task": "Review the plan. Challenge assumptions. Check for drift. Report: diagnosis, drift check, recommendation, risks.", "output": "oracle-verdict.md", "reads": ["plan.md", "context.md"] }
  ],
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
