---
name: plan
description: Research, scout, plan, review, and challenge implementation
---

## researcher
output: research.md

Research official docs, specs, benchmarks, and recent changes relevant to: {task}

Focus on primary sources. Drop stale or SEO-heavy results. If web tools are unavailable, write research.md noting no external research was available and exit successfully.

## scout
output: context.md

Analyze the codebase for {task}

Read research.md from {chain_dir} for additional context on what to look for.

## planner
reads: context.md, research.md
output: plan.md

Create an implementation plan based on the codebase context and research findings.

Context: {chain_dir}/context.md
Research: {chain_dir}/research.md

Save the plan to plan.md. When done, report the full path to plan.md.

## reviewer
reads: plan.md, context.md
output: review.md

Review the implementation plan for:
- Correctness and feasibility — are the proposed changes sound? Any missing steps?
- Test coverage and validation — does the plan include adequate testing? Any gaps?
- Cleanup and maintainability — is there unnecessary complexity? Simpler alternatives?

Cite specific files, assumptions, and line references. Report only evidence-backed findings.

## oracle
reads: plan.md, review.md
output: oracle-verdict.md

Review the plan and review findings. Challenge assumptions. Check for drift from the original task requirements. Surface contradictions, hidden risks, and anything the planner may have missed.

Report: inherited decisions, diagnosis, drift check, recommendation, risks.

<!-- {{ ansible_managed }} --->
