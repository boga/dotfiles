{% raw %}---
name: ansible
description: Run and manage Ansible playbooks and tasks. Use this skill when running playbooks, applying changes, targeting specific tags, dry-running tasks, checking syntax, or debugging playbook execution.
---

# Ansible

## Running playbooks

```bash
# Run a playbook
ansible-playbook site.yml

# Target specific tags
ansible-playbook site.yml --tags mytag
ansible-playbook site.yml --tags "tag1,tag2"

# Skip tags
ansible-playbook site.yml --skip-tags mytag

# Dry-run: preview changes without applying
ansible-playbook site.yml --check --diff
```

## Inspecting before running

```bash
# Check syntax without executing
ansible-playbook site.yml --syntax-check

# List all tasks that would run
ansible-playbook site.yml --list-tasks

# List all available tags
ansible-playbook site.yml --list-tags

# List matching hosts
ansible-playbook site.yml --list-hosts
```

## Controlling execution

```bash
# Start from a specific task (useful after a failure)
ansible-playbook site.yml --start-at-task "Task name"

# Confirm each task interactively
ansible-playbook site.yml --step

# Limit to specific hosts
ansible-playbook site.yml --limit hostname

# Pass extra variables
ansible-playbook site.yml -e "key=value"
ansible-playbook site.yml -e "@vars.yml"
```

## Verbosity

```bash
ansible-playbook site.yml -v      # task results
ansible-playbook site.yml -vv     # + file diffs
ansible-playbook site.yml -vvv    # + connection info
ansible-playbook site.yml -vvvv   # + plugin debug
```

## Debugging inventory and connectivity

```bash
# Inspect parsed inventory
ansible-inventory --list
ansible-inventory --graph

# Test host connectivity
ansible all -m ping

# Run an ad-hoc command
ansible all -m shell -a "uname -a"

# Gather facts for a host
ansible hostname -m gather_facts
```

## Templates and Jinja2

- Use `ansible.builtin.template` to deploy files with variable interpolation.
- Use `ansible.builtin.copy` when no interpolation is needed.
- If a template file contains literal `{{ }}` that should not be interpreted by Jinja2 (e.g. config file syntax), wrap the relevant content in `{% raw %}...{% endraw %}`.
- `ansible_managed` is available in templates as a standard "do not edit" header string.

## Module documentation

```bash
# Full docs for a module
ansible-doc ansible.builtin.template
ansible-doc ansible.builtin.copy
ansible-doc ansible.builtin.file
ansible-doc ansible.builtin.command

# Short parameter summary
ansible-doc -s ansible.builtin.template

# List all available modules
ansible-doc -l

# Search modules by keyword
ansible-doc -l | grep copy
```
{% endraw %}
