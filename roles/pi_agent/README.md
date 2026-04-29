# pi_agent

Installs and configures the [Pi coding agent](https://www.npmjs.com/package/@mariozechner/pi-coding-agent) on macOS.

## What it does

1. **Installs Pi** via mise (`mise install pi`), using the version already declared in `~/.config/mise/config.toml` (managed by the `cp` role from `templates/mise.toml`).
2. **Merges desired settings** into `~/.pi/agent/settings.json` without clobbering keys the agent manages at runtime (e.g. `lastChangelogVersion`, `defaultModel`).

## Variables

| Variable                      | Default                     | Description                                       |
|-------------------------------|-----------------------------|---------------------------------------------------|
| `pi_agent_settings_path`      | `~/.pi/agent/settings.json` | Path to the Pi agent settings file                |
| `pi_agent_settings_overrides` | `{}` (JSON string)          | JSON string of keys to enforce in `settings.json` |

`pi_agent_settings_overrides` is intentionally a **raw JSON string** (not a YAML dict) to avoid YAML↔JSON type-mapping ambiguity. The role converts it internally with `from_json` before merging.

## Usage

Include the role in a play and set the overrides variable in `group_vars` or `host_vars`:

```yaml
# group_vars/all.yml
pi_agent_settings_overrides: |-
  {
    "collapseChangelog": true,
    "enableInstallTelemetry": false,
    "packages": [
      "npm:some-extension"
    ]
  }
```

```yaml
# site.yml
- name: "Configure Pi agent"
  tags: pi
  ansible.builtin.include_role:
    name: pi_agent
```

## Idempotence

- The npm install task uses `state: latest`; it reports `changed` only when a newer version is available.
- The settings merge reads the current file, applies overrides, and writes back only if the result differs from the current content. Re-running with unchanged variables reports `ok`.
- The role bootstraps correctly on a fresh machine where `settings.json` does not yet exist.
