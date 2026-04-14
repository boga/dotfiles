{% raw %}---
name: ansible
description: Run and manage Ansible playbooks and tasks. Use this skill when running the dotfiles playbook, applying config changes, targeting specific tags, dry-running tasks, checking syntax, or debugging playbook execution.
---

# Ansible

## This repo

```bash
# Run the full playbook
ansible-playbook -i inventory.yml site.yml

# Apply only config files (most common)
ansible-playbook -i inventory.yml site.yml --tags configs

# Dry-run: preview changes without applying them
ansible-playbook -i inventory.yml site.yml --check --diff

# Dry-run for configs only
ansible-playbook -i inventory.yml site.yml --tags configs --check --diff
```

Available tags: `configs`

## Common flags

```bash
# Check syntax without running
ansible-playbook -i inventory.yml site.yml --syntax-check

# List all tasks that would run (no execution)
ansible-playbook -i inventory.yml site.yml --list-tasks

# List all tasks for a specific tag
ansible-playbook -i inventory.yml site.yml --tags configs --list-tasks

# Show diff for changed files (templates, copies)
ansible-playbook -i inventory.yml site.yml --diff

# Start from a specific task (useful after a failure)
ansible-playbook -i inventory.yml site.yml --start-at-task "Copy ~/.config/wezterm/wezterm.lua"

# Run step by step with confirmation
ansible-playbook -i inventory.yml site.yml --step

# Extra verbosity for debugging (-v through -vvvv)
ansible-playbook -i inventory.yml site.yml -v
ansible-playbook -i inventory.yml site.yml -vvv
```

## Targeting

```bash
# Skip specific tags
ansible-playbook -i inventory.yml site.yml --skip-tags configs

# Pass extra variables
ansible-playbook -i inventory.yml site.yml -e "some_var=value"

# Limit to specific hosts (when inventory has multiple)
ansible-playbook -i inventory.yml site.yml --limit swap
```

## Debugging

```bash
# Check inventory is parsed correctly
ansible-inventory -i inventory.yml --list

# Test connectivity to hosts
ansible -i inventory.yml all -m ping

# Run a single ad-hoc command on hosts
ansible -i inventory.yml all -m shell -a "echo hello"
```

## Adding a new config file

1. Add the source file under `templates/`
2. Add a loop entry to the `"Copy configs"` task in `site.yml`:

```yaml
- {
    name: "Description of the file",
    src: "./templates/path/to/file",
    dest: "~/.config/path/to/destination",
  }
```

3. If the file contains `{{ }}` expressions (not Ansible variables), wrap it in `{% raw %}...{% endraw %}` to prevent Jinja2 interpolation.

## Adding a new task

Tasks without a `tags: configs` annotation run on every full playbook execution, not on `--tags configs`. Add `tags: configs` to tasks that are config-file related.
{% endraw %}
