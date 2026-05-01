# Agent Guidelines

## Claude Code Project Overview

This project uses Ansible to automate the setup and configuration of a development environment on macOS. It installs tools and applications via Homebrew and deploys configuration files.

## Project Structure

- `site.yml`: The main Ansible playbook.
- `ansible.cfg`: Ansible configuration (sets inventory path, roles path, etc.).
- `inventory.yml`: Inventory file with two hosts — `home` and `work` — both targeting `localhost`.
- `roles/`: Contains Ansible roles.
  - `cp`: A role for copying/templating config files to the target machine.
- `group_vars/`: Variables shared across all hosts (`all.yml`) and host-specific overrides (`home.yml`, `work.yml`).
- `host_vars/`: Additional per-host variable files.
- `templates/`: Jinja2 templates for configuration files (e.g., `wezterm.lua.j2`, `vimrc`).
- `README.md`: Project README.

## Boundaries

Do **not** read or modify files outside this repository unless the user explicitly says so.

## How to Use

The inventory is already committed. Since both `home` and `work` target `localhost`, always pass `--limit` to avoid running tasks against both entries at once.

**Run the full playbook:**

```bash
ansible-playbook site.yml --limit home
# or
ansible-playbook site.yml --limit work
```

### Running Specific Tasks

Use `--tags` to run only a subset of tasks:

- `configs`: Copies configuration files and generates shell integrations.

```bash
ansible-playbook site.yml --limit home --tags configs
```
