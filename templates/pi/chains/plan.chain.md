---
name: plan
description: Research (web, GitHub, Linear, env), scout codebase, plan, and challenge implementation
---

## parallel

### researcher
output: research.md

Research official docs, specs, benchmarks, and recent changes relevant to: {task}

Focus on primary sources. Drop stale or SEO-heavy results. Web research only — use web_search and fetch_content tools. If web tools are unavailable, write research.md noting no external research was available and exit successfully.

### gh-researcher
output: gh-context.md

Gather GitHub repository state relevant to: {task}

Focus on open PRs, related issues, recent CI status, and releases. If gh CLI is unavailable or the repo has no remote, write gh-context.md noting that and exit successfully.

### linear-researcher
output: linear-context.md

Gather Linear project context relevant to: {task}

Focus on related tickets, milestones, blockers, and project status. If Linear is unreachable or no relevant issues exist, write linear-context.md noting that and exit successfully.

### env-scout
output: env-context.md

Inventory local environment state relevant to: {task}

Focus on tool versions, running services, and package state that matter for the task. If nothing is relevant, write env-context.md noting a clean environment and exit successfully.

## scout
reads: research.md, gh-context.md, linear-context.md, env-context.md
output: context.md

Analyze the codebase for {task}

Read the research artifacts from {chain_dir} for additional context on what to look for:
- research.md — web research (docs, specs, benchmarks)
- gh-context.md — GitHub state (PRs, issues, CI)
- linear-context.md — Linear project state (tickets, milestones)
- env-context.md — local environment (tool versions, services)

## planner
reads: context.md, research.md, gh-context.md, linear-context.md, env-context.md
output: plan.md

Create an implementation plan based on the codebase context and research findings.

Context: {chain_dir}/context.md
Web research: {chain_dir}/research.md
GitHub context: {chain_dir}/gh-context.md
Linear context: {chain_dir}/linear-context.md
Environment context: {chain_dir}/env-context.md

Save the plan to plan.md. When done, report the full path to plan.md.

## oracle
reads: plan.md, context.md
output: oracle-verdict.md

Review the plan. Challenge assumptions. Check for drift from the original task requirements. Surface contradictions, hidden risks, and anything the planner may have missed.

Report: inherited decisions, diagnosis, drift check, recommendation, risks.

<!-- {{ ansible_managed }} --->
