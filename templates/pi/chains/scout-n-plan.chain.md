---
name: scout-n-plan
description: Gather context then plan implementation
---

## scout
output: context.md

Analyze the codebase for {task}

## planner
reads: context.md
output: plan.md

Create an implementation plan based on {previous}. Save the plan to plan.md. When done, report the full path to plan.md.

<!-- {{ ansible_managed }} --->
