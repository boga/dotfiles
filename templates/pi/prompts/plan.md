---
description: Research (web, GitHub, Linear, env), scout, plan, review, and challenge an implementation plan
argument-hint: "<task>"
---

Run the plan chain using the subagent tool with the chain parameter and task: "$@".

The chain runs 4 research agents in parallel (web researcher, gh-researcher, linear-researcher, env-scout), then scouts the codebase, creates a plan, and challenges it via the oracle.

After the chain completes, present:
1. Full path to plan.md
2. Key findings from each research source (web, GitHub, Linear, environment)
3. Oracle verdict and challenged assumptions
4. Paths to all artifacts (research.md, gh-context.md, linear-context.md, env-context.md, context.md, plan.md, oracle-verdict.md)

<!-- {{ ansible_managed }} --->
