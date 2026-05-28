---
name: plan
description: Scout codebase, plan, and challenge implementation (called after parallel research)
---

## scout
reads: research.md, gh-context.md, linear-context.md, env-context.md
output: context.md

Analyze the codebase for {task}

Read the research artifacts from {chain_dir} for additional context on what to look for:
- research.md — web research (docs, specs, benchmarks)
- gh-context.md — GitHub state (PRs, issues, CI)
- linear-context.md — Linear project state (tickets, milestones)
- env-context.md — local environment (tool versions, services)

Skip any missing files — not all research sources may be available.

## planner
reads: context.md
output: plan.md

Create an implementation plan based on the codebase context.

Primary input: {chain_dir}/context.md (scout's distilled codebase context including research findings).

If you need to verify details or the context is insufficient, the raw research files are available in {chain_dir}:
- research.md — web research (docs, specs, benchmarks)
- gh-context.md — GitHub state (PRs, issues, CI)
- linear-context.md — Linear project state (tickets, milestones)
- env-context.md — local environment (tool versions, services)

Save the plan to plan.md. When done, report the full path to plan.md.

## oracle
reads: plan.md, context.md
output: oracle-verdict.md

Review the plan. Challenge assumptions. Check for drift from the original task requirements. Surface contradictions, hidden risks, and anything the planner may have missed.

Report: inherited decisions, diagnosis, drift check, recommendation, risks.

<!-- {{ ansible_managed }} --->
