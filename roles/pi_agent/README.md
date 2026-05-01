# pi_agent

Installs and configures the [Pi coding agent](https://www.npmjs.com/package/@mariozechner/pi-coding-agent) on macOS.

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
