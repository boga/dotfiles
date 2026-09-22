/**
 * Re-injects the "ask via ask_user_question, not prose" instruction into the
 * system prompt on every turn.
 *
 * Static rules in AGENTS.md are read once and decay as a session grows: late in
 * a long conversation the model reliably drifts back to ending turns with
 * plain-text questions ("Want me to commit?"). before_agent_start fires after
 * every user prompt, so this reminder is always within the recent context
 * window and cannot be crowded out.
 *
 * Advisory by design. It does not detect or block prose questions after the
 * fact — that needs a message_end detector, which costs a wasted turn on every
 * rhetorical question a heuristic misreads.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const REMINDER = `## Asking the user — use the tool, never prose

When you need input from the user, call \`ask_user_question\`. Do NOT end a turn
with a question written as plain text.

This applies to every question that blocks or branches your work:
- Confirmations — "commit and push?", "apply this?", "shall I proceed?"
- Choices between approaches, files, hosts, or scopes
- Any request for a decision you are not authorised to make yourself

Shape the question properly:
- \`radio\` for one-of-N, \`checkbox\` for many-of-N, \`text\` for open-ended
- Put real trade-offs in each option's \`description\` — cost, risk, what breaks
- Keep \`allowOther: true\` unless the options are genuinely exhaustive
- Set \`allowComment: true\` when the reasoning matters as much as the choice
- Batch related questions into ONE call instead of several round trips

Not covered by this rule: rhetorical or explanatory questions inside an answer,
and questions the user asked *you* (answer those in prose, make no edits).`;

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (event) => {
    // Don't advertise a tool that isn't loaded in this session.
    const selected: unknown = event.systemPromptOptions?.selectedTools ?? [];
    const names = Array.isArray(selected)
      ? selected.map((tool) =>
          typeof tool === "string" ? tool : (tool as { name?: string })?.name,
        )
      : [];

    if (!names.includes("ask_user_question")) return;

    return { systemPrompt: `${event.systemPrompt}\n\n${REMINDER}` };
  });
}
