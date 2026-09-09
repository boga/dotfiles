{% raw %}---
name: coderabbit
description: Run a CodeRabbit CLI (`coderabbit`) code review. Use this skill only when the user explicitly says "Use CodeRabbit" or "Ask CodeRabbit". Do not trigger on general review phrases, and do not use it inside the Reviewer agent.
---

# CodeRabbit CLI

The CodeRabbit CLI binary is `coderabbit`. Verified against **0.7.6** — check `coderabbit review --help`
before trusting any flag below if the version differs.

## Review commands

Scope is selected with **flags**, not bare words. `coderabbit review uncommitted` fails with
`error: too many arguments for 'review'`.

```bash
# Review all tracked changes. --help documents no default for --base, so pass
# it explicitly rather than relying on one.
coderabbit review --base master

# Review only uncommitted changes (staged + tracked edits)
coderabbit review --uncommitted

# Review only committed changes (branch commits vs base)
coderabbit review --committed

# Also include files not yet added to git
coderabbit review --include-untracked

# Non-default base branch
coderabbit review --base master
coderabbit review --committed --base master

# Lighter, faster review with reduced context work
coderabbit review --light --committed --base master
```

## Output modes

Plain text is the **default** — there is no `--plain` flag.

```bash
coderabbit review --committed --base master   # plain text (default; read this yourself)
coderabbit review --agent --committed         # structured findings for machine parsing
```

Use `--agent` only when something needs to parse findings; otherwise take the default.

## Bounding the run — MANDATORY

A review takes minutes and can exceed 30 on a large diff or on the free CLI allowance — which is
why the cap below is a *give-up* threshold, not an expected duration: past it, report CodeRabbit as
unavailable and move on rather than waiting out the full run. It has no
built-in cap, so an unbounded foreground call will hang the caller. **Never invoke it without a
bound.**

Preferred — let the sandbox enforce the cap:

```javascript
ctx_execute({
  language: "shell",
  timeout: 600000, // 10 min hard cap
  code: "cd <repo> && coderabbit review --committed --base master 2>&1 | tail -80",
})
```

`timeout` is in milliseconds. Omitting it means **no server-side timer fires** — that is the hang.

If you must use plain bash, note that macOS has no `timeout` binary unless coreutils is installed.
Use perl, which is always present:

```bash
perl -e 'alarm shift; exec @ARGV' 600 coderabbit review --committed --base master
```

Do not redirect the run to a file and poll it. Any agent read-only enough to be reviewing code is
forbidden from creating files, `/tmp` included, so that recipe cannot be followed — use the bounded
`ctx_execute` form above and read the output directly.

**If the review does not finish inside the bound: stop waiting, report CodeRabbit as unavailable,
and continue with your own findings.** A missing second opinion is not a reason to produce nothing.

## Reading the output

Findings from the last local run can be re-read without paying for another review:

```bash
coderabbit review findings
```

## Tips

- Must run from inside a git repository (`--dir <path>` overrides the directory).
- Check the account and org first with `coderabbit auth status`; a repo with no org plan falls back
  to the free CLI allowance, which is slower.
- Results stream to the terminal as they complete, so a partial capture is still useful.
- Use the full `coderabbit` binary name — the `cr` alias is not always available.
- Treat its findings as one more reviewer: confirm each against the code and drop what you cannot
  reproduce.
{% endraw %}
