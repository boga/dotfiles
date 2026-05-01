# Markdown Styleguide

Use this guide for agent-facing Markdown: instructions, skills, task prompts, and project documentation consumed by Pi agents.

## Structure

- Start with one `#` heading that names the document purpose.
- Use `##` sections for major topics and `###` only when a section needs grouping.
- Put the most important operational rules first.
- Prefer short sections over long narrative blocks.
- Use lists for procedures, constraints, and checklists.

## Voice and Precision

- Write direct instructions in imperative mood.
- Prefer active voice.
- Be specific about required tools, files, commands, and boundaries.
- Avoid ambiguous words such as “maybe”, “usually”, “probably”, and “somehow”.
- State exceptions explicitly.

## Agent Instructions

- Make mandatory rules easy to scan with **MUST**, **MUST NOT**, or **STOP** when needed.
- Include ordered steps for workflows agents must execute in sequence.
- Keep one rule per bullet.
- Put safety or destructive-action warnings before the command or step.
- Reference exact paths in backticks.

## Commands and Code Blocks

- Use fenced code blocks with a language tag when possible.
- Keep commands copy-pasteable.
- Show required flags and placeholders clearly.
- Use comments inside code blocks only when they improve safe execution.

## Links and References

- Use relative links for files in this repository.
- Use descriptive link text instead of bare URLs.
- When referencing another instruction file, explain when to read it.

## Formatting

- Wrap filenames, commands, variables, branches, and config keys in backticks.
- Use tables only for compact reference data.
- Format tables manually:
  - Use leading and trailing pipes.
  - Pad and align header/data cells with spaces.
  - Do not pad separator rows; write separators as `|---|---|`.
  - Match separator width to the visible column width.
  - Escape literal pipe characters in cells as `\|`.
- Avoid excessive emphasis; reserve bold text for mandatory or high-risk rules.
- Keep lines readable and paragraphs short.

## Checklists

- Use checklists for verification or completion criteria.
- Make each item observable.
- Avoid checklist items that require guessing intent.

### Checklist example

```md
## Verification

- [ ] Run `ansible-playbook site.yml --limit home --syntax-check`.
- [ ] Confirm `templates/pi/AGENTS.md` references this guide.
```

### Table example

```md
| Symbol | Meaning       |
|--------|---------------|
| `\|`   | Remote synced |
| `↑`    | Ahead         |
```
