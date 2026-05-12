# Plan: `implement` Chain and Prompt

## Decisions

| Question | Answer |
|---|---|
| Context-builder skip | Prompt decides: with for greenfield, without for approved plans |
| Apply-worker | Stop after reviewers. Present findings. Apply only after user confirms. |
| Reviewer split | 3 parallel: correctness · tests · cleanup |
| Oracle placement | Not in chain. Oracle is a plan-chain concern. |
| Plan chain handoff | Accept `chainDir` from prior plan run so worker reads existing `plan.md` |
| Variant routing | One `/implement` prompt handles all variants |

---

## Chain: `implement`

```
context-builder → worker → parallel [reviewer×3]
```

No apply-worker in the chain. The prompt handles that after user confirmation.

### Steps

**1. context-builder**
- Output: `context.md`
- Task: analyze codebase for `{task}`; produce distilled context with line numbers, patterns, constraints, and a meta-prompt (`meta-prompt.md`) with goal, evidence, success criteria, hard constraints, validation, stop rules

**2. worker**
- Reads: `context.md`, `meta-prompt.md`
- Output: `progress.md`
- Task: implement using context and meta-prompt. Escalate unapproved decisions via `contact_supervisor`. No placeholders, no silent scope changes.

**3. parallel reviewers** (fan-out, concurrency 3)

| Reviewer | Focus | Output |
|---|---|---|
| A | Correctness & feasibility — sound changes, complete logic, matches requirements | `review-correctness.md` |
| B | Test coverage & edge cases — gaps in validation, untested paths | `review-tests.md` |
| C | Cleanup & simplicity — complexity, dead code, naming, simpler alternatives | `review-cleanup.md` |

All three read `progress.md` and `context.md`.

---

## Prompt: `implement`

One prompt, multiple invocation patterns. Runs in the main agent's context.

### Routing logic

1. **Does a `chainDir` or `plan.md` exist from a prior plan run?**
   - Yes → skip context-builder. Build chain: `worker → parallel reviewers`. Pass `chainDir`.
   - No → run full chain: `context-builder → worker → parallel reviewers`.

2. **User says "in the background" / "if blocked, ask me"?**
   - Run chain with `async: true`. Worker uses `contact_supervisor` natively.

3. **User says "just review" / "run reviewers only"?**
   - Run only the parallel reviewer fan-out (no context-builder, no worker).

4. **After chain completes:**
   - Present summary: what worker did (`progress.md`), findings per reviewer (blockers → fixes → notes).
   - List paths to all artifacts.
   - **Wait for user confirmation** before applying any fixes.

5. **User confirms "apply fixes":**
   - Run standalone `worker` with reads: `review-correctness.md`, `review-tests.md`, `review-cleanup.md`, `context.md`.
   - Task: apply fixes that make sense; skip suggestions that conflict with constraints or expand scope; report applied vs skipped with rationale.

---

## Use case mapping

| User phrase | What the prompt does |
|---|---|
| "Implement this." | Full chain (context-builder → worker → reviewers). Present findings. Wait. |
| "Implement this, then review it." | Same as above. |
| "Run reviewers for correctness, tests, and cleanup." | Parallel reviewer×3 only. |
| "Have worker implement this approved plan, then run reviewers." | Skip context-builder (plan exists). worker → reviewers. |
| "Have worker implement this approved plan. Afterward, run parallel reviewers, summarize their feedback, and apply the fixes that make sense." | Skip context-builder. worker → reviewers. Present summary. Wait. Apply on confirm. |
| "Run this implementation in the background. If the worker gets blocked, have it ask me." | Full chain, `async: true`. Worker escalates via `contact_supervisor`. |

---

## Files to create

| File | Description |
|---|---|
| `templates/pi/chains/implement.chain.md` | Chain definition (3 steps + parallel fan-out) |
| `templates/pi/prompts/implement.md` | Prompt template with routing logic |

## Files to modify

| File | Change |
|---|---|
| `group_vars/all.yml` | Add both files to `config_files` list |

## Deployment

```bash
ansible-playbook site.yml --limit work --start-at-task "Copy configs"
```
