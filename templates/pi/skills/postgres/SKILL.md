---
name: postgres
description: Query and inspect Postgres databases using psql, with DATABASE_URL read from the environment. Use when the user asks to run SQL, inspect schema/tables, or debug data in a Postgres-backed project.
---

# Postgres

Runs `psql` against the `DATABASE_URL` already present in the environment.

## How DATABASE_URL Is Resolved

Do not assume `DATABASE_URL` is set — check first. Never read, print, or echo its
value (it contains credentials) — only check that it resolves to a non-empty value:

```bash
test -n "$DATABASE_URL" && echo present || echo absent
```

This prohibition includes partial or truncated output too — no `head`, `cut`,
`grep -o`, `awk`, substring slicing, or any command that surfaces even a fragment of
the value (e.g. `echo $DATABASE_URL | head -c 20`). A leaked prefix can still expose
scheme, user, or host. The only permitted check is the `test -n` presence check
above.

### If DATABASE_URL is absent

Stop. Do not guess, invent, or ask the user to paste a connection string into chat.
Report this exact failure and instructions:

> `DATABASE_URL` is not set in this shell. Provide it one of two ways:
>
> 1. **Per-shell (temporary):** `export DATABASE_URL="postgres://user:password@host:5432/dbname"`
> 2. **Per-project (persistent, via mise):** if this project uses `mise`, add to
>    `mise.toml` (in this project or an ancestor directory):
>    ```toml
>    [env]
>    DATABASE_URL = "postgres://user:password@host:5432/dbname"
>    ```
>    then make sure `mise` is activated in your shell so the var is exported
>    automatically. Then re-run the task.

Do not proceed with any `psql`/`pg_dump` command until the existence check passes.

## Usage

### Discovery First

When the task is to find or confirm data (e.g., "find X users/table", "does a Y
table exist"), run `\dt` first:

```bash
psql "$DATABASE_URL" -c "\dt"
```

Do this before grepping application source code or guessing table names. Listing
tables is one cheap command vs. multiple grep/read round-trips through source code.
Only fall back to source-code search if the `\dt` output doesn't make the right
table obvious.

### Run a query

```bash
psql "$DATABASE_URL" -c "SELECT * FROM users LIMIT 10;"
```

### List tables

```bash
psql "$DATABASE_URL" -c "\dt"
```

### Describe a table

```bash
psql "$DATABASE_URL" -c "\d+ users"
```

### List schemas

```bash
psql "$DATABASE_URL" -c "\dn"
```

### Run a .sql file

```bash
psql "$DATABASE_URL" -f path/to/query.sql
```

### Dump schema only (no data)

```bash
pg_dump --schema-only "$DATABASE_URL"
```

## Output Handling

`psql` output can be large (wide tables, big result sets). Prefer routing it through
`ctx_execute`/`ctx_batch_execute` instead of raw `bash` when a query might return many
rows or wide columns, so only the derived answer enters context:

```javascript
ctx_execute(language: "shell", code: `
  psql "$DATABASE_URL" -At -F',' -c "SELECT id, email FROM users LIMIT 1000;"
`)
```

Use `-At -F','` (unaligned, tuples-only, comma field separator) for machine-parseable
output when you intend to filter/aggregate in code rather than eyeball it.

## Safety

- Treat any `INSERT`/`UPDATE`/`DELETE`/`DROP`/`TRUNCATE`/`ALTER` statement as a write —
  confirm with the user before running it, unless they explicitly asked for that exact
  change.
- Default to read-only exploration (`SELECT`, `\d`, `\dt`, `EXPLAIN`) when the task is
  "inspect" or "debug", not "modify."
- Never read, print, or log the value of `$DATABASE_URL` (it contains credentials).
  Only check existence (`test -n "$DATABASE_URL"`). Reference it by name in all
  commands and output.
- Never include full connection strings in commit messages, PR descriptions, or logs.
