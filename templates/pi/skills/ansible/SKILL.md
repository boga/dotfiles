{% raw %}---
name: ansible
description: Run and manage Ansible playbooks and tasks. Use this skill when running playbooks, applying changes, targeting specific tags, dry-running tasks, checking syntax, or debugging playbook execution.
---

# Ansible

## Running playbooks

```bash
# Run a playbook
ansible-playbook -i inventory.yml site.yml

# Target specific tags
ansible-playbook -i inventory.yml site.yml --tags mytag
ansible-playbook -i inventory.yml site.yml --tags "tag1,tag2"

# Skip tags
ansible-playbook -i inventory.yml site.yml --skip-tags mytag

# Dry-run: preview changes without applying
ansible-playbook -i inventory.yml site.yml --check --diff
```

## Inspecting before running

```bash
# Check syntax without executing
ansible-playbook -i inventory.yml site.yml --syntax-check

# List all tasks that would run
ansible-playbook -i inventory.yml site.yml --list-tasks

# List all available tags
ansible-playbook -i inventory.yml site.yml --list-tags

# List matching hosts
ansible-playbook -i inventory.yml site.yml --list-hosts
```

## Controlling execution

```bash
# Start from a specific task (useful after a failure)
ansible-playbook -i inventory.yml site.yml --start-at-task "Task name"

# Confirm each task interactively
ansible-playbook -i inventory.yml site.yml --step

# Limit to specific hosts
ansible-playbook -i inventory.yml site.yml --limit hostname

# Pass extra variables
ansible-playbook -i inventory.yml site.yml -e "key=value"
ansible-playbook -i inventory.yml site.yml -e "@vars.yml"
```

## Verbosity

```bash
ansible-playbook -i inventory.yml site.yml -v      # task results
ansible-playbook -i inventory.yml site.yml -vv     # + file diffs
ansible-playbook -i inventory.yml site.yml -vvv    # + connection info
ansible-playbook -i inventory.yml site.yml -vvvv   # + plugin debug
```

## Debugging inventory and connectivity

```bash
# Inspect parsed inventory
ansible-inventory -i inventory.yml --list
ansible-inventory -i inventory.yml --graph

# Test host connectivity
ansible -i inventory.yml all -m ping

# Run an ad-hoc command
ansible -i inventory.yml all -m shell -a "uname -a"

# Gather facts for a host
ansible -i inventory.yml hostname -m gather_facts
```

## Templates and Jinja2

- Use `ansible.builtin.template` to deploy files with variable interpolation.
- Use `ansible.builtin.copy` when no interpolation is needed.
- If a template file contains literal `{{ }}` that should not be interpreted by Jinja2 (e.g. config file syntax), wrap the relevant content in `{% raw %}...{% endraw %}`.
- `ansible_managed` is available in templates as a standard "do not edit" header string.

## Common patterns

```yaml
# Copy a file with templating
- name: Deploy config
  ansible.builtin.template:
    src: templates/myconfig.j2
    dest: ~/.config/myapp/config
    mode: '0600'

# Run a command and capture output
- name: Generate something
  ansible.builtin.command: mycommand --flag
  register: cmd_output
  changed_when: false

# Write captured output to a file
- name: Write output to file
  ansible.builtin.copy:
    content: "{{ cmd_output.stdout }}\n"
    dest: ~/.config/myapp/generated
    mode: '0600'

# Ensure a directory exists
- name: Create directory
  ansible.builtin.file:
    path: ~/.config/myapp
    state: directory
    mode: '0700'
```
{% endraw %}
