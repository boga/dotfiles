---
name: implement
description: Build context, implement task, and run sequential reviewers
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

Follow meta-prompt constraints exactly. Escalate unapproved decisions via `contact_supervisor` — do not guess or assume. No placeholders, no TODOs, no silent scope changes.

<!-- {{ ansible_managed }} --->
