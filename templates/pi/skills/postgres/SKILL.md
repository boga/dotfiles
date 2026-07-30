---
name: postgres
description: Query and inspect Postgres databases using psql, with DATABASE_URL sourced from the project's mise.toml (or an ancestor directory's mise.toml). Use when the user asks to run SQL, inspect schema/tables, or debug data in a Postgres-backed project.
---

# Postgres

Runs `psql` against the `DATABASE_URL` defined in the project's `mise.toml` (or an
ancestor directory's `mise.toml`, per mise's usual config resolution).

## How DATABASE_URL Is Resolved

Do not assume `DATABASE_URL` is already exported in the current shell — the agent's
bash tool may run a non-interactive shell that never sourced `mise activate`. Never
read, print, or echo the value of `DATABASE_URL` (it contains credentials) — only
check that it resolves to a non-empty value, via `mise`, from the project directory
(`cwd`):

```bash
mise exec -- sh -c 'test -n "$DATABASE_URL"' && echo present || echo absent
```

`mise exec -- <command>` loads env vars (including `[env]` entries) from the nearest
`mise.toml` walking up from `cwd`, then runs `<command>` with that env applied — no
prior shell activation required.

### If DATABASE_URL is absent

Stop. Do not guess, invent, or ask the user to paste a connection string into chat.
Report this exact failure and instructions:

> `DATABASE_URL` is not set for this project. Provide it one of two ways:
>
> 1. **Per-shell (temporary):** `export DATABASE_URL="postgres://user:password@host:5432/dbname"`
> 2. **Per-project (persistent, recommended):** add to `mise.toml` in this project
>    (or an ancestor directory):
>    ```toml
>    [env]
>    DATABASE_URL = "postgres://user:password@host:5432/dbname"
>    ```
>    Then re-run the task — `mise exec` will pick it up automatically.

Do not proceed with any `psql`/`pg_dump` command until the existence check passes.

### Expected mise.toml shape

The project (or an ancestor directory) is expected to define something like:

```toml
[env]
DATABASE_URL = "postgres://user:password@localhost:5432/mydb"
```

## Usage

### Run a query

```bash
mise exec -- psql "$DATABASE_URL" -c "SELECT * FROM users LIMIT 10;"
```

### List tables

```bash
mise exec -- psql "$DATABASE_URL" -c "\dt"
```

### Describe a table

```bash
mise exec -- psql "$DATABASE_URL" -c "\d+ users"
```

### List schemas

```bash
mise exec -- psql "$DATABASE_URL" -c "\dn"
```

### Run a .sql file

```bash
mise exec -- psql "$DATABASE_URL" -f path/to/query.sql
```

### Dump schema only (no data)

```bash
mise exec -- pg_dump --schema-only "$DATABASE_URL"
```

## Output Handling

`psql` output can be large (wide tables, big result sets). Prefer routing it through
`ctx_execute`/`ctx_batch_execute` instead of raw `bash` when a query might return many
rows or wide columns, so only the derived answer enters context:

```javascript
ctx_execute(language: "shell", code: `
  mise exec -- psql "$DATABASE_URL" -At -F',' -c "SELECT id, email FROM users LIMIT 1000;"
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
