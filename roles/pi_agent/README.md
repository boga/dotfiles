# pi_agent

Installs and configures the [Pi coding agent](https://www.npmjs.com/package/@earendil-works/pi-coding-agent) on macOS.

## What it does

1. **Merges desired settings** into `~/.pi/agent/settings.json` without clobbering keys the agent manages at runtime (e.g. `lastChangelogVersion`, `defaultModel`).

Pi itself is installed via mise — the version is declared in `templates/mise.toml` (deployed by the `cp` role) and mise handles the actual installation.

## Variables

| Variable                           | Default                     | Description                                                                                                                         |
|------------------------------------|-----------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| `pi_agent_settings_path`           | `~/.pi/agent/settings.json` | Path to the Pi agent settings file                                                                                                  |
| `pi_agent_settings_overrides`      | `{}` (JSON string)          | JSON string of additional keys to enforce in `settings.json`. Intentionally a raw string to avoid YAML↔JSON type-mapping ambiguity. |
| `pi_agent_settings_packages`       | `[]`                        | YAML list of Pi packages to enforce (group-level baseline).                                                                         |
| `pi_agent_settings_extra_packages` | `[]`                        | Host-specific packages to append to `pi_agent_settings_packages`. Define in `host_vars` to avoid self-referencing variable errors.  |

## Subagent model tiers

`@tintinweb/pi-subagents` has no settings-level per-agent override map: each agent's model and
thinking level live in its own `.md` frontmatter. Those files are Jinja templates deployed by the
`cp` role from `templates/pi/agents/`, so they read the variables below.

Each host defines three tiers in its `host_vars/<host>/vars.yml`. Every model named must also
appear in that host's `pi_agent_settings_overrides_local.enabledModels`, or `scopeModels` in
`templates/pi/subagents.json` will reject the spawn.

| Variable                       | Default                   | Used by                                          |
|--------------------------------|---------------------------|--------------------------------------------------|
| `pi_agent_model_fast`          | — (host must define)      | `Explorer`, `GithubScout`, `LinearScout`, `EnvironmentScout` |
| `pi_agent_model_daily`         | — (host must define)      | `Researcher`, `Worker`                           |
| `pi_agent_model_deep`          | — (host must define)      | `Planner`                                        |
| `pi_agent_model_reviewer`      | `{{ pi_agent_model_deep }}` | `Reviewer` — split out so a host can review on a cheaper tier |
| `pi_agent_reviewer_coderabbit` | `false`                   | `Reviewer` — gates the CodeRabbit step in its prompt |

The defaults for the last two live in `group_vars/all.yml`; the three tiers have no default on
purpose, so a new host fails loudly rather than inheriting another host's provider.

```yaml
# host_vars/work/vars.yml
pi_agent_model_fast: "anthropic/claude-haiku-4-5"
pi_agent_model_daily: "anthropic/claude-sonnet-5"
pi_agent_model_deep: "anthropic/claude-opus-5"
pi_agent_reviewer_coderabbit: true
```

## Subagents config

Fork-level behaviour is **not** part of `settings.json` — it lives in `~/.pi/agent/subagents.json`,
deployed from `templates/pi/subagents.json` by the `cp` role. `fallbackSubagent: none` is the
load-bearing key: without it an unresolvable `subagent_type` silently runs `general-purpose` with
the full tool set instead of failing.

## Usage

```yaml
# group_vars/all.yml
pi_agent_settings_overrides: |-
  {
    "collapseChangelog": true,
    "enableInstallTelemetry": false
  }

pi_agent_settings_packages:
  - "npm:some-extension"
  - "npm:another-extension"
```

```yaml
# host_vars/home/vars.yml — add host-specific packages without replacing the base list
pi_agent_settings_extra_packages:
  - "npm:home-only-extension"
```

```yaml
# site.yml
- name: "Install and configure Pi agent"
  ansible.builtin.include_role:
    name: pi_agent
```

## Idempotence

- The settings merge reads the current file, applies overrides, and writes back only if the result differs from the current content. Re-running with unchanged variables reports `ok`.
- The role bootstraps correctly on a fresh machine where `settings.json` does not yet exist.
