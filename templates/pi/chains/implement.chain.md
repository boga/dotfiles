---
name: implement
description: Build context, implement, and run parallel reviewers
---

## context-builder
output: context.md

Analyze the codebase for {task}. Produce:

- `context.md`: distilled codebase context with line numbers, patterns, and constraints.
- `meta-prompt.md`: compact contract — goal, evidence, success criteria, hard constraints, validation, stop rules.

## worker
reads: context.md, meta-prompt.md
output: progress.md
progress: true

Implement {task} using the context and meta-prompt.

If research artifacts exist in {chain_dir} (research.md, gh-context.md, linear-context.md, env-context.md), reference them for implementation details.

Follow meta-prompt constraints exactly. Escalate unapproved decisions via `contact_supervisor` — do not guess or assume. No placeholders, no TODOs, no silent scope changes.

## parallel
concurrency: 3

### reviewer
reads: progress.md, context.md, meta-prompt.md, plan.md
output: review-correctness.md

Review the implementation for CORRECTNESS and FEASIBILITY. Are the changes sound and logically complete? Do they match the requirements? Any missing steps or broken assumptions? Check against meta-prompt.md constraints and plan.md (if available). Do not edit files. Report: Correct → Blocker → Note.

### reviewer
reads: progress.md, context.md, meta-prompt.md, plan.md
output: review-tests.md

Review the implementation for TEST COVERAGE and EDGE CASES. Are there gaps in validation or untested paths? Are edge cases handled? Is error handling adequate? Check against meta-prompt.md constraints and plan.md (if available). Do not edit files. Report: Correct → Blocker → Note.

### reviewer
reads: progress.md, context.md, meta-prompt.md, plan.md
output: review-cleanup.md

Review the implementation for CLEANUP and SIMPLICITY. Is there unnecessary complexity? Dead code, poor naming, or redundant logic? Simpler alternatives? Check against meta-prompt.md constraints and plan.md (if available). Do not edit files. Report: Correct → Blocker → Note.

<!-- {{ ansible_managed }} --->
